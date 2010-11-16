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

(defvar *mintty-cygpath* "/bin/mintty.exe")
(defvar *mintty-shell* "/etc/passwd")
(defvar *mintty-options* nil)
(defvar *mintty-window-class-name* "mintty")
(defvar *mintty-reuse-window-if-match* :class-and-directory)

(defun mintty ()
  (interactive)
  (mintty-at (default-directory)))

(defun mintty-login ()
  (interactive)
  (mintty-at (user-homedir-pathname)))

(defun mintty-at (&optional dir)
  (interactive "DDirectory: " :default0 (default-directory))
  (let ((existing-mintty (find-mintty dir)))
    (if (or (zerop existing-mintty)
            *prefix-args*)
        (let ((options (append (mintty-launch-options *mintty-options*)
                               (list (format nil "-e /bin/xhere ~A ~A" *mintty-shell* dir)))))
          (launch-mintty options))
      (activate-mintty existing-mintty))))

(defun mintty-help ()
  (interactive)
  (launch-mintty '("--help")))

(defun launch-mintty (options)
  (let ((cmd (mintty-launch-command options)))
    (launch-application cmd)))

(defun mintty-launch-command (options)
  (format nil "~A ~{~A~^ ~}"
          (cygmount-cygpath->winpath *mintty-cygpath*)
          options))

(defun mintty-launch-options (options)
  (append (mintt-internal-options)
          (if (listp options)
              options
            (list options))))

(defun mintty-launch-options (options)
  (list (format nil "--class ~A" *mintty-window-class-name*)
        ))

(defun find-mintty (dir)
  (flet ((c-str (lisp-string)
           (if lisp-string
               (si:make-string-chunk lisp-string)
             0)))
    (let ((default-class *mintty-window-class-name*)
          (default-title (cygmount-winpath->cygpath dir)))
      (multiple-value-bind (class title)
          (case *mintty-reuse-window-if-match*
            (:class-and-directory
             (values default-class default-title))
            (:class
             (values default-class nil))
            (:directory
             (values nil default-title))
            (t
             (plain-error (format nil "*mintty-reuse-window-if-match* は以下のどれかを設定してください。~%~{~A~%~}"
                                  (list :class-and-directory :class :directory)))))
        (when (or class title)
          (FindWindow (c-str class) (c-str title)))))))

(defun activate-mintty (hwnd)
  (OpenIcon hwnd)
  (SetForegroundWindow hwnd))


(provide "mintty/mintty")


;;; End
