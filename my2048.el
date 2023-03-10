(defun 2048/get-number (x y)
  (aref (aref 2048/board y) x)
  )

(defun 2048/set-number (x y number)
  (aset (aref 2048/board y) x number)
  )

(defun 2048/count-space ()
  (let ((count 0))
    (dotimes (i 2048/board-size count)
	     (dotimes (j 2048/board-size)
		      (if (= (2048/get-number i j) 0) (setq count (+ count 1)))
		      )
	     )
    )
  )

(defun 2048/add-new-square ()
    (catch 'break
      (if (= (2048/count-space) 0) (throw 'break 0))
      (let ((i (random 2048/board-size)) (j (random 2048/board-size)) (prob (random 100)))
	(while (/= (2048/get-number i j) 0)
	  (setq i (random 2048/board-size))
	  (setq j (random 2048/board-size))
	  )
	(if (< prob 80)
	    (2048/set-number i j 2)
	  (2048/set-number i j 4)
	  )
	)
      )
    )

(defun 2048/draw ()
  (setq 2048/row-line (propertize "+-------" 'face '(:height 150)))
  (setq 2048/row-line-end (propertize "+\n" 'face '(:height 150)))
  (setq 2048/col-line (propertize "|       " 'face '(:height 150)))
  (setq 2048/col-line-end (propertize "|\n" 'face '(:height 150)))
  (dotimes (i 2048/board-size)
    (dotimes (k 2048/board-size)
      (insert 2048/row-line)
      )
    (insert 2048/row-line-end)
    (dotimes (k 2048/board-size)
      (insert 2048/col-line)
      )
    (insert 2048/col-line-end)
    (dotimes (j 2048/board-size)
      (let ((number (2048/get-number j i)) (col ""))
	(cond ((= number 0) (setq col "       "))
	      ((< number 10) (setq col (format "   %i   " number)))
	      ((< number 100) (setq col (format "  %i   " number)))
	      ((< number 1000) (setq col (format "  %i  " number)))
	      (t (setq col (format " %i  " number)))
	      )
	(setq col (cond ((or (= number 0) (= number 2)) (propertize col 'face '(:foreground "#000000" :height 150)))
			((= number 4) (propertize col 'face '(:foreground "#B766AD" :height 150)))
			((= number 8) (propertize col 'face '(:foreground "#FF8040" :height 150)))
			((= number 16) (propertize col 'face '(:foreground "#F75000" :height 150)))
			((= number 32) (propertize col 'face '(:foreground "#BB3D00" :height 150)))
			((= number 64) (propertize col 'face '(:foreground "#FFD306" :height 150)))
			((= number 128) (propertize col 'face '(:foreground "#D9B300" :height 150)))
			((= number 256) (propertize col 'face '(:foreground "#AE8F00" :height 150)))
			((= number 512) (propertize col 'face '(:foreground "#0080FF" :height 150)))
			((= number 1024) (propertize col 'face '(:foreground "#0066CC" :height 150)))
			((= number 2048) (propertize col 'face '(:foreground "#004B97" :height 150)))
			((= number 4096) (propertize col 'face '(:foreground "#00A600" :height 150)))
			)
	      )
	(insert (propertize "|" 'face '(:height 150))  col)
	)
      )
    (insert 2048/col-line-end)
    (dotimes (k 2048/board-size)
      (insert 2048/col-line)
      )
    (insert 2048/col-line-end)
    )
  (dotimes (k 2048/board-size)
      (insert 2048/row-line)
      )
    (insert 2048/row-line-end)
    )

(defun 2048/score ()
  (insert (propertize (format " move step: %i\n" score) 'face '(:height 150)))
  (if win (insert (propertize (format " win!! you get 2048\n") 'face '(:height 150)))
    (insert "\n\n")
    )
  )

(defun 2048/hint ()
  (insert "\n\n"
	  (propertize " n: new game " 'face '(:foreground "dark green" :height 150))
	  (propertize " q: quit " 'face '(:foreground "blue" :height 150))
	  (propertize " u: undo " 'face '(:foreground "red" :height 150))
	  )
  )
 
(defun 2048/key-map ()
  (let ((map (make-sparse-keymap)))
    (define-key map [up] (lambda () (interactive) (2048/move "up")))
    (define-key map [down] (lambda () (interactive) (2048/move "down")))
    (define-key map [left] (lambda () (interactive) (2048/move "left")))
    (define-key map [right] (lambda () (interactive) (2048/move "right")))
    (define-key map "n" '2048/set-list)
    (define-key map "q" '2048/quit-game)
    (define-key map "u" '2048/undo)
    map
    )
  )

(defun 2048/new-game ()
  (setq score 0)
  (setq win nil)
  (setq 2048/board (make-vector 2048/board-size 0))
  (dotimes (i 2048/board-size) (aset 2048/board i (make-vector 2048/board-size 0)))
  (setq 2048/last-board (make-vector 2048/board-size 0))
  (dotimes (i 2048/board-size) (aset 2048/last-board i (make-vector 2048/board-size 0)))
  (dotimes (i 2) (2048/add-new-square))
  (2048/copy-board)
  (erase-buffer)
  (2048/score)
  (2048/draw)
  (2048/hint)
  )

(defun 2048/quit-game ()
  (interactive)
  (kill-buffer "2048-game")
  )

(defun 2048/undo ()
  (interactive)
  (if (2048/whether-move) (setq score (- score 1)))
  (dotimes (i 2048/board-size)
    (dotimes (j 2048/board-size)
      (2048/set-number i j (aref (aref 2048/last-board j) i))
      )
    )
  (erase-buffer)
  (2048/score)
  (2048/draw)
  (2048/hint)
  )

(defun 2048/move (direction)
  (interactive)
  (2048/copy-board)
  (setq score (+ score 1))
  (dotimes (k 2048/board-size)
    (cond ((string= direction "up") (2048/move-col-up k))
	  ((string= direction "down") (2048/move-col-down k))
	  ((string= direction "left") (2048/move-row-left k))
	  ((string= direction "right") (2048/move-row-right k))
	  )
    )
  (if (2048/whether-move) (2048/add-new-square)
    (setq score (- score 1))
    )
  (erase-buffer)
  (2048/score)
  (2048/draw)
  (2048/hint)
  )

(defun 2048/move-col-up (x)
  (let ((y 1) (mask (make-vector 2048/board-size 0)))
    (while (< y 2048/board-size)
      (catch 'break
	(if (2048/not-moveable x y) (throw 'break 0))
	(let ((j y))
	  (while (> j 0)
	    (cond ((= (2048/get-number x j) 0) (throw 'break 0))
		  ((= (2048/get-number x (- j 1)) 0)
		   (2048/set-number x (- j 1) (2048/get-number x j))
		   (2048/set-number x j 0)
		   )
		  ((/= (2048/get-number x j) (2048/get-number x (- j 1))) (throw 'break 0))
		  ((= (aref mask (- j 1)) 0)
		   (if (= (2048/get-number x j) 1024) (setq win t))
		   (2048/set-number x (- j 1) (* (2048/get-number x j) 2))
		   (2048/set-number x j 0)
		   (aset mask (- j 1) 1)
		   (throw 'break 0)
		   )
		  )
	    (setq j (- j 1))
	    )
	  )
	)
      (setq y (+ y 1))
      )
    )
  )

(defun 2048/move-col-down (x)
  (let ((y (- 2048/board-size 2)) (mask (make-vector 2048/board-size 0)))
    (while (>= y 0)
      (catch 'break
	(if (2048/not-moveable x y) (throw 'break 0))
	(let ((j y))
	  (while (< j (- 2048/board-size 1))
	    (cond ((= (2048/get-number x j) 0) (throw 'break 0))
		  ((= (2048/get-number x (+ j 1)) 0)
		   (2048/set-number x (+ j 1) (2048/get-number x j))
		   (2048/set-number x j 0)
		   )
		  ((/= (2048/get-number x j) (2048/get-number x (+ j 1))) (throw 'break 0))
		  ((= (aref mask (+ j 1)) 0)
		   (if (= (2048/get-number x j) 1024) (setq win t))
		   (2048/set-number x (+ j 1) (* (2048/get-number x j) 2))
		   (2048/set-number x j 0)
		   (aset mask (+ j 1) 1)
		   (throw 'break 0)
		   )
		  )
	    (setq j (+ j 1))
	    )
	  )
	)
      (setq y (- y 1))
      )
    )
  )

(defun 2048/move-row-left (y)
  (let ((x 1) (mask (make-vector 2048/board-size 0)))
    (while (< x 2048/board-size)
      (catch 'break
	(if (2048/not-moveable x y) (throw 'break 0))
	(let ((i x))
	  (while (> i 0)
	    (cond ((= (2048/get-number i y) 0) (throw 'break 0))
		  ((= (2048/get-number (- i 1) y) 0)
		   (2048/set-number (- i 1) y (2048/get-number i y))
		   (2048/set-number i y 0)
		   )
		  ((/= (2048/get-number i y) (2048/get-number (- i 1) y)) (throw 'break 0))
		  ((= (aref mask (- i 1)) 0)
		   (if (= (2048/get-number i y) 1024) (setq win t))
		   (2048/set-number (- i 1) y (* (2048/get-number i y) 2))
		   (2048/set-number i y 0)
		   (aset mask (- i 1) 1)
		   (throw 'break 0)
		   )
		  )
	    (setq i (- i 1))
	    )
	  )
	)
      (setq x (+ x 1))
      )
    )
  )

(defun 2048/move-row-right (y)
  (let ((x (- 2048/board-size 2)) (mask (make-vector 2048/board-size 0)))
    (while (>= x 0)
      (catch 'break
	(if (2048/not-moveable x y) (throw 'break 0))
	(let ((i x))
	  (while (< i (- 2048/board-size 1))
	    (cond ((= (2048/get-number i y) 0) (throw 'break 0))
		  ((= (2048/get-number (+ i 1) y) 0)
		   (2048/set-number (+ i 1) y (2048/get-number i y))
		   (2048/set-number i y 0)
		   )
		  ((/= (2048/get-number i y) (2048/get-number (+ i 1) y)) (throw 'break 0))
		  ((= (aref mask (+ i 1)) 0)
		   (if (= (2048/get-number i y) 1024) (setq win t))
		   (2048/set-number (+ i 1) y (* (2048/get-number i y) 2))
		   (2048/set-number i y 0)
		   (aset mask (+ i 1) 1)
		   (throw 'break 0)
		   )
		  )
	    (setq i (+ i 1))
	    )
	  )
	)
      (setq x (- x 1))
      )
    )
  )

(defun 2048/not-moveable (x y)
  (/= (2048/get-number x y) (aref (aref 2048/last-board y) x))
  )

(defun 2048/whether-move ()
  (catch 'break
    (dotimes (i 2048/board-size)
      (dotimes (j 2048/board-size)
	(if (2048/not-moveable i j) (throw 'break t))
	)
      )
    (throw 'break nil)
    )
  )

(defun 2048/copy-board ()
  (dotimes (i 2048/board-size)
    (dotimes (j 2048/board-size)
      (aset (aref 2048/last-board j) i (2048/get-number i j))
      )
    )
  )

(defun 2048/set-list ()
  (interactive)
  (use-local-map (2048/board-size-map))
  (erase-buffer)
  (insert (propertize "\nchoose board size:\n\n" 'face '(:height 150)))
  (dotimes (k 4)
    (insert (propertize (format "%i. %ix%i\n" (+ k 1) (+ k 3) (+ k 3)) 'face '(:height 150)))
    )
  )

(defun 2048/board-size-map ()
  (let ((map (make-sparse-keymap)))
    (define-key map "1" (lambda () (interactive) (2048/set-board-size 3)))
    (define-key map "2" (lambda () (interactive) (2048/set-board-size 4)))
    (define-key map "3" (lambda () (interactive) (2048/set-board-size 5)))
    (define-key map "4" (lambda () (interactive) (2048/set-board-size 6)))
    map
    )
  )

(defun 2048/set-board-size (x)
  (setq 2048/board-size x)
  (use-local-map (2048/key-map))
  (2048/new-game)
  )

(defun 2048-game ()
  (interactive)
  (switch-to-buffer "2048-game")
  (2048/set-list)
  )
