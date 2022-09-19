;; .emacs

;; Stop the damned thing from binging all the time
(setq ring-bell-function 'ignore)

;; Configure package sources
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl (warn "No SSL support"))
  (setq package-archives (quote (
                                 ("melpa" . "https://melpa.org/packages/")
                                 ("gnu" . "https://elpa.gnu.org/packages/")
                                 ))))
(package-initialize)

;; Load in use-package
(eval-when-compile
  (require 'use-package))

;; Update all the packages
;; (use-package auto-package-update
;;   :config
;;   (setq auto-package-update-delete-old-versions t)
;;   (setq auto-package-update-hide-results t)
;;   (auto-package-update_maybe))

;; ---------------------------------------------------------------------------------------------
;; General Appearance and Settings
;; ---------------------------------------------------------------------------------------------

;; Set the Emacs diary location
(setq diary-file "~/cs/diary")

;; Disable both the menubar and the toolbar
(menu-bar-mode -1)
(tool-bar-mode -1)

;; Remove all the scrollbars
(scroll-bar-mode -1)

;; CHange the scroll behaviour
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

;; If we have a fringe mode control, make the fringe smaller
(if (fboundp 'fringe-mode)
    (fringe-mode 8))

;; Set the frame titles to something meaningful
(setq frame-title-format
      '("" invocation-name " - " (:eval (if (buffer-file-name) (abbreviate-file-name (buffer-file-name)) "%b"))))

(add-to-list 'default-frame-alist '(width . 96))
(add-to-list 'default-frame-alist '(height . 0.8))
(add-to-list 'default-frame-alist '(top . 0.5))

;; Enable line and column number indicators
(line-number-mode t)
(column-number-mode t)

;; Disable tabs and set the tab width to two
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq-default js-indent-level 2)

;; Any key should delete the current selection
(delete-selection-mode t)

;; Configure some reasonable back-up and save behaviour
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; Make the kill-ring copy to the X clipboard
;;(setq x-select-enable-clipboard t)
(setq select-enable-clipboard t)

;; Set mouse avoidance mode to animate. We then tell emacs thet we
;; want the pointer to still be visible, which reduces some of my
;; confusion when I'm doing editing with the mouse. Note this is only
;; done in graphical mode.
(if (display-graphic-p)
    (progn
      (mouse-avoidance-mode 'animate)
      (setq make-pointer-invisible nil)))

;; Set the default frame size
; (add-to-list 'default-frame-alist '(width . 102))
; (add-to-list 'default-frame-alist '(height . 70))

;; Stop the Emacs start-up screen
(setq inhibit-splash-screen t)

;; Set the keyboard echo to be faster than the default
(setq echo-keystrokes 0.1)

;; Stop C-z from hiding the window in graphical mode and change it to do Undo instead
(if (display-graphic-p)
    (progn
      (global-set-key (kbd "C-z") 'undo)))

;; Set this file as a register (open with C-x r j i)
(set-register ?E '(file . "~/.emacs"))

;; Tell Emacs to log stuff more
(setq message-log-max t)

;; dired - reuse current buffer by pressing 'a'
(put 'dired-find-alternate-file 'disabled nil)

;; dired - always delete and copy recursively
(setq dired-recursive-deletes 'always)
(setq dired-recursive-copies 'always)

;; If there is a dired buffer displayed in the next window, use it's current
;; subdir, instead of the current subdir of this dired buffer
(setq dired-dwim-target t)

;; Enable cool dired extensions
(require 'dired-x)

;; We like ediff
(require 'ediff)
(eval-after-load 'ediff
  '(progn
     (set-face-foreground 'ediff-odd-diff-B "#ffffff")
     (set-face-background 'ediff-odd-diff-B "#292521")
     (set-face-foreground 'ediff-even-diff-B "#ffffff")
     (set-face-background 'ediff-even-diff-B "#292527")

     (set-face-foreground 'ediff-odd-diff-A "#ffffff")
     (set-face-background 'ediff-odd-diff-A "#292521")
     (set-face-foreground 'ediff-even-diff-A "#ffffff")
     (set-face-background 'ediff-even-diff-A "#292527")))

;; Make shell-scripts executable on save
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

;; Cleanup whitespace on save
(add-hook 'before-save-hook
          'whitespace-cleanup)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

;; ---------------------------------------------------------------------------------------------
;; Functions
;; ---------------------------------------------------------------------------------------------

;; Define a function to toggle full-screen mode and bind it to F11
(defun switch-full-screen ()
  (interactive)
  (shell-command "wmctrl -r :ACTIVE: -btoggle,fullscreen"))
(global-set-key (kbd "<f11>") 'switch-full-screen)

;; Define a function to evaluate and replace the selection and bind to (C-x C-e)
(defun eval-and-replace ()
  "Replace the preceding or highlighted sexp with it's value"
  (interactive)
  (let (expression)
    (if (use-region-p)
        (kill-region (region-beginning) (region-end))
      (backward-kill-sexp))
    (setq expression (current-kill 0))
    (message "Evaluating: '%s'" expression)
    (condition-case nil
        (prin1 (eval (read expression)) (current-buffer))
      (error (message "Invalid Expression") (insert expression)))))
(global-set-key (kbd "C-x C-e") 'eval-and-replace)

;; Define a function to rename the current buffer and file
(defun rename-current-buffer-file ()
  "Renames the current buffer and the file it's visiting"
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New Name: " filename)))
        (if (get-buffer new-name)
            (error "A buffer named '%s' already exists!" new-name)
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (message "File '%s' renamed to '%s'"
                   name (file-name-nondirectory new-name)))))))

;; Define a function that creates a new scratch buffer
(defun create-scratch-buffer ()
  "Create a new scratch buffer to work in (could be *scratch* - *scratchX*)"
  (interactive)
  (let ((n 0)
        bufname)
    (while (progn
             (setq bufname (concat "*scratch"
                                   (if (= n 0) "" (int-to-string n))
                                   "*"))
             (setq n (1+ n))
             (get-buffer bufname)))
    (switch-to-buffer (get-buffer-create bufname))
    (emacs-lisp-mode)))

(defun sudo-edit (&optional arg)
  (interactive "p")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:" (read-file-name "File: ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

(defun insert-date (prefix)
  "Insert the current date.  With PREFIX, use ISO-format.  With
two PREFIX arguments, write out the day and month name."
  (interactive "P")
  (let ((format (cond
                 ((not prefix) "%d.%m.%Y")
                 ((equal prefix '(4)) "%Y-%m-%d")
                 ((equal prefix '(16)) "%A, %d. %B %Y")))
        (system-time-locale "en_GB"))
    (insert (format-time-string format))))
(global-set-key (kbd "C-c d") 'insert-date)

;; (defun revert-all-buffers ()
;;   "Refreshes all open buffers from their respective files"
;;   (interactive "P")
;;   (let * ((list (buffer-list))
;;           (buffer (car list)))
;;        (while buffer
;;          (when (and (buffer-file-name buffer)
;;                     (not (buffer-modified-p buffer)))
;;            (set-buffer buffer)
;;            (revert-buffer t t t))
;;          (setq list (cdr list))
;;          (setq buffer (car list))))
;;   (messge "Refreshed open files"))

(defun shell-command-on-buffer ()
  "Asks for a command and executes it in an inferior shell with current buffer as input"
  (interactive)
  (shell-command-on-region
   (point-min) (point-max)
   (read-shell-command "Shell command on buffer: ")))
(global-set-key (kbd "M-\"") 'shell-command-on-buffer)

;; Add "F" key to open in new frame
(defun dired-find-file-other-frame ()
  "In dired, visit this file or directory in another window."
  (interactive)
  (find-file-other-frame (dired-get-file-for-visit)))
(eval-after-load "dired"
  '(define-key dired-mode-map "F" 'dired-find-file-other-frame))
(eval-after-load "dired"
  '(progn
     (define-key dired-mode-map (kbd "C-c n") 'my-dired-create-file)
     (defun my-dired-create-file (file)
       "Create a file called FILE. If the file alreadt exists, signal an error."
       (interactive
        (list (read-file-name "Create file: " (dired-current-directory))))
       (let* ((expanded (expand-file-name file))
              (try expanded)
              (dir (directory-file-name (file-name-directory expanded)))
              new)
         (if (file-exists-p expanded)
             (error "Cannot create file %s: file exists" expanded))
         (while (and try (not (file-exists-p try)) (not (equal new try)))
           (setq new try
                 try (directory-file-name(file-name-directory try))))
         (when (not (file-exists-p dir))
           (make-directory dir t))
         (write-region "" nil expanded t)
         (when new
           (dired-add-file new)
           (dired-move-to-filename))))))

;; ---------------------------------------------------------------------------------------------
;; Packages and Package Settings
;; ---------------------------------------------------------------------------------------------

(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; (use-package dashboard
;;   :ensure t
;;   :config
;;   (dashboard-setup-startup-hook)
;;   (setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))
;;   (setq dashboard-items '((projects . 5)
;;                           (agenda . 5)
;;                           (recents . 5)
;;                           (bookmarks . 5)
;;                           (registers . 5))))

(use-package bind-key
  :ensure t
  :config
  (add-to-list 'same-window-buffer-names "*Personal Keybindings*"))

;; (use-package arc-dark-theme)
(load-theme 'vscode-dark-plus t)

(use-package esup
  :ensure t)



(use-package w3m)

(use-package centaur-tabs
  :demand
  :config
  (centaur-tabs-mode t)
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward))

(use-package powerline
  :demand)
(powerline-default-theme)

(use-package treemacs)
(use-package treemacs-projectile)

(use-package fill-column-indicator
             :hook ((c++-mode . fci-mode)))

(use-package which-key
             :config
             (which-key-mode))

(use-package dimmer
  :config
  (dimmer-configure-which-key)
  (dimmer-mode t))

(use-package smartparens
             :hook ((c++-mode . smartparens-mode)
                    (c-mode . smartparens-mode))
             :config
             (show-smartparens-global-mode +1)
             (require 'smartparens-latex)
             (require 'smartparens-c))

(use-package diminish)
(use-package prettier-js)

(use-package windmove
             :commands (windmove-down windmove-up windmove-left windmove-right)
             :bind (("C-c <down>" . windmove-down)
                    ("C-c <up>" . windmove-up)
                    ("C-c <left>" . windmove-left)
                    ("C-c <right>" . windmove-right)))

(use-package tramp
             :config
             (setq tramp-default-method "ssh"))

(use-package flyspell
             :config
             (setq ispell-program-name "aspell"
                   ispell-extra-args '("--sug-mode=ultra")))

(use-package projectile
             :config
             (projectile-global-mode)
             (setq projectile-enable-caching t)
             (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
             (projectile-mode +1))

(use-package ivy :demand
  :commands (swiper ivy-resume)
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t
        enable-recursive-minibuffers t
        ivy-count-format "%d/%d ")
  :bind (("C-s" . swiper)
         ("C-c C-r" . ivy-resume)
         ("<f6>" . ivy-resume)))

(use-package ivy-hydra
  :after (ivy hydra))

(use-package counsel
  :after (ivy counsel)
  :config
  (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-c l" . counsel-locate)
         ("C-c m" . counsel-linux-app)
         ("C-c w" . counsel-wmctrl)
         ("C-c u" . counsel-unicode-char)
         ("C-c b" . counsel-bookmark)
         ("M-y" . counsel-yank-pop)))

(use-package ace-jump-mode
             :bind ("C-c SPC" . ace-jump-mode))

(use-package midnight)
(use-package move-text)

(use-package multiple-cursors
             :bind (("C-S-c C-S-c" . mc/edit-lines)
                    ("C->" . mc/mark-next-like-this)
                    ("C-<" . mc/mark-previous-like-this)
                    ("<M-S-down>" . mc/mark-next-like-this)
                    ("<M-S-up>" . mc/mark-previous-like-this)
                    ("C-c C-<" . mc/mark-all-like-this)
                    ("C-<down-mouse-1>" . mc/add-cursor-on-click)))

(use-package spray
             :bind ("<f6>" . spray-mode))


;; ---------------------------------------------------------------------------------------------
;; LaTeX
;; ---------------------------------------------------------------------------------------------

(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX_master nil)
(setq TeX-PDF-mode t)

;; ---------------------------------------------------------------------------------------------
;; Magit and Git Configurations
;; ---------------------------------------------------------------------------------------------

(defun magit-save-and-exit-commit-mode ()
  "Quickly save and exit from magit commit mode."
  (interactive)
  (save-buffer)
  (server-edit)
  (delete-window))

(defun magit-exit-commit-mode ()
  "Exit from magic commit mode."
  (interactive)
  (kill-buffer)
  (delete-window))

;; C-c C-a to amend without any prompt
(defun magit-just-amend ()
  "Amend without any prompt."
  (interactive)
  (save-window-excursion
    (magit-with-refresh
      (shell-command "git --no-pager commit --amend --reuse-message=HEAD"))))

;; C-x C-k to kill file on line
(defun magit-kill-file-on-line ()
  "Show file on current magit line and prompt for deletion."
  (intearactive)
  (magit-visit-item)
  (delete-current-buffer-file)
  (magit-refresh))

(use-package magit
             :config
             (set-face-background 'diff-file-header "#121212")
             (set-face-foreground 'diff-context "#666666")
             (set-face-foreground 'diff-added "#00cc33")
             (set-face-foreground 'diff-removed "#ff0000")
             (set-default 'magit-stage-all-confirm nil)
             (set-default 'magit-unstage-all-confirm nil)
             (add-hook 'magit-mode-hook 'magit-load-config-extensions)
             (eval-after-load "git-commit-mode"
               '(define-key git-commit-mode-map (kbd "C-c C-k") 'magit-exit-commit-mode))
             (eval-after-load "magit"
               '(define-key magit-status-mode-map (kbd "C-c C-a") 'magit-just-amend))
             (define-key magit-status-mode-map (kbd "C-x C-k") 'magit-kill-file-on-line)
             :bind ("C-c g" . magit-status))

(use-package git-gutter-fringe
             :config
             (global-git-gutter-mode +1))

;; ---------------------------------------------------------------------------------------------
;; Org Mode
;; ---------------------------------------------------------------------------------------------

(defun org-insert-code-block ()
  "Insert a code block for a specific language."
  (interactive)
  (let (type indent)
    (setq type (read-string "Enter language: "))
    (setq indent (make-string (current-column) ? ))
    (insert "#+BEGIN_SRC " type "\n" indent)
    (save-excursion
      (insert "\n" indent "#+END_SRC\n"))))

(defun org-insert-example ()
  "Insert an example block."
  (interactive)
  (let (indent)
    (setq indent (make-string (current-column) ? ))
    (insert "#+BEGIN_EXAMPLE" "\n" indent)
    (save-excursion
      (insert "\n" indent "#+END_EXAMPLE\n"))))

(defun my-org-fit-window-to-buffer (&optional ARG PRED OPT)
  "Attached as advice to org-fit-window-to-buffer (ignore ARG, PRED and OPT).

This function will set centaur-tabs-display-line-format to nil
which will hide the tab bar for the current buffer.  This means
that the pop-up windows that org uses for things like tag
selection and agenda mode selection will not have tabs"
  (when (boundp 'centaur-tabs-display-line-format)
    (set centaur-tabs-display-line-format nil)))

(use-package org
  :config
  (setq org-agenda-files (quote ("~/cs/gtd.org")))
  (setq org-directory "~/cs")
  (setq org-default-notes-file (concat org-directory "/notes.org"))
  (setq org-refile-targets '(("~/cs/gtd_archive.org" :level . 1)))
  (setq org-todo-keyword-faces
        '(("BLOCKED" . "yellow")
          ("STARTED" . "cyan")))
  (advice-add 'org-fit-window-to-buffer :after 'my-org-fit-window-to-buffer)
  (require 'org-protocol)

  (setq org-capture-templates
      (quote
       (
        ("g" "Getting Things Done")
        ("gt" "New Todo Item" entry (file+headline "~/cs/gtd.org" "Tasks")
         (file "~/cs/dotfiles/tmp_gtd_task.txt"))
        ("gT" "New Todo Item (Ann.)" entry (file+headline "~/cs/gtd.org" "Tasks")
         (file "~/cs/dotfiles/tmp_gtd_task_ann.txt"))
        ("gs" "Someday Task" entry (file+headline "~/cs/someday.org" "Tasks")
         "* TODO %T %?\n")
        ("gr" "Weekly GTD Review" entry (file+olp+datetree "~/cs/gtd_review.org")
         (file "~/cs/dotfiles/tmp_gtd_review.txt"))
        ("n" "Note Taking")
        ("nn" "Capture Note" entry (file "~/cs/notes.org")
         (file "~/cs/dotfiles/tmp_note.txt"))
        ("ni" "Capture Idea" entry (file+headline "~/cs/ideas.org" "Ideas")
         (file "~/cs/dotfiles/tmp_idea.txt"))
        ("nI" "Capture Idea (Ann.)" entry (file+headline "~/cs/ideas.org" "Ideas")
         (file "~/cs/dotfiles/tmp_idea_ann.txt"))
        ("j" "Journal Entry" entry (file+olp+datetree "~/cs/journal.org")
         (file "~/cs/dotfiles/tmp_journal.txt"))
        ("f" "Start Food Diary Day" entry (file "~/cs/food.org")
         (file "~/cs/dotfiles/tmp_food_day.txt"))
        ("p"
         "Protocol"
         entry
         (file+headline "~/cs/notes.org" "Inbox")
         "* %:description\n  [[%:link][%:description]]\n\n  #+BEGIN_QUOTE\n  %i\n  #+END_QUOTE\n\n  %?\n\n  Captured on %U\n")
        ("L"
         "Protocol Link"
         entry
         (file+headline "~/cs/notes.org" "Inbox")
         "* %:description\n  [[%:link][%:description]]\n\n  %?\n\n  Captured On: %U\n"))))

  (require 'epa-file)
  ;; (epa-file-enable)
  (require 'org-crypt)
  (org-crypt-use-before-save-magic)
  (setq org-tags-exclude-from-inheritance (quote ("crypt")))
  (setq org-crypt-key nil)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((dot . t) (latex . t)))
  (defun my-org-confirm-babel-evaluate (lang body)
    (not (string= lang "dot")))
  (setq org-confirm-babel-evaluate 'my-org-confirm-babel-evaluate))

(require 'org)
(global-set-key (kbd "C-c r") 'org-capture)
(global-set-key (kbd "C-c a") 'org-agenda)

(use-package poporg
  :bind (("C-c /" . poporg-dwim)))

(use-package htmlize
  :defer t
  :config
  (progn

    ;; It is required to disable `fci-mode' when `htmlize-buffer' is called;
    ;; otherwise the invisible fci characters show up as funky looking
    ;; visible characters in the source code blocks in the html file.
    ;; http://lists.gnu.org/archive/html/emacs-orgmode/2014-09/msg00777.html
    (with-eval-after-load 'fill-column-indicator
      (defvar modi/htmlize-initial-fci-state nil
        "Variable to store the state of `fci-mode' when `htmlize-buffer' is called.")

      (defun modi/htmlize-before-hook-fci-disable ()
        (setq modi/htmlize-initial-fci-state fci-mode)
        (when fci-mode
          (fci-mode -1)))

      (defun modi/htmlize-after-hook-fci-enable-maybe ()
        (when modi/htmlize-initial-fci-state
          (fci-mode 1)))

      (add-hook 'htmlize-before-hook #'modi/htmlize-before-hook-fci-disable)
      (add-hook 'htmlize-after-hook #'modi/htmlize-after-hook-fci-enable-maybe))

    ;; `flyspell-mode' also has to be disabled because depending on the
    ;; theme, the squiggly underlines can either show up in the html file
    ;; or cause elisp errors like:
    ;; (wrong-type-argument number-or-marker-p (nil . 100))
    (with-eval-after-load 'flyspell
      (defvar modi/htmlize-initial-flyspell-state nil
        "Variable to store the state of `flyspell-mode' when `htmlize-buffer' is called.")

      (defun modi/htmlize-before-hook-flyspell-disable ()
        (setq modi/htmlize-initial-flyspell-state flyspell-mode)
        (when flyspell-mode
          (flyspell-mode -1)))

      (defun modi/htmlize-after-hook-flyspell-enable-maybe ()
        (when modi/htmlize-initial-flyspell-state
          (flyspell-mode 1)))

      (add-hook 'htmlize-before-hook #'modi/htmlize-before-hook-flyspell-disable)
      (add-hook 'htmlize-after-hook #'modi/htmlize-after-hook-flyspell-enable-maybe))))

;; ---------------------------------------------------------------------------------------------
;; Thesaurus
;; ---------------------------------------------------------------------------------------------

(use-package powerthesaurus
             :bind ("C-c s" . powerthesaurus-lookup-word-dwim))

;; ---------------------------------------------------------------------------------------------
;; C/C++
;; ---------------------------------------------------------------------------------------------

(global-unset-key (kbd "M-o"))
(use-package origami
             :hook ((c++-mode . origami-mode)
                    (c-mode . origami-mode))
             :bind (:map origami-mode-map
                         (("M-o C" . 'origami-close-all-nodes)
                          ("M-o c" . 'origami-open-node)
                          ("M-o O" . 'origami-open-all-nodes)
                          ("M-o o" . 'origami-forward-toggle-node)
                          ("<backtab>" . 'origami-recursively-toggle-node))))

(use-package lsp-mode
  :hook ((c++-mode . lsp)
         (c-mode . lsp)
         (lsp-mode . lsp-enable-which-key-integration)))

(use-package lsp-ui
  :commands lsp-ui-mode
  :bind (:map lsp-ui-mode-map (([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
                               ([remap xref-find-references] . lsp-ui-peek-find-references)))
  :config
  (setq lsp-ui-doc-enable nil))

(use-package lsp-ivy
  :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs
  :commands lsp-treemacs-errors-list)

;;
;; Old Irony configuration (I used Irony for a long time, before lsp-mode was stable)
;;

;; (defun my-irony-mode-hook ()
;;   (define-key irony-mode-map
;;       [remap completion-at-point] 'counsel-irony)
;;   (define-key irony-mode-map
;;       [remap complete-symbol] 'counsel-irony))

;; (use-package irony
;;              :hook ((c++-mode . irony-mode)
;;                     (c-mode . irony-mode))
;;              :config
;;              (add-hook 'irony-mode-hook 'my-irony-mode-hook)
;;              (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options))

;; (use-package irony-eldoc
;;              :hook (irony-mode . irony-eldoc))

(use-package company
             :config
             (setq company-idle-delay 0.5)
             (setq company-tooltip-limit 10)
             (setq company-minimum-prefix-length 2)
             (global-company-mode 1))
;;             (eval-after-load 'company
;;               '(add-to-list 'company-backends 'company-irony)))

;; (use-package company-irony)

(use-package flycheck
             :config
             (global-flycheck-mode))

;; (use-package flycheck-irony
;;              :hook (flycheck-mode . flycheck-irony-setup))

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

;; We want to see line numbers in our C/C++ files
(add-hook 'c++-mode-hook 'linum-mode)
(add-hook 'c-mode-hook 'linum-mode)

;; This hack fixes indentation for C++11's "enum class" in Emacs.
;; http://stackoverflow.com/questions/6497374/emacs-cc-mode-indentation-problem-with-c0x-enum-class/6550361#6550361

(defun inside-class-enum-p (pos)
  "Check if POS is within the braces of a C++ \"enum class\"."
  (ignore-errors
    (save-excursion
      (goto-char pos)
      (up-list -1)
      (backward-sexp 1)
      (looking-back "enum[ \t]+class[ \t]+[^}]+"))))

(defun align-enum-class (langelem)
  (if (inside-class-enum-p (c-langelem-pos langelem))
      0
    (c-lineup-topmost-intro-cont langelem)))

(defun align-enum-class-closing-brace (langelem)
  (if (inside-class-enum-p (c-langelem-pos langelem))
      '-
    '+))

(defun fix-enum-class ()
  "Setup `c++-mode' to better handle \"class enum\"."
  (add-to-list 'c-offsets-alist '(topmost-intro-cont . align-enum-class))
  (add-to-list 'c-offsets-alist
               '(statement-cont . align-enum-class-closing-brace)))

(add-hook 'c++-mode-hook 'fix-enum-class)

(defun clang-format-buffer-smart ()
  "Reformat buffer if .clang-format exists in the projectile root."
  (let ((extension))
    (setq extension (file-name-extension (buffer-file-name)))
    (when (member extension '("c" "cc" "cpp" "cxx" "h" "hh" "hxx"))
      (progn
        (message "Formatting on save...")
        (when (file-exists-p (expand-file-name ".clang-format" (projectile-project-root)))
          (clang-format-buffer))))))

(defun clang-format-buffer-smart-on-save ()
  "Add auto-save hook for clang-format-buffer-smart."
  (add-hook 'before-save-hook 'clang-format-buffer-smart nil t))

(use-package clang-format
             :hook ((c-mode . clang-format-buffer-smart-on-save)
                    (c++-mode . clang-format-buffer-smart-on-save)))

(defun insert-file-header ()
  "Insert a file header."
  (interactive)
  (let (brief)
    (setq brief (read-string "Enter file brief: "))
    (goto-line 0)
    (insert "/**\n * @file ")
    (insert (file-relative-name buffer-file-name (projectile-project-root)))
    (insert "\n * @brief " brief "\n */\n\n")))

(defun insert-header-exclusion ()
  "Insert header exclusion macros."
  (interactive)
  (let (projname filename macroname)
    (setq projname (upcase (projectile-project-name)))
    (setq projname (replace-regexp-in-string "[-/\.]" "_" projname nil))
    (setq filename (file-relative-name buffer-file-name (projectile-project-root)))
    (setq filename (replace-regexp-in-string "[-/\.]" "_" (upcase filename) nil))
    (setq macro_name (concat "__" projname "_" filename "__"))
    (insert "#ifndef " macro_name "\n")
    (insert "#define " macro_name "\n")
    (insert "\n")
    (save-excursion
      (goto-char (point-max))
      (insert "\n\n#endif /*" macro_name "*/\n"))))

(defun insert-namespace ()
  "Insert C++ namespace statements."
  (interactive)
  (let (namespace names)
    (setq namespace (read-string "Enter namespace: "))
    (setq names (split-string namespace "\\."))
    (dolist (name names)
      (insert "namespace " name " {\n"))
    (insert "\n")
    (save-excursion
      (insert "\n\n")
      (dolist (name names)
        (insert "} /* namespace " name " */\n")))))

(defun insert-function-doxygen()
  "Insert doxygen comment at point."
  (interactive)
  (let
      ((contents (-some->> (lsp--text-document-position-params)
                    (lsp--make-request "textDocument/hover")
                    (lsp--send-request)
                    (gethash "contents")
                    (gethash "value"))))
    (let (str args indent)
      (forward-line 0)
      (forward-word 1)
      (backward-word 1)
      (setq indent (make-string (current-column) ? ))
      (setq str (progn (string-match "(\\(.*\\))" contents)
                       (match-string 1 contents)))
      (setq args (split-string str ","))
      (insert "/**\n" indent " * @brief ")
      (save-excursion
        (insert "\n" indent " * ")
        (dolist (arg args)
          (print arg)
          (let (arg_name)
            (setq arg_name
                  (progn (string-match "[[:space:]]*[_:*&a-zA-Z0-9]+[[:space:]]+\\([_a-zA-Z0-9]*\\)" arg)
                         (match-string 1 arg)))
            (insert "\n" indent " * @param " (if arg_name arg_name "") " ")))
        (insert "\n" indent " */\n" indent)))))

;; ---------------------------------------------------------------------------------------------
;; Assembly Programming
;; ---------------------------------------------------------------------------------------------

(use-package llvm-mode
  :load-path "~/.emacs.d/raw/"
  :mode "\\.ll\\'"
  :interpreter "llvm")

(use-package gas-mode
  :load-path "~/.emacs.d/raw/"
  :mode "\\.s\\'"
  :interpreter "gas")

;; ---------------------------------------------------------------------------------------------
;; Interceptor Stone
;; ---------------------------------------------------------------------------------------------

(use-package interceptor-stone-mode
  :load-path "~/.emacs.d/raw/"
  :mode "\\.stone\\'"
  :interpreter "interceptor-stone")
(add-to-list 'auto-mode-alist '("\\.stone\\'" . interceptor-stone-mode))

(use-package interceptor-pebble-mode
  :load-path "~/.emacs.d/raw/"
  :mode "\\.pebbel\\'"
  :interpreter "interceptor-pebble")
(add-to-list 'auto-mode-alist '("\\.pebble\\'" . interceptor-pebble-mode))

;; ---------------------------------------------------------------------------------------------
;; Haskell
;; ---------------------------------------------------------------------------------------------

(use-package haskell-mode
             :bind (:map haskell-mode-map
                         (("C-," . haskell-move-nested-left)
                          ("C-." . haskell-move-nested-right)
                          ("C-c ." . (lambda ()
                                       (interactive)
                                       (let ((col (current-column)))
                                         (haskell-align-imports)
                                         (haskell-sort-imports)
                                         (goto-char (+ (point) col)))))
                          ;; Get type and info of the symbol at point
                          ("C-c C-t" . haskell-process-do-type)
                          ("C-c C-i" . haskell-process-do-info)
                          ;; Jump to the imports. Keep tabbing to jump between import groups
                          ("<f8>" . haskell-nagivate-imports)
                          ;; Jump to the definition of the current symbol
                          ("M-." . haskell-mode-tag-find)
                          ;; Open the cabal file
                          ("C-c v c" . haskell-cabal-visit-file)))
             :config
             (add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
             (add-hook 'haskell-mode-hook 'turn-on-haskell-decl-scan)
             (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode))

(use-package intero
             :hook (haskell . intero-mode))

(defun hackage ()
  "Search Hackage for a package by name"
  (interactive)
  (w3m-browse-url
   (concat
    "http://hackage.haskell.org/package/"
    (url-hexify-string (if mark-active
                           (buffer-substring (region-beginning) (region-end))
                         (read-string "Search Hackage: "))))))

(defun stackage ()
  "Search Stackage for a package by name"
  (interactive)
  (let* ((dominant (locate-dominating-file (buffer-file-name (current-buffer)) "stack.yaml"))
         (epkg (url-hexify-string
                (if mark-active
                    (buffer-substring (region-beginning) (region-end))
                  (read-string "Search Stackage: "))))
         (url (if dominant
                  (with-temp-buffer
                    (insert-file-contents (concat dominant "stack.yaml"))
                    (let* ((str (buffer-string))
                           (start (string-match "lts-[0-9]" str 0))
                           (end (string-match "^" str start)))
                      (concat "https://www.stackage.org/" (substring
                      str start (- end 1)) "/package/" epkg)))
                (concat "http://hackage.haskell.org/package/" epkg))))
    (w3m-browse-url url)))

(defun hayoo (query)
  "Do a Hayoo search for a query."
  (interactive
   (let ((def (haskell-ident-at-point)))
     (if (and def (symbolp def)) (setq def (symbol-name def)))
     (list (read-string (if def
                            (format "Hayoo query (default %s): " def)
                          "Hayoo query: ")
                        nil nil def))))
  (w3m-browse-url (format "http://hayoo.fh-wedel.de/?query=%s" query)))

;; ---------------------------------------------------------------------------------------------
;; TypeScript
;; ---------------------------------------------------------------------------------------------

(use-package typescript-mode
  :config
  (setq typescript-indent-level 2))

;; ---------------------------------------------------------------------------------------------
;; Custom Variables and Custom Faces by Emacs (GENERATED BY EMACS)
;; ---------------------------------------------------------------------------------------------

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(browse-url-browser-function 'browse-url-firefox)
 '(c-offsets-alist '((innamespace . 0)))
 '(custom-safe-themes
   '("84d2f9eeb3f82d619ca4bfffe5f157282f4779732f48a5ac1484d94d5ff5b279" default))
 '(exec-path
   '("/usr/bin" "/bin" "/usr/sbin" "/sbin" "/Applications/Emacs.app/Contents/MacOS/bin-x86_64-10_14" "/Applications/Emacs.app/Contents/MacOS/libexec-x86_64-10_14" "/Applications/Emacs.app/Contents/MacOS/libexec" "/Applications/Emacs.app/Contents/MacOS/bin"))
 '(fci-rule-character-color nil)
 '(fci-rule-color "#343d46")
 '(gas-enable-symbol-highlight nil)
 '(gas-opcode-column 8)
 '(haskell-notify-p t)
 '(haskell-stylish-on-save t)
 '(lsp-clients-clangd-args '("--compile-commands-dir=build"))
 '(lsp-clients-clangd-executable "clangd-10")
 '(org-agenda-tags-column -120)
 '(org-file-apps
   '((auto-mode . emacs)
     ("\\.mm\\'" . default)
     ("\\.x?html?\\'" . default)
     ("\\.pdf\\'" . "evince %s")
     ("\\.pptx\\'" . "libreoffice %s")
     ("\\.xlsx\\'" . "libreoffice %s")
     ("\\.docx\\'" . "libreoffice %s")))
 '(org-html-toplevel-hlevel 1)
 '(org-log-done 'note)
 '(org-log-into-drawer t)
 '(org-log-refile 'time)
 '(org-log-reschedule 'note)
 '(org-modules
   '(org-bbdb org-bibtex org-crypt org-docview org-gnus org-info org-irc org-mhe org-rmail org-w3m))
 '(org-refile-targets
   '(("~/cs/gtd_archive.org" :level . 1)
     (org-agenda-files :tag . "")
     (nil :tag . "")))
 '(org-tags-column -96)
 '(package-selected-packages
   '(htmlize auto-package-update flycheck-pos-tip typescript-mode esup jinja2-mode yaml-tomato yaml-mode smart-mode-line-powerline-theme smart-mode-line cmake-mode lsp-ui spinner lsp-mode dimmer centaur-tabs ivy treemacs which-key fill-column-indicator use-package))
 '(powerline-default-separator 'slant)
 '(powerline-display-buffer-size nil)
 '(powerline-display-hud t)
 '(powerline-display-mule-info nil)
 '(powerline-gui-use-vcs-glyph nil)
 '(powerline-minor-mode-filter-mode 'exclude)
 '(powerline-minor-mode-filter-regexp-list '("GitGutter" "Abbrev" "ELDoc" "Projectile" "WK" "ivy"))
 '(projectile-completion-system 'ivy)
 '(safe-local-variable-values
   '((org-html-htmlize-output-type . css)
     (htmlize-output-type . css)))
 '(size-indication-mode t)
 '(sp-highlight-pair-overlay nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 98 :spacing=90 :width normal :foundry "CTDB" :family "Fira Code"))))
 '(italic ((t (:slant oblique :family "DejaVu Sans Mono for Powerline"))))
 '(mode-line-inactive ((t (:background "Black" :foreground "gray60" :slant italic :weight normal))))
 '(org-agenda-date-today ((t (:foreground "#569cd6" :weight normal :height 1.0))))
 '(org-done ((t (:foreground "dark gray" :box nil :weight normal))))
 '(org-scheduled-today ((t (:foreground "#DCDCAA" :weight normal :height 1.0))))
 '(org-todo ((t (:foreground "#569cd6" :box nil :weight normal)))))
