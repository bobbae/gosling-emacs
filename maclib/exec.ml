; From israel.umcp-cs@UDel-Relay Tue Feb  1 03:05:33 1983
; Received: from CMU-CS-A by UTAH-20; Tue 1 Feb 83 03:00:37-MST
; Received: from UDEL-RELAY by CMU-CS-PT;  1 Feb 83 03:30:07 EST
; Return-Path: <israel.umcp-cs@UDel-Relay>
; Date:     31 Jan 83 23:18:37 EST  (Mon)
; From: Bruce Israel <israel.umcp-cs@UDel-Relay>
; Subject:  handy little package
; To: unix.emacs@cmu-cs-a
; Remailed-To: :INCLUDE: "TEMP:EMACS.DST" at CMU-CS-A
; Remailed-From: Unix Emacs at CMU-CS-A
; Remailed-Date: Tuesday,  1 February 1983 0408-EST
; 
; exec.ml is a handy little package I wrote that allows you to put
; calls to mlisp functions on the invocation line.  For example, typing
; 
;     emacs -lexec.l '+(goto-line 34)' '+(end-of-line)' file.l
; 
; to the shell will start editing file.l at the end of line 34 (that
; is, assuming that goto.ml is loaded or autoloaded already).
; 
; The code is as follows:

(progn exec-str i char
    (setq i 1)
    (setq exec-str "(progn ")
    (while (< i (argc))
	   (setq char (substr (argv i) 1 1))
	   (if (= "+" char) (setq exec-str
				  (concat exec-str (substr (argv i) 2 999999)))
	       (!= "-" char) (error-occured (visit-file (argv i))))
	   (setq i (+ 1 i)))
    (setq exec-str (concat exec-str ")"))
    (execute-mlisp-line exec-str))


