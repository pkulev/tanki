(setv *resolution* (, 1024 768)
      [*width* *height*] *resolution*
      *debug* False
      *music* True)

(defn clamp [val min-val max-val]
  (get (sorted [min-val val max-val]) 1))
