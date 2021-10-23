(import random)

(import [pyray :as pr])

(import [tanki [common]])

(defclass Obstacle []

  (defn --init-- [self pos width height]
    (setv self.pos pos
          self.speed 3
          self.width width
          self.height height
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
  (setv texture-top "assets/gfx/obstacle-top.png")
  (setv texture-bottom "assets/gfx/obstacle-bottom.png")

  (defn --init-- [self top bottom]
    (setv self.top top
          self.bottom bottom
          self.checked? False))

  (defn set-pos-x [self x]
    (setv self.top.pos.x x
          self.bottom.pos.x x))

  (defn get-pos-x [self]
    self.bottom.pos.x)

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
                  [initial-pos-x 700]
                  ;; gap should be big enough to fit jumping player
                  ;; for now it looks like player.width + 1/3 of player.width is ok
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
    (setv objects [])
    (for [n (range self.num)]
      (setv distance-x (random.randint self.min-distance-x self.max-distance-x)
            top-height (random.randint self.min-top-height self.max-top-height)
            bottom-height (- common.*height* self.gap top-height))
      (objects.append
        (ObstaclePair
          (Obstacle (pr.Vector2 (+ 700 (* n distance-x)) 0) 120 top-height)
          (Obstacle (pr.Vector2 (+ 700 (* n distance-x)) (+ top-height self.gap)) 120 bottom-height))))
    objects)

  (defn find-farest-object [self]
    (setv obj None
          x -1)
    (for [object self.objects]
      (when (> (object.get-pos-x) x)
        (setv obj object
              x (object.get-pos-x))))
    obj)

  (defn update [self]
    (for [object self.objects]
      (object.update)
      ;; we really don't care top or bottom here
      (when (< (+ (object.get-pos-x) object.bottom.width) 0)
        (object.set-pos-x (+ ((. (self.find-farest-object) get-pos-x))
                             (random.randint self.min-distance-x self.max-distance-x))))))

  (defn render [self]
    (for [object self.objects]
      (object.render))))
