(defun tocode (cos)
  "from cons of string to cons of integer"
  (mapcar (lambda (str)
	    (map 'cons
		 #'char-code
		 str))
	  cos))

(defun tohex (coi)
  "from cons of integer to hex"
  (let ((res nil))
    (labels ((f (coi res)
	       (if coi
		   (f (cdr coi)
		      (push (write-to-string (car coi) :base 16) res))
		   (reverse res))))
      (f coi res))))

(defun addprefix (cos)
  "add a prefix to every string in cons"
  (mapcar (lambda (str)
	    (format nil "~{\\x~a~}" str))
	  cos))

(defun addsuffix (cos)
  "add a new-line char to a string in cons"
  (mapcar (lambda (str)
	    (format nil "~a\\x0A" str))
	  cos))

(defun tostring (cos)
  "from cons of string to a string"
  (format nil "~{~A~}" cos))

(defun transform (cos)
  "transform cons of strings to string"
  (string-right-trim
   "\\x0A" (tostring (addsuffix (addprefix (mapcar #'tohex (tocode cos)))))))

(let ((ind 0))
  (defun yieldtoken(str i)
    "a closure function, yield tokens of size 4"
    (incf ind i)
    (if str (subseq str (- ind i) (if (< ind (length str))
				      (- ind (mod ind 4))
				      (length str)))
	nil)))

(defun lines (str n)
  "a closure, break down a string to n-line(s)"
  (let ((acc nil))
  (loop for i from  0 to (/ (length str) n)
	do (push (yieldtoken str n) acc))
    (reverse acc)))

(defun checkline (str uin)
  "check user-input and string length"
  (min (if (> uin 3) (- uin (mod uin 4)) 4)
       (length str)))

(defun encode (input output num)
  "read a file, process it, write result to another file"
  ;; transform the input data from string to hex
  (let* ((datain (transform (with-open-file (my-stream input :direction :input)
			      (loop for buff = (read-line my-stream nil)
				    while buff
				    collect buff))))
	 ;; spliting a line to many lines as per user input
	 (dataout (lines datain (checkline datain num))))
    ;; writing the output data
    ;; add \z to the end of each line as per lua requirements
    (with-open-file (my-stream output :direction :output)
      (loop for buff in dataout
	    do (when (not (equal buff ""))
		 (princ buff my-stream)
		 (princ "\\z" my-stream)
		 (terpri my-stream))))))

(encode "input.txt" "output.txt" 42)
