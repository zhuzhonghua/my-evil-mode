;; my evil mode
;; forbiden single key change

(defun dummy-bind ()
	(interactive)
	(message "dummy key"))

(defvar my-evil-mode-hook nil)

(defvar my-evil-local-mode-map
	(make-keymap))

(define-minor-mode my-evil-local-mode
	"read only except prefix keystrokes"
	:init-value nil
	:global 1
	:lighter " my-evil"
	:keymap my-evil-local-mode-map)

(defvar-local pre-keystrokes '()
	"record pre keystrokes to perform next operation")

(defvar-local line-selection-overlay nil
	"the overlay of just line selection")

(defvar-local visual-begin-pos nil
	"begin pos of the visual line")

(defvar-local visual-end-pos nil
	"end pos of the visual line")

(defun clear-keystrokes ()
	"clear saved keystrokes"
	(setq pre-keystrokes '()))

(defun advice-clear-everything ()
	(clear-keystrokes)
	;;(message "clear keystrokes")
	(if line-selection-overlay
			(delete-overlay line-selection-overlay))
	(setq line-selection-overlay nil)
	(setq visual-begin-pos nil)
	(setq visual-end-pos nil))

(advice-add #'keyboard-quit :before #'advice-clear-everything)

(defmacro push-keystrokes (k)
	"the macro save keystrokes to later action"
	`(lambda ()
		 (interactive)
		 (push ,k pre-keystrokes)
		 (message "saved keystrokes %s" pre-keystrokes)
		 (if (trigger-operation ,k)
				 (clear-keystrokes))))

(defun refresh-visual-pos ()
	"update the var's value"
	(if visual-begin-pos
			(let ((line-begin-pos-now (line-beginning-position)))
				(setq visual-begin-pos (if (< line-begin-pos-now visual-begin-pos)
																	 line-begin-pos-now
																 visual-begin-pos)))
		(setq visual-begin-pos (line-beginning-position)))
	(if visual-end-pos
			(let ((line-end-pos-now (line-end-position)))
				(setq visual-end-pos (if (> line-end-pos-now visual-end-pos)
																	 line-end-pos-now
																 visual-end-pos)))
		(setq visual-end-pos (line-beginning-position))))

(defun make-line-visual-selection ()
	"start line visual selection"
	(interactive)
	(refresh-visual-pos)
	(if line-selection-overlay
			(move-overlay line-selection-overlay visual-begin-pos visual-end-pos)
		(setq line-selection-overlay
					(make-overlay visual-begin-pos visual-end-pos)))
	(overlay-put line-selection-overlay 'face 'region))

(defun trigger-operation (arg)
	"trigger multi key operation"
	(cond ((eq 'd arg) (or (trigger-dd)
												 (trigger-d-region-kill)))
				((eq 'y arg) (or (trigger-yy)
												 (trigger-y-region-copy)))))

(defun trigger-dd ()
	"check if can trigger dd operation"
	(if (and (eq 'd (car pre-keystrokes))
					 (eq 'd (cadr pre-keystrokes)))
			(let ((empty-line? (eq (line-beginning-position)
														 (line-end-position))))
				(ignore-errors
					(move-beginning-of-line nil)
					(kill-line))
				(if (not empty-line?)
						(delete-char 1))
				t)))

(defun trigger-d-region-kill ()
	"kill select region"
	(if mark-active
			(progn
				(kill-region (region-beginning) (region-end))
				t)))

(defun trigger-yy ()
	"check if can trigger yy operation"
	(if (and (eq 'y (car pre-keystrokes))
					 (eq 'y (cadr pre-keystrokes)))
			(progn
				(kill-ring-save (line-beginning-position) (line-end-position))
				t)))

(defun trigger-y-region-copy ()
	"if mark-active copy"
	(if mark-active
			(progn
				(kill-ring-save (region-beginning) (region-end))
				t)))

(defun do-p-operation ()
	"do p operation = yank"
	(interactive)
	(move-end-of-line nil)
	(newline)
	(yank))

(defun do-upper-p-operation ()
	"do P operation = yank"
	(interactive)
	(move-previous-line-new-line)
	(yank))
	
(defun move-next-line ()
	"move next line check visual selection"
	(interactive)
	(next-line)
	)

(defun my-evil-initialize ()
	(unless (or (minibufferp)
							(not (equal (key-binding "k") 'self-insert-command)))
		(my-evil-local-mode 1)
		(clear-keystrokes)))

(define-globalized-minor-mode	my-evil-mode my-evil-local-mode	my-evil-initialize)

(defun my-evil-mode-disable ()
	"Disable my evil mode on special occation"
	(interactive)
	(my-evil-local-mode -1)
	(advice-clear-everything))

(defun my-evil-mode-enable ()
	"auto enable my evil mode when evil mode"
	(interactive)	
	(if (and (not (bound-and-true-p my-evil-local-mode))
					 (/= (point) (line-beginning-position)))
			(backward-char))
	(my-evil-local-mode 1))


(define-key my-evil-local-mode-map (kbd "0") 'move-beginning-of-line)
(define-key my-evil-local-mode-map (kbd "1") 'dummy-bind)
;; just for test
;;(define-key my-evil-local-mode-map (kbd "1") (push-keystrokes 1))
(define-key my-evil-local-mode-map (kbd "2") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "3") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "4") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "5") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "6") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "7") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "8") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "9") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "a") 'forward-char-insert)
(define-key my-evil-local-mode-map (kbd "A") 'line-end-insert)
(define-key my-evil-local-mode-map (kbd "b") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "B") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "c") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "C") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "d") (push-keystrokes 'd))
(define-key my-evil-local-mode-map (kbd "D") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "e") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "E") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "f") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "F") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "g") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "G") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "h") 'backward-char)
(define-key my-evil-local-mode-map (kbd "H") 'backward-char)
(define-key my-evil-local-mode-map (kbd "i") 'my-evil-mode-disable)
(define-key my-evil-local-mode-map (kbd "I") 'my-evil-mode-disable)
(define-key my-evil-local-mode-map (kbd "j") 'next-line)
(define-key my-evil-local-mode-map (kbd "J") 'next-line)
(define-key my-evil-local-mode-map (kbd "k") 'previous-line)
(define-key my-evil-local-mode-map (kbd "K") 'previous-line)
(define-key my-evil-local-mode-map (kbd "l") 'forward-char)
(define-key my-evil-local-mode-map (kbd "L") 'forward-char)
(define-key my-evil-local-mode-map (kbd "m") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "M") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "n") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "N") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "o") 'next-line-insert)
(define-key my-evil-local-mode-map (kbd "O") 'previous-line-insert)
(define-key my-evil-local-mode-map (kbd "p") 'do-p-operation)
(define-key my-evil-local-mode-map (kbd "P") 'do-upper-p-operation)
(define-key my-evil-local-mode-map (kbd "q") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "Q") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "r") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "R") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "s") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "S") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "t") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "T") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "u") 'undo)
(define-key my-evil-local-mode-map (kbd "U") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "v") 'set-mark-command)
(define-key my-evil-local-mode-map (kbd "V") 'make-line-visual-selection)
(define-key my-evil-local-mode-map (kbd "w") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "W") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "x") 'delete-char)
(define-key my-evil-local-mode-map (kbd "X") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "y") (push-keystrokes 'y))
(define-key my-evil-local-mode-map (kbd "Y") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "z") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "Z") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "DEL") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "RET") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "SPC") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd ";") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd ":") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "/") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "?") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd ",") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "<") 'beginning-of-buffer)
(define-key my-evil-local-mode-map (kbd ".") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd ">") 'end-of-buffer)
(define-key my-evil-local-mode-map (kbd "'") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "\"") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "[") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "{") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "]") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "}") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "-") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "_") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "+") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "=") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "\\") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "|") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "#") 'dummy-bind)
(define-key my-evil-local-mode-map (kbd "$") 'move-end-of-line)

(defun line-end-insert ()
	(interactive)
	(move-end-of-line nil)
	(my-evil-mode-disable))

(defun next-line-insert ()
	(interactive)
	(move-end-of-line nil)
	(newline)
	(my-evil-mode-disable))

(defun forward-char-insert ()
	(interactive)
	(forward-char)
	(my-evil-mode-disable))

(defun move-previous-line-new-line ()
	"move to previous line check first line"
	(if (= 1 (line-number-at-pos))
			(progn
				(move-beginning-of-line nil)
				(newline)
				(previous-line nil))
		(progn
			(previous-line nil)
			(move-end-of-line nil)
			(newline))))

(defun previous-line-insert ()
	(interactive)
	(move-previous-line-new-line)
	(my-evil-mode-disable))

(defun kill-whole-line (&optional arg)
	(interactive)
	(move-beginning-of-line arg)
	(kill-line arg)
	(kill-line arg))

;;(global-set-key (kbd "M-i") 'my-evil-mode)

(add-hook 'minibuffer-setup-hook 'my-evil-mode-disable)
(add-hook 'minibuffer-exit-hook 'my-evil-mode-enable)

(provide 'my-evil-mode)
