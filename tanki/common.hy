(setv *resolution* (, 1024 768))
(setv [*width* *height*] *resolution*)

(setv *debug* False)
(setv *music* True)

(defn clamp [val min-val max-val]
  (get (sorted [min-val val max-val]) 1))
