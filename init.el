(add-to-list 'load-path (file-name-directory load-file-name))
(require 'el-expectations)

(defgroup tff nil
  "Toggle between Friend Files."
  :group 'tff)

(defcustom tff-extension-mapping
  '(("cpp" "h")
    ("h" "cpp")
    ("haml" "yaml")
    ("yaml" "haml"))
  "mapping between file extensions"
  :type '(repeat
          (list
           (string :tag "from")
           (string :tag "to")))
  :group 'tff)

(defcustom tff-path-mapping
  '(("src" "include")
    ("include" "src"))
  "replacements of file paths"
  :type '(repeat
          (list
           (string :tag "from")
           (string :tag "to")))
  :group 'tff)

(defun tff-replace-extension
  (patterns input)
  "replaces the extension from input with a matching pattern from patterns"
  (let*
      ((extension (file-name-extension input))
       (basename (file-name-sans-extension input))
       (p (assoc extension patterns)))
    (if p (concat basename "." (car (cdr p))) nil)))

(defun tff-replace-with-first-matching-regexp
  (patterns input)
  "iterates over patterns and return the regexp-replace of the first regexp-match"
  (if (first patterns)
      (let* ((pair (first patterns))
             (pattern (car pair))
             (repl (car (cdr pair)))
             (replaced (replace-regexp-in-string pattern repl input))
             (finished (not (string= replaced input))))
        (if finished replaced (tff-replace-with-first-matching-regexp (rest patterns) input)))
    input))

(defun tff-calc-file-name
  (ext-patterns regexp-patterns input)
  "replaces the file-extension and the regexp-patterns"
  (tff-replace-with-first-matching-regexp regexp-patterns (or (tff-replace-extension ext-patterns input) input)))

(defun tff
  ()
  "toggles between friend fiels (see tff customization group)"
  (interactive)
  (let* ((file-name (buffer-file-name))
         (new-file-name (tff-calc-file-name '(("cpp" "h")("h" "cpp")) '() file-name)))
    (if (not (string= file-name new-file-name)) (find-file new-file-name))))

(global-set-key (kbd "C-1") 'tff)

(progn
  (put 'tff-path-mapping 'safe-local-variable 'listp)
  (put 'tff-extension-mapping 'safe-local-variable 'listp)
)

(expectations
  (desc "nil when no matching extension")
  (expect nil (tff-replace-extension '(("cpp" "h")) "test.rb"))
  (desc "not nil when a extension matches")
  (expect "test.yaml" (tff-replace-extension '(("cpp" "h")("rb" "yaml")) "test.rb"))

  (desc "replace with first matching regexp")
  (expect "/some/path/src/test" (tff-replace-with-first-matching-regexp '(("include" "src")("src" "include")) "/some/path/include/test"))
  (desc "no replacement when no regexp matches")
  (expect "/some/path/include/test" (tff-replace-with-first-matching-regexp '(("abc" "def")) "/some/path/include/test"))

  (desc "combine extension and regex replacement")
  (expect "/some/path/include/test.h" (tff-calc-file-name '(("cpp" "h")) '(("src" "include")) "/some/path/src/test.cpp"))
  (desc "combine no extension match and regex replacement")
  (expect "/some/path/include/test.cc" (tff-calc-file-name '(("cpp" "h")) '(("src" "include")) "/some/path/src/test.cc"))
  (desc "combine extension match and no regex replacement")
  (expect "/some/path/src/test.h" (tff-calc-file-name '(("cpp" "h")) '(("src2" "include")) "/some/path/src/test.cpp"))
  )
