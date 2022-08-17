module OnsTabbar

import CustomElement

%foreign "browser:lambda: e => e.id"
prim__id : AnyPtr -> PrimIO String

id : AnyPtr -> IO String
id ptr = primIO $ prim__id ptr

%foreign "browser:lambda: id => document.getElementById(id).active = false"
prim__removeActive : String -> PrimIO ()

removeActive : String -> IO ()
removeActive ptr = primIO $ prim__removeActive ptr

export
onsTabbar : CustomElement ()
onsTabbar = do Template
                 """
                 <slot></slot>
                 """

               (getActiveTab, setActiveTab) <- State "activeTab" Nothing

               Listener "active" (\self, target => do maybeOldTab <- getActiveTab <*> pure self
                                                      case maybeOldTab of
                                                           Just oldTab => removeActive oldTab
                                                           Nothing => pure ()

                                                      newTab <- id target
                                                      setActiveTab (Just newTab) <*> pure self)
