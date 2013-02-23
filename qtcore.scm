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

(module qtcore
    *

(import chicken scheme foreign)

(use
 coops
 extras
 smoke)

(foreign-declare "#include <smoke/qtcore_smoke.h>")
(foreign-declare "#include <QtCore>")

(define string->qstring
  (foreign-lambda* c-pointer ((c-string str))
    "QString *s = new QString(QString::fromUtf8(str));"
    "C_return(s);"))

(define qstring->string
  (foreign-lambda* c-string ((c-pointer qstr))
    "QString *s = (QString *)qstr;"
    "C_return(s->toUtf8().data());"))

(smoke-stack-add-type!
 'qstring
 (lambda (stack idx)
   (qstring->string
    (%smoke-stack-pointer stack idx)))
 (lambda (stack idx s)
   (%smoke-stack-set-pointer!
    stack idx (string->qstring s))))

(begin-for-syntax
 (set! smoke-type-signatures
       (cons '(qstring . scalar)
             smoke-type-signatures)))

(define-foreign-variable %qtcore-smoke c-pointer "qtcore_Smoke")
(define qtcore-smoke #f)

(define (init-qtcore-smoke)
  ((foreign-lambda void init_qtcore_Smoke))
  (set! qtcore-smoke (make <Smoke> 'this %qtcore-smoke)))

(define delete-qtcore-smoke
  (foreign-lambda void delete_qtcore_Smoke))


(define-class <qtcore-binding> (<SchemeSmokeBinding>)
  ())

(define-method (make-scheme-object (this <qtcore-binding>) type pointer)
  (cond
   (else (call-next-method))))

(init-qtcore-smoke)

(define qtcore (make <qtcore-binding> 'smoke qtcore-smoke))

;;;XXX: what about calling delete-qtcore-smoke?  i don't think we can
;;;     safely do this with garbage collection, because the caller may
;;;     never need to use qtcore directly in the first place.

)
