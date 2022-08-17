module Main

import CustomElement

main : IO ()
main = customElement "eric-element" $ do (getCount, setCount) <- State "count" 0
                                         Listener "click" (\self => do c <- getCount <*> pure self
                                                                       putStrLn $ show c
                                                                       setCount (c + 1) <*> pure self)
