module Main

import CustomElement
import OnsList
import OnsListItem

main : IO ()
main = do customElement "ons-list" onsList
          customElement "ons-list-item" onsListItem
