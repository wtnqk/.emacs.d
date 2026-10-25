;;; init.el -*- lexical-binding: t; -*-

;; Nix manages all Emacs packages. Keep the old straight.el forms working by
;; treating `:straight' as a no-op and never invoking straight at runtime.
(require 'use-package-core)
(defun use-package-normalize/:straight (_name _keyword args) args)
(defun use-package-handler/:straight (name _keyword _arg rest state)
  (use-package-process-keywords name rest state))
(add-to-list 'use-package-keywords :straight t)
(defun straight-use-package (&rest _args) nil)

(setq use-package-always-defer t
      use-package-expand-minimally t)

;; mozc_emacs_helper は Linux のみ Nix が供給する。
(unless (eq system-type 'darwin)
  (use-package mozc
    :ensure nil
    :demand t
    :custom (default-input-method "japanese-mozc")))

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
;; dired/dirvish バッファも自動更新の対象にする。既定(nil)だと
;; ファイル紐付けバッファだけが見張られ、一覧は g 押下まで古いまま。
;; Emacs 31 ではこの名前のコマンドは存在せず、変数は setq で直接たたく。
;; dired 系は auto-revert-interval（既定5秒）周期で追従する。
(setq global-auto-revert-non-file-buffers t)
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
     "e n" '(next-error :which-key "next error")
     "e p" '(previous-error :which-key "prev error")
     "e l" '(flycheck-list-errors :which-key "error list")
     "e f" '(my/lsp-diag-list :which-key "diagnostics (lspce/flycheck)")
     "l d" '(xref-find-definitions :which-key "definitions")
     "l r" '(xref-find-references :which-key "references")
     "l i" '(xref-find-implementations :which-key "implementations")
     "l s" '(my/lspce-workspace-symbol :which-key "workspace symbol")
     "l m" '(consult-imenu :which-key "imenu")
     "l a" '(my/lspce-code-actions :which-key "code action")
     "l n" '(my/lspce-rename :which-key "rename symbol")
     "l h" '(my/lspce-inlay-hints :which-key "inlay hints")
    "g g" '(magit-status :which-key "magit")
    "g d" '(difftastic-magit-diff :which-key "difftastic diff")
    "g t" '(git-timemachine :which-key "git time machine")
    "g m" '(git-messenger :which-key "git blame")
    "g l" '(git-link :which-key "git link")
    "t g" '(ghostel :which-key "terminal")
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
  :preface
  ;; Emacs 31 で旧 cl.el が削除され、key-combo.el:479 のトップレベル
  ;; `lexical-let' が void-function 化（require 自体が失敗する）していた。
  ;; 用途は 2 関数が 1 つの変数を共有するだけで、展開後の中身は
  ;; 単なるグローバル可変への読み書きなので、let への置換で意味的に等価。
  (defmacro lexical-let (bindings &rest body)
    "削除された旧 cl.el マクロの互換。`let' に展開する。"
    (declare (debug let) (indent let))
    `(let ,bindings ,@body))
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

;; Nix が供給する doom-everforest-theme をテーマ探索パスへ追加する。
(when-let ((theme (locate-library "doom-everforest-theme")))
  (add-to-list 'custom-theme-load-path (file-name-directory theme)))

;; doom-themes-base.el の face 表は gnus-group-news-low-empty へ
;; :inherit 'gnus-group-news-low を張るが、gnus 既定側は news-low へ
;; :inherit news-low-empty を張るため相互継承の輪になる（upstream 側の不具合）。
;; 両方が face-spec-map に揃うと、ポップアップ枠（corfu/posframe）作成時の
;; face 初期化で "Face inheritance results in inheritance cycle" が
;; signaling され、補完ウィンドウの生成が失敗し続けて *Messages* へ
;; バックトレースが流れ続ける。def-doom-theme はテーマロード時にこの表を
;; 展開するので、展開前に表側をパッチして :inherit を使わない
;; 「base5 色直書き・normal 太さ」（テーマの意図と同一の見た目）へ置換し、
;; 輪の生成そのものを無くす。下の use-package より前（＝テーマ展開前）に
;; 評価される位置に置くこと。
(with-eval-after-load 'doom-themes-base
  (when-let ((entry (assq 'gnus-group-news-low-empty doom-themes-base-faces)))
    (setcdr entry '(:foreground base5 :weight 'normal))))

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

(use-package dimmer
  :straight (dimmer :type git :host github :repo "gonewest818/dimmer.el")
  :demand t
  :custom
  (dimmer-fraction 0.3)
  ;; 前景色だけ落とす。背景を塗るモードだとdoom-modelineや
  ;; dirvishのペイン配色と喧嘩する。
  (dimmer-adjustment-mode :foreground)
  (dimmer-use-colorspace :cielab)
  :config
  (dimmer-mode t))

(use-package focus
  :straight (focus :type git :host github :repo "larstvei/Focus")
  :custom
  ;; カーソル移動のたびに再計算せず、少しまとめて更新させる。
  ;; 既定では無効。必要時は =M-x focus-mode= で buffer単位のトグル。
  (focus-update-idle-delay 0.2))

(use-package indent-guide
  :straight (indent-guide :type git :host github :repo "zk-phi/indent-guide")
  :demand t
  :custom
  (indent-guide-delay 0.1)
  ;; ▏(U+258F)はHackGen系にグリフが無く不可視化することがあるため、
  ;; どの等幅フォントにもあるボックス描画文字を使う。
  (indent-guide-char "│")
  ;; ネストした階段も描く（typescriptの深いネストで効く）。
  (indent-guide-recursive t)
  :config
  ;; everforestの背景(#2b3339)に対し明確に知覚できる段差の色。
  (set-face-foreground 'indent-guide-face "#5c6b72")
  ;; elispは括弧の刻みが細かくガイドがノイズになる。
  (add-to-list 'indent-guide-inhibit-modes 'emacs-lisp-mode)
  (add-to-list 'indent-guide-inhibit-modes 'org-mode)
  (indent-guide-global-mode 1))

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

;; docker-trampは廃止。Tramp 2.7以降に tramp-container として統合され、
;; Emacs 31同梱のTramp 2.8.2なら /usr/share/emacs/31.1/lisp/net/tramp-container.elc
;; がそのまま使える（docker/podman/kubectl/nerdctl/docker-compose）。
;; 接続文字列の意味が変わった点に注意:
;;   旧: /docker:HOST/CONTAINER:   （docker-tramp式）
;;   新: /docker:CONTAINER@HOST:   （tramp-container式。例 /docker:mybox@localhost:）

(use-package consult-tramp
  :straight (:host github :repo "Ladicle/consult-tramp")
  :after consult
  :commands consult-tramp
  :custom
  ;; consult-trampのコンテナ一覧は廃止済みdocker-tramp APIに依存するため無効化。
  ;; コンテナ内ファイルは /docker:名前@ホスト: を直接M-x find-fileする。
  (consult-tramp-enable-docker nil))

(use-package dired
  :straight nil
  :custom
  (dired-dwim-target t)
  (dired-hide-details-hide-symlink-targets nil)
  (dired-listing-switches "-alh")
  (dired-recursive-copies 'always)
  (dired-use-ls-dired nil)
  :hook (dired-mode . (lambda () (display-line-numbers-mode -1))))

;; dirvish: Diredの置き換え。ディレクトリバッファを「セッション」として扱い、
;; ヘッダにgit状態・履歴・タブ・絞り込みを内蔵する。MELPA未収録のためGitHub直取得。
;; 内蔵attrが nerd-icons-dired（アイコン）、dired-collapse（単子展開）、
;; dired-narrow（絞り込み）を兼ねるので、それらの単体導入は廃止した。
;; diredfl・wdired・diff-hlはdirvishと併用可能なのでそのまま。
;; dirvish-side はそれ自体がトグルコマンド（開→再押で選択→サイド側で再押で閉）。
;; サイドバーは treemacs と同じ右側に置く。
;; C-x d は素の dired ではなくフルフレームの dirvish セッションへ。
;; （override-dired-mode を入れても dired コマンド単体はレイアウトを
;; 組み立てないので、見た目が素 dired と変わらない。dirvish コマンドは
;; 既定で parent|一覧|preview の三ペインレイアウトを開く。C-u 付きで
;; ディレクトリ指定。窓を占有したくないときは M-x dirvish-dwim。）
(use-package dirvish
  :straight (:host github :repo "alexluigit/dirvish"
             :files (:defaults "extensions/*")
             :depends (f ht s nerd-icons))
  :init (dirvish-override-dired-mode)
  :custom
  (dirvish-side-display-alist '((side . right) (slot . 1)))
  (dirvish-side-width 40)
  ;; icons=nerd-icons、collapse=単一サブディレクトリの折り畳み、
  ;; file-size=duによるサイズ表示（SI/IEC可読形式）。
  (dirvish-attributes '(subtree-state nerd-icons collapse file-size))
  :bind
  ("C-c SPC t t" . dirvish-side)
  ("C-x d" . dirvish)
  ;; C-x 4 d（dired-other-window）を dirvish-dwim に置換。他の窓があれば
  ;; 選択窓だけ、無ければフルフレームになる dired 兼 dirvish。
  ("C-x 4 d" . dirvish-dwim)
  ;; 以下は dirvish 2.3.0 の現行コマンド名で統一（2024-10 時点、
  ;; 導入済みパッケージ内を grep して実在確認済み）。旧README由来の
  ;; dirvish-quick-visit / dirvish-filter-menu / dirvish-occur /
  ;; dirvish-sort-by-mtime / dirvish-tabs-* / dirvish-remove-buffer /
  ;; dirvish-backup-dir-menu / dirvish-subtree-state-toggle は
  ;; master で廃止・改名されており、バインドだと「Autoloading …
  ;; failed to define function」の原因になる（use-package の遅延
  ;; バインドがパッケージ本体を読み込んでシンボル確認するため）。
  (:map dirvish-mode-map
        ("/" . dirvish-narrow)
        ("a" . dirvish-quick-access)
        ("f" . dirvish-file-info-menu)
        ("y" . dirvish-yank-menu)
        ("^" . dired-up-directory)
        ("H" . dirvish-history-jump)
        ("h" . dirvish-history-go-backward)
        ("l" . dirvish-history-go-forward)
        ("n" . dired-next-line)
        ("p" . dired-previous-line)
        ("TAB" . dirvish-subtree-toggle)
        ;; q は upstream既定の dirvish-quit（フルフレームの復帰キー）。
        ("s" . dirvish-quicksort)
        ("F" . dirvish-emerge-menu)
        ("C-s" . consult-line)
        (">" . dirvish-side-increase-width)
        ("<" . dirvish-side-decrease-width)
        ;; ── 未設定だった便利機能の追補（2026-10） ──
        ;; SPC は dired-next-line の置換。同じ移動は n/p が担う。
        ;; { } ; は dirvish-mode-map で空いていた文字（dired 既定込みで走査）。
        ("SPC" . dirvish-dispatch)
        ("{" . dirvish-layout-switch)
        ("}" . dirvish-layout-toggle)
        (";" . dirvish-setup-menu)
        ;; 以下はバッファローカルの C-c 前語。dirvish-mode-map の C-c は
        ;; C-c C-l / C-c C-q 以外空いており、グローバルリーダー
        ;; C-c SPC とも競合しない。
        ("C-c /" . dirvish-fd)
        ("C-c m" . dirvish-mark-menu)
        ("C-c t" . dirvish-subtree-menu)
        ("C-c r" . dirvish-renaming-menu)
        ("C-c v" . dirvish-vc-menu)
        ("C-c a" . dirvish-chxxx-menu)
        ("C-c R" . dirvish-rsync)
        ("C-c h" . dirvish-history-menu)
        ("C-c c" . dirvish-dired-cheatsheet)
        ("C-c l" . dirvish-ls-switches-menu)
        ("C-c f" . dirvish-fd-switches-menu)
        ("C-c S" . dirvish-rsync-switches-menu)
        ("C-c w" . dirvish-copy-file-path)
        ("C-c W" . dirvish-copy-file-name)
        ("C-c o" . dirvish-find-file-true-path)
        ("C-c d" . dirvish-total-file-size)
         ;; ディレクトリ作成が +（dired既定）なので、対応するファイル作成。
         ;; dired-create-empty-file は Emacs 31 でも既定未バインド。
         ("C-c i" . dired-create-empty-file))
  ;; dirvish-masterの現行APIはこのグローバルマイナーモード（旧変数
  ;; dirvish-side-follow-buffer-fileは廃止済み）。サイドバーがカーソルの
  ;; ファイル／プロジェクトルートへ自動追従する。
  :config
  (dirvish-side-follow-mode 1)
  ;; dirvish-emerge 用の git 条件を2つ追加する（upstream の predicate は
  ;; recent/directories/files/symlinks/executables の6つだけで、git 系の
  ;; 条件は同梱されていない）。predicate はファイル毎に local-name /
  ;; full-name / type / attrs を引数として呼ばれるので、git を1ファイル
  ;; 1プロセスで起動すると listing 全体で遅くなる。リポジトリルートで
  ;; `git status --porcelain -z -uall' を1回だけ実行し、結果を短TTLで
  ;; キャッシュして参照する（コミット等で2秒以内に状態が変われば再取得）。
  (with-eval-after-load 'dirvish-emerge
    (defvar dirvish-emerge--git-status-cache
      (make-hash-table :test 'equal)
      "Cache of (ROOT . (STATUS-LIST . TIMESTAMP)) for git predicates.")
    (defun dirvish-emerge--git-status-list (root)
      "Return (REL-PATH . XY) pairs from `git status' below ROOT.
XY is the two-char porcelain status. Cached for 2 seconds."
      (let* ((now (float-time))
             (ent (gethash root dirvish-emerge--git-status-cache)))
        (if (and ent (< (- now (cdr ent)) 2.0))
            (car ent)
          (let* ((git (executable-find "git"))
                 (default-directory root)
                 (raw (when git
                        (with-temp-buffer
                          (ignore-errors
                            (process-file git nil (current-buffer) nil
                                          "status" "--porcelain" "-z" "-uall"))
                          (buffer-string)))))
            (let (acc pending-second)
              (dolist (entry (split-string (or raw "") "\0" t))
                (if pending-second
                    ;; rename/copy の2番目のエントリは移動先パスそのもの。
                    (push (cons entry "R") acc)
                  (push (cons (substring entry 3) (substring entry 0 2)) acc)
                  (when (string-match-p "[RC]" (substring entry 0 2))
                    (setq pending-second t))))
              (let ((result (nreverse acc)))
                (puthash root (cons result now)
                         dirvish-emerge--git-status-cache)
                result))))))
    (dirvish-emerge-define-predicate git-changed-files
      "Tracked files with uncommitted changes (staged or unstaged)."
      (when-let* ((dir (file-name-directory full-name))
                  (_guard (not (file-remote-p full-name)))
                  (root (locate-dominating-file dir ".git"))
                  (root (file-name-as-directory root))
                  (hit (assoc (file-relative-name full-name root)
                              (dirvish-emerge--git-status-list root))))
        (not (equal "??" (cdr hit)))))
    (dirvish-emerge-define-predicate git-untracked-files
      "Files not yet registered in Git (untracked)."
      (when-let* ((dir (file-name-directory full-name))
                  (_guard (not (file-remote-p full-name)))
                  (root (locate-dominating-file dir ".git"))
                  (root (file-name-as-directory root))
                  (hit (assoc (file-relative-name full-name root)
                              (dirvish-emerge--git-status-list root))))
        (equal "??" (cdr hit))))))

;; wdired: Diredバッファでファイル名やpermissionを直接編集できるようにする。
;; Emacs標準機能のため取得は不要。diredで「r」を押すと編集モードに入る。
;; oil.nvim型の「ステージ→一括適用」モデル:
;;   d = その行に打ち消し線で削除をステージ（この時点ではまだディスクは無傷。
;;       wdired外で押すと自動でwdiredに入り、以降 r/rename/a/新規作成も
;;       同じくステージ扱いになる）
;;   w = 削除・リネーム・新規作成を一括適用（oilの:w相当）
;;   q = 何も適用せず破棄して閉じる（oilのq相当）
(use-package wdired
  :straight nil
  :custom (wdired-allow-to-change-permissions 'advanced)
  :init
  ;; Emacs 31では confirm-kill-processes が廃止され、プロセス生存バッファの
  ;; killが常時yes/no確認になった（subr.elのprocess-kill-buffer-query-
  ;; function）。diff-hl等の内部一時バッファ（先頭が空白の名前）は
  ;; 無確認で殺し、shell等の目に見えるバッファは従来どおり確認する。
  (defun my/kill-buffer-process-query ()
    "内部（空白始まり名）バッファの確認を省略するkill確認関数。"
    (let ((process (get-buffer-process (current-buffer))))
      (or (not process)
          (not (memq (process-status process) '(run stop open listen)))
          (not (process-query-on-exit-flag process))
          (let ((name (buffer-name (current-buffer))))
            (or (eq ?\s (aref name 0))
                (yes-or-no-p
                 (format "Buffer %s has a running process; kill it? "
                         name)))))))
  (when (fboundp 'process-kill-buffer-query-function)
    (remove-hook 'kill-buffer-query-functions
                 #'process-kill-buffer-query-function)
    (add-hook 'kill-buffer-query-functions
              #'my/kill-buffer-process-query))
  (defface my/oil-strike '((t :inherit dired-flagged :strike-through t))
    "`my/oil-flag-delete' がステージした削除行の表示。"
    :group 'dired-faces)
  (defvar-local my/oil--deletes nil
    "`my/oil-flag-delete' が打った打ち消し線overlayのリスト（バッファローカル）。")
  (defun my/oil--any-flagged-p ()
    "バッファにdiredの削除フラグ（先頭 ?D）が1つでもあればt。"
    (save-excursion
      (goto-char (point-min))
      (catch 'hit
        (while (progn (skip-chars-forward " \t\n\r") (not (eobp)))
          (when (eq ?D (char-after (line-beginning-position)))
            (throw 'hit t))
          (forward-line 1))
        nil)))
  (defun my/oil-flag-delete ()
    "カーソル行のエントリをoil.nvim風に削除ステージする。
画面に打ち消し線が出るだけで、ディスクはまだ何も変わらない。同じ行で
もう一度押すと取消。wdired以外で押した場合は自動でwdired編集に入るため、
rename（行のテキスト編集）や a（ファイル作成）も同じ「w で一括適用」に
載る。適用は `my/wdired-apply'。"
    (interactive)
    (unless (or (derived-mode-p 'dired-mode) (eq major-mode 'wdired-mode))
      (user-error "Dired/dirvish バッファでのみ使えます"))
    ;; Emacs 31のwdiredは minor-mode変数を持たない（major-modeを
    ;; 'wdired-modeに差し替える実装）ため、状態はmajor-modeで見る。
    (unless (eq major-mode 'wdired-mode)
      (wdired-change-to-wdired-mode))
    (let* ((bol (line-beginning-position))
           (live (seq-filter #'overlay-buffer my/oil--deletes))
           (hit (seq-find (lambda (o)
                            (and (<= (overlay-start o) bol)
                                 (< bol (overlay-end o))))
                          live)))
      (if hit
          (progn
            (delete-overlay hit)
            (setq my/oil--deletes (delq hit my/oil--deletes)))
        (let ((name (dired-get-filename 'no-dir t))
              (file (dired-get-filename nil t)))
          (cond
           ((null file) (user-error "この行にファイル名がありません"))
           ((member name '("." "..")) (user-error "%s は削除できません" name))
           (t
            ;; 絶対パスをステージ時点での名前としてオーバーレイに保持。
            ;; 適用前に同じ行をリネームしても、削除対象は元の名のまま。
            (let ((o (make-overlay bol (line-end-position) nil t t)))
              (overlay-put o 'face 'my/oil-strike)
              (overlay-put o 'priority 90)
              (overlay-put o 'my/oil-file file)
              (push o my/oil--deletes))))))))
  (defun my/wdired-apply ()
    "wdired バッファでステージされた変更をまとめて適用する（oilの:w）。
打ち消し線ステージ分の削除を先に実ファイルへ適用し、続けて
`wdired-finish-edit' を走らせるので、削除とリネームと新規作成が1回のwで
同時に効く。wdired外では、diredフラグ（?D）が残っていれば
`dired-do-flagged-delete'、無ければ本来の
`dired-copy-filename-as-kill'（ファイル名コピー）にフォールバックする。"
    (interactive)
    (cond
     ((eq major-mode 'wdired-mode)
      ;; Emacs 31のwdiredは「行そのものの削除」を削除として検出しない
      ;; （ファイル名テキストの空欄化のみが files-deleted に入り、
      ;; さらに finish-edit 中の revert で行が復活する）。そのため
      ;; 削除はここで dired の削除機構を直接適用してしまう。
      ;; ステージ時の絶対パスをオーバーレイから取るため、適用前に
      ;; 行をリネームしていても削除対象は元のファイル名のまま。
      (let ((fails 0))
        (dolist (ov (sort (seq-filter #'overlay-buffer my/oil--deletes)
                          (lambda (a b) (> (overlay-start a) (overlay-start b)))))
          (when-let ((file (overlay-get ov 'my/oil-file)))
            (condition-case err
                (dired-delete-file file dired-recursive-deletes
                                   delete-by-moving-to-trash)
              ((debug error)
               (cl-incf fails)
               (dired-log "Failed to delete %s:\n%s\n"
                          file (error-message-string err)))))
          (delete-overlay ov))
        (setq my/oil--deletes nil)
        (when (> fails 0)
          (message "%d 件の削除に失敗（*Dired log* 参照）" fails)))
      (wdired-finish-edit))
     ((my/oil--any-flagged-p)
      (dired-do-flagged-delete))
     (t
      (call-interactively #'dired-copy-filename-as-kill))))
  (defun my/wdired-abort-quit ()
    "変更を一切適用せず破棄して閉じる（oilのq）。
ステージ済みの削除・リネーム・新規作成はすべてディスクに触れずに消える。
dirvishセッション内なら `dirvish-quit'、そうでなければ窓を閉じる。"
    (interactive)
    (unless (eq major-mode 'wdired-mode)
      (user-error "wdired 編集モードではありません"))
    (dolist (ov my/oil--deletes)
      (when (overlay-buffer ov)
        (delete-overlay ov)))
    (setq my/oil--deletes nil)
    (wdired-abort-changes)
    (cond
     ((and (fboundp 'dirvish-curr) (dirvish-curr)) (dirvish-quit))
     ((one-window-p t) (bury-buffer))
     (t (quit-window 'kill))))
  :bind (:map dired-mode-map
              ("r" . wdired-change-to-wdired-mode)
              ("d" . my/oil-flag-delete)
              ("w" . my/wdired-apply))
       (:map wdired-mode-map
              ("d" . my/oil-flag-delete)
              ("w" . my/wdired-apply)
              ("q" . my/wdired-abort-quit)
              ("a" . dired-create-empty-file)))

(use-package diredfl
  :config (diredfl-global-mode 1))

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
;; 導線（リーダー t t）は dirvish-side へ移行済み。ここは設定のみ残置し、
;; M-x treemacs で従来通り呼び出せる（tab-bar連携の設定もそのまま有効）。
(use-package treemacs
  :defer t
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

;; consult-flycheck: consult repo 同梱の診断一覧（vertico/orderless/marginalia 乗り）。
;; leader =e f= の非LSPバッファ側フォールバックで使う。
(use-package consult-flycheck :straight t :defer t)

;; 窓を割らないfloat系ヘルパー。このEmacs 31.1ビルドにはtooltip-show-at-pointが
;; 無いので、tooltip-frame-parametersのleft/topでカーソル位置に置く。
(defun my/tooltip-at-point (text)
  "カーソル付近にTEXTのツールチップをfloat表示する（窓は割らない）。"
  (require 'tooltip nil t)
  (if (not (and (display-graphic-p) (fboundp 'tooltip-show)))
      (message "%s" (string-trim text))
    (condition-case nil
        (let ((tooltip-frame-parameters
               (append (when (fboundp 'x-window-pixel-position)
                         (let ((xy (x-window-pixel-position)))
                           `((left . ,(car xy)) (top . ,(1+ (cdr xy))))))
                       tooltip-frame-parameters)))
          (tooltip-show text))
      ((debug error) (message "%s" (string-trim text))))))

;; lspce 有効化ガード。この関数は起動時に定義される（use-package は defer）。
;; 各モードの hook から呼ばれ、(1) lspce がロードできる（Rust モジュール実在）、
;; (2) このバッファの種別に対応するサーバーコマンドが実行可能、の両方を満たす時だけ
;; lspce-mode を立てる。満たさないバッファ（yaml/lua 等の非対応モード）では
;; 完全に無音で何もしない。
(defun my/lspce-maybe-enable ()
  "サーバーが実在するバッファだけ lspce-mode を有効化する。"
  (when buffer-file-name
    (when-let ((servers
                (condition-case nil
                    (progn
                      (require 'lspce)
                      (lspce--server-program (lspce--lsp-type)))
                  ((debug error) nil))))
      (when (seq-some (lambda (p) (executable-find (car p))) servers)
        (lspce-mode 1)))))

;; leader の =l= グループ用ラッパー。lspce は autoload cookie が薄いので、
;; require してから対話実行する（xref-find-* は autoload 済みなので直 binds）。
(defun my/lspce-code-actions ()
  "code action 候補一覧から選んで実行する。"
  (interactive)
  (unless (bound-and-true-p lspce-mode)
    (user-error "このバッファにはLSPサーバが接続されていません"))
  (require 'lspce)
  (call-interactively #'lspce-code-actions))
(defun my/lspce-rename ()
  "カーソル位置のシンボルをプロジェクト全体でリネームする。"
  (interactive)
  (unless (bound-and-true-p lspce-mode)
    (user-error "このバッファにはLSPサーバが接続されていません"))
  (require 'lspce)
  (call-interactively #'lspce-rename))
(defun my/lspce-inlay-hints ()
  "inlay hints（型・引数名の薄い表示）をトグルする。"
  (interactive)
  (unless (bound-and-true-p lspce-mode)
    (user-error "このバッファにはLSPサーバが接続されていません"))
  (require 'lspce)
  (lspce-inlay-hints-mode 1))
(defun my/lspce-workspace-symbol (pattern)
  "ワークスペース全体のシンボルを PATTERN で検索し Consult 一覧を出す。"
  (interactive "sWorkspace symbol: ")
  (unless (bound-and-true-p lspce-mode)
    (user-error "このバッファにはLSPサーバが接続されていません"))
  (require 'lspce)
  (if-let ((xrefs (xref-backend-apropos 'xref-lspce pattern)))
      (xref-show-xrefs xrefs 'apropos)
    (user-error "シンボルが見つかりません")))
(defun my/lsp-diag-list ()
  "診断一覧。lspce(flymake)バッファは flymake 一覧、他は consult-flycheck。"
  (interactive)
  (if (and (bound-and-true-p lspce-mode) (bound-and-true-p flymake-mode))
      (progn (require 'flymake) (flymake-show-buffer-diagnostics))
    (consult-flycheck)))

;; nvimのK相当: カーソル位置のドキュメント/診断をポップアップで出す。
;; 優先順は LSP hover → elispの完全ドキュメント → eldocシグネチャ → 無しメッセージ。
;; describe-symbolを全モードで拾うとpythonのlist/map等がelispのdocと
;; 衝突して誤爆するので、elisp派生モードに限定する。
(defun my/doc-symbol ()
  "elisp派生モードでsymbol-at-pointの完全docを出す。無ければnil。"
  (when (derived-mode-p 'emacs-lisp-mode)
    ;; thing-at-pointは文字列を返す。describe-symbolはsymbol必須なので
    ;; fbound/bound実在チェック後にinternする。
    (when-let* ((name (thing-at-point 'symbol 'no-properties))
                (sym (intern-soft name))
                ((or (fboundp sym) (boundp sym))))
      (condition-case nil
          (progn (describe-symbol sym) t)
        ((debug user-error) nil)))))

(defun my/doc-eldoc ()
  "eldocが最後に生成したdocをツールチップで出す。無ければnil。"
  (when-let ((buf (and (fboundp 'eldoc-doc-buffer)
                       ;; 対話外で呼ぶとdocバッファ未生成時にuser-errorを
                       ;; 投げる（eldoc.el:513）ので、無しはnilとして扱う。
                       (condition-case nil (eldoc-doc-buffer)
                         (user-error nil))))
             ((> (buffer-size buf) 0)))
    (my/tooltip-at-point
     (with-current-buffer buf
       (string-trim (buffer-substring-no-properties (point-min) (point-max)))))
    t))

(defun my/doc-at-point ()
  "カーソル位置のホバー情報を表示する（nvimのK代替）。"
  (interactive)
  (cond
   ((and (fboundp 'lspce-help-at-point) (bound-and-true-p lspce-mode))
    ;; lspce は hover を posframe の float でカーソル位置に出す（窓は割らない）。
    ;; posframe 不可の環境は my/lspce--display-help-reduce が tooltip に退避させる。
    (message "doc-at-point: LSP hover経路（lspce posframe float）")
    (condition-case e
        (progn (lspce-help-at-point) t)
      ((debug error)
       (message "lspce hover失敗: %s → eldocにフォールバック"
                (error-message-string e))
       nil)))
   ((my/doc-symbol))
   ((my/doc-eldoc))
   (t (message "カーソル位置のドキュメントはありません"))))
;; 注意: printable文字のKをグローバルバインドすると、Kを明示バインドしていない
;; モード（python/ts/org/elisp等）で大文字Kのタイピングがホバーになる。
;; 競合監査の結果、printableでない =C-c h= に決定（dirvish内だけ局所定義の
;; dirvish-history-menuが勝つが、ディレクトリ画面にhoverは不要なので許容）。
(global-set-key (kbd "C-c h") #'my/doc-at-point)
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
  ;; Nix が treesit-grammars を供給するため、実行時の自動導入は行わない。
  :custom (treesit-auto-install nil)
  :config (global-treesit-auto-mode 1))
(use-package apheleia :config (apheleia-global-mode 1))

;; lspce の依存（README 記載）。f と markdown-mode は lspce.el がロード時に
;; require するため、Nix 側でも明示的に導入する。yasnippet は導入済み。
(use-package f :straight t :defer t)
(use-package markdown-mode :straight t :defer t)
;; hover float の描画先。無いと lspce は別窓表示に退避する（窓を割られる）。
;; MELPA に recipe が無いので GitHub 直指定（lspce と同じ作者）。posframe は
;; Package-Requires 経由で MELPA から自動導入される。
(use-package posframe-plus
  :straight (posframe-plus :type git :host github :repo "zbelial/posframe-plus")
  :defer t)

(use-package lspce
  :straight (lspce :type git :host github :repo "zbelial/lspce"
            :files (:defaults (:exclude "src" "Cargo.toml" "Cargo.lock" "docs" "images")
                              "lspce-module.so")
            :pre-build (("cargo" "build" "--release")
                        ("cp" "./target/release/liblspce_module.so" "./lspce-module.so")))
  :commands lspce-mode
  :custom
  (lspce-send-changes-idle-time 0.2)
  ;; imenu をサーバー索引に（consult-imenu が kind 付きで拾える）。
  (lspce-enable-imenu-index-function t)
  ;; hover を eldoc（エコーエリア）へ流さない。lsp-mode 時代の
  ;; lsp-ui-doc 相当の「hover は C-c h の float のみ」に戻し、
  ;; アイドル時の hover 往復も減らす。minibuffer には signature だけ出る。
  (lspce-eldoc-enable-hover nil)
  :config
  ;; marksman は markdown、tsserver は typescript/js/json を担当。mise 絶対パスで
  ;; 指定し、GUI emacs の PATH 問題の影響を受けないようにする（marksman/oxfmt と同じ方針）。
  (let ((tsl (expand-file-name "~/.local/share/mise/installs/npm-typescript-language-server/latest/bin/typescript-language-server"))
        (marksman (expand-file-name "~/.local/share/mise/installs/marksman/latest/marksman")))
    (setq lspce-server-programs
          `(("rust" "rust-analyzer" "")
            ("python" "jedi-language-server" "")
            ("python" "pylsp" "")
            ("go" "gopls" "")
            ("typescript" ,tsl "--stdio")
            ("js" ,tsl "--stdio")
            ("json" ,tsl "--stdio")
            ("markdown" ,marksman ""))))
  ;; md-mode（yibie/md-mode）の type は "md" になり default と噛み合わないため
  ;; markdown に正規化する。
  (defun my/lspce-lsp-type ()
    "lspce の言語種別。markdown 系を \"markdown\" に正規化する。"
    (if (memq major-mode '(markdown-mode markdown-ts-mode md-mode))
        "markdown"
      (funcall #'lspce--lsp-type-default)))
  (setq lspce-lsp-type-function #'my/lspce-lsp-type)
  ;; xref 結果（定義/参照/実装/apropos）は Consult 一覧で出す。
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  ;; lspce バッファの診断は flymake が担当。flycheck を同時に見せると
  ;;  fringe/下線が二重になるので、flycheck は該当バッファだけ止める。
  ;; markdown は flycheck（textlint 等）が主役なので flycheck を残す。
  (add-hook 'lspce-mode-hook
            (lambda ()
              (when (and (fboundp 'flycheck-mode)
                         (not (memq major-mode '(markdown-mode markdown-ts-mode md-mode))))
                (flycheck-mode -1)))))

;; hover float を everforest soft の float 配色に寄せる。lspce は描画時に
;; #191a1b（漆黒）/ 枠 "orange" を直書きするため、posframe-plus-show の
;; 引数を *lspce-hover* バッファに限定して差し替える（bg2=#465258, bg3=#505a60）。
(with-eval-after-load 'posframe-plus
  (defun my/lspce-posframe-colors (args)
    "lspce の hover float だけ背景/枠色をテーマ色に置換する。"
    (if (and (stringp (car-safe args))
             (string= (car args) "*lspce-hover*"))
        (append (list (nth 0 args) (nth 1 args) (nth 2 args))
                ;; nthc は subr-x のため単独ロード環境では void を引くことがある。
                (let ((plist (nthcdr 3 args)))
                  (plist-put (plist-put plist :background-color "#465258")
                             :internal-border-color "#505a60")))
      args))
  (advice-add 'posframe-plus-show :filter-args #'my/lspce-posframe-colors)
  ;; posframe が使えない環境では lspce は別窓表示に逃げるが、それは
  ;; 「窓を割らない」方針に反するので tooltip に退避させる。
  (defun my/lspce--display-help-reduce (orig kind content)
    "posframe 不可時は hover を tooltip で出す（窓分割禁止）。"
    (if (and (fboundp 'posframe-workable-p) (posframe-workable-p))
        (funcall orig kind content)
      (my/tooltip-at-point content)))
  (advice-add 'lspce--display-help :around #'my/lspce--display-help-reduce))

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

(use-package python :straight nil :hook (python-ts-mode . my/lspce-maybe-enable))
(use-package go-mode :mode "\\.go\\'" :hook (go-mode . my/lspce-maybe-enable))
(use-package rust-mode
  :mode "\\.rs\\'"
  :custom (rust-format-on-save t)
  :hook (rust-mode . my/lspce-maybe-enable))

(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook ((typescript-mode . my/lspce-maybe-enable)
         (typescript-mode . my/oxfmt-ts-mode-setup))
  :custom (my/oxfmt-command (expand-file-name "~/.local/share/mise/installs/node/latest/bin/oxfmt"))
  :init
  (defcustom my/oxfmt-command "oxfmt"
    "TypeScript 整形用の oxfmt コマンド。"
    :type 'string
    :group 'languages)
  (defcustom my/format-timeout-seconds 10
    "外部整形コマンドの待機上限（秒）。`my/format-with-process' が使用。"
    :type 'number
    :group 'languages)
  (defun my/format-with-process (command args &optional timeout)
    "buffer 内容を COMMAND に ARGS 付きでパイプ投入し、0 終了なら stdout を反映。
`call-process-region' と違い、待機は 100ms 刻みの `accept-process-output' ループ
（ Emacs 31 ではこの関数の timeout 位置引数が REMOTE 扱いで使えない）。TIMEOUT
秒（省略時 `my/format-timeout-seconds'）でプロセスを kill して buffer は変更
しない。CLI がハングしても Emacs がフリーズせず C-g でも中断できる。"
    (let* ((timeout (or timeout my/format-timeout-seconds))
           (out (generate-new-buffer " *format-out*"))
           (errb (generate-new-buffer " *format-err*"))
           (proc nil))
      (unwind-protect
          (condition-case sig
              (progn
                (setq proc (make-process
                            :name (format "format %s" (file-name-nondirectory command))
                            :command (cons command args)
                            :buffer out
                            :stderr errb
                            ;; デフォルト sentinel は "Process ... finished" を
                            ;; :buffer に追記し、整形出力に混入するため無効化。
                            :sentinel (lambda (_proc _event) nil)
                            :connection-type 'pipe
                            :coding 'utf-8-unix
                            :noquery t))
                (process-send-region proc (point-min) (point-max))
                (process-send-eof proc)
                (let ((deadline (+ (float-time) timeout)))
                  ;; 'exit 検知で止めると stdout が途中で取り込まれるため、
                  ;; sentinel 込みの後始末完了（process-live-p が nil）まで待つ。
                  (while (and (process-live-p proc) (< (float-time) deadline))
                    (accept-process-output proc 0.1))
                  (cond
                   ((process-live-p proc)
                    (message "my/format-with-process: %s: タイムアウト (%ds)、kill しました"
                             command timeout)
                    (delete-process proc)
                    nil)
                   ((= (process-exit-status proc) 0)
                    (save-excursion
                      (goto-char (point-min))
                      (replace-buffer-contents out))
                    t)
                   (t
                    (message "my/format-with-process: %s exit %s: %s"
                             command (process-exit-status proc)
                             (with-current-buffer errb (string-trim (buffer-string))))
                    nil))))
            ((error quit)
             ;; 起動直後の死（PATH に node が無い等）や C-g 中断はここでは無変更。
             (message "my/format-with-process: %s: %S" command sig)
             nil))
        (when (and proc (process-live-p proc))
          (delete-process proc))
        (kill-buffer out)
        (kill-buffer errb))))
  (defun my/oxfmt-format-buffer ()
    "oxfmt を buffer に対して走らせ、結果をその場で反映する。
`replace-buffer-contents' で point 保存。oxfmt が非 0 終了（構文エラー等）
なら buffer は触らない。"
    (interactive)
    (when-let ((cmd (executable-find my/oxfmt-command)))
      (my/format-with-process cmd
                              (list "--stdin-filepath"
                                    (or (buffer-file-name) (buffer-name))))))
  (defun my/oxfmt-ts-mode-setup ()
    "typescript-mode で保存時整形を tsserver でなく oxfmt に切り替える。
LSP の documentFormatting（tsserver 内蔵・別スタイル）と二重競合するため、
この buffer だけ format-on-save を落とし、before-save で oxfmt を走らせる。
診断等の LSP 機能自体はそのまま残る。"
    (add-hook 'before-save-hook #'my/oxfmt-format-buffer nil t)))
(use-package web-mode
  :mode (("\\.tsx\\'" . web-mode)
         ("\\.jsx\\'" . web-mode)
         ("\\.svelte\\'" . web-mode))
  :hook (web-mode . my/lspce-maybe-enable))
(use-package svelte-mode :mode "\\.svelte\\'" :hook (svelte-mode . my/lspce-maybe-enable))

(use-package yaml-mode :mode "\\.ya?ml\\'" :hook (yaml-mode . my/lspce-maybe-enable))
(use-package toml-mode :mode "\\.toml\\'" :hook (toml-mode . my/lspce-maybe-enable))
(use-package json-mode :mode "\\.json\\'" :hook (json-mode . my/lspce-maybe-enable))
(use-package lua-mode :mode "\\.lua\\'" :hook (lua-mode . my/lspce-maybe-enable))

(use-package erlang :mode "\\.erl\\'" :hook (erlang-mode . my/lspce-maybe-enable))
(use-package elixir-mode :mode "\\.exs?\\'" :hook (elixir-mode . my/lspce-maybe-enable))
(use-package gleam-ts-mode :mode "\\.gleam\\'" :hook (gleam-ts-mode . my/lspce-maybe-enable))
(use-package haskell-mode :mode "\\.hs\\'" :hook (haskell-mode . my/lspce-maybe-enable))
(use-package tuareg :mode "\\.mli?\\'" :hook (tuareg-mode . my/lspce-maybe-enable))
(use-package kotlin-mode :mode "\\.kts?\\'" :hook (kotlin-mode . my/lspce-maybe-enable))

(use-package sql :straight nil :hook (sql-mode . my/lspce-maybe-enable))
(use-package textui
  :straight (:host github :repo "yibie/textui"))
(defvar my/mmdc-command
  (or (executable-find "mmdc")
      (expand-file-name "~/.bun/bin/mmdc"))
  "Mermaid CLI executable.")
(defvar my/chrome-command
  (or (getenv "CHROME_EXECUTABLE")
      (executable-find "google-chrome-stable")
      (executable-find "chromium")
      "/usr/sbin/google-chrome")
  "Browser executable used by Mermaid/Puppeteer.")
(use-package md-mode
  :straight (:host github :repo "yibie/md-mode")
  :mode "\\.md\\'"
  :hook (md-mode . my/lspce-maybe-enable)
  :custom
  (md-render-mermaid-enabled t)
  (md-render-mermaid-command my/mmdc-command)
  (md-render-mermaid-browser my/chrome-command))
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

(use-package typst-ts-mode :mode "\\.typ\\'" :hook (typst-ts-mode . my/lspce-maybe-enable))

(use-package diagram-viewer
  :straight (:host github :repo "wtnqk/diagram-viewer")
  :after md-mode
  :demand t
  :custom
  (diagram-viewer-cache-directory
   (no-littering-expand-var-file-name "diagram-viewer/cache/"))
  :config
  (require 'diagram-viewer-adapter-mermaid)
  (require 'diagram-viewer-adapter-md-mode)

  ;; 既存の実行ファイル設定だけを再利用する。
  ;; PNG用のscale設定はSVG rendererへ渡さない。
  (setq diagram-viewer-mermaid-command md-render-mermaid-command
        diagram-viewer-mermaid-browser-executable
        md-render-mermaid-browser)

  ;; 明示的な置換を許可し、このブロックの再評価にも対応する。
  (diagram-viewer-mermaid-enable t)
  (diagram-viewer-md-mode-enable t)

  (define-key md-mode-map (kbd "C-c d")
              #'diagram-viewer-view-at-point)
  (define-key md-mode-map (kbd "C-c D")
              #'diagram-viewer-md-mode-view-rendered-at-point))

;; Emacs 31.1 未満には内蔵 markdown-ts-mode が無く、require に失敗する。
(when (version<= "31.1" emacs-version)
  ;; 内蔵モードへ .md を割り当てる。このブロックは SQLと文書形式 の
  ;; yibie/md-mode より後に評価されるため、auto-mode-alist で prepend 優先となる。
  (use-package markdown-ts-mode
    :straight nil
    :mode "\\.md\\'"
    :hook (markdown-ts-mode . my/lspce-maybe-enable))
  ;; yibie側のRendered viewはmd-mode限定（derived-mode check）。 内蔵モードの
  ;; C-c C-vはn/pだけ使うので、空いているC-c C-v mでmd-modeへ乗り換える。
  ;; md-mode側ではC-c C-vが単体コマンドのため、同じ接頭辞には足さない。
  (defun my/markdown-switch-to-md-mode ()
    "Switch the current buffer to `md-mode' (Rendered view lives there)."
    (interactive)
    (if (derived-mode-p 'md-mode)
        (user-error "Already in md-mode")
      (md-mode)))
  (defun my/markdown-switch-to-markdown-ts-mode ()
    "Switch the current buffer back to the built-in `markdown-ts-mode'."
    (interactive)
    (if (derived-mode-p 'markdown-ts-mode)
        (user-error "Already in markdown-ts-mode")
      (markdown-ts-mode)))
  (with-eval-after-load 'markdown-ts-mode
    (keymap-set markdown-ts-mode-map "C-c C-v m"
                #'my/markdown-switch-to-md-mode))
  ;; md-mode側ではC-c C-vがリーブなので逆方向は空いているC-c C-r（return）。
  (with-eval-after-load 'md-mode
    (keymap-set md-mode-map "C-c C-r"
                #'my/markdown-switch-to-markdown-ts-mode))
  (use-package markdown-ts-appear
    :straight (:host github :repo "Thysrael/markdown-ts-appear")
    :hook (markdown-ts-mode . markdown-ts-appear-mode)
    :config
    ;; Mermaid図プレビュー。Chrome は md-mode と同一の検出結果を使う。
    (setenv "PUPPETEER_EXECUTABLE_PATH" my/chrome-command)
    (setopt markdown-ts-appear-diagram-renderers
            (list (cons "mermaid"
                        (lambda (language code theme callback)
                          (markdown-ts-appear-diagram-mmdc
                           language code theme callback
                           my/mmdc-command)))))
    ;; 数式プレビューの手順（既定無効。TeX が入っていない状態での有効化不可）:
    ;; 1. sudo dnf install texlive-latex dvisvgm   (既定エンジン)
    ;; 2. (use-package latex-to-svg-for-markdown :straight t :defer t)
    ;;    で MELPA 版 (>= 0.22.2) を導入
    ;; 3. (setopt markdown-ts-appear-enable-math-preview t)
    ;;    して markdown-ts-appear-mode を入れ直す
    ))

;; buffer 内容を CLI の stdin に流し stdout を反映する共通処理。
;; replace-buffer-contents で point を保持し、終了コード非 0
;; （構文エラー等）では buffer を変更しない。
(defun my/cli-format-buffer (command &rest args)
  "Feed buffer contents to COMMAND with ARGS on stdin and apply stdout.
実体は `my/format-with-process'（非同期＋タイムアウト付き）。"
  (my/format-with-process command args))

(defcustom my/node-command
  (expand-file-name "~/.local/share/mise/installs/node/latest/bin/node")
  "mermaid ブロックパス用の node。
marksman や oxfmt と同じく mise の絶対パスで指定し、GUI emacs の
PATH 問題の影響を受けないようにする。"
  :type 'string
  :group 'languages)

(defcustom my/mermaid-md-script
  (expand-file-name "var/formatters/md-mermaid.mjs" user-emacs-directory)
  "Markdown 内の mermaid ブロックを整形する vendored スクリプト。"
  :type 'string
  :group 'languages)

(defcustom my/mermaidfmt-command
  (expand-file-name "var/formatters/node_modules/.bin/mermaidfmt"
                    user-emacs-directory)
  ".mmd 整形用の mermaidfmt CLI（var/formatters に vendoring 済み）。"
  :type 'string
  :group 'languages)

(defun my/markdown-format-buffer ()
  "Markdown を整形する。oxfmt 本文 + mermaid ブロックは mermaid-formatter。"
  (interactive)
  (my/oxfmt-format-buffer)
  (when (and (file-exists-p my/mermaid-md-script)
             (executable-find my/node-command))
    (my/cli-format-buffer my/node-command my/mermaid-md-script)))

(defun my/mermaid-format-buffer ()
  "mermaid ソース（.mmd）を mermaidfmt で整形する。"
  (interactive)
  (my/cli-format-buffer my/mermaidfmt-command))

(defun my/mermaid-format-on-save ()
  "mermaid buffer で保存時に整形を走るようにする。"
  (add-hook 'before-save-hook #'my/mermaid-format-buffer nil t))

(defun my/markdown-format-on-save ()
  "Markdown/mermaid buffer で保存時に整形を走るようにする。
lspce にはフォーマット機能が無い（textDocument/formatting を発らない）ため、
保存時の整形は oxfmt + mermaid-formatter に一本化できる。marksman は
hover/補完用の接続に留まる。"
  (add-hook 'before-save-hook #'my/markdown-format-buffer nil t))

;; .mmd には mermaid-mode パッケージ（diagrams 節で導入済み、:mode で
;; \.mmd/\.mermaid を占有）を使う。自作モードは不要なのでフックだけ載せる。
(add-hook 'mermaid-mode-hook #'my/mermaid-format-on-save)

(add-hook 'markdown-ts-mode-hook #'my/markdown-format-on-save)
;; yibie/md-mode に切り替えた buffer でも同じ整形が走る。
(add-hook 'md-mode-hook #'my/markdown-format-on-save)

(use-package zig-mode
  :mode "\\.zig\\'"
  :custom (zig-format-on-save nil)
  :hook (zig-mode . my/lspce-maybe-enable))

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
(use-package elm-mode :mode "\\.elm\\'" :hook (elm-mode . my/lspce-maybe-enable))
(use-package fish-mode :mode (("\\.fish\\'" . fish-mode) ("/config\\.fish\\'" . fish-mode)))

(use-package ghostel
  :commands (ghostel ghostel-project ghostel-compile)
  :custom
  ;; Nix パッケージに同梱されたネイティブモジュールをそのまま使う。
  (ghostel-module-directory
   (or (getenv "GHOSTEL_MODULE_DIR")
       (when-let ((lib (locate-library "ghostel")))
         (file-name-directory lib))
       (expand-file-name "var/ghostel/" user-emacs-directory)))
  (ghostel-module-auto-install nil))

(use-package prism
  :commands (prism-mode prism-whitespace-mode))

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
         (k8s-mode . my/lspce-maybe-enable)))

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
(use-package terraform-mode :mode "\\.tf\\'" :hook (terraform-mode . my/lspce-maybe-enable))
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

;; Nix の mu に同梱された mu4e、またはプロファイル上の mu4e を探索する。
(dolist (dir (list (getenv "MU4E_LISP_DIR")
                   (expand-file-name "~/.nix-profile/share/emacs/site-lisp/mu4e")
                   "/usr/share/emacs/site-lisp/mu4e"))
  (when (and dir (file-directory-p dir))
    (add-to-list 'load-path dir)))
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
