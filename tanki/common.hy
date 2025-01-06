(import pathlib [Path])

(import pyray :as pr)


(setv *resolution* #(1024 768)
      [*width* *height*] *resolution*
      *debug* False
      *music* True
      *assets-dir* (/ (. (Path __file__) parent parent) "assets"))

(defn clamp [val min-val max-val]
  (get (sorted [min-val val max-val]) 1))

(defn res [#* parts]
  (/ *assets-dir* #* parts))

(defn load-texture [#* parts]
  (pr.load-texture (str (res "gfx" #* parts))))

(defn load-sound [#* parts]
  (pr.load-sound (str (res "snd" #* parts))))

(defn load-music-stream [#* parts]
  (pr.load-music-stream (str (res "snd" #* parts))))
