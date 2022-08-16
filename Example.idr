module Main

import CustomElement
import OnsList
import OnsListItem

main : IO ()
main = customElement "eric-element" $ do PropEffect Bool "open" (\self, last, current => putStrLn $ "was " ++ show last ++ " now " ++ show current)
                                         PropEffect String "help" (\self, last, current => putStrLn current)
                                         Prop Bool "yes"
                                         Prop String "hoho"
