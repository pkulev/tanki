(import [pyray :as pr])

(defclass Player []

  (setv gravity 10)

  (defn --init-- [self pos]
    (setv self.pos pos

          self.fuel 100

          self.floor pos.y
          self.max-jump-y 100
          self.jump? False
          self.weapon-cooldown 10
          self.weapon-cur-cooldown 0
          self.weapon-ready? True)
    (setv self.texture (pr.load-texture "assets/gfx/player.png"
                                        (pr.get-color 0x16ff0b))))

  (defn update [self]
    (when (> self.pos.y self.max-jump-y)
      (+= self.pos.y 3))

    (when (pr.is-key-down pr.KEY_D)
      (+= self.pos.x 10))

    (when (pr.is-key-down pr.KEY_A)
      (-= self.pos.x 10))

    (when (pr.is-key-down pr.KEY_SPACE)
      (self.fire))

    (when (pr.is-key-down pr.KEY_LEFT_SHIFT)
      (self.jump)))

  (defn fire [self]
    (when self.weapon-ready?
      (setv self.weapon-ready? False)
      (print "Pshooo"))

    (if (> self.weapon-cur-cooldown 0)
        (-= self.weapon-cur-cooldown 1)
        (setv self.weapon-cur-cooldown self.weapon-cooldown
              self.weapon-ready? True)))

  (defn jump [self]
    (when (< self.pos.y (+ self.floor self.max-jump-y))
      (-= self.pos.y 5)))

  (defn render [self]
    (pr.draw-texture-ex self.texture self.pos 0.0 1.0 pr.RAYWHITE)))
