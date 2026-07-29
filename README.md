# Emacs configuration

The source of truth is `config.org`. It tangles only `early-init.el` and
`init.el`, and saving it in Emacs regenerates both files automatically.

## First start

After cloning, generate the startup files once with:

```sh
emacs -Q --batch -l org --eval '(org-babel-tangle-file "config.org")'
```

Then run `emacs`. straight.el downloads packages on the first start, so it
takes a while. Install icon fonts afterward with
`M-x nerd-icons-install-fonts` and restart Emacs.

## Useful keys

- `C-c SPC s r`: ripgrep
- `C-c SPC o s`: search Org-roam notes with ripgrep
- `C-c SPC o c`: capture a task or note
- `C-c SPC o a`: agenda
- `C-c SPC m m`: mu4e
- `C-c SPC r r`: Elfeed

Mail account examples are in `mail/`. Copy their values into private files in
the home directory and replace all placeholders before running `mu init`.
Store the password-only GPG file as `~/.mail-password.gpg`; Emacs credentials
can separately live in `~/.authinfo.gpg`.
