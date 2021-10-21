(import [pyray :as pr])

(defclass Background []
  "Background with parallax."

  (defn --init-- [self name]
    (setv self.name name
          self.scrolling-back 0.0
          self.scrolling-mid 0.0
          self.scrolling-fore 0.0

          self.background (pr.load-texture f"assets/gfx/background-{name}.png")
          self.midround (pr.load-texture f"assets/gfx/midground-{name}.png")
          self.foreground (pr.load-texture f"assets/gfx/foreground-{name}.png")))

  (defn reset [self]
    (setv self.scrolling-back 0.0
          self.scrolling-mid 0.0
          self.scrolling-fore 0.0))

  (defn update [self]
    (-= self.scrolling-back 0.1)
    (-= self.scrolling-mid 0.5)
    (-= self.scrolling-fore 1.0)

    (when (<= self.scrolling-back (- (* self.background.width 2)))
      (setv self.scrolling-back 0.0))

    (when (<= self.scrolling-mid (- (* self.midround.width 2)))
      (setv self.scrolling-mid 0.0))

    (when (<= self.scrolling-fore (- (* self.foreground.width 2)))
      (setv self.scrolling-fore 0.0)))

  (defn render [self]
    (pr.draw-texture-v self.background
                       (pr.Vector2 self.scrolling-back -20)
                       pr.RAYWHITE)
    (pr.draw-texture-v self.background
                       (pr.Vector2 (+ self.scrolling-back (* self.background.width 2)) 20)
                       pr.RAYWHITE)

    (pr.draw-texture-v self.midround
                       (pr.Vector2 self.scrolling-mid 100)
                       pr.RAYWHITE)
    (pr.draw-texture-v self.midround
                       (pr.Vector2 (+ self.scrolling-mid (* self.midround.width 2)) 120)
                       pr.RAYWHITE)

    (pr.draw-texture-v self.foreground
                       (pr.Vector2 self.scrolling-fore 70)
                       pr.RAYWHITE)
    (pr.draw-texture-v self.foreground (pr.Vector2 (+ self.scrolling-fore (* self.foreground.width 2)) 70)
                       pr.RAYWHITE)))
