;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Mikey O'Brien"
      user-mail-address "hughobrien.v@gmail.com")
(setq doom-font (font-spec :family "JetBrains Mono" :size 14)
      doom-serif-font (font-spec :family "JetBrains Mono"))

(use-package-hook! evil
  :pre-init
  (setq evil-respect-visual-line-mode t) ;; sane j and k behavior
  t)

;; Set theme and remove the defaults
(setq doom-theme 'doom-vibrant)
(remove-hook 'window-setup-hook #'doom-init-theme-h)
(add-hook 'after-init-hook #'doom-init-theme-h 'append)
(delq! t custom-theme-load-path)

(setq org-directory "~/org/")
(setq-default major-mode 'org-mode)

(with-eval-after-load 'lsp-mode
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\build\\'"))

(defun plantuml-find-icon ()
  "Find and insert !include statement for AWS resource.
Download this and modify basedir appropriately
https://github.com/plantuml/plantuml-stdlib"
  (interactive)
  (let ((basedir (expand-file-name "~/git/plantuml-stdlib/awslib")))
    (helm :sources
          (helm-build-sync-source "AWS Architecture"
                                  :candidates (directory-files-recursively basedir "")
                                  :fuzzy-match t
                                  :action (lambda (candidate)  (insert (format "!include <awslib%s>" (nth 1 (split-string candidate basedir)))))
                                  ))))

(setq plantuml-jar-path "/opt/homebrew/Cellar/plantuml/1.2022.4/libexec/plantuml.jar") ;; The homebrew install location
(setq plantuml-default-exec-mode 'jar)
(setq read-process-output-max (* 1024 1024)) ;; 1 mb

(after! org
  (add-to-list 'org-agenda-files '"~/org/roam/daily/" '"~/org/roam")
  (setq org-ellipsis " [...] ")
  (setq org-plantuml-jar-path (expand-file-name  "/opt/homebrew/Cellar/plantuml/1.2022.4/libexec/plantuml.jar"))
  (setq org-src-window-setup 'current-window)
  (add-hook! 'org-mode-hook 'turn-on-visual-line-mode)
  (setq org-capture-templates
        '(("t" "todo" entry (file+headline "todo.org" "Unsorted")
           "* TODO %?\n\%i\n%a"
           :prepend t)
          ("d" "deadline" entry (file+headline "todo.org" "Schedule")
           "* TODO %?\nDEADLINE: <%(org-read-date)>\n\n%i\n%a"
           :prepend t)
          ("s" "schedule" entry (file+headline "todo.org" "Schedule")
           "* TODO %?\nSCHEDULED: <%(org-read-date)>\n\n%i\n%a"
           :prepend t)))
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((plantuml . t))))


(setq display-line-numbers-type t)

(use-package! nix-mode
  :mode "\\.nix\\'")

(setq compilation-scroll-output 'first-error)

(defun shell-mode-hook-setup ()
  "Set up `shell-mode'."
  (setq-local company-backends '((company-files company-native-complete)))
  (local-set-key (kbd "TAB") 'company-complete)

  ;; @see https://github.com/redguardtoo/emacs.d/issues/882
  (setq-local company-idle-delay 1))
(add-hook! 'eshell-mode-hook 'shell-mode-hook-setup)


(after! flycheck
  (use-package! flymake-cursor
    :config
    (flymake-cursor-mode))
  (use-package! flymake-vale
    :ensure t
    :hook ((text-mode       . flymake-vale-load)
           (latex-mode      . flymake-vale-load)
           (org-mode        . flymake-vale-load)
           (markdown-mode   . flymake-vale-load)
           (message-mode    . flymake-vale-load))
    :config
        (add-hook! 'find-file-hook 'flymake-vale-maybe-load)
        (add-hook! 'org-mode-hook 'flymake-mode)
        (add-to-list 'flymake-vale-modes 'org-mode)))
  ;; )

(use-package! tree-sitter
  :config
  (require 'tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(defun smerge-repeatedly ()
  "Perform smerge actions again and again"
  (interactive)
  (smerge-mode 1)
  (smerge-transient))
(after! transient
  (transient-define-prefix smerge-transient()
    [["Move"
      ("n" "next" (lambda () (interactive) (ignore-errors (smerge-next)) (smerge-repeatedly)))
      ("p" "previous" (lambda () (interactive) (ignore-errors (smerge-prev)) (smerge-repeatedly)))]
     ["Keep"
      ("b" "base" (lambda () (interactive) (ignore-errors (smerge-keep-base)) (smerge-repeatedly)))
      ("u" "upper" (lambda () (interactive) (ignore-errors (smerge-keep-upper)) (smerge-repeatedly)))
      ("l" "lower" (lambda () (interactive) (ignore-errors (smerge-keep-lower)) (smerge-repeatedly)))
      ("a" "all" (lambda () (interactive) (ignore-errors (smerge-keep-all)) (smerge-repeatedly)))
      ("RET" "current" (lambda () (interactive) (ignore-errors (smerge-keep-current)) (smerge-repeatedly)))]
     ["Diff"
      ("<" "upper/base" (lambda () (interactive) (ignore-errors (smerge-diff-base-upper)) (smerge-repeatedly)))
      ("=" "upper/lower" (lambda () (interactive) (ignore-errors (smerge-diff-upper-lower)) (smerge-repeatedly)))
      (">" "base/lower" (lambda () (interactive) (ignore-errors (smerge-diff-base-lower)) (smerge-repeatedly)))
      ("R" "refine" (lambda () (interactive) (ignore-errors (smerge-refine)) (smerge-repeatedly)))
      ("E" "ediff" (lambda () (interactive) (ignore-errors (smerge-ediff)) (smerge-repeatedly)))]
     ["Other"
      ("c" "combine" (lambda () (interactive) (ignore-errors (smerge-combine-with-next)) (smerge-repeatedly)))
      ("r" "resolve" (lambda () (interactive) (ignore-errors (smerge-resolve)) (smerge-repeatedly)))
      ("k" "kill current" (lambda () (interactive) (ignore-errors (smerge-kill-current)) (smerge-repeatedly)))
      ("q" "quit" (lambda () (interactive) (smerge-auto-leave)))]]))


(after! treemacs
  (defvar treemacs-file-ignore-extensions '()
    "File extension which `treemacs-ignore-filter' will ensure are ignored")
  (defvar treemacs-file-ignore-globs '()
    "Globs which will are transformed to `treemacs-file-ignore-regexps' which `treemacs-ignore-filter' will ensure are ignored")
  (defvar treemacs-file-ignore-regexps '()
    "RegExps to be tested to ignore files, generated from `treeemacs-file-ignore-globs'")
  (defun treemacs-file-ignore-generate-regexps ()
    "Generate `treemacs-file-ignore-regexps' from `treemacs-file-ignore-globs'"
    (setq treemacs-file-ignore-regexps (mapcar 'dired-glob-regexp treemacs-file-ignore-globs)))
  (if (equal treemacs-file-ignore-globs '()) nil (treemacs-file-ignore-generate-regexps))
  (defun treemacs-ignore-filter (file full-path)
    "Ignore files specified by `treemacs-file-ignore-extensions', and `treemacs-file-ignore-regexps'"
    (or (member (file-name-extension file) treemacs-file-ignore-extensions)
        (let ((ignore-file nil))
          (dolist (regexp treemacs-file-ignore-regexps ignore-file)
            (setq ignore-file (or ignore-file (if (string-match-p regexp full-path) t nil)))))))
  (add-to-list 'treemacs-ignored-file-predicates #'treemacs-ignore-filter))

(setq treemacs-file-ignore-extensions '())
(setq treemacs-file-ignore-globs '())

;; TODO add template generators for day,week,month,year logs

(use-package! direnv
  :config
  (direnv-mode))


(load! "private/private-config.el")
