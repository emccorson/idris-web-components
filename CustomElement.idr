-- %default total

--------------------------------------------------------------------------------
-- JS helpers
--------------------------------------------------------------------------------

%foreign "browser:lambda: makerProp"
prim__makerProp : String -> PrimIO AnyPtr

makerProp : String -> IO AnyPtr
makerProp name = primIO $ prim__makerProp name

%foreign "browser:lambda: defineCustomElement"
prim__defineCustomElement : AnyPtr -> PrimIO ()

defineCustomElement : AnyPtr -> IO ()
defineCustomElement maker = primIO $ prim__defineCustomElement maker

--------------------------------------------------------------------------------
-- Idris
--------------------------------------------------------------------------------

data CustomElement : Type -> Type where
  Prop : (name : String) -> CustomElement ()        -- a custom element with a string property and a synced attribute

customElement : CustomElement a -> IO ()
customElement inp = do (_, maker) <- buildClass inp
                       defineCustomElement maker
  where
    buildClass : CustomElement b -> IO (b, AnyPtr)
    buildClass (Prop name) = makerProp name >>= \maker => pure ((), maker)

--------------------------------------------------------------------------------
-- test
--------------------------------------------------------------------------------

main : IO ()
main = customElement $ Prop "hello"
