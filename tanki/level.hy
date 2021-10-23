(import math)

(import [pyray :as pr])

(import [tanki.background [Background]]
        [tanki.common [*width* *height*]]
        [tanki.obstacles [ObstaclePool]]
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
          self.new-record? False

          self.score 0
          self.max-score 0

          self.prepare-countdown (TextCountdown (, (, 0.4 "3")
                                                   (, 0.8 "2")
                                                   (, 1.2 "1")
                                                   (, 1.6 "GO")))
          self.obstacles (ObstaclePool :gap (int (+ self.player.texture.height
                                                    (/ self.player.texture.height 2))))
          self.collision-sound (pr.load-sound "assets/snd/take-damage.wav"))
    (pr.set-sound-volume self.collision-sound 0.5))

  ;; save to file
  (defn set-max-score [self score]
    (setv self.max-score score))

  (defn get-max-score [self]
    self.max-score)

  (defn toggle-pause [self]
    (setv self.paused? (not self.paused?)))

  (defn restart [self]
    (self.bg.reset)
    (self.player.reset)
    (self.prepare-countdown.reset)
    (self.obstacles.reset)
    (setv self.game-over? False
          self.score 0
          self.new-record? False))

  (defn update [self]
    (when self.game-over?
      (when (pr.is-key-released pr.KEY_SPACE)
        (self.restart))
      (return))

    (unless self.paused?
      (self.prepare-countdown.update))

    (unless (or (not self.prepare-countdown.done?) self.paused?)
      (self.bg.update)
      (self.obstacles.update)
      (self.player.update)

      (when (or (> (+ self.player.pos.y (* self.player.texture.height 2/3)) *height*)
                (self.collision-with-obstacle))
        (setv self.game-over? True)
        (when (> self.score (self.get-max-score))
          (self.set-max-score self.score)
          (setv self.new-record? True)))

      ;; scores!
      (for [obstacle self.obstacles.objects]
        ;; player passed obstacle at 3px
        (setv diff (- self.player.pos.x (+ (obstacle.get-pos-x) obstacle.bottom.width)))
        (when (and (< diff 5)
                   (> diff 0)
                   (not obstacle.checked?))
          (+= self.score 1)
          (setv obstacle.checked? True))

        (when (and (> self.player.pos.x (+ (obstacle.get-pos-x) obstacle.bottom.width 7)))
          (setv obstacle.checked? False)))))

  (defn collision-with-obstacle [self]
    ;; TODO: check only closest
    (when (self.obstacles.check-collision self.player.collision-rect)
        (pr.play-sound self.collision-sound)
        (return True)))

  (defn render-game-over-lay [self]
    (setv info-w 350
          info-h 180
          info-x (- (// *width* 2) (// info-w 2))
          info-y (- (// *height* 2) (// info-h 2))
          score f"Score: {self.score}"
          max-score f"Max score: {(self.get-max-score)}"
          score-size-x (pr.measure-text score 20)
          max-score-size-x (pr.measure-text max-score 20)
          new-record "New record!"
          new-record-size-x (pr.measure-text new-record 20)
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
    (when self.new-record?
      (setv new-record-x (+ (- (// info-w 2) (// new-record-size-x 2)) info-x))
      (pr.draw-rectangle-lines (- new-record-x 10)
                               (+ info-y 75)
                               (+ new-record-size-x 20)
                               30
                               pr.GOLD)
      (pr.draw-text new-record
                    new-record-x
                    (+ info-y 80)
                    20
                    pr.GOLD))
    (pr.draw-text "Press SPACE to restart level"
                  (+ info-x 15)
                  (+ info-y 120)
                  20
                  pr.RAYWHITE)
    (pr.draw-text "Press ESCAPE to exit game"
                  (+ info-x 15)
                  (+ info-y 145)
                  20
                  pr.RAYWHITE))

  (defn render [self]
    (self.bg.render)
    (self.obstacles.render)
    (self.player.render)
    (self.prepare-countdown.render)

    (setv size-x (pr.measure-text (str self.score) 36)
          rect-w 100)
    (pr.draw-rectangle (int (- (/ *width* 2) (/ rect-w 2)))
                       2
                       rect-w
                       40
                       (pr.fade pr.DARKGRAY 0.5))

    (pr.draw-text (str self.score)
                  (int (- (/ *width* 2) (/ size-x 2)))
                  5
                  36
                  pr.RAYWHITE)

    (when self.game-over?
      (self.render-game-over-lay))

    (when self.paused?
      (setv size-x (pr.measure-text "PAUSED" 36))
      (pr.draw-text "PAUSED"
                    (int (- (/ *width* 2) (/ size-x 2)))
                    (// *height* 2)
                    36
                    pr.RED))))
