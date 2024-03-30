(asdf:defsystem "learn-qt"
  :author "garlic0x1"
  :license "MIT"
  :depends-on (:alexandria :str :qtools :qtcore :qtgui)
  :components ((:module "src"
                :components ((:file "package")
                             (:file "counter")
                             (:file "prompt")))))
