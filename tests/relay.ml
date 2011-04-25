
open Lwt_zmq
open Lwt

let relay sock tag =
  let rec relay_rec previous_write =
    zmq_recv sock  >>= (fun s ->
      let () = print_endline (Printf.sprintf "%s -- %s" tag s) in
      let write = previous_write >>= (fun () -> zmq_send sock s)
      in relay_rec write)
  in relay_rec (return ())


let main () =
  let addr = "tcp://*:5555" in
  let ctx = ZMQ.init () in
  let rep = zmq_create ctx ZMQ.Socket.rep in
  let req = zmq_create ctx ZMQ.Socket.req in
  let () = zmq_bind rep addr in
  let () = zmq_connect req addr in
  Lwt_unix.run (
    let (_:unit Lwt.t) = zmq_send req "hello" in
    Lwt.choose [relay rep "rep"; relay req "req"]
  )

let () = main ()
