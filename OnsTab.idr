module OnsTab

import CustomElement
import OnsGlobal

css : String
css =
  """
  \{globalCss}
  """

%foreign "browser:lambda: self => self.shadowRoot.querySelector('input').checked = true"
check : This -> PrimIO ()

%foreign "browser:lambda: self => self.shadowRoot.querySelector('input').checked = false"
uncheck : This -> PrimIO ()

toggleCheck : Bool -> This -> IO ()
toggleCheck False self = primIO $ uncheck self
toggleCheck True self = primIO $ check self

export
onsTab : CustomElement ()
onsTab = do Template
              """
              <style>
                \{css}
              </style>
                <input type="radio" style="display:none">
                <button class="tabbar__button">
                  <div class="tabbar__label">
                    <slot></slot>
                  </div>
                </button>
              """

            triggerActive <- Event "active"

            let activeEffect = \self, last, current => if last /= current
                                                       then do toggleCheck current self
                                                               triggerActive <*> pure self
                                                       else pure ()
            (getActive, setActive) <- PropEffect Bool "active" activeEffect

            Listener "click" (\self, _ => setActive True <*> pure self)

            Pure ()
