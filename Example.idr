module Main

import CustomElement
import OnsList
import OnsListItem

main : IO ()
main = customElement "eric-element" $ do triggerAction <- Event "action"
                                         Listener "click" (\self => triggerAction <*> pure self)
                                         Listener "action" (\self => putStrLn "action, boys.")
