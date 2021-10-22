(import [pyray :as pr])

(import [tanki [common]])


(defclass JetpackSound []

  (defn --init-- [self]
    (setv self.sound (pr.load-music-stream "assets/snd/jetpack1.wav"))
    (pr.set-music-volume self.sound 0.5)
    (pr.play-music-stream self.sound))

  (defn pause [self]
    (pr.pause-music-stream self.sound))

  (defn resume [self]
    (pr.resume-music-stream self.sound))

  (defn update [self]
    (pr.update-music-stream self.sound)))


(defclass Player []

  (defn --init-- [self pos]
    (setv self.pos pos
          self.-start-pos (pr.Vector2 pos.x pos.y)

          self.rotation 0
          self.fall-speed 4
          self.jump-speed 10
          self.weapon-cooldown 10
          self.texture (pr.load-texture "assets/gfx/player.png"
                                        pr.WHITE)
          self.jetpack-sound (JetpackSound)
          self.collision-rect (pr.Rectangle (+ pos.x 10)
                                            (+ pos.y 10)
                                            (- self.texture.width 15)
                                            (- self.texture.height 20)))
    (self.reset))

  (defn reset [self]
    (setv self.pos (pr.Vector2 self.-start-pos.x self.-start-pos.y)
          self.fuel 100
          self.booster 1
          self.booster-max 3
          self.weapon-cur-cooldown 0
          self.weapon-ready? True)
    (self.adjust-collider))

  (defn adjust-collider [self]
    (setv self.collision-rect.x (+ self.pos.x 10)
          self.collision-rect.y (+ self.pos.y 10)))

  (defn update [self]
    (+= self.pos.y self.fall-speed)

    (when (pr.is-key-down pr.KEY_SPACE)
      (self.fire))

    (when (pr.is-key-down pr.KEY_LEFT_SHIFT)
      (self.jump))

    (when (pr.is-key-released pr.KEY_LEFT_SHIFT)
      (self.jetpack-sound.pause))

    (self.adjust-collider)
    (self.jetpack-sound.update))

  (defn fire [self]
    (when self.weapon-ready?
      (setv self.weapon-ready? False)
      (print "Pshooo"))

    (if (> self.weapon-cur-cooldown 0)
        (-= self.weapon-cur-cooldown 1)
        (setv self.weapon-cur-cooldown self.weapon-cooldown
              self.weapon-ready? True)))

  (defn jump [self]
    (self.jetpack-sound.resume)

    (-= self.pos.y self.jump-speed)

    (when (<= self.pos.y 0)
      (setv self.pos.y 0)))

  (defn render [self]
    (pr.draw-texture-ex self.texture self.pos self.rotation 1.0 pr.RAYWHITE)

    (when common.*debug*
      (pr.draw-rectangle-lines-ex self.collision-rect 1 pr.RED))))
