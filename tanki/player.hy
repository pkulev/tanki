(import [pyray :as pr])

(import [tanki [common ui]])


(defclass JetpackSound []

  (defn --init-- [self]
    (setv self.sound (pr.load-music-stream "assets/snd/jetpack-cut.wav")
          self.length (pr.get-music-time-length self.sound))
    (pr.set-music-volume self.sound 0.1)
    (pr.play-music-stream self.sound)
    (self.pause))

  (defn pause [self]
    ;; TODO: SeekMusicStream is new function that doesn't exist in raylib 3.7.0
    ;; FIXME: so to workaround it we can restart sound in advance
    (when (>= (pr.get-music-time-played self.sound) (- self.length 0.8))
      (pr.stop-music-stream self.sound)
      (pr.play-music-stream self.sound))
    (pr.pause-music-stream self.sound))

  (defn resume [self]
    (pr.resume-music-stream self.sound))

  (defn update [self]
    (when (>= (pr.get-music-time-played self.sound) (- self.length 0.1))
      ;; TODO: SeekMusicStream is new function that doesn't exist in raylib 3.7.0
      #_(pr.seek-music-stream self.sound 0.0)
      (pr.stop-music-stream self.sound)
      (pr.play-music-stream self.sound))
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
          self.fuel-depletion-sound (pr.load-sound "assets/snd/select.wav")
          self.jetpack-sound (JetpackSound)
          self.collision-rect (pr.Rectangle (+ pos.x 10)
                                            (+ pos.y 10)
                                            (- self.texture.width 15)
                                            (- self.texture.height 20))
          self.fuel-bar (ui.ProgressBar 5 5 100 20
                                        pr.DARKGRAY
                                        pr.VIOLET
                                        100
                                        0
                                        100
                                        :label "Fuel"
                                        :font-size 20
                                        :label-color pr.VIOLET
                                        :spacing 5))
    (self.reset))

  (defn reset [self]
    (setv self.pos (pr.Vector2 self.-start-pos.x self.-start-pos.y)
          self.fuel 100
          self.fuel-depleted? False
          self.booster 1
          self.booster-max 3
          self.weapon-cur-cooldown 0
          self.weapon-ready? True)
    (self.adjust-collider)
    (self.fuel-bar.update self.fuel)
    (self.set-fuel-depleted self.fuel-depleted?))

  (defn adjust-collider [self]
    (setv self.collision-rect.x (+ self.pos.x 10)
          self.collision-rect.y (+ self.pos.y 10)))

  (defn update [self]
    (+= self.pos.y self.fall-speed)

    (setv self.fuel (common.clamp (+ self.fuel 0.5) 0 100))
    ;; Recharched!
    (when (> self.fuel 25)
      (self.set-fuel-depleted False))

    (when (pr.is-key-down pr.KEY_SPACE)
      (self.fire))

    (when (pr.is-key-down pr.KEY_LEFT_SHIFT)
      (self.jump))

    (when (pr.is-key-released pr.KEY_LEFT_SHIFT)
      (self.jetpack-sound.pause))

    (self.fuel-bar.update self.fuel)

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

  (defn get-fuel-consumption [self]
    (cond [(< self.fuel 10) 1.2]
          [(< self.fuel 70) 1.4]
          [True 1.5]))

  (defn set-fuel-depleted [self val]
    "Updates fuel meter color to denote that engine is not working."
    (setv self.fuel-depleted? val
          self.fuel-bar.fg-color (if val pr.RED pr.VIOLET)))

  (defn jump [self]
    (when self.fuel-depleted?
      (return))

    (when (> self.fuel 0)
      (self.jetpack-sound.resume)
      (-= self.pos.y self.jump-speed)
      (setv self.fuel (common.clamp (- self.fuel (self.get-fuel-consumption)) 0 100)))

    ;; TODO: add depletion sound
    (when (= self.fuel 0)
      (self.set-fuel-depleted True)
      (pr.play-sound self.fuel-depletion-sound))

    (when (<= self.pos.y 0)
      (setv self.pos.y 0)))

  (defn render [self]
    (pr.draw-texture-ex self.texture self.pos self.rotation 1.0 pr.RAYWHITE)
    (self.fuel-bar.render)

    (when common.*debug*
      (pr.draw-rectangle-lines-ex self.collision-rect 1 pr.RED))))
