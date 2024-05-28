package main

import "core:fmt"
import "core:net"

main :: proc() {
  endpoint := net.Endpoint {
    address = net.IP4_Any,
    port    = 8000,
  }

  socket, socket_err := net.listen_tcp(endpoint)
  if socket_err != nil do fmt.println("Failet to create server")

  defer net.close(socket)
  fmt.println("Server listening")

  for {
    client, source, tcp_err := net.accept_tcp(socket)
    if tcp_err != nil do fmt.println("Client error")

    handle_client(client)
  }

}

handle_client :: proc(client: net.TCP_Socket) {
  fmt.println("Client conntected")
  defer net.close(client)

  buffer := make([]u8, 1024)
  defer delete(buffer)

  for {
    message := get_message(client, buffer)
    fmt.printfln("Received from client: %s", message)
  }
}

get_message :: proc(client: net.TCP_Socket, buffer: []u8) -> string {
  n, recv_err := net.recv_tcp(client, buffer)

  if recv_err != nil do fmt.println("Recv error")
  if n == 0 do fmt.println("Client disconnected")

  return string(buffer[:n])
}
