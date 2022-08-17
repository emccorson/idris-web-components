module Main

import CustomElement

import OnsTab
import OnsTabbar

child : CustomElement ()
child = do Prop String "hello"
           Template "<slot></slot>"

%foreign "browser:lambda: self => self.querySelector('eric-child')"
prim__getChild : This -> PrimIO AnyPtr

getChild : This -> IO AnyPtr
getChild self = primIO $ prim__getChild self

parent : CustomElement ()
parent = do (getHello, setHello) <- Depend (Prop String "hello") child   -- careful! these functions are for children, not parents.
            -- Depend (Prop String "nope") child     -- <--- this will fail because the prop doesn't exist on child!
            Listener "click" (\self, target => setHello "this be the verse" <*> getChild self)
            Template "<slot></slot>"

main : IO ()
main = do customElement "eric-child" child
          customElement "eric-parent" parent
