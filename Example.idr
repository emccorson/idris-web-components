module Main

import CustomElement

%foreign "browser:lambda: switchClass"
prim__switchClass : String -> PrimIO (This -> String -> String -> ())

switchClass : String -> IO (This -> String -> String -> ())
switchClass prop = primIO $ prim__switchClass prop

main : IO ()
main = customElement "eric-element" $ do Template "<h1><slot></slot></h1>"
                                         Listener "click" $ \_ => putStrLn "clicked"
                                         Listener "click" $ \_ => putStrLn "clacked"
