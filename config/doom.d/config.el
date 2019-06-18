;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; General setup
(setq user-full-name    "Roland Siegbert"
      user-mail-address "roland@siegbert.info"

      +doom-modeline-buffer-file-name-style 'relative-from-project

      ;; TODO: Don't ask when killing emacs (really?)
      confirm-kill-emacs nil
      )

;; Font
(setq
 doom-font (font-spec :family "Iosevka Term Medium" :size 16)
 doom-big-font (font-spec :family "Iosevka Term Medium" :size 17)
 doom-variable-pitch-font (font-spec :family "Input" :size 16))

;; TODO
;;;; (when IS-LINUX
;;;;   (font-put doom-font :weight 'semi-light))
;;;; (when IS-MAC
;;;;   (setq ns-use-thin-smoothing t))

;; Themes
(require 'doom-themes)

;;; Frames/Windows
(add-to-list 'default-frame-alist '(inhibit-double-buffering . t))

;; Global settings (defaults)
(setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
      doom-themes-enable-italic t) ; if nil, italics is universally disabled

;; Load the theme (doom-one, doom-molokai, etc); keep in mind that each theme
;; may have their own settings.
(load-theme 'doom-one-light' t)

;; Enable flashing mode-line on errors
(doom-themes-visual-bell-config)

;; Enable custom neotree theme (all-the-icons must be installed!)
(doom-themes-neotree-config)

;; or for treemacs users
(doom-themes-treemacs-config)

;; Corrects (and improves) org-mode's native fontification.
(doom-themes-org-config)

;; Enable emoji globally
(add-hook 'after-init-hook #'global-emojify-mode)


;;
;;; :lang org
(after! org
  (add-to-list 'org-modules 'org-habit t))

;; Pop-rule
(after! org
  (set-popup-rule! "^\\*Org Agenda.*\\*$" :size 0.5 :side 'right :vslot 1  :select t :quit t   :ttl nil :modeline nil :autosave t)
  (set-popup-rule! "^CAPTURE.*\\.org$"    :size 0.4 :side 'bottom          :select t                                  :autosave t))

;; automatically redisplay images generated by babel
(add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images)

;; place latex-captions below figures and tables
(setq org-latex-caption-above nil)

(setq org-directory "~/org/"
      org-agenda-files (list org-directory)
      org-ellipsis " ▼ "

      ;; The standard unicode characters are usually misaligned depending on the
      ;; font. This bugs me. Markdown #-marks for headlines are more elegant.
      org-bullets-bullet-list '("#"))

;; Org-Noter
(def-package! org-noter
  :defer t
  :after org-mode
  :config
  (map!
   (:leader
     (:prefix "n"
       :desc "Org-noter-insert" :n "i" #'org-noter-insert-note))))

;; Setup
(setq org-noter-always-create-frame nil
      org-noter-auto-save-last-location t)

;;
;; Show week numbers in calendar
  (setq calendar-week-start-day 1
        calendar-intermonth-text
        '(propertize
          (format "%2d"
                  (car
                   (calendar-iso-from-absolute
                    (calendar-absolute-from-gregorian (list month day year)))))
          'font-lock-face 'font-lock-function-name-face))

;; Projectile
(setq projectile-enable-caching nil)

;; Magit
;; automatic spellchecking in commit messages
(add-hook 'git-commit-setup-hook 'git-commit-turn-on-flyspell)
;; mitigate terminal is dumb
(setenv "EDITOR" "emacsclient")
;; submodules
(with-eval-after-load 'magit
(magit-add-section-hook 'magit-status-sections-hook
                            'magit-insert-modules
                            'magit-insert-unpulled-from-upstream)
  (setq magit-module-sections-nested nil))

;;
;;; eshell
;; add fish-like autocompletion
(def-package! esh-autosuggest
  :defer t
  :after eshell-mode
  :config
  (add-hook 'eshell-mode-hook #'esh-autosuggest-mode)
  ;; utilize completion from fish
  (when (and (executable-find "fish")
             (require 'fish-completion nil t))
    (global-fish-completion-mode)))

;; fix pcomplete-completions-at-point uses a deprecated calling function
(add-hook 'eshell-mode-hook (lambda ()
                              (remove-hook 'completion-at-point-functions #'pcomplete-completions-at-point t)))
;; aliases
(after! eshell
  (set-eshell-alias!
   "ff"  "+ivy/projectile-find-file"
   "fd"  "counsel-projectile-find-dir"
   "/p" "+ivy/project-search"
   "/d" "+ivy/project-search-from-cwd"
   "d"   "deer $1"
   "l"   "ls -l"
   "la"  "ls -la"
   "gl"  "(call-interactively 'magit-log-current)"
   "gs"  "magit-status"
   "gc"  "magit-commit"
   "gbD" "my/git-branch-delete-regexp $1"
   "gbS" "my/git-branch-match $1"
   "rg"  "rg --color=always $*"
   "bat" "my/eshell-bat $1"))
;; Improvements from howard abrahams
;; programs that want to pause the output uses cat instead
(setenv "PAGER" "cat")

;;
;;; Keybinds

(map! :m "M-j" #'multi-next-line
      :m "M-k" #'multi-previous-line

      ;; Easier window movement
      :n "C-h" #'evil-window-left
      :n "C-j" #'evil-window-down
      :n "C-k" #'evil-window-up
      :n "C-l" #'evil-window-right

      (:map vterm-mode-map
        ;; Easier window movement
        :i "C-h" #'evil-window-left
        :i "C-j" #'evil-window-down
        :i "C-k" #'evil-window-up
        :i "C-l" #'evil-window-right)

      (:map evil-treemacs-state-map
        "C-h" #'evil-window-left
        "C-l" #'evil-window-right
        "M-j" #'multi-next-line
        "M-k" #'multi-previous-line)

      (:when IS-LINUX
        "s-x" #'execute-extended-command
        "s-;" #'eval-expression
        ;; use super for window/frame navigation/manipulation
        "s-w" #'delete-window
        "s-W" #'delete-frame
        "s-n" #'+default/new-buffer
        "s-N" #'make-frame
        "s-q" (if (daemonp) #'delete-frame #'evil-quit-all)
        ;; Restore OS undo, save, copy, & paste keys (without cua-mode, because
        ;; it imposes some other functionality and overhead we don't need)
        "s-z" #'undo
        "s-c" (if (featurep 'evil) #'evil-yank #'copy-region-as-kill)
        "s-v" #'yank
        "s-s" #'save-buffer
        ;; Buffer-local font scaling
        "s-+" #'doom/reset-font-size
        "s-=" #'doom/increase-font-size
        "s--" #'doom/decrease-font-size
        ;; Conventional text-editing keys
        "s-a" #'mark-whole-buffer
        :gi [s-return]    #'+default/newline-below
        :gi [s-S-return]  #'+default/newline-above
        :gi [s-backspace] #'doom/backward-kill-to-bol-and-indent)

      :leader
      (:prefix "f"
        "t" #'find-in-dotfiles
        "T" #'browse-dotfiles))
