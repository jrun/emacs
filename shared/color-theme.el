;; Color Themes
(add-to-list 'load-path (concat dotfiles-dir "/vendor/color-theme"))
(require 'color-theme)
(color-theme-initialize)

;; Activate theme
(load-file (concat dotfiles-dir "/vendor/color-theme-subdued.el"))
(load-file (concat dotfiles-dir "/vendor/color-theme-almost-monokai.el"))
(load-file (concat dotfiles-dir "/vendor/color-theme-molokai.el"))
(load-file (concat dotfiles-dir "/vendor/color-theme-vibrant-ink.el"))
(load-file (concat dotfiles-dir "/vendor/color-theme-ir-black.el"))
(load-file (concat dotfiles-dir "/vendor/color-theme-tangotango.el"))
(color-theme-tangotango)
