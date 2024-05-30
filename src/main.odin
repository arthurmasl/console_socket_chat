package main

import "core:fmt"
import "core:net"

users_count: u32

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
  users_count += 1
  defer net.close(client)

  buffer := make([]u8, 1024)
  defer delete(buffer)

  for {
    n, recv_err := net.recv(client, buffer)

    if recv_err != nil do fmt.println("Recv error")
    if n == 0 {
      users_count -= 1
      fmt.println("User disconnected")
      break
    }

    message := buffer[:n]
    fmt.printfln("User%d: %s", users_count, string(message))
    net.send(client, message)
  }
}
