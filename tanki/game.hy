(import pyray :as pr)

(import tanki [common]
        tanki.background [Background]
        tanki.common [*width* *height*]
        tanki.common :as tc
        tanki.controls [InputSystem]
        tanki.level [Level]
        tanki.player [Player])


(defclass Game []

  (setv level-names ["1" "2" "3"])
  (setv states [:main-menu :in-game])

  (defn __init__ [self]
    (pr.set-config-flags pr.FLAG-MSAA-4X-HINT)
    (pr.init-window *width* *height* "Tanki")
    (pr.init-audio-device)
    (pr.set-target-fps 60)
    (pr.set-exit-key pr.KEY_NULL)

    (setv self.state :in-game
          self.input (InputSystem)
          self.level (Level (get self.level-names 0))
          self.music (tc.load-music-stream "theme.wav")))

  (defn run [self]
    (pr.play-music-stream self.music)
    (while (not (pr.window-should-close))
      (pr.update-music-stream self.music)

      (self.input.update)
      (self.level.update)

      (pr.begin-drawing)
      (pr.clear-background pr.RAYWHITE)
      (self.level.render)

      ;; (pr.draw-text f"Booster: {self.level.player.booster}/{self.level.player.booster-max}"
      ;;               200
      ;;               0
      ;;               20
      ;;               pr.LIME)

      (pr.draw-fps 940 0)
      (when common.*debug*
        (pr.draw-line (// *width* 2) 0 (// *width* 2) *height* pr.RED)
        (pr.draw-line 0 (// *height* 2) *width* (// *height* 2) pr.GREEN)
        (self.input.render))
      (pr.end-drawing)

      (when (pr.is-key-released pr.KEY_D)
        (setv common.*debug* (not common.*debug*)))

      (when (self.input.action? ':toggle-device ':in-game)
        (self.input.set-next-device))

      (when (self.input.action? ':toggle-pause ':in-game)
        (self.level.toggle-pause))

      (when (self.input.action? ':restart ':in-game)
        (self.level.restart))

      (when (pr.is-key-released pr.KEY_M)
        (setv common.*music* (not common.*music*))
        (if common.*music*
            (pr.play-music-stream self.music)
            (pr.stop-music-stream self.music))))
    (pr.close-window)))
