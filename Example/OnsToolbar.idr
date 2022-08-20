module Example.OnsToolbar

import CustomElement
import Example.OnsGlobal

css : String
css =
  """
  \{globalCss}
  """

%foreign "browser:lambda: self => self.classList.add('toolbar')"
prim__addClass : This -> PrimIO ()

addClass : This -> IO ()
addClass self = primIO $ prim__addClass self

export
onsToolbar : CustomElement ()
onsToolbar = do Template
                  """
                  <style>
                    \{css}
                  </style>
                  <div class="toolbar__left">
                    <slot name="left"></slot>
                  </div>
                  <div class="toolbar__center">
                    <slot name="center"></slot>
                    <slot></slot>
                  </div>
                  <div class="toolbar__right">
                    <slot name="right"></slot>
                  </div>
                  """

                FirstConnected addClass
