;; skk-abbrev-mode-replace.el
;; 標準のskk-abbrev-mode を無効にして、一時英字入力モードにする。

(skk-mode)
;; 半角スペースを入力
(defun skk-space (&optional arg)
  (interactive "P")
  (insert " "))

;; -- skk-abbrev-mode時に入力した文字をcapitalizeする
;; skk.el の skk-toggle-character を書き換え
(defun skk-toggle-capitalize (arg)
  "skk-abbrev-mode時に入力した文字をcapitalizeする"
  (interactive "P")
  (cond
   ((eq skk-henkan-mode 'on)
    (let (char)
      (skk-save-point
       (goto-char skk-henkan-start-point)
       (while (and (>= skk-save-point (point))
                   ;; (not (eobp))
                   (or
                    ;; "ー" では文字種別が判別できないので、ポイントを進める。
                    (looking-at "ー")
                    (eq 'unknown (setq char (skk-what-char-type)))))
         (forward-char 1)))
      (skk-henkan-skk-region-by-func
       (cond ((eq char 'ascii) #'capitalize-region))
       ;; `skk-katakana-region' の引数 VCONTRACT または
       ;; `skk-hiragana-region' の引数 VEXPAND を与える。
       (memq char '(hiragana katakana)))))
   ((and (skk-in-minibuffer-p)
         (not skk-j-mode))
    ;; ミニバッファへの初突入時。
    (skk-j-mode-on))
   (t
    (setq skk-katakana (not skk-katakana))))
  (skk-kakutei)
  nil)


;; -- skk-abbrev-mode時に入力した文字をupppercaseにする
;; skk.el の skk-toggle-character を書き換え
(defun skk-toggle-uppercase (arg)
  "skk-abbrev-mode時に入力した文字をuppercaseにする"
  (interactive "P")
  (cond
   ((eq skk-henkan-mode 'on)
    (let (char)
      (skk-save-point
       (goto-char skk-henkan-start-point)
       (while (and (>= skk-save-point (point))
                   ;; (not (eobp))
                   (or
                    ;; "ー" では文字種別が判別できないので、ポイントを進める。
                    (looking-at "ー")
                    (eq 'unknown (setq char (skk-what-char-type)))))
         (forward-char 1)))
      (skk-henkan-skk-region-by-func
       (cond ((eq char 'ascii) #'upcase-region))
       ;; `skk-katakana-region' の引数 VCONTRACT または
       ;; `skk-hiragana-region' の引数 VEXPAND を与える。
       (memq char '(hiragana katakana)))))
   ((and (skk-in-minibuffer-p)
         (not skk-j-mode))
    ;; ミニバッファへの初突入時。
    (skk-j-mode-on))
   (t
    (setq skk-katakana (not skk-katakana))))
  (skk-kakutei)
  nil)


;; 1度変換して確定する
(defun skk-abbrev-henkan-kakutei (&optional arg)
  (interactive "P")
  (skk-start-henkan arg)
  (skk-kakutei))

;; hippie-expand で展開してから確定する
(defun skk-abbrev-kautei-hippie-expand (&optional args)
  (interactive "P")
  (hippie-expand args)
  (skk-kakutei))

;; skk-macs.el の skk-abbrev-mode-on を上書き
(defun skk-abbrev-mode-on ()
  (setq skk-mode t
        skk-abbrev-mode t
        skk-latin-mode nil
        skk-j-mode nil
        skk-jisx0208-latin-mode nil
        skk-jisx0201-mode nil
        )
  (skk-setup-keymap)
  ; skk-setup-keymap のあとでキーを追加
  (define-key skk-abbrev-mode-map " " 'skk-space)

  ;; abbrevのトグルを「半角←→全角」ではなく、「先頭を大文字(capitalize)」に変更
  (define-key skk-abbrev-mode-map "\C-q" 'skk-toggle-capitalize)

  ;; C-@ で小文字→大文字に変換する
  (define-key skk-abbrev-mode-map "\C-@" 'skk-toggle-uppercase)

  ;; abbrev-modeの時は\で確定にする
  (define-key skk-abbrev-mode-map "\\" 'skk-kakutei)

  ;; C-i で hippie-expand を呼び出す
  (define-key skk-abbrev-mode-map "\C-i" 'skk-abbrev-kautei-hippie-expand)
  (skk-update-modeline 'abbrev)
  (skk-cursor-set))
