@Section(time -- a mode line clock)
@Index[time]@Index[clock]
This package only implements one user-visible function, @i[time], which puts
the current time of day and load average (continuously updating!) in the
mode line of each window.  It uses global-mode-string and the subprocess
control facility.  Major!
