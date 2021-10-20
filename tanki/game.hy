(import [pyray :as pr])

(import [tanki.background [Background]]
        [tanki.common [*width* *height*]]
        [tanki.level [Level]]
        [tanki.player [Player]])

(setv *level-names* ["1" "2" "3"])


(defn restart-level [level]
  (Level level))

(defn run []
  (pr.init-window *width* *height* "Tanki")
  (pr.set-target-fps 60)

  (setv current-level (get *level-names* 0)
        level (restart-level current-level))

  (while (not (pr.window-should-close))
    (level.update)

    (pr.begin-drawing)
    (pr.clear-background pr.RAYWHITE)
    (level.render)

    (pr.draw-text f"Fuel: {level.player.fuel}" 0 0 20 pr.VIOLET)

    (pr.draw-fps 940 0)
    (pr.end-drawing)

    (when (pr.is-key-released pr.KEY_P)
      (level.toggle-pause))

    (when (or (> level.player.pos.y *height*)
              (pr.is-key-released pr.KEY_R))
      (setv level (restart-level current-level))))
  (pr.close-window))
