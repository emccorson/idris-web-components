module OnsTab

import CustomElement

export
onsTab : CustomElement ()
onsTab = do Template
              """
              <style>
                :host([active]) {
                  background-color: pink;
                }
              </style>
              <slot></slot>
              """

            triggerActive <- Event "active"

            let activeEffect = \self, last, current => if (current && not last)
                                                       then triggerActive <*> pure self
                                                       else pure ()
            (getActive, setActive) <- PropEffect Bool "active" activeEffect

            Listener "click" (\self, _ => setActive True <*> pure self)
