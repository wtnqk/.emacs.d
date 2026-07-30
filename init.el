;;; init.el --- Generated from init.org -*- lexical-binding: t; -*-

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t
      use-package-always-defer t
      use-package-expand-minimally t)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-readable-p custom-file)
  (load custom-file nil 'nomessage))

(defconst my/is-mac (eq system-type 'darwin))
(defconst my/is-windows (eq system-type 'windows-nt))
(defconst my/is-linux (eq system-type 'gnu/linux))
(defconst my/is-wsl
  (and my/is-linux
       (or (getenv "WSL_DISTRO_NAME")
           (string-match-p "microsoft" (downcase operating-system-release)))))

(defun my/add-exec-path (directory)
  "Add DIRECTORY to both `exec-path' and PATH when it exists."
  (when (file-directory-p directory)
    (add-to-list 'exec-path directory)
    (setenv "PATH" (concat directory path-separator (getenv "PATH")))))

(dolist (directory '("~/.local/bin" "~/.cargo/bin" "~/go/bin" "~/.ghcup/bin"
                     "~/.opam/default/bin"))
  (my/add-exec-path (expand-file-name directory)))

(use-package no-littering
  :demand t
  :config
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

(setq gc-cons-threshold (* 64 1024 1024)
      gc-cons-percentage 0.1
      read-process-output-max (* 1024 1024)
      create-lockfiles nil
      make-backup-files t
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      sentence-end-double-space nil
      use-short-answers t
      ring-bell-function #'ignore)

(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 100
              truncate-lines nil)

(global-auto-revert-mode 1)
(delete-selection-mode 1)
(electric-pair-mode 1)
(save-place-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(global-display-line-numbers-mode 1)
(column-number-mode 1)

(dolist (hook '(org-mode-hook term-mode-hook shell-mode-hook eshell-mode-hook
                dashboard-mode-hook mu4e-main-mode-hook))
  (add-hook hook (lambda () (display-line-numbers-mode -1))))

(use-package which-key
  :straight nil
  :demand t
  :config (which-key-mode 1))

(use-package general
  :demand t
  :config
  (general-create-definer my/leader
    :prefix "C-c SPC")
  (my/leader
    "f f" '(find-file :which-key "find file")
    "f r" '(consult-recent-file :which-key "recent file")
    "b b" '(consult-buffer :which-key "switch buffer")
    "p p" '(project-switch-project :which-key "switch project")
    "p f" '(project-find-file :which-key "project file")
    "s r" '(consult-ripgrep :which-key "ripgrep")
    "s m" '(symon-mode :which-key "system monitor")
    "g g" '(magit-status :which-key "magit")
    "g d" '(difftastic-magit-diff :which-key "difftastic diff")
    "g t" '(git-timemachine :which-key "git time machine")
    "g m" '(git-messenger :which-key "git blame")
    "g l" '(git-link :which-key "git link")
    "k k" '(kubernetes-overview :which-key "kubernetes")
    "o a" '(org-agenda :which-key "agenda")
    "o c" '(org-capture :which-key "capture")
    "o r" '(org-roam-node-find :which-key "roam node")
    "o s" '(my/org-roam-rg :which-key "search notes")
    "m m" '(mu4e :which-key "mail")
    "r t" '(consult-tramp :which-key "remote files")
    "r r" '(elfeed :which-key "RSS")))

(use-package key-chord
  :demand t
  :custom (key-chord-two-keys-delay 0.1)
  :config
  (key-chord-mode 1)
  (key-chord-define-global "fj" #'view-mode)
  (key-chord-define-global "jf" #'view-mode))

(use-package key-combo
  :hook ((typescript-mode . key-combo-mode)
         (web-mode . key-combo-mode)))

(use-package dmacro
  :demand t
  :config (global-dmacro-mode 1))

(use-package god-mode
  :commands god-mode
  :bind ("C-c SPC k g" . god-mode))

(use-package vundo :bind ("C-x u" . vundo))
(use-package rainbow-delimiters :hook (prog-mode . rainbow-delimiters-mode))
(use-package editorconfig :config (editorconfig-mode 1))

(defun my/tangle-config-on-save ()
  "Tangle this literate configuration after saving it."
  (when (file-equal-p buffer-file-name
                      (expand-file-name "init.org" user-emacs-directory))
    (org-babel-tangle)))
(add-hook 'org-mode-hook
          (lambda ()
            (when (and buffer-file-name
                       (file-equal-p buffer-file-name
                                     (expand-file-name "init.org" user-emacs-directory)))
              (add-hook 'after-save-hook #'my/tangle-config-on-save nil t))))

(straight-use-package
 '(doom-everforest-theme
   :type git
   :host github
   :repo "Cardoso1994/doom-everforest-theme"))
(add-to-list 'custom-theme-load-path
             (expand-file-name "straight/build/doom-everforest-theme"
                               user-emacs-directory))

(use-package doom-themes
  :demand t
  :config
  (load-theme 'doom-everforest t)
  (doom-themes-org-config))

(use-package nerd-icons)
(use-package doom-modeline
  :demand t
  :custom
  (doom-modeline-icon (display-graphic-p))
  (doom-modeline-height 28)
  :config (doom-modeline-mode 1))

(use-package nerd-icons-completion
  :after marginalia
  :config (nerd-icons-completion-mode 1))

(when (display-graphic-p)
  (let ((font-name (if (find-font (font-spec :name "HackGen Console NF"))
                       "HackGen Console NF-12"
                     "Hack-12")))
    (set-frame-font font-name nil t)
    (dolist (charset '(japanese-jisx0208 japanese-jisx0212 katakana-jisx0201))
      (set-fontset-font t charset
                        (font-spec :family "HackGen Console NF")
                        nil 'append))))

(when my/is-mac
  (setq mac-command-modifier 'meta
        mac-option-modifier 'super))

(use-package vertico
  :demand t
  :custom (vertico-cycle t)
  :config (vertico-mode 1))

(use-package orderless
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia :demand t :config (marginalia-mode 1))

(use-package consult
  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer)
         ("M-y" . consult-yank-pop)))
(use-package embark
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim)
         ("C-h B" . embark-bindings)))
(use-package embark-consult :after (embark consult))
(use-package affe :commands (affe-find affe-grep))

(use-package corfu
  :demand t
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :config (global-corfu-mode 1))
(use-package cape
  :demand t
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

(use-package project :straight nil)
(use-package magit
  :commands magit-status
  :custom
  (magit-diff-refine-hunk 'all)
  (magit-diff-paint-whitespace 'untrailing))
(use-package difftastic
  :demand t
  :custom (difftastic-executable (or (executable-find "difft") "difft"))
  :config
  (require 'difftastic-bindings)
  (difftastic-bindings-mode 1))
(use-package magit-gitflow
  :after magit)
(use-package git-modes)
(use-package git-messenger
  :commands git-messenger)
(use-package git-link
  :commands git-link)
(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode))
  :config
  (with-eval-after-load 'magit
    (require 'diff-hl-magit)
    (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)))
(use-package git-timemachine
  :commands git-timemachine)

(use-package tramp
  :straight nil
  :custom (tramp-default-method "ssh"))

(use-package docker-tramp
  :straight (:host github :repo "emacs-pe/docker-tramp.el")
  :config (docker-tramp-add-method))

(use-package consult-tramp
  :straight (:host github :repo "Ladicle/consult-tramp")
  :after consult
  :commands consult-tramp)

(use-package dired
  :straight nil
  :custom
  (dired-dwim-target t)
  (dired-hide-details-hide-symlink-targets nil)
  (dired-listing-switches "-alh")
  (dired-recursive-copies 'always)
  (dired-use-ls-dired nil)
  :hook (dired-mode . (lambda () (display-line-numbers-mode -1))))

(use-package diredfl
  :config (diredfl-global-mode 1))

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package dired-collapse
  :hook (dired-mode . dired-collapse-mode))

(use-package dired-narrow
  :bind (:map dired-mode-map
              ("/" . dired-narrow)))

(use-package symon
  :demand t
  :custom (symon-delay 2)
  :config (symon-mode 1))

(use-package flycheck :hook (prog-mode . flycheck-mode))
(use-package yasnippet :config (yas-global-mode 1))
(use-package yasnippet-snippets :after yasnippet)
(use-package treesit-auto
  :custom (treesit-auto-install 'prompt)
  :config (global-treesit-auto-mode 1))
(use-package apheleia :config (apheleia-global-mode 1))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-enable-file-watchers nil)
  (lsp-completion-provider :none)
  (lsp-headerline-breadcrumb-enable t)
  :init
  (defun my/lsp-mode-setup-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless)))
  :hook (lsp-completion-mode . my/lsp-mode-setup-completion))
(use-package lsp-ui :after lsp-mode :commands lsp-ui-mode)
(use-package lsp-treemacs :after lsp-mode)
(use-package dap-mode :after lsp-mode :commands dap-debug)

(use-package flycheck
  :demand t
  :custom
  (flycheck-check-syntax-automatically '(save mode-enabled))
  (flycheck-display-errors-delay 0.3)
  :config
  (global-flycheck-mode 1))

(use-package flycheck-pos-tip
  :after flycheck
  :demand t
  :config
  (flycheck-pos-tip-mode 1))

(use-package flycheck-elsa
  :after flycheck
  :demand t)

(use-package flycheck-projectile
  :after (flycheck projectile)
  :commands flycheck-projectile-list-errors)


(use-package avy
  :bind (("M-g c" . avy-goto-char-timer)
         ("M-g w" . avy-goto-word-1)
         ("M-g l" . avy-goto-line)))

(use-package avy-zap
  :after avy
  :bind (("M-z" . avy-zap-to-char)
         ("M-Z" . avy-zap-up-to-char)))

(use-package expand-region
  :bind (("C-=" . er/expand-region)
         ("C--" . er/contract-region)))

(use-package multiple-cursors
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)
         ("C-c C-RET" . mc/edit-lines)))

(use-package python :straight nil :hook (python-ts-mode . lsp-deferred))
(use-package go-mode :mode "\\.go\\'" :hook (go-mode . lsp-deferred))
(use-package rust-mode
  :mode "\\.rs\\'"
  :custom (rust-format-on-save t)
  :hook (rust-mode . lsp-deferred))

(use-package typescript-mode :mode "\\.ts\\'" :hook (typescript-mode . lsp-deferred))
(use-package web-mode
  :mode (("\\.tsx\\'" . web-mode)
         ("\\.jsx\\'" . web-mode)
         ("\\.svelte\\'" . web-mode))
  :hook (web-mode . lsp-deferred))
(use-package svelte-mode :mode "\\.svelte\\'" :hook (svelte-mode . lsp-deferred))

(use-package yaml-mode :mode "\\.ya?ml\\'" :hook (yaml-mode . lsp-deferred))
(use-package toml-mode :mode "\\.toml\\'" :hook (toml-mode . lsp-deferred))
(use-package json-mode :mode "\\.json\\'" :hook (json-mode . lsp-deferred))
(use-package lua-mode :mode "\\.lua\\'" :hook (lua-mode . lsp-deferred))

(use-package erlang :mode "\\.erl\\'" :hook (erlang-mode . lsp-deferred))
(use-package elixir-mode :mode "\\.exs?\\'" :hook (elixir-mode . lsp-deferred))
(use-package gleam-ts-mode :mode "\\.gleam\\'" :hook (gleam-ts-mode . lsp-deferred))
(use-package haskell-mode :mode "\\.hs\\'" :hook (haskell-mode . lsp-deferred))
(use-package tuareg :mode "\\.mli?\\'" :hook (tuareg-mode . lsp-deferred))
(use-package kotlin-mode :mode "\\.kts?\\'" :hook (kotlin-mode . lsp-deferred))

(use-package sql :straight nil :hook (sql-mode . lsp-deferred))
(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode) ("\\.md\\'" . markdown-mode))
  :hook (markdown-mode . lsp-deferred))
(use-package typst-ts-mode :mode "\\.typ\\'" :hook (typst-ts-mode . lsp-deferred))

(use-package zig-mode
  :mode "\\.zig\\'"
  :custom (zig-format-on-save nil)
  :hook (zig-mode . lsp-deferred))

(defun my/ansible-maybe-enable ()
  "Enable Ansible support for YAML files in conventional Ansible paths."
  (when (and buffer-file-name
             (string-match-p
              (rx (or "playbook" "/roles/" "/ansible/"))
              (downcase buffer-file-name)))
    (ansible-mode 1)))

(use-package ansible
  :hook (yaml-mode . my/ansible-maybe-enable))
(use-package ansible-doc :after ansible)

(use-package apache-mode
  :mode (("/\\.htaccess\\'" . apache-mode)
         ("/apache2/.*\\.conf\\'" . apache-mode)
         ("/httpd/conf/.*\\.conf\\'" . apache-mode)))
(use-package bazel :mode (("/BUILD\\(?:\\.bazel\\)?\\'" . bazel-mode)
                          ("/WORKSPACE\\'" . bazel-mode)
                          ("\\.bzl\\'" . bazel-mode)))
(use-package conf-mode :straight nil :mode ("\\.cnf\\'" . conf-mode))
(use-package csv-mode :mode (("\\.csv\\'" . csv-mode) ("\\.tsv\\'" . csv-mode)))

(use-package docker-compose-mode
  :mode (("compose\\.ya?ml\\'" . docker-compose-mode)
         ("docker-compose.*\\.ya?ml\\'" . docker-compose-mode)))
(use-package dockerfile-mode
  :mode (("Dockerfile.*\\'" . dockerfile-mode)
         ("\\.dockerfile\\'" . dockerfile-mode)))
(use-package elm-mode :mode "\\.elm\\'" :hook (elm-mode . lsp-deferred))
(use-package fish-mode :mode (("\\.fish\\'" . fish-mode) ("/config\\.fish\\'" . fish-mode)))

(use-package hcl-mode :mode (("\\.hcl\\'" . hcl-mode) ("\\.tfvars\\'" . hcl-mode)))
(use-package ini-mode :mode "\\.ini\\'")
(use-package just-mode :mode (("/[Jj]ustfile\\'" . just-mode) ("\\.just\\'" . just-mode)))

(use-package k8s-mode
  :mode (("/k8s/.*\\.ya?ml\\'" . k8s-mode)
         ("/kubernetes/.*\\.ya?ml\\'" . k8s-mode)
         ("/manifests/.*\\.ya?ml\\'" . k8s-mode))
  :init
  (add-to-list 'magic-mode-alist
               '("\\(?:---[[:space:]]*\\)?apiVersion:[[:space:]]" . k8s-mode))
  :custom (k8s-indent-offset 2)
  :hook ((k8s-mode . yas-minor-mode)
         (k8s-mode . lsp-deferred)))

(defun my/helm-template-maybe-enable ()
  "Enable Go template highlighting inside a Helm chart."
  (when (and buffer-file-name
             (locate-dominating-file buffer-file-name "Chart.yaml"))
    (go-template-helper-mode 1)))

(use-package go-template-helper-mode
  :hook ((yaml-mode . my/helm-template-maybe-enable)
         (k8s-mode . my/helm-template-maybe-enable)))
(use-package kubernetes-helm
  :commands (kubernetes-helm-template kubernetes-helm-install
             kubernetes-helm-upgrade kubernetes-helm-status))
(use-package kubernetes :commands kubernetes-overview)

(use-package mermaid-mode :mode (("\\.mmd\\'" . mermaid-mode) ("\\.mermaid\\'" . mermaid-mode)))
(use-package make-mode :straight nil :mode ("\\.mk\\'" . makefile-mode))
(use-package nginx-mode
  :mode (("nginx\\.conf\\'" . nginx-mode)
         ("/nginx/.*\\.conf\\'" . nginx-mode)))
(use-package scss-mode :mode (("\\.scss\\'" . scss-mode) ("\\.sass\\'" . scss-mode)))

(use-package ssh-config-mode
  :mode (("/\\.ssh/config\\(?:\\.d/.*\\.conf\\)?\\'" . ssh-config-mode)
         ("/sshd?_config\\(?:\\.d/.*\\.conf\\)?\\'" . ssh-config-mode)
         ("/known_hosts\\'" . ssh-known-hosts-mode)
         ("/authorized_keys2?\\'" . ssh-authorized-keys-mode)))
(use-package syslog-mode :mode "\\.log\\'")
(use-package systemd
  :mode (("\\.\\(?:service\\|timer\\|socket\\|mount\\|target\\|path\\|slice\\|scope\\|nspawn\\)\\'"
          . systemd-mode)))
(use-package terraform-mode :mode "\\.tf\\'" :hook (terraform-mode . lsp-deferred))
(use-package tmux-mode :mode (("\\.tmux\\.conf\\'" . tmux-mode) ("/tmux\\.conf\\'" . tmux-mode)))

(use-package org
  :straight nil
  :mode ("\\.org\\'" . org-mode)
  :custom
  (org-directory (expand-file-name "~/00.orgs"))
  (org-agenda-files (list org-directory))
  (org-default-notes-file (expand-file-name "inbox.org" org-directory))
  (org-log-done 'time)
  (org-startup-indented t)
  (org-hide-emphasis-markers t)
  (org-return-follows-link t)
  :config
  (setq org-capture-templates
        '(("t" "Todo" entry (file+headline org-default-notes-file "Inbox")
           "* TODO %?\n  %U\n  %a")
          ("n" "Note" entry (file+headline org-default-notes-file "Notes")
           "* %?\n  %U\n  %a"))))

(use-package org-modern :hook (org-mode . org-modern-mode))

(use-package org-roam
  :custom
  (org-roam-directory (file-truename (expand-file-name "roam" org-directory)))
  (org-roam-db-location (expand-file-name "org-roam.db" no-littering-var-directory))
  :bind (("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture))
  :config (org-roam-db-autosync-mode 1))

(defun my/org-roam-rg ()
  "Search all Org-roam notes using ripgrep and Consult."
  (interactive)
  (consult-ripgrep org-roam-directory))

(add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e")
(use-package mu4e
  :straight nil
  :commands mu4e
  :custom
  (mu4e-maildir (expand-file-name "~/Mail"))
  (mu4e-get-mail-command "mbsync -a")
  (mu4e-update-interval 300)
  (mu4e-change-filenames-when-moving t)
  (mu4e-compose-format-flowed t)
  (message-send-mail-function 'message-send-mail-with-sendmail)
  (sendmail-program (or (executable-find "msmtp") "msmtp"))
  (message-sendmail-extra-arguments '("--read-envelope-from"))
  (message-sendmail-f-is-evil t))
(use-package mu4e-alert :after mu4e :config (mu4e-alert-enable-mode-line-display))

(use-package elfeed
  :commands elfeed
  :custom (elfeed-db-directory (expand-file-name "elfeed" no-littering-var-directory)))
(use-package elfeed-org
  :after elfeed
  :custom (rmh-elfeed-org-files (list (expand-file-name "feeds.org" org-directory)))
  :config (elfeed-org))

(use-package dashboard
  :demand t
  :custom
  (dashboard-startup-banner 'logo)
  (dashboard-center-content t)
  (dashboard-items '((recents . 8) (projects . 5) (agenda . 5)))
  :config (dashboard-setup-startup-hook))

(when my/is-wsl
  (setq browse-url-generic-program "wslview"
        browse-url-browser-function
        (if (executable-find "wslview") #'browse-url-generic #'browse-url-default-browser)))

(when my/is-windows
  (setq w32-pass-lwindow-to-system nil
        w32-lwindow-modifier 'super))

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %.2fs with %d GCs"
                     (float-time (time-subtract after-init-time before-init-time))
                     gcs-done)))

;;; init.el ends here
