package client

import "core:fmt"
import "core:net"
import "core:os"
import "core:thread"

get_socket :: proc() -> net.TCP_Socket {
  endpoint := net.Endpoint {
    address = net.IP4_Any,
    port    = 8000,
  }

  socket, socket_err := net.dial_tcp(endpoint)
  if socket_err != nil do fmt.println("Failed to connect")

  // defer net.close(socket)

  return socket
}

main :: proc() {
  fmt.println("connected")

  t1 := thread.create_and_start(proc() {
    socket := get_socket()
    write_to_server(socket)
  })

  t2 := thread.create_and_start(proc() {
    socket := get_socket()
    read_from_server(socket)
  })

  for {
    // fmt.println("t1", thread.is_done(t1))
    // fmt.println("t2", thread.is_done(t2))
  }
}

write_to_server :: proc(server: net.TCP_Socket) {
  buffer := make([]u8, 1024)
  defer delete(buffer)

  for {
    fmt.println("write")
    input := get_input(buffer)
    net.send(server, input)
  }
}

get_input :: proc(buffer: []u8) -> []u8 {
  n, line_err := os.read(os.stdin, buffer)
  if line_err < 0 do fmt.println("read line error")

  return buffer[:n - 1]

}

read_from_server :: proc(server: net.TCP_Socket) {
  buffer := make([]u8, 1024)
  defer delete(buffer)

  for {
    fmt.println("read")
    n, recv_err := net.recv_tcp(server, buffer)

    if recv_err != nil do fmt.println("Recv error")
    if n == 0 do fmt.println("Server disconnected")

    fmt.printfln("Received from server: %s", n)
  }
}
