(vendor 'jump)

(load "shared/cucumber")
(load "shared/javascript")
(load "shared/markdown")
(load "shared/ruby")
(load "shared/sgml")
(load "shared/snippets")

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(vendor 'magit)
(eval-after-load 'magit
  '(progn
     (set-face-foreground 'magit-diff-add "green3")
     (set-face-foreground 'magit-diff-del "red3")))
