;;; early-init.el --- Generated from init.org -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil
      load-prefer-newer t
      frame-inhibit-implied-resize t
      gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; WSLg はフレームサイズが文字グリッドの倍数からずれると、端数ピクセル分が
;; 白帯として描画されることがある。pixelwise なリサイズを許可することで、
;; フレームを画面（ワークエリア）のピクセルサイズに厳密に合わせられるようにする。
(setq frame-resize-pixelwise t
      window-resize-pixelwise t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(add-to-list 'default-frame-alist '(vertical-scroll-bars . nil))
(add-to-list 'default-frame-alist '(menu-bar-lines . 0))
(add-to-list 'default-frame-alist '(tool-bar-lines . 0))

(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name)

;; 読み込み時に出る lexical-binding クッキー欠落警告だけを抑制する。
;; 早期起動の警告は warning-inhibit-types、初期化後の警告は
;; warning-suppress-types が照合される。 旧Emacsには warnings.el も
;; これらの変数も無いので無視される。
(require 'warnings nil t)
(when (boundp 'warning-inhibit-types)
  (add-to-list 'warning-inhibit-types '(files missing-lexbind-cookie))
  (add-to-list 'warning-suppress-types '(files missing-lexbind-cookie)))

(when (getenv "WSL_DISTRO_NAME")
  (setenv "GTK_IM_MODULE" "ibus")
  (setenv "QT_IM_MODULE" "ibus")
  (setenv "XMODIFIERS" "@im=ibus")
  (when (and (executable-find "ibus-daemon")
             (not (eq 0 (call-process "pgrep" nil nil nil "-x" "ibus-daemon"))))
    (call-process "ibus-daemon" nil 0 nil "-drx")))

;;; early-init.el ends here
