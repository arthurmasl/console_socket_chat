package client

import "core:fmt"
import "core:net"
import "core:os"
import "core:thread"

main :: proc() {
  endpoint := net.Endpoint {
    address = net.IP4_Any,
    port    = 8000,
  }

  socket, socket_err := net.dial_tcp(endpoint)
  if socket_err != nil do fmt.println("Failed to connect")

  fmt.println("connected")
  defer net.close(socket)

  t1 := thread.create_and_start_with_data(&socket, proc(data: rawptr) {
    write_to_server((^net.TCP_Socket)(data)^)
  })

  t2 := thread.create_and_start_with_data(&socket, proc(data: rawptr) {
    read_from_server((^net.TCP_Socket)(data)^)
  })

  for {
    t1_done := thread.is_done(t1)
    t2_done := thread.is_done(t2)

    if t1_done do thread.terminate(t1, 0)
    if t2_done do thread.terminate(t2, 0)

    if t1_done && t2_done do break
  }

  fmt.println("done")
}

write_to_server :: proc(server: net.TCP_Socket) {
  buffer := make([]u8, 1024)
  defer delete(buffer)

  for {
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
    n, recv_err := net.recv_tcp(server, buffer)

    if recv_err != nil do fmt.println("Recv error")
    if n == 0 do fmt.println("Server disconnected")

    message := buffer[:n]
    fmt.printfln("Received from server: %s", string(message))
  }
}
