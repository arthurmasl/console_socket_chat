package client

import "core:fmt"
import "core:net"
import "core:os"

main :: proc() {
  endpoint := net.Endpoint {
    address = net.IP4_Any,
    port    = 8000,
  }

  socket, socket_err := net.dial_tcp(endpoint)
  if socket_err != nil {
    fmt.println("Failed to connect")
  }

  defer net.close(socket)
  fmt.println("connected")

  write_to_server(socket)
  // read_from_server(socket)
}

write_to_server :: proc(server: net.TCP_Socket) {
  buffer := make([]u8, 1024)
  defer delete(buffer)

  for {
    n, line_err := os.read(os.stdin, buffer)
    if line_err < 0 {
      fmt.println("read line error")
      return
    }

    message := buffer[:n - 1]
    net.send(server, message)
  }
}

read_from_server :: proc(server: net.TCP_Socket) {
  buffer := make([]u8, 1024)
  defer delete(buffer)

  for {
    recv, recv_err := net.recv_tcp(server, buffer)

    if recv_err != nil {
      fmt.println("Recv error")
    }

    if recv == 0 {
      fmt.println("Server disconnected")
    }

    fmt.printfln("Received from server: %s", recv)
  }
}
