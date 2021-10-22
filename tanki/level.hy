(import math)

(import [pyray :as pr])

(import [tanki.background [Background]]
        [tanki.common [*width* *height*]]
        [tanki.obstacles [Obstacle]]
        [tanki.player [Player]])


(defclass TextCountdown []
  "Simple animated text."

  (defn --init-- [self frames]
    (setv self.frames frames
          self.current-frame 0
          self.frames-num (len frames)
          self.current-local-time 0.0
          self.done? False))

  (defn reset [self]
    (setv self.current-frame 0
          self.current-local-time 0.0
          self.done? False))

  (defn update [self]
    (unless self.done?
      (+= self.current-local-time (pr.get-frame-time))

      (setv [time _] (get self.frames self.current-frame))
      (when (>= self.current-local-time time)
        (if (= (+ self.current-frame 1) self.frames-num)
            (setv self.done? True)
            (+= self.current-frame 1)))))

  (defn render [self]
    (unless self.done?
      (setv [_ text] (get self.frames self.current-frame)
            size (pr.measure-text-ex (pr.get-font-default) text 36 3))

      (pr.draw-text text
                    (int (- (/ *width* 2) (/ size.x 2)))
                    (// *height* 2)
                    36
                    pr.WHITE))))


(defclass Level []
  (defn --init-- [self name]
    (setv self.name name
          self.bg (Background name)
          self.player (Player (pr.Vector2 100 500))
          self.paused? False
          self.game-over? False

          self.score 4

          self.prepare-countdown (TextCountdown (, (, 0.4 "3")
                                                   (, 0.8 "2")
                                                   (, 1.2 "1")
                                                   (, 1.6 "GO")))
          self.obstacles [(Obstacle (pr.Vector2 700 300))]))

  (defn get-max-score [self]
    10)

  (defn toggle-pause [self]
    (setv self.paused? (not self.paused?)))

  (defn restart [self]
    (self.bg.reset)
    (self.player.reset)
    (self.prepare-countdown.reset)
    (setv self.game-over? False
          self.obstacles [(Obstacle (pr.Vector2 700 300))]))

  (defn update [self]
    (when self.game-over?
      (when (pr.is-key-released pr.KEY_SPACE)
        (self.restart))
      (return))

    (unless self.paused?
      (self.prepare-countdown.update))

    (unless (or (not self.prepare-countdown.done?) self.paused?)
      (self.bg.update)
      (for [obstacle self.obstacles]
        (obstacle.update))
      (self.player.update)

      (when (or (> (+ self.player.pos.y (* self.player.texture.height 2/3)) *height*)
                (self.collision-with-obstacle))
        (setv self.game-over? True))))

  (defn collision-with-obstacle [self]
    ;; TODO: check only closest
    (for [obstacle self.obstacles]
      (when (pr.check-collision-recs self.player.collision-rect
                                     obstacle.collision-rect)
        (return True))))

  (defn render-game-over-lay [self]
    (setv info-w 350
          info-h 180
          info-x (- (// *width* 2) (// info-w 2))
          info-y (- (// *height* 2) (// info-h 2))
          score f"Score: {self.score}"
          max-score f"Max score: {(self.get-max-score)}"
          score-size-x (pr.measure-text score 20)
          max-score-size-x (pr.measure-text max-score 20)
          overlay-rect (pr.Rectangle info-x
                                     info-y
                                     info-w
                                     info-h))
    (pr.draw-rectangle-rec overlay-rect (pr.fade pr.DARKGRAY 0.6))
    (pr.draw-rectangle-lines-ex overlay-rect 5 (pr.fade pr.RAYWHITE 0.6))
    (pr.draw-text score
                  (+ (- (// info-w 2) (// score-size-x 2)) info-x)
                  (+ info-y 20)
                  20
                  pr.RAYWHITE)
    (pr.draw-text max-score
                  (+ (- (// info-w 2) (// max-score-size-x 2)) info-x)
                  (+ info-y 50)
                  20
                  pr.RAYWHITE)
    (pr.draw-text "Press SPACE to restart level"
                  (+ info-x 15)
                  (+ info-y 100)
                  20
                  pr.RAYWHITE)
    (pr.draw-text "Press ESCAPE to exit game"
                  (+ info-x 15)
                  (+ info-y 130)
                  20
                  pr.RAYWHITE))

  (defn render [self]
    (self.bg.render)
    (for [obstacle self.obstacles]
      (obstacle.render))
    (self.player.render)
    (self.prepare-countdown.render)

    (when self.game-over?
      (self.render-game-over-lay))

    (when self.paused?
      (setv size-x (pr.measure-text "PAUSED" 36))
      (pr.draw-text "PAUSED"
                    (int (- (/ *width* 2) (/ size-x 2)))
                    (// *height* 2)
                    36
                    pr.RED))))
