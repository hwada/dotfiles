;; package管理
(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("org"   . "https://orgmode.org/elpa/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

;; auto-complete（自動補完）
(require 'auto-complete-config)
(global-auto-complete-mode 0.5)

;; el-get
;(add-to-list 'load-path (locate-user-emacs-file "el-get/el-get"))
;(unless (require 'el-get nil 'noerror)
;  (with-current-buffer
;      (url-retrieve-synchronously "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
;    (goto-char (point-max))
;    (eval-print-last-sexp)))
;(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")

;(el-get-bundle auto-complete)
;(el-get-bundle org-mode)

;; 日本語環境の設定
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(set-default 'buffer-file-coding-system 'utf-8)

;; Windowsにおけるフォントの設定（Consolasとメイリオ）
(set-face-attribute 'default nil :family "Consolas" :height 110)
(set-fontset-font 'nil 'japanese-jisx0208
                  (font-spec :family "メイリオ"))
(add-to-list 'face-font-rescale-alist
              '(".*メイリオ.*" . 1.08))

;; color theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'monokai t)

;; line numberの表示
(require 'linum)
(global-linum-mode t)

(setq default-tab-width 4) ; tabサイズ
(menu-bar-mode 0) ; メニューバーを非表示
(tool-bar-mode 0) ; ツールバーを非表示
(scroll-bar-mode -1) ; default scroll bar消去
(which-function-mode 1) ; 現在ポイントがある関数名をモードラインに表示
(show-paren-mode 1) ; 対応する括弧をハイライト
(transient-mark-mode 1) ; リージョンのハイライト
(setq inhibit-startup-message 1) ; スタートアップメッセージを表示させない

;; ターミナルで起動したときにメニューを表示しない
(if (eq window-system 'x)
    (menu-bar-mode 1) (menu-bar-mode 0))
(menu-bar-mode nil)

;; scratchの初期メッセージ消去
(setq initial-scratch-message "")

;; スクロールは1行ごとに
(setq mouse-wheel-scroll-amount '(1 ((shift) . 5)))

;; スクロールの加速をやめる
(setq mouse-wheel-progressive-speed nil)

;; key-map
(define-key global-map "\C-\\" 'undo)

;; bufferの最後でカーソルを動かそうとしても音をならなくする
(defun next-line (arg)
  (interactive "p")
  (condition-case nil
      (line-move arg)
    (end-of-buffer)))

;; beep音無効
(setq ring-bell-function 'ignore)


;; org-modeの設定
(setq org-directory "~/Dropbox/memo/org")
(setq org-default-notes-file "notes.org")

; Org-captureを呼び出すキーシーケンス
(define-key global-map "\C-cc" 'org-capture)
; Org-captureのテンプレート（メニュー）の設定
(setq org-capture-templates
      '(("n" "Note" entry (file+headline "~/Dropbox/memo/org/notes.org" "Notes")
         "* %?\nEntered on %U\n %i\n %a")
        ))

(defun insert-current-date()
  "現在年月日をカレントバッファに出力します。引数Nを与えるとN日前を出力します。"
  (interactive)
  (insert (format-time-string "%Y-%m-%d(%a) %H:%M:%S" (current-time))))

(define-key global-map "\C-c\C-j" 'org-journal-new-entry) ; 標準で定義されない?
; メモをC-M-^一発で見るための設定
; https://qiita.com/takaxp/items/0b717ad1d0488b74429d から拝借
(defun show-org-buffer (file)
  "Show an org-file FILE on the current buffer."
  (interactive)
  (if (get-buffer file)
      (let ((buffer (get-buffer file)))
        (switch-to-buffer buffer)
        (message "%s" file))
    (find-file (concat "~/Dropbox/memo/org/" file))))
(global-set-key (kbd "C-M-^") '(lambda () (interactive)
                                 (show-org-buffer "notes.org")))
(use-package org-journal
  :ensure t
  :defer t
  :custom
  (org-journal-dir "~/Dropbox/memo/org/journal")
  (org-journal-file-format "%Y-%m-%d")
  (org-journal-date-format "%A, %d %B %Y"))
  
;; ivy設定
(require 'ivy)
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)
(setq ivy-height 30) ;; minibufferのサイズを拡大（重要）
(setq ivy-extra-directories nil)
(setq ivy-re-builders-alist
      '((t . ivy--regex-plus)))

;; counsel設定
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "C-M-r") 'counsel-recentf)
(setq counsel-find-file-ignore-regexp (regexp-opt '("./" "../")))
(global-set-key "\C-s" 'swiper)
(setq swiper-include-line-number-in-search t) ;; line-numberでも検索可能

;; migemo + swiper（日本語をローマ字検索できるようになる）
;(require 'avy-migemo)
;(avy-migemo-mode 1)
;(require 'avy-migemo-e.g.swiper)


;; dumb-jump
(require 'dumb-jump)
; これをしないとホームディレクトリ以下が検索対象になる
(setq dumb-jump-default-project "")
; 日本語を含むパスだとgit grepがちゃんと動かない…
(setq dumb-jump-force-searcher 'rg)
; 標準キーバインドを有効にする
(dumb-jump-mode)


;; magit
(require 'magit)
(global-set-key (kbd "C-x g") 'magit-status)
