(in-package :cl-fileshare)

(hunchentoot:define-easy-handler (api :uri "/index") ()
  (let* ((post-data (hunchentoot:raw-post-data :force-text t))
         (json-data (json:decode-json-from-string post-data))
         (current-path (cdr (assoc :path json-data))))
    ;; strip out extra \ characters from json string before sending
    (remove "\\"
            (json:encode-json-alist-to-string
             (cons
              (cons "currentPath" current-path)
              (index-directory current-path)))
            :test 'string=)))

(hunchentoot:define-easy-handler (download-dir :uri "/download-directory") ()
  (let* ((post-data (hunchentoot:raw-post-data :force-text t))
         (json-data (json:decode-json-from-string post-data))
         (path (cdr (assoc :path json-data))))
    (log:debug path)
    (if (child-directory-p path *share-root*)
        (json:encode-json-alist-to-string (list (cons "path"
                                                      (download-file-or-directory path))))
        (json:encode-json-alist-to-string '(("error" . "Permission to access path denied"))))))

(defun download-file-or-directory (path) ;; returns a path to be downloaded or nil
  (cond ((cl-fad:directory-exists-p path)
         (multiple-value-bind (output message status)
             (trivial-shell:shell-command
              (format nil "tar -cvf ~a~a.tar ~a" *share-root* "download" path))
           (if (eq status 0)
               (format nil "~a~a" *share-root* "download.tar")
               (format t "~a ~a ~a" output message status))))
        ((cl-fad:file-exists-p path) path)))

(defun configure-logging (&key (log-file *log-file*))
  (if *debug*
      (log:config :all :sane :d :daily log-file)
      (log:config :all :sane :daily log-file)))

(defun start-fileshare ()
  (configure-logging)
  (setq hunchentoot:*session-max-time* (* 24 60 60)
        hunchentoot:*CATCH-ERRORS-P* t
        hunchentoot:*log-lisp-errors-p* t
        hunchentoot:*log-lisp-backtraces-p* t
        hunchentoot:*log-lisp-warnings-p* t
        hunchentoot:*lisp-errors-log-level* :debug
        hunchentoot:*lisp-warnings-log-level* :debug)
  (progn
    (push (hunchentoot:create-folder-dispatcher-and-handler
           "/static/" "~/lisp/cl-fileshare/static/")
          hunchentoot:*dispatch-table*)
    (push (hunchentoot:create-folder-dispatcher-and-handler
           "/download/" "/home/gaige/Dropbox/")
          hunchentoot:*dispatch-table*)
    (push (hunchentoot:create-static-file-dispatcher-and-handler
           "/" "static/index.html")
          hunchentoot:*dispatch-table*))
    (setq *file-server*
        (make-instance
         'hunchentoot:easy-acceptor
         :port *file-port*
         :access-log-destination "fileshare-access.log"
         :message-log-destination "fileshare-error.log"))
  (hunchentoot:start *file-server*))

(defun stop-fileshare ()
  (when *file-server*
    (hunchentoot:stop *file-server* :soft t)))
