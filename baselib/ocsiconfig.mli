exception Config_file_error of string
val config_file : string ref
val verbose : bool ref
val silent : bool ref
val daemon : bool ref
val veryverbose : bool ref
val version_number : string
val pidfile : string option ref
val server_name : string
val full_server_name : string
val uploaddir : string option ref
val logdir : string ref
val default_user : string ref
val default_group : string ref
val minthreads : int ref
val maxthreads : int ref
val max_number_of_threads_queued : int ref
val max_number_of_connections : int ref
val mimefile : string ref
val connect_time_max : float ref
val keepalive_timeout : float ref
val netbuffersize : int ref
val filebuffersize : int ref
val maxrequestbodysize : int64 option ref
val maxuploadfilesize : int64 option ref
val defaultcharset : string option ref
val datadir : string ref
val bindir : string ref
val user : string option ref
val group : string option ref
val command_pipe : string ref
val debugmode : bool ref
val set_uploaddir : string option -> unit
val set_logdir : string -> unit
val set_configfile : string -> unit
val set_pidfile : string -> unit
val set_mimefile : string -> unit
val set_verbose : unit -> unit
val set_silent : unit -> unit
val set_daemon : unit -> unit
val set_veryverbose : unit -> unit
val set_minthreads : int -> unit
val set_maxthreads : int -> unit
val set_max_number_of_threads_queued : int -> unit
val set_max_number_of_connections : int -> unit
val set_connect_time_max : float -> unit
val set_keepalive_timeout : float -> unit
val set_netbuffersize : int -> unit
val set_filebuffersize : int -> unit
val set_maxuploadfilesize : int64 option -> unit
val set_maxrequestbodysize : int64 option -> unit
val set_default_charset : string option -> unit
val set_datadir : string -> unit
val set_bindir : string -> unit
val set_user : string option -> unit
val set_group : string option -> unit
val set_command_pipe : string -> unit
val set_debugmode : bool -> unit
val get_uploaddir : unit -> string option
val get_logdir : unit -> string
val get_config_file : unit -> string
val get_pidfile : unit -> string option
val get_mimefile : unit -> string
val get_verbose : unit -> bool
val get_silent : unit -> bool
val get_daemon : unit -> bool
val get_veryverbose : unit -> bool
val get_default_user : unit -> string
val get_default_group : unit -> string
val get_minthreads : unit -> int
val get_maxthreads : unit -> int
val get_max_number_of_threads_queued : unit -> int
val get_max_number_of_connections : unit -> int
val get_connect_time_max : unit -> float
val get_keepalive_timeout : unit -> float
val get_netbuffersize : unit -> int
val get_filebuffersize : unit -> int
val get_maxuploadfilesize : unit -> int64 option
val get_maxrequestbodysize : unit -> int64 option
val get_default_charset : unit -> string option
val get_datadir : unit -> string
val get_bindir : unit -> string
val get_user : unit -> string option
val get_group : unit -> string option
val get_command_pipe : unit -> string
val get_debugmode : unit -> bool
val display_version : unit -> 'a
val config : unit -> Simplexmlparser.xml list
