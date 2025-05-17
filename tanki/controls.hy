"Input management."

(import dataclasses [dataclass field])

(import tanki.common)

(import pyray :as pr)

;; ActionSet is mapping of some context/scheme identificator to allowed set of
;; actions in the terms of game. It can be created dynamically too (in future).

(defclass [dataclass] Action []
  (setv #^ str name None))


(setv *controls*
  {"gamepad"
   {:global
    {:toggle-debug 1
     :toggle-music 2}

    :menu
    {:select "X"
     :back "B"}

    :in-game
    {:jump 7 #_ pr.GAMEPAD-BUTTON-RIGHT-FACE-LEFT
     :restart 8
     :toggle-pause 9
     :toggle-device 10
     :fire 11}}

   "keyboard"
   {:global
    {:toggle-debug pr.KEY_D
     :toggle-music pr.KEY_M}

    :menu
    {:select "LMB"
     :back pr.KEY_ESCAPE}

    :in-game
    {:jump pr.KEY_LEFT_SHIFT
     :restart pr.KEY_R
     :toggle-device pr.KEY_I
     :toggle-pause pr.KEY_P
     :fire pr.KEY_SPACE}}})


(defclass Device [])

(defclass Keyboard [Device]

  (setv name "keyboard")

  (defn key-pressed? [self key]
    (pr.is-key-down key))

  (defn key-released? [self key]
    (pr.is-key-released key))

  (defn key? [self key [mode :released]]
    (match mode
           :released (self.key-released? key)
           :pressed (self.key-pressed? key))))


(defclass Gamepad [Device]

  (setv name "gamepad")

  (defn button-pressed? [self button]
    (pr.is-gamepad-button-down 0 button)) ;; FIXME: !!! DOWN != PRESSED (just-pressed mb)

  (defn button-released? [self button]
    (pr.is-gamepad-button-released 0 button))

  (defn key? [self key [mode :released]]
    ;; (when (!= (pr.get-gamepad-button-pressed) -1)
    ;;   (print (pr.get-gamepad-button-pressed)))
    (print (pr.get-gamepad-button-pressed))
    (match mode
           :released (self.button-released? key)
           :pressed (self.button-pressed? key))))


(defclass InputSystem []

  (defn __init__ [self]
    (setv self.devices {"keyboard" (Keyboard)}
          self.device (get self.devices "keyboard")))

  (defn get-next-device [self]
    "Return next supported device."
    (setv next-index (% (+ (.index (list self.devices) self.device.name) 1) (len self.devices)))
    (get self.devices (get (list self.devices) next-index)))

  (defn set-next-device [self]
    (setv self.device (self.get-next-device)))

  (defn gamepad-available? [self]
    (pr.is-gamepad-available 0))

  (defn device-registered? [self device]
    (in device self.devices))

  (defn register-device [self device]
    (setv (get self.devices device.name) device))

  (defn deregister-device [self name]
    (when (= self.device.name name)
      (self.set-next-device))
    (.pop self.devices name None))

  (defn check-gamepad [self]
    (if (self.gamepad-available?)
        (self.register-device (Gamepad))
        (self.deregister-device "gamepad")))

  (defn update [self]
    (self.check-gamepad))

  (defn render [self]
    (when tanki.common.*debug*
      (pr.draw-text f"Device: {self.device}" 5 30 20 pr.RAYWHITE)
      (pr.draw-text f"Devices: {self.devices}" 5 60 20 pr.RAYWHITE)))

  (defn action? [self action context [mode :released]]
    (setv the-control (get *controls* self.device.name context action))

    (when (is the-control None)
      (print "oh no I don't know such action")
      (return False))

    (if (isinstance the-control tuple)
        (setv [control atype key-type] the-control)
        (setv [control atype key-type] [the-control :key mode]))

    (self.device.key? control key-type)))
