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

(module qtdbus
    *

(import chicken scheme foreign)

(use
 coops
 extras
 smoke)

(foreign-declare "#include <smoke/qtdbus_smoke.h>")

(define-foreign-variable %qtdbus-smoke c-pointer "qtdbus_Smoke")
(define qtdbus-smoke #f)

(define (init-qtdbus-smoke)
  ((foreign-lambda void init_qtdbus_Smoke))
  (set! qtdbus-smoke (make <Smoke> 'this %qtdbus-smoke)))

(define delete-qtdbus-smoke
  (foreign-lambda void delete_qtdbus_Smoke))


(define-class <qtdbus-binding> (<SchemeSmokeBinding>)
  ())

(define-method (make-scheme-object (this <qtdbus-binding>) type pointer)
  (cond
   (else (call-next-method))))

(init-qtdbus-smoke)

(define qtdbus (make <qtdbus-binding> 'smoke qtdbus-smoke))

(set-finalizer! qtdbus delete-qtdbus-smoke)

)
