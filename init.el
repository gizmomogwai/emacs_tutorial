(add-to-list 'load-path (file-name-directory load-file-name))
(require 'el-expectations)

(expectations
  (desc "good test")
  (expect 1 1)
  (desc "bad test")
  (expect 1 2)
  )
