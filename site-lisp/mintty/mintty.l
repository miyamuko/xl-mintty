; -*- mode: lisp; package: mintty; encoding: shift_jis -*-

;;; mintty/mintty.l
;;
;; Copyright (c) 2010 MIYAMUKO Katsuyuki.
;;
;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the
;; "Software"), to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject to
;; the following conditions:
;;
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
;; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
;; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

;;; Code:

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "mintty/package")
  )

(in-package :mintty)

(export '(mintty
          mintty-login
          mintty-at
          mintty-help
          ))

(defvar *cygwin-root-dir* nil)
(defvar *mintty-path* "bin/mintty.exe") ;; relative path from *cygwin-root-dir*
(defvar *mintty-options* nil)
(defvar *mintty-window-class-name* "mintty")

(defun mintty ()
  (interactive)
  (mintty-at (default-directory) (not *prefix-args*)))

(defun mintty-login ()
  (interactive)
  (mintty-at (user-homedir-pathname) nil))

(defun mintty-at (&optional dir reuse-window)
  (interactive "DDirectory: " :default0 (default-directory))
  (let ((existing-mintty (when reuse-window
                           (find-mintty dir))))
    (if (and existing-mintty (not (zerop existing-mintty)))
        (activate-mintty existing-mintty)
      (launch-mintty (mintty-launch-options *mintty-options*) dir))))

(defun mintty-help ()
  (interactive)
  (launch-mintty '("--help")))

(defun launch-mintty (options &optional dir)
  (let ((cmd (mintty-launch-command options)))
    (call-process cmd :no-std-handles t :show :show
                  :exec-directory (or dir (default-directory))
                  :environ '(("CHERE_INVOKING" . "yes")))))

(defun mintty-launch-command (options)
  (format nil "~A ~{~A~^ ~}" (mintty-full-path) options))

(defun mintty-launch-options (options)
  (append (mintt-internal-options)
          (if (listp options)
              options
            (list options))))

(defun mintty-launch-options (options)
  (list (format nil "--class ~A" *mintty-window-class-name*)
        ))

(defun mintty-full-path ()
  (merge-pathnames *mintty-path* (cygwin-root-dir)))

(defun cygwin-root-dir ()
  (or *cygwin-root-dir*
      ;; >= Cygwin 1.7
      (read-registry "SOFTWARE\\Wow6432Node\\Cygwin\\setup" "rootdir" :local-machine)
      (read-registry "SOFTWARE\\Cygwin\\setup" "rootdir" :local-machine)
      ;; < Cygwin 1.7
      (read-registry "SOFTWARE\\Wow6432Node\\Cygnus Solutions\\Cygwin\\mounts v2\\/" "native" :current-user)
      (read-registry "SOFTWARE\\Cygnus Solutions\\Cygwin\\mounts v2\\/" "native" :current-user)
      (read-registry "SOFTWARE\\Wow6432Node\\Cygnus Solutions\\Cygwin\\mounts v2\\/" "native" :local-machine)
      (read-registry "SOFTWARE\\Cygnus Solutions\\Cygwin\\mounts v2\\/" "native" :local-machine)))


(defun find-mintty (dir)
  (flet ((c-str (lisp-string)
           (if lisp-string
               (si:make-string-chunk lisp-string)
             0)))
    (FindWindow (c-str *mintty-window-class-name*) 0)))

(defun activate-mintty (hwnd)
  (OpenIcon hwnd)
  (SetForegroundWindow hwnd))


(provide "mintty/mintty")


;;; End
