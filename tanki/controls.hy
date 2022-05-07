"Input management."

(import dataclasses [dataclass field])

(import tanki.common)

(import pyray :as pr)

;; ActionSet is mapping of some context/scheme identificator to allowed set of
;; actions in the terms of game. It can be created dynamically too (in future).

#@(dataclass
    (defclass Action []
      (setv ^str name None)))


(setv *controls*
  {"gamepad"
   {:global
    {:toggle-debug "X"}

    :menu
    {:select "X"
     :back "B"}

    :in-game
    {:jump 7 #_pr.GAMEPAD-BUTTON-RIGHT-FACE-LEFT
     :restart (, 8 :button :released)
     :pause "B"}}

   "keyboard"
   {:global
    {:toggle-debug "D"
     :toggle-music "M"}

    :menu
    {:select "LMB"
     :back pr.KEY_ESCAPE}

    :in-game
    {:jump pr.KEY_LEFT_SHIFT
     :restart (, pr.KEY_R :key :released)
     :toggle-pause pr.KEY_P}}})


(defclass Device [])

(defclass Keyboard [Device]

  (setv name "keyboard")

  (defn key-pressed? [self key]
    (pr.is-key-down key))

  (defn key-released? [self key]
    (pr.is-key-released key))

  (defn key? [self key mode]
    (cond [(= mode :released) (self.key-released? key)]
          [True (self.key-pressed? key)])))


(defclass Gamepad [Device]

  (setv name "gamepad")

  (defn button-pressed? [self button]
    (pr.is-gamepad-button-pressed 0 button))

  (defn button-released? [self button]
    (pr.is-gamepad-button-released 0 button))

  (defn key? [self key mode]
    ;; (when (!= (pr.get-gamepad-button-pressed) -1)
    ;;   (print (pr.get-gamepad-button-pressed)))
    (print (pr.get-gamepad-button-pressed))
    (cond [(= mode :released) (self.button-released? key)]
          [True (self.button-pressed? key)])))


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

  (defn action? [self action context]
    (setv [control atype key-type] (get *controls* self.device.name context action))
    (self.device.key? control key-type)))
