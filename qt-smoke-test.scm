
(import chicken scheme)

(use
 coops
 extras
 smoke
 smoke-qtcore
 smoke-qtgui)

(init-qtcore-smoke)
(init-qtgui-smoke)
(printf "~S~%" qtcore-smoke)
(printf "~S~%" (slot-value qtcore-smoke 'this))
(let ((m (find-method qtcore-smoke "QApplication" "QApplication$?")))
  (print (ModuleIndex-index m)))
;;((foreign-lambda int themain))
(delete-qtcore-smoke)
(delete-qtgui-smoke)
