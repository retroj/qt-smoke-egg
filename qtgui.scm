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
 lolevel
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
  (cond
   (else (call-next-method))))


(define (string-list->c-string-list lst #!optional len)
  (define make-c-string-list
    (foreign-lambda* c-pointer ((int len))
      "char **p = (char **)malloc(sizeof(char**) * (len + 1));"
      "p[len] = 0;"
      "C_return(p);"))
  (define copy-string-into-list
    (foreign-lambda* void ((c-pointer p) (c-string s) (int i))
      "char **q = (char **)p;"
      "size_t len = strlen(s);"
      "char *dest = (char *)malloc(len + 1);"
      "strcpy(dest, s);"
      "q[i] = dest;"))
  (define free-c-string-list
    (foreign-lambda* void ((c-pointer p))
      "char **q = (char **)p;"
      "while (*q) {"
      "    free(*q);"
      "    ++q;"
      "}"
      "free(p);"))
  (let* ((len (or len (length lst)))
         (p (make-c-string-list len))
         (i 0))
    (for-each
     (lambda (s)
       (copy-string-into-list p s i)
       (set! i (+ 1 i)))
     lst)
    (set-finalizer! p free-c-string-list)
    p))

(define (make-int-pointer n)
  (let ((p ((foreign-lambda* (c-pointer int) ((int init))
              "int *p = (int *)malloc(sizeof(int));"
              "*p = init;"
              "C_return(p);")
            n)))
    (set-finalizer! p free)
    p))

(define-syntax with-qapplication
  (syntax-rules ()
    ((with-qapplication (arguments) proc)
     (let* ((args (cons (program-name) arguments))
            (nargs (length args))
            (argc (make-int-pointer nargs))
            (argv (string-list->c-string-list args nargs))
            (qapp #f))
       (dynamic-wind
           (lambda ()
             (unless qapp
               (set! qapp (instantiate qtgui "QApplication" "QApplication$?"
                                       `((c-pointer ,argc)      ;; &argc
                                         (c-pointer ,argv)))))) ;; argv

           ;; Qt will remove arguments that it recognizes, and will
           ;; change argc and argv.  We should convert the changed argv
           ;; back to a scheme list and pass it to proc.

           proc
           (lambda ()
             (let ((mid (find-method qtgui "QApplication" "~QApplication")))
               (call-method qtgui mid qapp))))))))


(init-qtgui-smoke)

(define qtgui (make <qtgui-binding> 'smoke qtgui-smoke))

(set-finalizer! qtgui delete-qtgui-smoke)

)
