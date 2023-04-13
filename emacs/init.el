(defvar koi/default-font "Iosevkoi")
(defvar koi/variable-pitch-font "Iosevkoi")
(defvar koi/default-font-size 140)
(defvar koi/variable-pitch-font-size 140)
(defvar koi/frame-transparency '(90 . 90))
(defvar koi/scroll-step 8)

(setq gc-cons-threshold (* 50 1000 1000))

(defun koi/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                    (time-subtract after-init-time before-init-time)))
           gcs-done))
(add-hook 'emacs-startup-hook #'koi/display-startup-time)

(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Update regularly
(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

(use-package restart-emacs)

(defun koi/reload()
  (interactive)
  (org-babel-tangle-file '"~/.emacs.d/init.org")
  (org-reload)
  (load-file user-init-file))

(defun koi/restart()
  (interactive)
  (koi/reload)
  (restart-emacs))

(setq inhibit-startup-message t)

(tool-bar-mode -1)
(scroll-bar-mode)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)

(defalias 'yes-or-no-p 'y-or-n-p)

(setq-default
 smooth-scroll-margin 0
 cursor-type 'box  ;; (box, bar, hbar)
 locale-coding-system 'utf-8)

(setq
 vc-follow-symlinks t           ;follow symlinks automatically
 mouse-yank-at-point t	        ;middle click with the mouse yanks at point
 mouse-autoselect-window -.1)   ;window focus follows the mouse pointer

(setq
 scroll-margin koi/scroll-step
 hscroll-margin koi/scroll-step

 ;; make mouse scrolling smooth
 mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control)))
 mouse-wheel-progressive-speed nil

 scroll-conservatively 10
 scroll-preserve-screen-position 1
 fast-but-imprecise-scrolling t)

;; If a text is selected and you type something, itwnds
(delete-selection-mode t)

(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'lsp-ui-doc-frame-mode-hook #'(lambda()(display-line-numbers-mode -1)))
(add-hook 'org-mode-hook #'(lambda()(display-line-numbers-mode -1)))

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(global-unset-key (kbd "C-z"))

;; Set frame transparency
(set-frame-parameter (selected-frame) 'alpha koi/frame-transparency)
(add-to-list 'default-frame-alist `(alpha . ,koi/frame-transparency))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(defvar koi/tab-width 4)
(setq default-tab-width koi/tab-width)
(setq tab-width koi/tab-width)

(global-hl-line-mode t)

(set-fringe-mode 10)

(setq lexical-binding t) ;; Highlighting

(defvar my-todo "~/personal/notes/todo.org")
(ffap-bindings)

(setq
 confirm-nonexistent-file-or-buffer nil ; don't ask to create a buffer
 eval-expression-print-length nil ; do not truncate printed expressions
 eval-expression-print-level nil  ; print nested expressions

 jit-lock-defer-time 0
 send-mail-function 'sendmail-send-it
 indicate-buffer-boundaries 'right       ;fringe markers (on the left side)
 enable-recursive-minibuffers t	 ;whatever...
 load-prefer-newer t			 ;prefer newer .el instead of the .elc
 switch-to-buffer-preserve-window-point t) ;this allows operating on the same buffer in diff. positions

;; Libraries
(use-package dash)
(use-package s)

;; (defvar cache-dir "~/.config/emacs/tmp/")

(setq history-length 300   ; Default is 30

      kill-ring-max 5000   ; Truncate kill ring after 5000 entries
      mark-ring-max 5000)  ; Truncate mark ring after 5000 entries

(savehist-mode 1)
(use-package no-littering)

(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))
                               auto-save-file-name-transforms `((".*", temporary-file-directory t))
                               savehist-additional-variables '(kill-ring search-ring regexp-search-ring))

(use-package recentf
  :init
  (recentf-mode 1)
  :config
  (setq recentf-max-saved-items 500)
  (setq recentf-max-menu-items 60))

;; folding
(use-package origami)
(use-package vimish-fold)

(setq show-paren-delay 0) ; show immediately

(use-package paredit
  :config (paredit-mode t))

(use-package rainbow-mode)
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package evil
  :init
  (setq evil-want-fine-undo nil)
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(setq evilnc-comment-text-object "c")
(use-package evil-nerd-commenter
  :after evil
  :bind ("M-;" . evilnc-comment-or-uncomment-lines))

;; (setq evilnc-comment-text-object "c")
(define-key evil-inner-text-objects-map evilnc-comment-text-object 'evilnc-inner-commenter)
(define-key evil-outer-text-objects-map evilnc-comment-text-object 'evilnc-outer-commenter)

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package general
  :after evil
  :config
  (general-create-definer koi/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-c")

  (koi/leader-keys
    "t" '(:ignore t :which-key "Toggles")
    "ts" '(hydra-text-scale/body :which-key "Scale text")
    "tt" '(counsel-load-theme :which-key "Choose theme")))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.3))

(use-package beacon
  :config
  (beacon-mode 1))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :after ivy
  :init (ivy-rich-mode 1))

(use-package counsel
  :bind (("C-M-j" . 'counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))

  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1))

(use-package ivy-prescient
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  ;; Uncomment the following line to have sorting remembered across sessions!
  (prescient-persist-mode 1)
  (ivy-prescient-mode 1))

(use-package hydra
  :defer t)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package vimish-fold)
(use-package nix-mode)

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :commands (projectile-project-root
             projectile-project-name
             projectile-project-p
             projectile-locate-dominating-file
             projectile-relevant-known-projects)
  :init
  (setq projectile-cache-file (concat cache-dir "projectile.cache")
        ;; Auto-discovery is slow to do by default. Better to update the list
        ;; when you need to (`projectile-discover-projects-in-search-path').
        projectile-auto-discover nil
        projectile-enable-caching (not noninteractive)
        projectile-globally-ignored-files '(".DS_Store" "TAGS")
        projectile-globally-ignored-file-suffixes '(".elc" ".pyc")))

(setq projectile-project-root-files-bottom-up
      (append '(".projectile"  ; projectile's root marker
                ".project"     ; doom project marker
                ".git")        ; Git VCS root dir
              (when (executable-find "hg")
                '(".hg"))      ; Mercurial VCS root dir
              (when (executable-find "bzr")
                '(".bzr")))    ; Bazaar VCS root dir
      ;; This will be filled by other modules. We build this list manually so
      ;; projectile doesn't perform so many file checks every time it resolves
      ;; a project's root -- particularly when a file has no project.
      projectile-project-root-files '()
      projectile-project-root-files-top-down-recurring '("Makefile"))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit)
(use-package forge)

(defun koi/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :commands (lsp lsp-deferred)
  :hook ((lsp-mode . koi/lsp-mode-setup)
         (lsp-mode . lsp-enable-which-key-integration)))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom)
  :config
  (setq lsp-ui-sideline-enable t)
  (setq lsp-ui-sideline-show-hover t))
(use-package lsp-treemacs :after lsp)
(use-package lsp-ivy)

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
  (:map lsp-mode-map
        ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(add-hook 'after-init-hook 'global-company-mode)

(use-package company-box
  :hook (company-mode . company-box-mode))
(use-package company-quickhelp
  :config
  (company-quickhelp-mode 1))

(use-package tree-sitter
  :config
  (global-tree-sitter-mode))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package dired-single)

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(use-package ranger)

(use-package vterm
  :commands vterm
  :config
  (setq vterm-shell "fish")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000))


(defun koi/configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  ;; Bind some useful keys for evil-mode
  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell
  :hook (eshell-first-time-mode . koi/configure-eshell)
  :config
  (setq eshell-rc-script "~/.dotfiles/emacs/eshell/profile"
        eshell-aliases-file "~/.dotfiles/emacs/eshell/aliases"
        eshell-history-size 5000
        eshell-buffer-maximum-lines 5000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t
        eshell-destroy-buffer-when-process-dies t
        eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh")))
(use-package eshell-git-prompt)

(use-package doom-themes
  :init (load-theme 'doom-moonlight t))

(use-package all-the-icons
  :after 'dashboard-mode)

(column-number-mode)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

(use-package page-break-lines ;; Required for fancy lines
  :after ('dashboard-mode)
  :init (global-page-break-lines-mode 1))

(use-package dashboard
  :config (dashboard-setup-startup-hook)
  :custom
  (setq dashboard-startup-banner "~/Pictures/.wallpapers/eicon.png"
        dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-center-content t
        dashboard-banner-logo-title nil
        dashboard-set-init-info t
        dashboard-set-footer t
        dashboard-footer-messages '("Dashboard is pretty cool!")
        dashboard-footer-icon '(all-the-icons-octicon "dashboard"
                                                      :height 1.1
                                                      :v-adjust -0.05
                                                      :face 'font-lock-keyword-face)))

(set-face-attribute 'default nil :font koi/default-font :height koi/default-font-size)
(set-face-attribute 'fixed-pitch nil :font koi/default-font :height koi/default-font-size)
(set-face-attribute 'variable-pitch nil :font koi/default-font :height koi/variable-pitch-font-size :weight 'regular)

(defun jk/org-colors-catppuccin ()
  "Enable Catppuccin colors for Org headers."
  (interactive)
  (dolist
      (face
       '((org-level-1 1.4 "#fab387" "#241E29" ultra-bold);;Peach
         (org-level-2 1.3 "#f38ba8" "#29222F" normal)    ;;Red
         (org-level-3 1.2 "#cba6f7" "#332B3B" normal)    ;;Mauve
         (org-level-4 1.1 "#89b4fa" "#2B313B" normal)    ;;Blue
         (org-level-5 1.0 "#74c7ec" "#2B363B" normal)    ;;Sapphire
         (org-level-6 1.0 "#a6e3a1" "#2D3B2B" normal)    ;;Green
         (org-level-7 1.0 "#f9e2af" "#3B362B" normal)    ;;Yellow
         (org-level-8 1.0 "#fab387" "#3B312B" normal)))  ;;Pearh
    (set-face-attribute (nth 0 face) nil :font koi/variable-pitch-font :weight (nth 4 face) :height (nth 1 face) :foreground (nth 2 face) :background (nth 3 face)))
  (set-face-attribute 'org-hide nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil :inherit '(shadow fixed-pitch) :font koi/default-font :weight 'normal :height 1.0 :foreground "#bac2de")
  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(defun koi/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(defun koi/org-mode-visual-fill ()
  (setq visual-fill-column-width 120
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package org
  :hook (org-mode . koi/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")
  (setq org-hide-emphasis-markers t)

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-agenda-files
        '("~/personal/todo.org"))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
          (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  (setq org-refile-targets
        '(("Archive.org" :maxlevel . 1)
          ("Tasks.org" :maxlevel . 1)))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
        '((:startgroup)
                                        ; Put mutually exclusive tags here
          (:endgroup)
          ("@errand" . ?E)
          ("@home" . ?H)
          ("@work" . ?W)
          ("agenda" . ?a)
          ("planning" . ?p)
          ("publish" . ?P)
          ("batch" . ?b)
          ("note" . ?n)
          ("idea" . ?i)))

  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
        '(("d" "Dashboard"
           ((agenda "" ((org-deadline-warning-days 7)))
            (todo "NEXT"
                  ((org-agenda-overriding-header "Next Tasks")))
            (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

          ("n" "Next Tasks"
           ((todo "NEXT"
                  ((org-agenda-overriding-header "Next Tasks")))))

          ("W" "Work Tasks" tags-todo "+work-email")

          ;; Low-effort next actions
          ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
           ((org-agenda-overriding-header "Low Effort Tasks")
            (org-agenda-max-todos 20)
            (org-agenda-files org-agenda-files)))

          ("w" "Workflow Status"
           ((todo "WAIT"
                  ((org-agenda-overriding-header "Waiting on External")
                   (org-agenda-files org-agenda-files)))
            (todo "REVIEW"
                  ((org-agenda-overriding-header "In Review")
                   (org-agenda-files org-agenda-files)))
            (todo "PLAN"
                  ((org-agenda-overriding-header "In Planning")
                   (org-agenda-todo-list-sublevels nil)
                   (org-agenda-files org-agenda-files)))
            (todo "BACKLOG"
                  ((org-agenda-overriding-header "Project Backlog")
                   (org-agenda-todo-list-sublevels nil)
                   (org-agenda-files org-agenda-files)))
            (todo "READY"
                  ((org-agenda-overriding-header "Ready for Work")
                   (org-agenda-files org-agenda-files)))
            (todo "ACTIVE"
                  ((org-agenda-overriding-header "Active Projects")
                   (org-agenda-files org-agenda-files)))
            (todo "COMPLETED"
                  ((org-agenda-overriding-header "Completed Projects")
                   (org-agenda-files org-agenda-files)))
            (todo "CANC"
                  ((org-agenda-overriding-header "Cancelled Projects")
                   (org-agenda-files org-agenda-files)))))))

  (setq org-capture-templates
        `(("t" "Tasks / Projects")
          ("tt" "Task" entry (file+olp "~/Projects/Code/emacs-from-scratch/OrgFiles/Tasks.org" "Inbox")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

          ("j" "Journal Entries")
          ("jj" "Journal" entry
           (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
           :clock-in :clock-resume
           :empty-lines 1)
          ("jm" "Meeting" entry
           (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

          ("w" "Workflows")
          ("we" "Checking Email" entry (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

          ("m" "Metrics Capture")
          ("mw" "Weight" table-line (file+headline "~/Projects/Code/emacs-from-scratch/OrgFiles/Metrics.org" "Weight")
           "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)))

  (define-key global-map (kbd "C-c j")
    (lambda () (interactive) (org-capture nil "jj")))

  (jk/org-colors-catppuccin))


(use-package org-superstar
  :after org
  :config
  (setq
   org-ellipsis " ⋯ "
   org-superstar-headline-bullets-list '("" "◉" "●" "○" "•") ;;⁖  if 1. dont work
   org-superstar-item-bullet-alist '((?+ . ?➤) (?- . ?✦))) ; changes +/- symbols in item lists
  (add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))
  :custom
  ((set-face-attribute 'org-superstar-item nil :height 1.0)
   (set-face-attribute 'org-superstar-header-bullet nil :height 0.8)
   (set-face-attribute 'org-superstar-leading nil :height 1.3)))


(use-package visual-fill-column
  :hook (org-mode . koi/org-mode-visual-fill))

(with-eval-after-load 'org

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes))

(with-eval-after-load 'org
  ;; This is needed as of Org 9.2
  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python")))

;; Automatically tangle our Emacs.org config file when we save it
(defun koi/org-babel-tangle-config ()
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'koi/org-babel-tangle-config)))

(custom-set-faces
 '(markdown-header-face ((t (:inherit font-lock-function-name-face :weight bold :family koi/variable-pitch-font))))
 '(markdown-header-face-1 ((t (:inherit markdown-header-face :height 1.5))))
 '(markdown-header-face-2 ((t (:inherit markdown-header-face :height 1.4))))
 '(markdown-header-face-3 ((t (:inherit markdown-header-face :height 1.3))))
 '(markdown-header-face-4 ((t (:inherit markdown-header-face :height 1.2))))
 '(markdown-header-face-5 ((t (:inherit markdown-header-face :height 1.0))))
 '(markdown-header-face-6 ((t (:inherit markdown-header-face :height 1.0)))))

(setq org-fontify-whole-heading-line t
      org-fontify-done-headline t
      org-fontify-quote-and-verse-blocks t)