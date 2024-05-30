package main

import "core:fmt"
import "core:math/big"
import "core:net"
import "core:strings"
import "core:thread"

users: [dynamic]net.TCP_Socket

main :: proc() {
  server := init_server()
  defer net.close(server)

  for {
    client := accept_client(server)

    thread.create_and_start_with_data(&client, proc(data: rawptr) {
      handle_client((^net.TCP_Socket)(data)^)
    })
  }
}

init_server :: proc() -> net.TCP_Socket {
  port := 8000
  endpoint := net.Endpoint {
    address = net.IP4_Any,
    port    = port,
  }

  socket, socket_err := net.listen_tcp(endpoint)
  if socket_err != nil do fmt.println("Failet to create server")
  fmt.printfln("Server started on port %d", port)

  return socket
}

accept_client :: proc(server: net.TCP_Socket) -> net.TCP_Socket {
  client, source, tcp_err := net.accept_tcp(server)
  if tcp_err != nil do fmt.println("Client error")

  fmt.printfln("User%d conntected", client)
  append(&users, client)

  return client
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
    send_to_users(client, message)
  }
}

send_to_users :: proc(sender: net.TCP_Socket, message: []u8) {
  fmt.printfln("User%d: %s", sender, message)

  for &user in users {
    if user != sender do net.send(user, message)
  }
}
