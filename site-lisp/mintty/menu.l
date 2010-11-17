; -*- mode: lisp; package: mintty; encoding: shift_jis -*-

;;; mintty/menu.l
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

(defvar *mintty-menu-name* "Mintty(&M)")
(defvar *mintty-menu-symbol* 'mintty)

(defvar *mintty-menu-parent* 'ed::tools)
(defvar *mintty-menu-position* ':above-kbd-macro)

(defparameter *mintty-popup-menu* nil)
(defun mintty-popup-menu ()
  (unless *mintty-popup-menu*
    (setf *mintty-popup-menu*
          (define-popup-menu 'mintty
            (:item nil "Mintty を開く"
             'mintty)
            (:item nil "現在のディレクトリで起動"
             '(lambda ()
               (interactive)
               (let ((*prefix-args* t))
                 (mintty))))
            (:item nil "ホームディレクトリで起動"
             'mintty-login)
            (:item nil "ディレクトリを指定して起動..."
             'mintty-at)
            :sep
            (:item nil "Mintty のヘルプ"
             'mintty-help)
            (:item nil (concat "mintty &version " (mintty-version))
             'mintty-about-message)
            )))
  *mintty-popup-menu*)

(defun mintty-setup-menu ()
  (let ((tools (get-menu *app-menu* *mintty-menu-parent*)))
    (let ((pos (get-menu-position tools *mintty-menu-symbol*)))
      (when pos
        (delete-menu tools pos t)))
    (insert-popup-menu tools
                       (get-menu-position tools *mintty-menu-position*)
                       (mintty-popup-menu) *mintty-menu-name*)))

(if *app-menu*
    (mintty-setup-menu)
  (add-hook '*init-app-menus-hook* 'mintty-setup-menu))


(provide "mintty/menu")


;;; End
