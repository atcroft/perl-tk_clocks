# perl-tk_clocks
Various graphical clocks written in perl/Tk.

This project is a collection of various graphical clocks written using perl/Tk. The current clocks present in the collection are as follows:

* tk_articulated_clock.pl
  * Similar to the clock at this link: http://blog.longnow.org/02009/07/18/articulated-clock-hands/
  * Can be articulated with hands in H->M->S or S->M->H (inner to outer) order.
  * Can display as a 12 or 24 hour analog face.
  * Display updates approximately every 0.25s.

* tk_bar_clock.pl
  * A representation of the clock at this link: https://www.thinkgeek.com/product/jhig/
  * Includes time as a progress bar (second of day), broken up into 24 hour segments.
  * Includes hour and minute as progress bars.
  * Can display in 12 or 24 hour mode.
  * Display updates approximately every 0.25s.

* tk_binary_clock-358181.pl
  * A representation of the clock at this link: http://www.anelace.com/Crystal_Blue.html
  * My first perl/Tk clock program (so there are oddities, such as if you mouse over a "cell").
  * Includes binary display, time, and second of day.
  * Includes time as a progress bar (second of day), broken up into 24 hour segments.
  * Can display in 12 or 24 hour mode.
  * Three (3) brightness levels.
  * Can display in "BCD" or "true" binary mode. 
    * "BCD" - each digit is one column.
    * "true" - hour, minute, and second are displayed as binary numbers on rows 2 through 4, in that order.
  * Optional "cell" outlining. (I find the hardest thing about reading the physical clock (which I own) is perceiving the empty cells in the dark (especially from across the room).)
  * Display updates approximately every 0.25s.

* tk_led_word_clock.pl
  * A representation of the clock at this link: https://www.thinkgeek.com/product/impi/
  * Uses words to tell time. (Appropriate words are illuminated.)
  * Shows time in five minute intervals. (10:37 would be given as "It is twenty five to eleven".)
  * Display updates approximately every 5s.

* tk_slow_watch.pl
  * A representation of the clock at this link: http://www.slow-watches.com/
  * Displays time with a single hand on a 24-hour face, with each tick on the face a 15-minute increment.
  * Display updates approximately every 5s.

I wrote the clocks for my own entertainment, but perhaps they might be of interest or amusement for others. As such, I do not guarantee the code to necessarily follow the best of practices, etc. Also, while I am unaware of any patent encumberances on the designs, I have not looked into it very far (so if there are, please let me know and I will remove them from the repository, with apologies). With that, enjoy (and if you run across an interesting clock display/layout, let me know).

