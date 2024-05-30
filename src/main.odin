package main

import "core:fmt"
import "core:math/big"
import "core:net"
import "core:strings"
import "core:thread"

users: [dynamic]net.TCP_Socket

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

    fmt.printfln("User%d conntected", client)
    append(&users, client)

    thread.create_and_start_with_data(&client, proc(data: rawptr) {
      handle_client((^net.TCP_Socket)(data)^)
    })
  }

}

handle_client :: proc(client: net.TCP_Socket) {
  client := client
  defer net.close(client)

  buffer := make([]u8, 1024)
  defer delete(buffer)

  for {
    n, recv_err := net.recv(client, buffer)

    if recv_err != nil do fmt.println("Recv error")
    if n == 0 {
      fmt.println("User disconnected")
      break
    }

    message := buffer[:n]
    fmt.printfln("User%d: %s", client, message)

    for &user in users {
      if user != client do net.send(user, message)
    }
  }
}
