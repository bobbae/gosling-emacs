;****************************************************************
;* File: ll-click.ml                                            *
;* Last modified on Sat Apr 19 10:30:22 1986 by roberts         *
;* -----------------------------------------------------------  *
;*     Handles mouse events for the lauralee system.            *
;****************************************************************

;****************************************************************
;* Global variables                                             *
;****************************************************************


(declare-global ll-last-window)		;Window of last up transition
(declare-global ll-last-dot)		;Dot at last up transition
(declare-global ll-drag-window)		;Window at last down transition
(declare-global ll-drag-dot)		;Dot at last down transition
(declare-global ll-old-window)		;Window before last down transition
(declare-global ll-old-dot)		;Dot before last down transition
(declare-global ll-opcode)		;Operation = (CLICK, DOUBLE, DRAG)
(declare-global ll-last-sequence)	;Sequence number of last down
(declare-global ll-last-down-time)	;Time of last down
(declare-global ll-last-up-time)	;Time of last up

(setq ll-last-sequence 0)
(setq ll-last-up-time 0)



;****************************************************************
;* (if (ll-record-transition) up-action [down-action])          *
;*                                                              *
;*     This function acts as a service for the click hook       *
;* operations and determines the operation type.  The           *
;* function returns TRUE on the up transition since this        *
;* is generally the one clients want to service.  On the        *
;* up transition, the following values are returned             *
;*                                                              *
;*     ll-opcode          either "CLICK", "DOUBLE" or "DRAG"    *
;*     ll-old-window      window before down transition         *
;*     ll-old-dot         dot before down transition            *
;*     ll-drag-window     window at down transition             *
;*     ll-drag-dot        dot at down transition                *
;*                                                              *
;* Other globals are set in this routine but these should be    *
;* considered as local bookkeeping data rather than as          *
;* guaranteed results.                                          *
;*                                                              *
;* KLUDGE WARNING:                                              *
;*                                                              *
;*     Note that the double click logic allows dot and the      *
;* saved value to stray by 1.  Although this could be           *
;* defended on the grounds of mouse jiggle, it is actually      *
;* here as a kludge around the problem that marking the         *
;* current folder name with a ">" changes dot so that           *
;* the last recorded up-transition dot and this value           *
;* may not agree, although they can differ by at most 1.        *
;****************************************************************

(defun
   (ll-record-transition
      (if down
         (progn
            (setq ll-last-sequence mouse-sequence-number)
            (setq ll-drag-dot (+ (dot)))
            (setq ll-drag-window (current-window))
            (setq ll-last-down-time (current-numeric-time))
            (setq ll-old-dot #old-dot)
            (setq ll-old-window #old-window)
            0
         )
         (progn
            (setq ll-opcode
               (if
                  (& (<= ll-last-down-time (+ ll-last-up-time 1))
                     (= (current-window) ll-last-window)
                     (<= (abs (- (dot) ll-last-dot)) 1)
                  ) "DOUBLE"
                  (& (!= (dot) ll-drag-dot)
                     (= mouse-sequence-number (+ ll-last-sequence 1))
                  ) "DRAG"
                  "CLICK"
               )
            )
            (setq ll-last-window (current-window))
            (setq ll-last-dot (+ (dot)))
            (if (= ll-opcode "DOUBLE")
               (ll-cancel-double-click)
               (ll-record-uptime)
            )
            1
         )
      )
   )
)



;****************************************************************
;* (ll-record-uptime)                                           *
;* (ll-cancel-double-click)                                     *
;*                                                              *
;*     If there is considerable work to do in a click           *
;* operation, the timing for double-click testing gets          *
;* messed up.  To get around this, clients should call          *
;* (ll-record-uptime) when the logical end of a click           *
;* operation occurs that might be a double click and            *
;* (ll-cancel-double-click) when this testing should            *
;* always be false.                                             *
;****************************************************************

(defun (ll-record-uptime (setq ll-last-up-time (current-numeric-time))))

(defun (ll-cancel-double-click (setq ll-last-up-time 0)))



;****************************************************************
;* (ll-button-block ...)                                        *
;*                                                              *
;*     Like save-excursion or progn, ll-button-block            *
;* surrounds a list of MLisp commands and executes them         *
;* in turn after (1) changing the cursor to an hourglass        *
;* and (2) setting an error-occured trap.  When the            *
;* block exits (either normally or after an error)              *
;* the cursor is reset.                                         *
;****************************************************************

(defun
   (ll-button-block istmt nstmt errflag errstr
      (setq nstmt (nargs))
      (setq istmt 0)
      (ll-start-hourglass)
;      (setq errflag (error-occured 
      (while (< istmt nstmt) (arg (setq istmt (+ 1 istmt))))
;      ))
      (if errflag (setq errstr "strange error"))
      (ll-stop-hourglass)
      (if errflag (Error errstr))
   )
)

;****************************************************************
;* (Error msg)                                                  *
;*                                                              *
;*     This exists only to clean up the error message typeout,  *
;* which should hardly say "ll-button-block: mumble".           *
;****************************************************************

(defun (Error (error-message (arg 1))))



;****************************************************************
;* (ll-start-hourglass)                                         *
;*                                                              *
;*     Changes the cursor to an hourglass so that the           *
;* user knows this will take a while.                           *
;****************************************************************

(defun
   (ll-start-hourglass
      (start-thinking)
      (sit-for 0)
      (novalue)
   )
)

;****************************************************************
;* (ll-stop-hourglass)                                          *
;*                                                              *
;*     Changes the cursor back to the arrow and clears the      *
;* message buffer.                                              *
;****************************************************************

(defun
   (ll-stop-hourglass
      (message "")
      (sit-for 0)
      (stop-thinking)
      (novalue)
   )
)
