(add-to-list 'load-path (file-name-directory load-file-name))
(require 'el-expectations)

(defun tff-replace-extension
  (patterns input)
  "replaces the extension from input with a matching pattern from patterns"
  (let*
      ((extension (file-name-extension input))
       (basename (file-name-sans-extension input))
       (p (assoc extension patterns)))
    (if p (concat basename "." (car (cdr p))) nil)))

(expectations
  (desc "nil when no matching extension")
  (expect nil (tff-replace-extension '(("cpp" "h")) "test.rb"))
  (desc "not nil when a extension matches")
  (expect "test.yaml" (tff-replace-extension '(("cpp" "h")("rb" "yaml")) "test.rb"))
  )
