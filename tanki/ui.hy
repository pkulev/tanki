(import pyray :as pr)

(import tanki [common])


(defclass ProgressBar []

  (defn __init__ [self x y w h bg-color fg-color val min-val max-val
                  [label None]
                  [font-size None]
                  [label-color pr.RAYWHITE]
                  [spacing 3]]
    (when (and label (not font-size))
      (raise (ValueError "set font-size when setting label")))

    (setv self.x x
          self.y y
          self.w w
          self.h h
          self.bg-color bg-color
          self.fg-color fg-color
          self.val val
          self.min-val min-val
          self.max-val max-val
          self.label label
          self.font-size font-size
          self.label-color label-color
          self.label-size-x (when label (pr.measure-text label font-size))
          self.spacing spacing))

  (defn update [self val]
    (setv self.val (common.clamp val self.min-val self.max-val)))

  (defn render [self]
    (setv x (if self.label (+ self.x self.label-size-x self.spacing) self.x)
          val-% (/ (* self.val 100) (- self.max-val self.min-val))
          fill-h (int (* (/ self.w 100) val-%)))

    ;; label
    (when self.label
      (pr.draw-text self.label self.x self.y self.font-size self.label-color))

    ;; background
    (pr.draw-rectangle x self.y self.w self.h self.bg-color)
    ;; fill rectangle
    (pr.draw-rectangle x self.y fill-h self.h self.fg-color)))
