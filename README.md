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
- `C-x o`: select any window with ace-window
- `C-x 2` / `C-x 3`: split vertically / horizontally
- `C-c C-z`: zoom (temporarily maximize) the current window
- `C-q`: toggle the right-side treemacs file tree
- `C-x C-t`: open the tab-bar menu (tabs are named after projects)

## Window management

Splitting, moving between, resizing and organizing windows is handled through a
set of mutually-complementary tools.

### Splitting

- `C-x 2` — split vertically (windows stacked top/bottom)
- `C-x 3` — split horizontally (windows side by side)
- `C-x 1` — keep only the current window
- `C-x 0` — delete the current window (the buffer is kept)

### Moving between windows

- `C-x o` — ace-window: show a letter on each window (a s d f g h j k l); press
  it to move there. From ace-window you can also dispatch other window actions.
- `C-c <left>` / `C-c <right>` — winner-mode: undo / redo window splits and
  resizes.

### Resizing

- `C-x ^` — enlarge the current window vertically
- `C-x }` — enlarge horizontally
- `C-x {` — shrink horizontally
- `C-x +` — balance all window sizes

### Zoom

- `C-c C-z` — zoom-window: temporarily maximize the current window; press again
  to restore the previous window configuration.

### File tree (treemacs)

- `C-q` — toggle the treemacs sidebar on the right.
- It follows the current project and file automatically, shows Git status
  (`deferred` mode), and is unique per tab (see below).

### Tabs (tab-bar)

- `C-x C-t` — open the tab-bar keymap (`t` new tab, `n`/`p` next/previous,
  `r` rename, `0` close).
- Each tab is named after its project.
- treemacs is separate per tab: switching tabs swaps the file tree to that
  tab's project.

### Opening files into a chosen window (Embark)

After calling `C-.` on a file/buffer/bookmark candidate:

- `o` — open in a window you pick with ace-window
- `2` — split below and open
- `3` — split to the right and open

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
