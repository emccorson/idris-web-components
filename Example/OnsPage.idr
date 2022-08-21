module Example.OnsPage

import CustomElement
import Example.OnsGlobal

%default total

css : String
css =
  """
  \{globalCss}

  .has-toolbar + .page__background + .page__content {
    top: 44px;
    top: var(--toolbar-height);
    padding-top: 0;
  }
  """

%foreign "browser:lambda: self => { const toolbarSlot = self.shadowRoot.querySelector('slot[name=toolbar]'); toolbarSlot.addEventListener('slotchange', () => toolbarSlot.assignedNodes().length === 0 ? toolbarSlot.classList.remove('has-toolbar') : toolbarSlot.classList.add('has-toolbar')) }"
prim__toolbarListener : This -> PrimIO ()

toolbarListener : This -> IO ()
toolbarListener self = primIO $ prim__toolbarListener self

export
onsPage : CustomElement ()
onsPage = do Template
               """
               <style>
                 \{css}
               </style>
               <div class="page" style="width: 100%" shown>
                 <slot name="toolbar"></slot>
                 <div class="page__background"></div>
                 <div class="page__content">
                   <slot></slot>
                 </div>
               </ons-page>
               """

             FirstConnected toolbarListener

             Pure ()
