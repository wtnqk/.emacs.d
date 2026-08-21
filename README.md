# Emacs configuration

The source of truth is `init.org`. It tangles only `early-init.el` and
`init.el`, and saving it in Emacs regenerates both files automatically.

## First start

After cloning, generate the startup files once with:

```sh
emacs -Q --batch -l org --eval '(org-babel-tangle-file "init.org")'
```

Then run `emacs`. straight.el downloads packages on the first start, so it
takes a while. Install icon fonts afterward with
`M-x nerd-icons-install-fonts` and restart Emacs.

## Useful keys

- `F11`: toggle fullscreen
- `C-c SPC s r`: ripgrep
- `C-c SPC o s`: search Org-roam notes with ripgrep
- `C-c SPC o c`: capture a task or note
- `C-c SPC o a`: agenda
- `C-c SPC m m`: mu4e
- `C-c SPC r r`: Elfeed
- `C-=` / `C--`: expand or contract the selection
- `M-.` / `M-,`: smart jump or jump back
- `M-g c` / `M-g w` / `M-g l`: jump to a character, word, or line

## Completion

Minibuffer completion uses Vertico, Orderless, Marginalia, and Consult. In-buffer
completion uses Corfu and Cape, with Prescient saving completion history and
kind-icon showing candidate kinds. `TAB` completes at point.

## Static checks

Flycheck runs automatically when supported buffers are enabled and when they are
saved. Use `C-c SPC s e` to show project-wide Flycheck errors.

- Org buffers use the `textlint` checker through `npx`; install textlint and its
  rules in the project being edited.
- Emacs Lisp buffers use `flycheck-elsa`.
- CloudFormation buffers use `flycheck-cfn`; install `cfn-lint` and `cfn_nag`
  if those checks are needed.

Mail account examples are in `mail/`. Copy their values into private files in
the home directory and replace all placeholders before running `mu init`.
Store the password-only GPG file as `~/.mail-password.gpg`; Emacs credentials
can separately live in `~/.authinfo.gpg`.
