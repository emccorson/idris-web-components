-- %default total

--------------------------------------------------------------------------------
-- JS helpers
--------------------------------------------------------------------------------

%foreign "browser:lambda: makeProp"
prim__makeProp : String -> PrimIO AnyPtr

makeProp : String -> IO AnyPtr
makeProp name = primIO $ prim__makeProp name

%foreign "browser:lambda: makeListener"
prim__makeListener : String -> IO () -> PrimIO AnyPtr

makeListener : String -> IO () -> IO AnyPtr
makeListener event callback = primIO $ prim__makeListener event callback

%foreign "browser:lambda: defineCustomElement"
prim__defineCustomElement : AnyPtr -> PrimIO ()

defineCustomElement : AnyPtr -> IO ()
defineCustomElement make = primIO $ prim__defineCustomElement make

--------------------------------------------------------------------------------
-- Idris
--------------------------------------------------------------------------------

data CustomElement : Type -> Type where
  Prop : (name : String) -> CustomElement ()        -- a string property and a synced attribute
  Listener : (event : String) -> (callback : IO ()) -> CustomElement ()    -- do some side-effect on an event

customElement : CustomElement a -> IO ()
customElement inp = do (_, make) <- buildClass inp
                       defineCustomElement make
  where
    buildClass : CustomElement b -> IO (b, AnyPtr)
    buildClass (Prop name) = makeProp name >>= \make => pure ((), make)
    buildClass (Listener event callback) = makeListener event callback >>= \make => pure ((), make)

--------------------------------------------------------------------------------
-- test
--------------------------------------------------------------------------------

main : IO ()
main = customElement $ Listener "click" $ putStrLn "hey now"
