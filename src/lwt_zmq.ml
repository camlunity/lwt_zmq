
type 'a zmq_sock = {
  sock : 'a ZMQ.Socket.t ;
  fd: Lwt_unix.file_descr
}

let wrap_zmqcall event z action =
  let open Lwt_unix in
  let open ZMQ.Socket in
  try
    let () = check_descriptor z.fd in
    let evt = events z.sock in
    if ((event = Read && readable z.fd && evt = Poll_in) ||
           (event = Write && writable z.fd && evt = Poll_out))
    then
      Lwt.return (action ())
    else
      register_action event z.fd action
  with
    | Retry
    | Unix.Unix_error((Unix.EAGAIN | Unix.EWOULDBLOCK | Unix.EINTR), _, _)
    | Sys_blocked_io ->
        (* The action could not be completed immediatly, register it: *)
      register_action event z.fd action
    | Retry_read ->
      register_action Read z.fd action
    | Retry_write ->
      register_action Write z.fd action
    | e -> Lwt.fail e

let zmq_create ctx type_ =
  let sock = ZMQ.Socket.create ctx type_ in
  let fd = Lwt_unix.of_unix_file_descr (ZMQ.Socket.get_fd sock) in
  {sock=sock; fd=fd}

let zmq_bind z addr =
  Lwt_unix.check_descriptor z.fd;
  ZMQ.Socket.bind z.sock addr

let zmq_bind z addr =
  Lwt_unix.check_descriptor z.fd;
  ZMQ.Socket.bind z.sock addr

let zmq_connect z addr =
  Lwt_unix.check_descriptor z.fd;
  ZMQ.Socket.connect z.sock addr

let zmq_recv z =
  wrap_zmqcall Lwt_unix.Read z (fun () -> ZMQ.Socket.recv z.sock)

let zmq_send ?opt z s =
  wrap_zmqcall Lwt_unix.Write z (fun () -> ZMQ.Socket.send ?opt:opt z.sock s)
