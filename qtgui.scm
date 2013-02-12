;; Copyright 2013 John J Foerch. All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are
;; met:
;;
;;    1. Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;    2. Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in
;;       the documentation and/or other materials provided with the
;;       distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY JOHN J FOERCH ''AS IS'' AND ANY EXPRESS OR
;; IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;; DISCLAIMED. IN NO EVENT SHALL JOHN J FOERCH OR CONTRIBUTORS BE LIABLE
;; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
;; BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
;; WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
;; OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
;; ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(module qtgui
    *

(import chicken scheme foreign)

(use
 coops
 extras
 smoke)

(foreign-declare "#include <smoke/qtgui_smoke.h>")

(define-foreign-variable %qtgui-smoke c-pointer "qtgui_Smoke")
(define qtgui-smoke #f)

(define (init-qtgui-smoke)
  ((foreign-lambda void init_qtgui_Smoke))
  (set! qtgui-smoke (make <Smoke> 'this %qtgui-smoke)))

(define delete-qtgui-smoke
  (foreign-lambda void delete_qtgui_Smoke))


(define-class <qtgui-binding> (<SchemeSmokeBinding>)
  ())

(define-method (make-scheme-object (this <qtgui-binding>) type pointer)
  (select type
    (else (call-next-method))))

(init-qtgui-smoke)

(define qtgui (make <qtgui-binding> 'smoke qtgui-smoke))

(set-finalizer! qtgui delete-qtgui-smoke)

)
