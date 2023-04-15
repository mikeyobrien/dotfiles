;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(add-load-path! "private")
(when (file-exists-p "private/private-config.el")
  (require 'private-config))

(setq user-full-name "Mikey O'Brien"
      user-mail-address "hughobrien.v@gmail.com")
(setq doom-font (font-spec :family "FiraCode Nerd Font" :size 14)
      doom-serif-font (font-spec :family "Roboto"))


(use-package-hook! evil
  :pre-init
  (setq evil-respect-visual-line-mode t) ;; sane j and k behavior
  t)

(setq doom-scratch-initial-major-mode 'lisp-interaction-mode)

;; Set theme and remove the defaults
(setq doom-theme 'doom-one)
(remove-hook 'window-setup-hook #'doom-init-theme-h)
(add-hook 'after-init-hook #'doom-init-theme-h 'append)
(delq! t custom-theme-load-path)

(setq-default major-mode 'org-mode)

;; use excorporate to sync outlook calendar
(setq diary-file "~/org/diary")
(setq excorporate-diary-today-file diary-file)

(with-eval-after-load 'lsp-mode
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\build\\'"))

(setq read-process-output-max (* 1024 1024)) ;; 1 mb

(setq +org-roam-auto-backlinks-buffer t
      org-ellipsis " [...] "
      org-directory "~/org/"
      org-roam-db-location (concat org-directory ".org-roam.db")
      org-archive-location (concat org-directory ".archive/%s::")
      org-agenda-files (directory-files org-directory t "\\.org$"))

(after! org
  (add-to-list 'org-agenda-files '"~/org/roam/daily/" '"~/org/roam")
  (setq org-agenda-include-diary t)
  (setq org-ellipsis " [...] ")
  (setq org-src-window-setup 'current-window)
  (add-hook! 'org-mode-hook 'turn-on-visual-line-mode)
  (setq org-capture-templates
        '(("i" "inbox" entry (file+headline "inbox.org" "Unsorted")
           "* TODO %?\n\%i\n%a"
           :prepend t)
          ("T" "today" entry (file+headline "~/org/tasks.org" "Tasks")
                "* TODO %?\n  SCHEDULED: %t"
                :prepend t)
          ("d" "deadline" entry (file+headline "todo.org" "Schedule")
           "* TODO %?\nDEADLINE: <%(org-read-date)>\n\n%i\n%a"
           :prepend t)
          ("s" "schedule" entry (file+headline "inbox.org" "Schedule")
           "* TODO %?\nSCHEDULED: <%(org-read-date)>\n\n%i\n%a"
           :prepend t)))
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((plantuml . t))))

(after! org-roam
  (setq org-roam-capture-templates
        `(("n" "note" plain
           ,(format "#+title: ${title}\n%%[%s/template/note.org]" org-roam-directory)
           :target (file "note/%<%Y%m%d%H%M%S>-${slug}.org")
           :unnarrowed t)
          ("p" "project" plain
           ,(format "#+title: ${title}\n%%[%s/template/project.org]" org-roam-directory)
           :target (file "project/%<%Y%m%d>-${slug}.org")
           :unnarrowed t)
          ("s" "secret" plain "#+title: ${title}\n\n"
           :target (file "secret/%<%Y%m%d%H%M%S>-${slug}.org.gpg")
           :unnarrowed t))
        ;; Use human readable dates for dailies titles
        org-roam-dailies-capture-templates
        '(("d" "default" entry "* %?"
           :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%B %d, %Y>\n\n"))))

  ;; Make the backlinks buffer easier to peruse by folding leaves by default.
  (add-hook 'org-roam-buffer-postrender-functions #'magit-section-show-level-2)

  ;; List dailies and zettels separately in the backlinks buffer.
  (advice-add #'org-roam-backlinks-section :override #'org-roam-grouped-backlinks-section)

  ;; Open in focused buffer, despite popups
  (advice-add #'org-roam-node-visit :around #'+popup-save-a)

  ;; Add ID, Type, Tags, and Aliases to top of backlinks buffer.
  (advice-add #'org-roam-buffer-set-header-line-format :after #'org-roam-add-preamble-a))



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

(defun connect-desktop ()
  (interactive)
  (find-file "/ssh:desktop:~"))

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

(use-package! tramp
  :config
  (add-to-list 'tramp-remote-path "/etc/profiles/per-user/mobrien/bin")
  (add-to-list 'tramp-remote-path "/etc/profiles/per-user/mobrienv/bin")
  (add-to-list 'tramp-remote-path "/run/current-system/sw/bin")
  (add-to-list 'tramp-methods
        '("yadm"
        (tramp-login-program "yadm")
        (tramp-login-args (("enter")))
        (tramp-login-env (("SHELL") ("/bin/sh")))
        (tramp-remote-shell "/bin/sh")
        (tramp-remote-shell-args ("-c")))))


(after! lsp-mode
  (lsp-register-client
    (make-lsp-client :new-connection (lsp-tramp-connection "pyright-langserver")
                     :major-modes '(python-mode)
                     :remote? t
                     :server-id 'pyright-remote)))

;;; :tools magit
(setq magit-repository-directories '(("~/Code" . 2))
      magit-save-repository-buffers nil
      ;; Don't restore the wconf after quitting magit, it's jarring
      magit-inhibit-save-previous-winconf t
      transient-values '((magit-rebase "--autosquash" "--autostash")
                         (magit-pull "--rebase" "--autostash")
                         (magit-revert "--autostash")))


(defun c1-layout ()
  (interactive)
  (delete-other-windows)
  (let ((bottom-half (split-window-below (floor (* 0.3 (window-height)))))
        (vterm-buffer (get-buffer "*vterm*")))
    (if vterm-buffer
        (switch-to-buffer vterm-buffer)
      (+vterm/here 0))

    (split-window-right (floor (* 0.3 (window-width))))
    (org-agenda-list)
    (windmove-right)
    (switch-to-buffer (get-buffer "*doom*"))))

(defun yadm-status ()
  (interactive)
  (magit-status "/yadm::")
  (add-to-list 'tramp-remote-path "/run/current-system/sw/bin"))

(setq mu4e-maildir "~/.mail"
      mu4e-attachment-dir "~/Downloads")

(setq user-mail-address "me@mikeyobrien.com"
      user-full-name  "Mikey O'Brien")

;; Get mail
(setq mu4e-get-mail-command "mbsync protonmail"
      mu4e-change-filenames-when-moving t   ; needed for mbsync
      mu4e-update-interval 120)             ; update every 2 minutes

;; Send mail
(setq message-send-mail-function 'smtpmail-send-it
      smtpmail-auth-credentials "pass bridge-key"
      smtpmail-smtp-server "127.0.0.1"
      smtpmail-stream-type 'starttls
      smtpmail-smtp-service 1025)


(if (file-exists-p "private/private-config.el")
    (load! "private/private-config.el"))
