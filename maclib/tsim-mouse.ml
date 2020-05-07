(load "vs100-mouse.ml")

(defun
    (emacs-dsp-entry-hook (send-string-to-terminal "\e("))
    (emacs-dsp-exit-hook (send-string-to-terminal "\e)"))
)

(emacs-dsp-entry-hook)
