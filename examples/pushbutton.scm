#! /bin/sh
#| -*- scheme -*-
exec csi -s $0 "$@"
|#

(import chicken scheme)

(use
 extras
 smoke
 qtcore
 qtgui)

(run-with-qapplication
 (list (command-line-arguments))
 (lambda (args)
   (let ((qapp (qapplication-instance)))
     (add-event-handler qapp "timerEvent" void)
     (call-method qtcore QObject::startTimer qapp #f ((int 100))))

   (let* ((widget (new qtgui QWidget))
          (layout (new qtgui QGridLayout ((c-pointer ,widget))))
          (button1 (new qtgui QPushButton ((qstring "Push the button, Frank.")
                                           (c-pointer #f))))
          (button2 (new qtgui QPushButton ((qstring "Make a widget...")
                                           (c-pointer #f))))
          (label1 (new qtgui QLabel))
          (label2 #f))

     (let ((mid (find-method qtgui "QGridLayout" "addWidget#$$")))
       (%call-method qtgui mid layout #f `((c-pointer ,button1) (int 0) (int 0)))
       (%call-method qtgui mid layout #f `((c-pointer ,button2) (int 1) (int 0)))
       (%call-method qtgui mid layout #f `((c-pointer ,label1) (int 0) (int 1))))

     (define (push-the-button-frank . ignored)
       (call-method qtgui QLabel::setText label1 #f ((qstring "Baaaah!"))))

     (define (make-a-widget . ignored)
       (unless label2
         (set! label2 (new qtgui QLabel ((qstring "It came true!")
                                         (c-pointer #f))))
         (call-method qtgui QGridLayout::addWidget
                      layout #f ((c-pointer ,label2)
                                 (int 1) (int 1)))))

     (add-event-handler button1 "mouseReleaseEvent" push-the-button-frank)
     (add-event-handler button2 "mouseReleaseEvent" make-a-widget)

     (call-method qtgui QWidget::show widget)
     (call-method-with-callbacks qtgui QApplication::exec #f 'int))))
