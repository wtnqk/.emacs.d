(use-package mozc
  :ensure nil
  :demand t
  :custom (default-input-method "japanese-mozc"))

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
     "s e" '(flycheck-projectile-list-errors :which-key "project errors")
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

(autoload 'org-babel-tangle "ob-tangle" nil t)

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
         ("C-h B" . embark-bindings))
  :config
  ;; 候補をウィンドウを選んで開く / 分割して開くアクション（takeokunn流）
  (defmacro my/embark-ace-action (fn)
    `(defun ,(intern (concat "my/embark-ace-" (symbol-name fn))) ()
       (interactive)
       (with-demoted-errors "%s"
         (aw-switch-to-window (aw-select nil))
         (call-interactively (symbol-function ',fn)))))

  (defmacro my/embark-split-action (fn split-type)
    `(defun ,(intern (concat "my/embark-"
                             (symbol-name fn)
                             "-"
                             (car (last (split-string
                                         (symbol-name split-type) "-"))))) ()
       (interactive)
       (funcall #',split-type)
       (call-interactively #',fn)))

  ;; ace-window: 候補を任意ウィンドウへ
  (define-key embark-file-map     (kbd "o") (my/embark-ace-action find-file))
  (define-key embark-buffer-map   (kbd "o") (my/embark-ace-action switch-to-buffer))
  (define-key embark-bookmark-map (kbd "o") (my/embark-ace-action bookmark-jump))

  ;; split window (2: 下に分割、3: 右に分割)
  (define-key embark-file-map     (kbd "2") (my/embark-split-action find-file split-window-below))
  (define-key embark-buffer-map   (kbd "2") (my/embark-split-action switch-to-buffer split-window-below))
  (define-key embark-bookmark-map (kbd "2") (my/embark-split-action bookmark-jump split-window-below))

  (define-key embark-file-map     (kbd "3") (my/embark-split-action find-file split-window-right))
  (define-key embark-buffer-map   (kbd "3") (my/embark-split-action switch-to-buffer split-window-right))
  (define-key embark-bookmark-map (kbd "3") (my/embark-split-action bookmark-jump split-window-right)))
(use-package embark-consult :after (embark consult))
(use-package affe :commands (affe-find affe-grep))

;; wgrep: *grep*バッファを直接編集し、変更を各ファイルへ一括適用できるようにする。
;; grep-modeの起動時にwgrep-setupでwgrep-modeを有効化する。
(use-package wgrep
  :hook (grep-setup-hook . wgrep-setup))

(use-package corfu
  :demand t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-cycle t)
  (corfu-on-exact-match nil)
  (corfu-preselect 'prompt)
  :config
  (global-corfu-mode 1))
(use-package cape
  :demand t
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'cape-history)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

(use-package prescient
  :demand t
  :custom (prescient-aggressive-file-save t)
  :config (prescient-persist-mode 1))

(use-package kind-icon
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(setq tab-always-indent 'complete)

(use-package project :straight nil)
(use-package magit
  :commands magit-status
  :custom
  (magit-diff-refine-hunk 'all)
  (magit-diff-paint-whitespace 'untrailing)
  (magit-display-buffer-function #'magit-display-buffer-fullcolumn-most-v1))
(use-package difftastic
  :demand t
  :custom (difftastic-executable (or (executable-find "difft") "difft"))
  :config
  (require 'difftastic-bindings)
  (difftastic-bindings-mode 1))
(use-package git-modes)
(use-package magit-gitflow
  :after magit)
(use-package git-messenger
  :commands git-messenger)
(use-package git-link
  :commands git-link)
(declare-function diff-hl-magit-post-refresh "diff-hl-magit")

(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode))
  :config
  (with-eval-after-load 'magit
    (when (require 'diff-hl-magit nil t)
      (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))))
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

;; wdired: Diredバッファでファイル名やpermissionを直接編集できるようにする。
;; Emacs標準機能のため取得は不要。diredで「r」を押すと編集モードに入る。
(use-package wdired
  :straight nil
  :custom (wdired-allow-to-change-permissions 'advanced)
  :bind (:map dired-mode-map
              ("r" . wdired-change-to-wdired-mode)))

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

;; winner-mode: ウィンドウ分割・サイズ変更の履歴を undo/redo する（Emacs標準）。
(use-package winner
  :straight nil
  :demand t
  :config
  (winner-mode 1)
  (global-set-key (kbd "C-c <left>")  #'winner-undo)
  (global-set-key (kbd "C-c <right>") #'winner-redo))

;; ace-window: 番号/キーで任意のウィンドウへ高速移動。標準の C-x o（次ウィンドウ）を置き換える。
(use-package ace-window
  :bind (("C-x o" . ace-window))
  :custom
  (aw-dispatch-always t)
  (aw-scope 'frame)
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (aw-minibuffer-flag t))

;; zoom-window: 現在のウィンドウを一時的に最大化する。
(use-package zoom-window
  :commands zoom-window-zoom
  :bind (("C-c C-z" . zoom-window-zoom)))

;; tab-bar: プロジェクト単位でタブ（ワークスペース）を管理し、タブをプロジェクト名で自動リネームする。
(use-package tab-bar
  :straight nil
  :demand t
  :bind-keymap (("C-x C-t" . tab-prefix-map))
  :custom
  (tab-bar-close-button-show nil)
  (tab-bar-close-last-tab-choice nil)
  (tab-bar-close-tab-select 'left)
  (tab-bar-new-tab-choice "*scratch*")
  (tab-bar-new-button-show nil)
  (tab-bar-tab-name-truncated-max 12)
  (tab-bar-separator " | ")
  :config
  (tab-bar-mode 1)
  (defun my/tab-bar-rename-tab (&rest _)
    (interactive)
    (let ((proj-name (if-let ((proj (project-current)))
                         (project-name proj)
                       "-")))
      (tab-bar-rename-tab proj-name)))
  (add-hook 'window-selection-change-functions #'my/tab-bar-rename-tab)
  (define-key tab-prefix-map (kbd "r") #'my/tab-bar-rename-tab))

;; treemacs: 右側のファイルツリー。プロジェクト追従・Git表示・状態永続化に対応。
(use-package treemacs
  :defer t
  :bind (("C-q" . treemacs))
  :config
  (treemacs-project-follow-mode 1)
  (treemacs-filewatch-mode 1)
  (treemacs-follow-mode 1)
  (treemacs-git-mode 'deferred)
  (setopt treemacs-width 50)
  (setopt treemacs-position 'right)
  (setopt treemacs-is-never-other-window t))

;; treemacs-tab-bar: tab-bar の各タブごとに独立した treemacs ワークスペースを持つ連携。
;; TABごとに treemacs バッファが異なるため、プロジェクト単位のワークスペースがタブと同期する。
(use-package treemacs-tab-bar
  :after (treemacs)
  :config (treemacs-set-scope-type 'Tabs))

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
(use-package yasnippet
  :demand t
  :custom (yas-snippet-dirs
           (list (expand-file-name "snippets" user-emacs-directory)))
  :config (yas-global-mode 1))
(use-package yasnippet-snippets :after yasnippet)
(use-package consult-yasnippet
  :demand t
  :bind (("C-c y" . consult-yasnippet)
         ("C-c C-y" . consult-yasnippet)))
(declare-function global-treesit-auto-mode "treesit-auto")

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
  (lsp-marksman-server-command (expand-file-name "~/.local/share/mise/installs/marksman/latest/marksman"))
  :init
  (defun my/lsp-mode-setup-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless)))
  :hook (lsp-completion-mode . my/lsp-mode-setup-completion))
(use-package lsp-ui :after lsp-mode :commands lsp-ui-mode)
(use-package lsp-treemacs :after lsp-mode)
(use-package dap-mode :after lsp-mode :commands dap-debug)

(use-package flymake-proc)

(with-eval-after-load 'flycheck
  (flycheck-define-checker textlint
    "A linter for prose."
    :command ("npx" "textlint" "--format" "unix" source-inplace)
    :error-patterns
    ((warning line-start (file-name) ":" line ":" column ": "
              (id (one-or-more (not (any " "))))
              (message (one-or-more not-newline)
                       (zero-or-more "\n" (any " ") (one-or-more not-newline)))
              line-end))
    :modes (org-mode))
  (add-to-list 'flycheck-checkers 'textlint))

(use-package flycheck-elsa
  :after flycheck
  :demand t
  :config
  (with-eval-after-load 'elisp-mode
    (add-hook 'emacs-lisp-mode-hook #'flycheck-elsa-setup)))

(use-package flycheck-projectile
  :after (flycheck projectile)
  :commands flycheck-projectile-list-errors)

(use-package cfn-mode
  :commands cfn-mode
  :config
  (add-to-list 'magic-mode-alist
               '("\\(?:---\\n\\)?AWSTemplateFormatVersion:" . cfn-mode)))

(use-package flycheck-cfn
  :after cfn-mode
  :commands flycheck-cfn-setup
  :hook (cfn-mode . flycheck-cfn-setup))

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

(use-package smartparens)

(use-package smart-jump
  :commands (smart-jump-go smart-jump-back smart-jump-references)
  :custom (smart-jump-bind-keys nil)
  :bind (("M-." . smart-jump-go)
         ("M-," . smart-jump-back)
         ("M-?" . smart-jump-references)))

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
(use-package textui
  :straight (:host github :repo "yibie/textui"))
(use-package md-mode
  :straight (:host github :repo "yibie/md-mode")
  :mode "\\.md\\'"
  :hook (md-mode . lsp-deferred)
  :custom
  (md-render-mermaid-enabled t)
  (md-render-mermaid-command (expand-file-name "~/.bun/bin/mmdc"))
  (md-render-mermaid-browser "/usr/sbin/google-chrome"))
(defcustom my/md-render-mermaid-scale 2
  "Scale factor passed to Mermaid CLI and included in its media cache key."
  :type '(number :validate
                 (lambda (widget)
                   (unless (> (widget-value widget) 0)
                     (widget-put widget :error "Scale must be positive")
                     widget)))
  :group 'md-render)

(defun my/md-render-media-command-with-mermaid-scale
    (original backend input file)
  "Call ORIGINAL for BACKEND, INPUT, and FILE, overriding Mermaid scale."
  (let ((result (funcall original backend input file)))
    (when (eq backend 'mermaid)
      (when-let ((scale-argument
                  (cdr (member "--scale" (car result)))))
        (setcar scale-argument
                (number-to-string my/md-render-mermaid-scale))))
    result))

(defun my/md-render-media-cache-file-with-mermaid-scale
    (original backend source)
  "Call ORIGINAL for BACKEND and SOURCE with Mermaid scale in the cache key."
  (funcall original backend
           (if (eq backend 'mermaid)
               (concat source "\0my/md-render-mermaid-scale="
                       (number-to-string my/md-render-mermaid-scale))
             source)))

(with-eval-after-load 'md-render-media
  (unless (advice-member-p
           #'my/md-render-media-command-with-mermaid-scale
           'md-render--media-command)
    (advice-add 'md-render--media-command :around
                #'my/md-render-media-command-with-mermaid-scale))
  (unless (advice-member-p
           #'my/md-render-media-cache-file-with-mermaid-scale
           'md-render--media-cache-file)
    (advice-add 'md-render--media-cache-file :around
                #'my/md-render-media-cache-file-with-mermaid-scale)))

(with-eval-after-load 'lsp-mode
  (add-to-list 'lsp-language-id-configuration
               '(md-mode . "markdown")))
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

(declare-function my/org-week-monday "init")
(declare-function my/org-daily-files-this-week "init")
(declare-function my/org-extract-heading-body "init")
(declare-function my/org-month-string "init")
(declare-function my/org-daily-files-in-month "init")
(declare-function my/org-monthly-aggregate "init")
(declare-function my/org-capture-monthly-aggregate "init")
(declare-function my/org-archive-last-month-dailies "init")

(defcustom my/org-hugo-base-dir
    (expand-file-name "hugo" (or (bound-and-true-p org-directory) "~/00.orgs"))
  "Root directory of the Hugo site used by ox-hugo."
  :type 'directory
  :group 'org)

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
  (org-clock-into-drawer t)
  (org-clock-out-when-done t)
  (org-clock-persist 'history)
  :config
  (org-clock-persistence-insinuate)
  (defun my/org-capture-daily-file ()
    "Return today's daily report file path, creating the directory if needed.

When the calendar month has rolled over, archive the previous month's
daily reports first (aggregate into monthly/ and move files to archive/)."
    (my/org-archive-last-month-dailies)
    (expand-file-name (format-time-string "daily/%Y-%m-%d.org") org-directory))
  (defun my/org-capture-weekly-file ()
    "Return this week's weekly report file path."
    (expand-file-name (format-time-string "weekly/%G-W%V.org") org-directory))
  (defun my/org-capture-monthly-file ()
    "Return this month's monthly report file path."
    (expand-file-name (format-time-string "monthly/%Y-%m.org") org-directory))
  (defun my/org-capture-meeting-file ()
    "Return a new timestamped meeting note file path."
    (expand-file-name (format-time-string "meetings/%Y-%m-%d-%H%M.org") org-directory))
  (defun my/org-capture-project-file ()
    "Return a new timestamped project note file path."
    (expand-file-name (format-time-string "projects/%Y-%m-%d-%H%M.org") org-directory))
  (defun my/org-capture-tech-note-file ()
    "Return a new timestamped tech note file path."
    (expand-file-name (format-time-string "notes/%Y-%m-%d-%H%M.org") org-directory))
  (defun my/org-entry-has-date-p (property date)
    "Return non-nil when PROPERTY on the current entry matches DATE."
    (when-let ((timestamp (org-entry-get nil property)))
      (condition-case nil
          (equal date
                 (format-time-string "%Y-%m-%d"
                                     (org-time-string-to-time timestamp)))
        (error nil))))
  (defun my/org-today-todos ()
    "Return today's scheduled or deadline TODOs as linked Org headings."
    (let ((date (format-time-string "%Y-%m-%d"))
          entries)
      (dolist (file (org-agenda-files))
        (when (file-readable-p file)
          (with-current-buffer (find-file-noselect file)
            (org-with-wide-buffer
             (org-map-entries
              (lambda ()
                (when (and (member (org-get-todo-state) org-not-done-keywords)
                           (or (my/org-entry-has-date-p "SCHEDULED" date)
                               (my/org-entry-has-date-p "DEADLINE" date)))
                  (push
                   (format "** TODO [[file:%s::%d][%s]]"
                           (expand-file-name file)
                           (line-number-at-pos)
                           (org-get-heading t t t t))
                   entries)))
              nil 'file)))))
      (if entries
          (mapconcat #'identity (nreverse entries) "\n")
        "** （今日のAgendaに未完了TODOはありません）")))
  (defun org-dblock-write:agenda (_params)
    "Write today's scheduled and deadline TODOs into an Org dynamic block."
    (insert (my/org-today-todos)))
  (defun my/org-capture-daily-template ()
    "Return the daily template with fixed work-item headings inserted."
    (with-temp-buffer
      (insert-file-contents
       (expand-file-name "templates/daily-report.org" org-directory))
      (goto-char (point-min))
      (when (re-search-forward "^\\* 今日やったこと[ \t]*$" nil t)
        (forward-line 1)
        (insert-file-contents
         (expand-file-name "templates/work-items.org" org-directory))
        (insert "\n"))
      (buffer-string)))
  (defun my/org-capture-hugo-file ()
    "Return a new timestamped Hugo post file path."
    (let ((directory (expand-file-name "hugo/org" org-directory)))
      (make-directory directory t)
      (expand-file-name (format-time-string "%Y-%m-%d-%H%M.org") directory)))
  (defun my/org-week-monday (&optional time)
    "Return encoded time for Monday 00:00 of the ISO week containing TIME."
    (let* ((time (or time (current-time)))
           (dow (nth 6 (decode-time time)))
           (iso-dow (if (= dow 0) 7 dow))
           (today-midnight (apply #'encode-time
                                   (append '(0 0 0) (nthcdr 3 (decode-time time))))))
      (time-subtract today-midnight (days-to-time (1- iso-dow)))))
  (defun my/org-daily-files-this-week ()
    "Return daily report file paths whose date falls in the current ISO week, sorted."
    (let ((dir (expand-file-name "daily" org-directory)))
      (when (file-directory-p dir)
        (let* ((monday (time-convert (my/org-week-monday) 'integer))
               (sunday (+ monday (* 7 86400) -1)))
          (sort
           (seq-filter
            (lambda (f)
              (let* ((name (file-name-base f))
                     (parsed (ignore-errors
                               (encode-time 0 0 0
                                            (string-to-number (substring name 8 10))
                                            (string-to-number (substring name 5 7))
                                            (string-to-number (substring name 0 4))))))
                (and parsed
                     (let ((secs (time-convert parsed 'integer)))
                       (and (>= secs monday) (<= secs sunday))))))
            (directory-files dir t "\\`[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\.org\\'"))
           #'string<)))))
  (defun my/org-extract-heading-body (file heading)
    "Return trimmed body text under the first HEADING found in FILE."
    (when (file-exists-p file)
      (with-temp-buffer
        (insert-file-contents file)
        (goto-char (point-min))
        (when (re-search-forward (format "^\\*+[ \t]+%s[ \t]*$" (regexp-quote heading)) nil t)
          (forward-line 1)
          (let ((start (point))
                (end (save-excursion
                       (if (re-search-forward "^\\*+[ \t]" nil t)
                           (match-beginning 0)
                         (point-max)))))
            (string-trim (buffer-substring-no-properties start end)))))))
  (defun my/org-capture-weekly-aggregate ()
    "Build an aggregated Org string from this week's daily reports."
    (let ((files (my/org-daily-files-this-week)))
      (if (null files)
          "（今週のdailyファイルが見つかりませんでした）"
        (mapconcat
         (lambda (f)
           (let ((body (my/org-extract-heading-body f "今日やったこと")))
             (format "** %s\n%s"
                     (file-name-base f)
                     (if (and body (not (string-empty-p body))) body "  (記載なし)"))))
         files
         "\n\n"))))
  (defun my/org-month-string (&optional time)
    "Return the month (YYYY-MM) containing TIME, defaulting to now."
    (format-time-string "%Y-%m" (or time (current-time))))
  (defun my/org-previous-month-year-month ()
    "Return (YEAR MONTH) for the month preceding the current month."
    (let* ((dt (decode-time (current-time)))
           (year (nth 5 dt))
           (month (nth 4 dt)))
      (if (= month 1)
          (list (1- year) 12)
        (list year (1- month)))))
  (defun my/org-daily-files-in-month (year month)
    "Return sorted daily report file paths whose date falls in YEAR-MONTH."
    (let ((dir (expand-file-name "daily" org-directory)))
      (when (file-directory-p dir)
        (sort (directory-files dir t
                               (format "\\`%04d-%02d-[0-9]\\{2\\}\\.org\\'" year month))
              #'string<))))
  (defun my/org-monthly-aggregate (ym)
    "Build an aggregated Org string from the daily reports of month YM (YYYY-MM)."
    (let* ((year (string-to-number (substring ym 0 4)))
           (month (string-to-number (substring ym 5 7)))
           (files (my/org-daily-files-in-month year month)))
      (if (null files)
          "（対象月のdailyファイルが見つかりませんでした）"
        (mapconcat
         (lambda (f)
           (let ((body (my/org-extract-heading-body f "今日やったこと")))
             (format "** %s\n%s"
                     (file-name-base f)
                     (if (and body (not (string-empty-p body))) body "  (記載なし)"))))
         files
         "\n\n"))))
  (defun my/org-capture-monthly-aggregate ()
    "Build an aggregated Org string from the current month's daily reports."
    (my/org-monthly-aggregate (my/org-month-string)))
  (defun my/org-archive-last-month-dailies ()
    "Aggregate last month's daily reports into monthly/YYYY-MM.org, then move
the daily files to archive/daily/YYYY-MM/. Idempotent per month."
    (interactive)
    (let* ((pair (my/org-previous-month-year-month))
           (year (car pair))
           (month (cadr pair))
           (ym (format "%04d-%02d" year month))
           (monthly-file (expand-file-name (format "monthly/%s.org" ym) org-directory))
           (archive-dir (expand-file-name (format "archive/daily/%s" ym) org-directory))
           (files (my/org-daily-files-in-month year month)))
      (when files
        ;; 1. Create the monthly aggregate file if it does not yet exist.
        (unless (file-exists-p monthly-file)
          (make-directory (file-name-directory monthly-file) t)
          (with-temp-file monthly-file
            (insert (format "#+title: 月報: %s\n#+date: %s-01\n\n* 今月の成果\n\n%s\n"
                            ym ym (my/org-monthly-aggregate ym)))))
        ;; 2. Move that month's daily files into the archive folder.
        (make-directory archive-dir t)
        (dolist (f files)
          (rename-file f (expand-file-name (file-name-nondirectory f) archive-dir) t))
        (message "日報(%s)を月報へ集約し archive へ移動しました" ym))))
  (setq org-capture-templates
        `(("t" "Todo" entry (file+headline org-default-notes-file "Inbox")
           "* TODO %?\n  %U\n  %a")
           ("n" "Note" entry (file+headline org-default-notes-file "Notes")
            "* %?\n  %U\n  %a")
           ("N" "New file from template")
           ("Nd" "Daily Report" plain (file my/org-capture-daily-file)
            (function my/org-capture-daily-template))
           ("Nw" "Weekly Report" plain (file my/org-capture-weekly-file)
           (file ,(expand-file-name "templates/weekly-report.org" org-directory)))
           ("Ng" "Monthly Report" plain (file my/org-capture-monthly-file)
           (file ,(expand-file-name "templates/monthly-report.org" org-directory)))
          ("Nm" "Meeting" plain (file my/org-capture-meeting-file)
           (file ,(expand-file-name "templates/meeting.org" org-directory)))
           ("Np" "Project" plain (file my/org-capture-project-file)
            (file ,(expand-file-name "templates/project.org" org-directory)))
           ("Nn" "Tech Note" plain (file my/org-capture-tech-note-file)
            (file ,(expand-file-name "templates/tech-note.org" org-directory)))
           ("Nh" "Hugo Post" plain (file my/org-capture-hugo-file)
            (file ,(expand-file-name "templates/hugo-post.org" org-directory)))))
  ;; .orgを開くたびに、月替わり分の日報を自動集約してアーカイブする。
  (my/org-archive-last-month-dailies))

(defun my/org-archive-dailies-on-startup ()
  "Archive last month's daily reports on Emacs startup."
  (require 'org)
  (when (fboundp 'my/org-archive-last-month-dailies)
    (my/org-archive-last-month-dailies)))
(add-hook 'after-init-hook #'my/org-archive-dailies-on-startup)

(use-package ox-hugo
  :after ox
  :commands (org-hugo-export-as-md
             org-hugo-export-to-md
             org-hugo-export-wim-to-md
             org-hugo-debug-info)
  :custom
  (org-hugo-base-dir my/org-hugo-base-dir)
  (org-hugo-auto-set-lastmod t))

(use-package ox-confluence-html
  :straight (ox-confluence-html
             :type git
             :host github
             :repo "Gchouchou/ox-confluence-html")
  :after ox
  :demand t)

(use-package org-modern
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda)))

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
  (mu4e-split-view 'horizontal)
  (message-send-mail-function 'message-send-mail-with-sendmail)
  (sendmail-program (or (executable-find "msmtp") "msmtp"))
  (message-sendmail-extra-arguments '("--read-envelope-from"))
  (message-sendmail-f-is-evil t))
(use-package mu4e-alert :after mu4e :config (mu4e-alert-enable-mode-line-display))

(use-package elfeed
  :commands elfeed
  :custom
  (elfeed-db-directory (expand-file-name "elfeed" no-littering-var-directory))
  (elfeed-show-entry-switch #'display-buffer))
(use-package elfeed-org
  :after elfeed
  :custom (rmh-elfeed-org-files (list (expand-file-name "feeds.org" (or (bound-and-true-p org-directory) "~/00.orgs"))))
  :config (elfeed-org))

(defun my/dashboard-insert-daily-notes (list-size)
  "Insert a list of the most recent daily report files."
  (let* ((dir (expand-file-name "daily"
                                 (if (boundp 'org-directory)
                                     org-directory
                                   (expand-file-name "~/00.orgs"))))
         (files (when (file-directory-p dir)
                  (sort (directory-files dir t "\\.org\\'") #'string>)))
         (files (dashboard-subseq files list-size)))
    (dashboard-insert-section
     "Daily Reports:"
     files
     list-size
     'daily
     (dashboard-get-shortcut 'daily)
     `(lambda (&rest _) (find-file-existing ,el))
     (file-name-nondirectory el))))

(use-package dashboard
  :demand t
  :custom
  (dashboard-startup-banner 'logo)
  (dashboard-center-content t)
  (dashboard-items '((daily . 7) (recents . 8) (projects . 5) (agenda . 5)))
  :config
  (add-to-list 'dashboard-item-generators '(daily . my/dashboard-insert-daily-notes))
  (add-to-list 'dashboard-item-shortcuts '(daily . "d"))
  (dashboard-setup-startup-hook))

(when my/is-wsl
  (setq browse-url-generic-program "wslview"
        browse-url-browser-function
        (if (executable-find "wslview") #'browse-url-generic #'browse-url-default-browser)))

(when my/is-windows
  (setq w32-pass-lwindow-to-system nil
        w32-lwindow-modifier 'super))

(defun my/wsl-copy (text &optional _push)
  "Copy TEXT to the WSLg system clipboard without affecting the kill ring."
  (let ((wl-copy (executable-find "wl-copy")))
    (when (and wl-copy (stringp text))
      (with-temp-buffer
        (insert text)
        (ignore-errors
         (call-process-region (point-min) (point-max) wl-copy nil 0 nil
                              "--type" "text/plain;charset=utf-8"))))))

(defun my/wsl-paste ()
  "Return WSLg clipboard contents, or nil when unavailable."
  (let ((wl-paste (executable-find "wl-paste")))
    (when wl-paste
      (with-temp-buffer
        (let ((status (ignore-errors
                        (call-process wl-paste nil t nil "--no-newline"))))
          (when (and (integerp status) (zerop status))
            (buffer-string)))))))

(when my/is-wsl
 (setq interprogram-cut-function #'my/wsl-copy)
 (setq interprogram-paste-function #'my/wsl-paste))

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %.2fs with %d GCs"
                     (float-time (time-subtract after-init-time before-init-time))
                     gcs-done)))

;;; init.el ends here
