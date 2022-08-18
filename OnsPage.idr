module OnsPage

import CustomElement
import OnsGlobal

css : String
css =
  """
  \{globalCss}
  """

export
onsPage : CustomElement ()
onsPage = Template
            """
            <style>
              \{css}
            </style>
            <div class="page" style="width: 100%" shown>
              <div class="page__background"></div>
              <div class="page__content">
                <slot></slot>
              </div>
            </ons-page>
            """
