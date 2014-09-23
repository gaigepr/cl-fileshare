(in-package :cl-fileshare)

(defvar *debug* t)

(defvar *file-port* 4040)
(defvar *file-server* nil)
(defvar *slime-port* 4010)

(defvar *log-file* "fileshare.log")
(defvar *configuration-file "fileshare.ini")
(defvar *configuration* nil)

(defvar *share-root* "/home/gaige/")
(defvar *share-index* '())
