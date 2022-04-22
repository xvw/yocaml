(** Describes a dedicated runtime for varying the execution context of YOCaml. *)

(** Although much of YOCaml is already abstracted by means of a rudimentary
    effect handler (based on a Freer Monad), it is assumed that the management
    of the control flow does not have to be handled by an end user or someone
    concerned with building a dedicated runtime (for Windows for example). So
    it is sufficient to provide a module that implements the necessary
    primitives that will be invoked in the effect manager.

    One might ask why not just use modules as an effect abstraction. Mainly
    because a Freer Monad is also a (logical) monad, so you can easily
    traverse them which makes the implementation of the engine much simpler. *)

(** {1 Runtime definition}

    The signature describes the set of primitives to be implemented to build
    an additional runtime. *)

module type RUNTIME = sig
  type 'a t

  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val return : 'a -> 'a t

  (** [get_time ()] should returns a float like [Unix.gettimeofday ()]. *)
  val get_time : unit -> float t

  (** [file_exists path] should returns [true] if [path] exists (as a file or
      a directory), [false] otherwise. *)
  val file_exists : Filepath.t -> bool t

  (** Same of [file_exists] but acting on the target. *)
  val target_exists : Filepath.t -> bool t

  (** [is_directory path] should returns [true] if [path] is an existing file
      and if the file is a directory, [false] otherwise. *)
  val is_directory : Filepath.t -> bool t

  (** [get_modification_time path] should returns a [Try.t] containing the
      modification time (as an integer) of the given file. The function may
      fail. *)
  val get_modification_time : Filepath.t -> int Try.t t

  (** Same of [get_modification_time] but acting on the target. *)
  val target_modification_time : Filepath.t -> int Try.t t

  (** [read_file path] should returns a [Try.t] containing the content (as a
      string) of the given file. The function may fail.*)
  val read_file : Filepath.t -> string Try.t t

  (** [content_changes filepath new_content] check if the content of the file
      has been changed. *)
  val content_changes : Filepath.t -> string -> bool Try.t t

  (** [write_file path content] should write (create or overwrite) [content]
      into the given path. The function may fail. *)
  val write_file : Filepath.t -> string -> unit Try.t t

  (** [read_dir path] should returns a list of children. The function is
      pretty optimistic if the directory does not exist, or for any other
      possible reason the function should fail, it will return an empty list. *)
  val read_dir : Filepath.t -> Filepath.t list t

  (** [create_dir path] is an optimistic version of [mkdir -p], the function
      extract the directory of a file and create it if it does not exists
      without any failure. *)
  val create_dir : ?file_perm:int -> Filepath.t -> unit t

  (** [log level message] justs dump a message on stdout. *)
  val log : Log.level -> string -> unit t

  (** [command cmd] performs a [shell commands] and returns the exit code. *)
  val command : string -> int t
end

(** {1 Helpers} *)

module Make (R : RUNTIME) : sig
  (** Runs a YOCaml program with a specific runtime. *)
  val execute : 'a Effect.t -> 'a R.t
end
