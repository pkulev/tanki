(import random)

(import [pyray :as pr])

(import [tanki [common]])

(defclass Obstacle []

  (defn --init-- [self pos &optional [width 0] [height 0]]
    (setv self.pos pos
          self.speed 3
          self.width width
          self.height height))

  #@(property
      (defn rect [self]
        (pr.Rectangle self.pos.x self.pos.y self.width self.height)))

  #@(property
      (defn collision-rect [self]
        self.rect))

  (defn randomize-size [self min-height max-height]
    (setv self.height (random.randint min-height max-height)))

  (defn update [self]
    (-= self.pos.x self.speed)
    (setv self.collision-rect.x self.pos.x
          self.collision-rect.y self.pos.y))

  (defn render [self]
    (pr.draw-rectangle-rec self.rect pr.YELLOW)
    (when common.*debug*
      (pr.draw-rectangle-lines-ex self.collision-rect 1 pr.RED))))


(defclass ObstaclePair []
  (setv texture-top "assets/gfx/obstacle-top.png")
  (setv texture-bottom "assets/gfx/obstacle-bottom.png")

  (defn --init-- [self x gap min-top-height max-top-height]
    (setv self.gap gap
          self.min-top-height min-top-height
          self.max-top-height max-top-height
          self.top (Obstacle (pr.Vector2 x 0) :width 120)
          self.bottom (Obstacle (pr.Vector2 x 0) :width 120)
          self.checked? False)
    (self.randomize-sizes))

  #@(property
      (defn x [self]
        self.bottom.pos.x))

  #@(x.setter
      (defn x [self new-x]
        (setv self.top.pos.x new-x
              self.bottom.pos.x new-x)))

  (defn randomize-top [self]
    (self.top.randomize-size self.min-top-height self.max-top-height))

  (defn randomize-bottom [self]
    (setv self.bottom.height (- common.*height* self.gap self.top.height)
          self.bottom.pos.y (+ self.top.height self.gap)))

  (defn randomize-sizes [self]
    (self.randomize-top)
    (self.randomize-bottom))

  (defn check-collision [self object-collider]
    (or (pr.check-collision-recs self.top.collision-rect object-collider)
        (pr.check-collision-recs self.bottom.collision-rect object-collider)))

  (defn update [self]
    (self.top.update)
    (self.bottom.update))

  (defn render [self]
    (self.top.render)
    (self.bottom.render)))

(defclass ObstaclePool []

  (defn --init-- [self
                  &optional
                  [num 4]
                  [initial-pos-x 600]
                  ;; gap should be big enough to fit jumping player
                  ;; for now it looks like player.height + 1/3 of player.height is ok
                  [gap 250]
                  ;; distance between obstacles
                  [min-distance-x 400]
                  [max-distance-x 500]
                  ;; x of top obstacles (random from min to max)
                  [min-top-height 50]
                  [max-top-height 400]]
    (setv self.num num
          self.max-distance-x max-distance-x
          self.initial-pos-x initial-pos-x
          self.gap gap
          self.min-distance-x min-distance-x
          self.max-distance-x max-distance-x
          self.min-top-height min-top-height
          self.max-top-height max-top-height
          self.objects (self.generate-obstacles)))

  (defn reset [self]
    (setv self.objects (self.generate-obstacles)))

  (defn check-collision [self object-collider]
    (for [obj self.objects]
      (when (obj.check-collision object-collider)
        (return True)))
    False)

  (defn generate-obstacles [self]
    (setv obstacles [])
    (for [n (range self.num)]
      (setv distance-x (random.randint self.min-distance-x self.max-distance-x)
            obstacle (ObstaclePair :x (+ self.initial-pos-x (* n distance-x))
                                   :gap self.gap
                                   :min-top-height self.min-top-height
                                   :max-top-height self.max-top-height))
      (obstacles.append obstacle))
    obstacles)

  (defn find-farest-obstacle [self]
    (setv obj None
          x -1)
    (for [obstacle self.objects]
      (when (> obstacle.x x)
        (setv obj obstacle
              x obstacle.x)))
    obj)

  (defn warp-pair [self pair]
    "Warps pair of obstacles that came out of x=0 behind x=width.

     Also randomizes where gap is."
    (setv pair.x (+ (. (self.find-farest-obstacle) x)
                    (random.randint self.min-distance-x self.max-distance-x)))
    (pair.randomize-sizes))

  (defn update [self]
    (for [pair self.objects]
      (pair.update)
      ;; we really don't care top or bottom here
      (when (< (+ pair.x pair.bottom.width) 0)
        (self.warp-pair pair))))

  (defn render [self]
    (for [pair self.objects]
      (pair.render))))
