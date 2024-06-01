package main

import "core:fmt"
import "core:math/big"
import "core:net"
import "core:strings"
import "core:thread"

users: [dynamic]net.TCP_Socket

main :: proc() {
  server := init_server()

  for {
    client := accept_client(server)

    thread.create_and_start_with_data(&client, proc(data: rawptr) {
      handle_client((^net.TCP_Socket)(data)^)
    })
  }

  defer net.close(server)
}

init_server :: proc() -> net.TCP_Socket {
  port := 8000
  endpoint := net.Endpoint {
    address = net.IP4_Any,
    port    = port,
  }

  socket, socket_err := net.listen_tcp(endpoint)
  if socket_err != nil do panic("Failet to create server")

  fmt.printfln("Server started on port %d", port)

  return socket
}

accept_client :: proc(server: net.TCP_Socket) -> net.TCP_Socket {
  client, source, tcp_err := net.accept_tcp(server)
  if tcp_err != nil do panic("Client error")

  fmt.printfln("User%d conntected", client)
  append(&users, client)

  return client
}

handle_client :: proc(client: net.TCP_Socket) {
  client := client
  buffer := make([]u8, 1024)

  for {
    message, disconnected := receive_message(client, buffer)

    if disconnected {
      disconnect_user(client)
      break
    }

    send_to_users(client, buffer[:message])
  }

  defer net.close(client)
  defer delete(buffer)
}

receive_message :: proc(client: net.TCP_Socket, buffer: []u8) -> (int, bool) {
  message, recv_err := net.recv(client, buffer)

  if recv_err != nil do panic("Receive error")
  if message == 0 do return message, true

  return message, false
}

disconnect_user :: proc(id: net.TCP_Socket) {
  fmt.println("User disconnected")

  for &user, index in users {
    if user == id {
      ordered_remove(&users, index)
    }
  }
}

send_to_users :: proc(sender: net.TCP_Socket, message: []u8) {
  fmt.printfln("User%d: %s", sender, message)

  for &user in users {
    if user != sender do net.send(user, message)
  }
}
