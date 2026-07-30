;;; early-init.el --- Generated from init.org -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil
      frame-inhibit-implied-resize t
      gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(add-to-list 'default-frame-alist '(vertical-scroll-bars . nil))
(add-to-list 'default-frame-alist '(menu-bar-lines . 0))
(add-to-list 'default-frame-alist '(tool-bar-lines . 0))
(add-to-list 'default-frame-alist '(fullscreen . fullboth))

(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name)

(when (getenv "WSL_DISTRO_NAME")
  (setenv "GTK_IM_MODULE" "ibus")
  (setenv "QT_IM_MODULE" "ibus")
  (setenv "XMODIFIERS" "@im=ibus")
  (when (and (executable-find "ibus-daemon")
             (not (eq 0 (call-process "pgrep" nil nil nil "-x" "ibus-daemon"))))
    (call-process "ibus-daemon" nil 0 nil "-drx")))

;;; early-init.el ends here
