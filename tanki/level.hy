(import math)

(import [pyray :as pr])

(import [tanki.background [Background]]
        [tanki.common [*width* *height*]]
        [tanki.player [Player]])


(defclass Level []
  (defn --init-- [self name]
    (setv self.name name
          self.bg (Background name)
          self.player (Player (pr.Vector2 50 500))
          self.paused? False
          self.preparing? True
          self.prepare-sec 3
          self.prepare-left self.prepare-sec))

  (defn toggle-pause [self]
    (setv self.paused? (not self.paused?)))

  (defn update [self]
    (unless (or self.preparing? self.paused?)
      (self.bg.update)
      (self.player.update))

    (when self.preparing?
      (-= self.prepare-left (pr.get-frame-time))
      (print (pr.get-frame-time))
      (when (< self.prepare-left -1)
        (print f"pre {self.prepare-left}")
        (setv self.preparing? False))))

  (defn render [self]
    (self.bg.render)
    (self.player.render)

    (when self.preparing?
      (setv text (if (>= self.prepare-left 0)
                     (str(math.ceil self.prepare-left))
                     "GO")
        size (pr.measure-text-ex (pr.get-font-default) text 36 3))
      (pr.draw-text text
                    (int (- (/ *width* 2) (/ size.x 2)))
                    (// *height* 2)
                    36
                    pr.WHITE))

    (when self.paused?
      (setv size (pr.measure-text-ex (pr.get-font-default) "PAUSED" 36 3))
      (pr.draw-text "PAUSED"
                    (int (- (/ *width* 2) (/ size.x 2)))
                    (// *height* 2)
                    36
                    pr.RED))))
