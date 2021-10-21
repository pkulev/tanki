(import [pyray :as pr])


(defclass Player []

  (defn --init-- [self pos]
    (setv self.pos pos

          self.fuel 100
          self.booster 1
          self.booster-max 3

          self.floor pos.y
          self.max-jump-y 0
          self.jump? False
          self.rotation 30
          self.fall-speed 4
          self.jump-speed 10
          self.weapon-cooldown 10
          self.weapon-cur-cooldown 0
          self.weapon-ready? True
          self.texture (pr.load-texture "assets/gfx/player.png"
                                        pr.WHITE)))

  (defn update [self]
    (+= self.pos.y self.fall-speed)

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
    (-= self.pos.y self.jump-speed)

    (when (<= self.pos.y 0)
      (setv self.pos.y 0)))

  (defn render [self]
    (pr.draw-texture-ex self.texture self.pos self.rotation 1.0 pr.RAYWHITE)))
