
type 'a zmq_sock

val zmq_create : ZMQ.context -> 'a ZMQ.Socket.kind -> 'a zmq_sock

val zmq_bind : 'a zmq_sock -> string -> unit

val zmq_connect : 'a zmq_sock -> string -> unit

val zmq_recv : 'a zmq_sock -> string Lwt.t

val zmq_send : 'a zmq_sock -> string -> unit Lwt.t
