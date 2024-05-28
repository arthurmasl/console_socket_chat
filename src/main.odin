package main

import "core:fmt"
import "core:net"

main :: proc() {
  endpoint := net.Endpoint {
    address = net.IP4_Any,
    port    = 8000,
  }

  socket, socket_err := net.listen_tcp(endpoint)
  if socket_err != nil {
    fmt.println("Failet to create server")
  }

  defer net.close(socket)
  fmt.println("Server listening")

  for {
    client, source, tcp_err := net.accept_tcp(socket)
    if tcp_err != nil {
      fmt.println("Client error")
    }

    handle_client(client)
  }

}

handle_client :: proc(client: net.TCP_Socket) {
  defer net.close(client)
  fmt.println("Client conntected")

  buffer := make([]u8, 1024)
  for {
    recv, recv_err := net.recv_tcp(client, buffer)

    if recv_err != nil {
      fmt.println("Recv error")
    }

    if recv == 0 {
      fmt.println("Client disconnected")
      break
    }

    message := buffer[:recv]

    fmt.printfln("Received from client: %s", message)
  }
}
