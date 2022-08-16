module Main

import CustomElement

main : IO ()
main = customElement "eric-element" $ do (getMsg, setMsg) <- State String "message" "hello"
                                         Listener "click" (\self => do msg <- getMsg <*> pure self
                                                                       putStrLn $ "my secret message is " ++ msg
                                                                       putStrLn "now let's destroy it"
                                                                       setMsg "[REDACTED]" <*> pure self)
