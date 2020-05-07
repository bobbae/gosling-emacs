(load "vs100-mouse.ml")

(defun
    (emacs-dsp-entry-hook (send-string-to-terminal "\e[?9h"))
    (emacs-dsp-exit-hook (send-string-to-terminal "\e[?9l"))
)

(emacs-dsp-entry-hook)
