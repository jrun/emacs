(unless (package-installed-p 'elixir-mode)
  (package-install 'elixir-mode))

(unless (package-installed-p 'alchemist)
  (package-install 'alchemist))

; http://alchemist.readthedocs.io/en/latest/configuration/
(setq alchemist-mix-command "/usr/local/bin/mix")
