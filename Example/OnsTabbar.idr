module Example.OnsTabbar

import CustomElement
import Example.OnsGlobal

%default total

css : String
css =
  """
  \{globalCss}

  ::slotted([slot=pages]) {
    height: inherit;
    -webkit-flex-shrink: 0;
            flex-shrink: 0;
    box-sizing: border-box;
    width: 100%;
    position: relative !important;
  }
  """

%foreign "browser:lambda: (index, self) => self.shadowRoot.querySelector('slot[name=tabs]').assignedNodes()[index].active = false"
prim__removeActive : Int -> This -> PrimIO ()

removeActive : Int -> This -> IO ()
removeActive index self = primIO $ prim__removeActive index self

%foreign "browser:lambda: (tab, self) => self.shadowRoot.querySelector('slot[name=tabs]').assignedNodes().findIndex(t => t === tab)"
prim__getIndex : AnyPtr -> This -> PrimIO Int

getIndex : AnyPtr -> This -> IO Int
getIndex target self = primIO $ prim__getIndex target self

%foreign "browser:lambda: self => self.shadowRoot.querySelector('slot[name=tabs]').addEventListener('slotchange', e => e.target.assignedNodes()[0].active = true)"
prim__firstTabListener : This -> PrimIO ()

firstTabListener : This -> IO ()
firstTabListener self = primIO $ prim__firstTabListener self

%foreign "browser:lambda: (index, self) => { const swiper = self.shadowRoot.querySelector('.ons-swiper-target'); swiper.style.transform = `translate3d(${0 - index * swiper.offsetWidth}px, 0, 0)` }"
prim__moveSwiper : Int -> This -> PrimIO ()

moveSwiper : Int -> This -> IO ()
moveSwiper index self = primIO $ prim__moveSwiper index self

export
onsTabbar : CustomElement ()
onsTabbar = do Template
                 """
                 <style>
                   \{css}
                 </style>
                 <div class="tabbar__content ons-swiper">
                   <slot name="pages" class="ons-swiper-target active" style="transition: all 0.3s cubic-bezier(0.4, 0.7, 0.5, 1) 0s">
                   </slot>
                   <div class="ons-swiper-blocker"></div>
                 </div>
                 <div class="tabbar">
                   <slot name="tabs"></slot>
                 </div>
                 """

               (getActiveIndex, setActiveIndex) <- State "activeIndex" Nothing

               FirstConnected firstTabListener

               Listener "active" (\self, target => do -- remove active from the previous tab
                                                      lastActive <- getActiveIndex <*> pure self
                                                      case lastActive of
                                                           Nothing => pure ()
                                                           Just index => removeActive index self

                                                      -- store the new active tab index
                                                      currentActive <- getIndex target self
                                                      setActiveIndex (Just currentActive) <*> pure self

                                                      -- show the new page
                                                      moveSwiper currentActive self)

               Pure ()
