module OnsTabbar

import CustomElement
import OnsGlobal

css : String
css =
  """
  \{globalCss}
  """

%foreign "browser:lambda: (id, self) => self.querySelector(`#${id}`).active = false"
prim__removeActive : String -> This -> PrimIO ()

removeActive : String -> This -> IO ()
removeActive id self = primIO $ prim__removeActive id self

%foreign "browser:lambda: ({id}) => id"
prim__getId : AnyPtr -> PrimIO String

getId : AnyPtr -> IO String
getId target = primIO $ prim__getId target

%foreign "browser:lambda: self => self.querySelector('ons-tab').id"
prim__getFirstTab : This -> PrimIO String

getFirstTab : This -> IO String
getFirstTab self = primIO $ prim__getFirstTab self

%foreign "browser:lambda: self => self.shadowRoot.querySelector('slot[name=\"tabs\"]').addEventListener('slotchange', e => e.target.assignedNodes()[0].active = true)"
prim__firstTabListener : This -> PrimIO ()

firstTabListener : This -> IO ()
firstTabListener self = primIO $ prim__firstTabListener self

export
onsTabbar : CustomElement ()
onsTabbar = do Template
                 """
                 <style>
                   \{css}
                 </style>
                 <div class="tabbar__content ons-swiper">
                   <div class="ons-swiper-target active">
                      <slot name="pages"></slot>
                   </div>
                   <div class="ons-swiper-blocker"></div>
                 </div>
                 <div class="tabbar">
                   <slot name="tabs"></slot>
                 </div>
                 """

               (getLastActive, setLastActive) <- State "lastactive" Nothing

               FirstConnected firstTabListener

               Listener "active" (\self, target => do lastActive <- getLastActive <*> pure self
                                                      case lastActive of
                                                           Nothing => pure ()
                                                           Just id => removeActive id self

                                                      currentActive <- getId target
                                                      setLastActive (Just currentActive) <*> pure self)

               Pure ()
