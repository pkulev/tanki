(import [pyray :as pr])

(import [tanki [common]]
        [tanki.background [Background]]
        [tanki.common [*width* *height*]]
        [tanki.level [Level]]
        [tanki.player [Player]])


(defclass Game []

  (setv level-names ["1" "2" "3"])

  (defn --init-- [self]
    (pr.init-window *width* *height* "Tanki")
    (pr.set-target-fps 60)

    (setv self.state :in-game
          self.level (Level (get self.level-names 0))))

  (defn restart-level [self]
    (setv self.level (Level self.level.name)))

  (defn run [self]
    (while (not (pr.window-should-close))
      (self.level.update)

      (pr.begin-drawing)
      (pr.clear-background pr.RAYWHITE)
      (self.level.render)

      (pr.draw-text f"Fuel: {self.level.player.fuel}" 0 0 20 pr.VIOLET)
      (pr.draw-text f"Booster: {self.level.player.booster}/{self.level.player.booster-max}" 100 0 20 pr.LIME)

      (pr.draw-fps 940 0)
      (pr.end-drawing)

      (when (pr.is-key-released pr.KEY_D)
        (setv common.*debug* (not common.*debug*)))

      (when (pr.is-key-released pr.KEY_P)
        (self.level.toggle-pause))

      (when (or (> self.level.player.pos.y *height*)
                (pr.is-key-released pr.KEY_R))
        (self.restart-level)))
    (pr.close-window)))
