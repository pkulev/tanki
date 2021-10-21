(import [pyray :as pr])

(import [tanki [common]])

(defclass Obstacle []

  (defn --init-- [self pos]
    (setv self.pos pos
          self.speed 3
          self.width 120
          self.height 500
          self.collision-rect (pr.Rectangle pos.x pos.y self.width self.height)))

  #@(property
      (defn rect [self]
        (pr.Rectangle self.pos.x self.pos.y self.width self.height)))

  (defn update [self]
    (-= self.pos.x self.speed)
    (setv self.collision-rect.x self.pos.x
          self.collision-rect.y self.pos.y))

  (defn render [self]
    (pr.draw-rectangle-rec self.rect pr.YELLOW)
    (when common.*debug*
      (pr.draw-rectangle-lines-ex self.collision-rect 1 pr.RED))))


(defclass ObstaclePair []
  (setv texture-up "assets/gfx/obstacle-up.png")
  (setv texture-down "assets/gfx/obstacle-down.png")

  (defn --init-- [self &optional [gap 250]])

  (defn update [self])

  (defn render [self]))

(defclass ObstaclePool []

  (defn --init-- [self &optional [num 3]]
    (setv self.obstacles [(ObstaclePair) (ObstaclePair) (ObstaclePair)])))
