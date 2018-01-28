(in-package :cl-repl)

(defconstant +version+ '0.4.0)

(defvar *logo*
"  ___  __          ____  ____  ____  __
 / __)(  )    ___ (  _ \\(  __)(  _ \\(  )
( (__ / (_/\\ (___) )   / ) _)  ) __// (_/\\
 \\___)\\____/      (__\\_)(____)(__)  \\____/
")

(defvar *copy* "(C) 2017-2018 TANI Kojiro <kojiro0531@gmail.com>")

(defvar *versions*
  #+ros.script
  (format nil "ver. ~a on ~?~a ~a"
    +version+
    #+ros.script
    "Roswell ~a, "
    #-ros.script
    ""
    #+ros.script
    `(,(ros::version))
    #-ros.script
    nil
    (lisp-implementation-type)
    (lisp-implementation-version)))

(defmacro when-option ((options opt) &body body)
  `(let ((it (getf ,options ,opt)))
     (when it
       ,@body)))

(opts:define-opts
  (:name :help
         :description "Print this help and exit."
         :short #\h
         :long "help")
  (:name :version
         :description "Show the version info and exit."
         :short #\v
         :long "version"))

(defun main (argv &key (show-logo t))
  (multiple-value-bind (options free-args)
    (handler-case (opts:get-opts argv)
      (error ()
        (format t "try `cl-repl --help`.~&")
        (uiop:quit 1)))
    (when-option (options :help)
      (opts:describe
        :prefix "A full-featured Common Lisp REPL implementation.")
      (uiop:quit 0))
    (when-option (options :version)
      (format t "cl-repl v~a~&" +version+)
      (uiop:quit 0)))
  (when show-logo
    (format t (color *logo-color* *logo*)))
  (format t "~a~%~a~2%" *versions* *copy*)
  (rl:register-function :complete #'completer)
  (repl)
  (rl:deprep-terminal))

