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

%foreign "browser:lambda: makeBind"
prim__makeBind : AnyPtr -> AnyPtr -> PrimIO AnyPtr

makeBind : AnyPtr -> AnyPtr -> IO AnyPtr
makeBind f g = primIO $ prim__makeBind f g

%foreign "browser:lambda: defineCustomElement"
prim__defineCustomElement : AnyPtr -> PrimIO ()

defineCustomElement : AnyPtr -> IO ()
defineCustomElement make = primIO $ prim__defineCustomElement make

%foreign "browser:lambda: setter"
prim__setter : String -> String -> PrimIO ()

setter : String -> String -> IO ()
setter prop value = primIO $ prim__setter prop value

--------------------------------------------------------------------------------
-- Idris
--------------------------------------------------------------------------------

Setter : Type
Setter = String -> IO ()

data CustomElement : Type -> Type where
  Prop : (name : String) -> CustomElement Setter        -- a string property and a synced attribute
  Listener : (event : String) -> (callback : IO ()) -> CustomElement ()    -- do some side-effect on an event

  (>>=) : CustomElement a -> (a -> CustomElement b) -> CustomElement b

customElement : CustomElement a -> IO ()
customElement inp = do (_, make) <- buildClass inp
                       defineCustomElement make
  where
    buildClass : CustomElement b -> IO (b, AnyPtr)
    buildClass (Prop name) = makeProp name >>= \make => pure (setter name, make)
    buildClass (Listener event callback) = makeListener event callback >>= \make => pure ((), make)
    buildClass (x >>= f) = do (res1, make1) <- buildClass x
                              (res2, make2) <- buildClass (f res1)
                              bothMakes <- makeBind make1 make2
                              pure (res2, bothMakes)

--------------------------------------------------------------------------------
-- test
--------------------------------------------------------------------------------

main : IO ()
main = customElement $ Prop "hello" >>= \setHello => Listener "click" (setHello "dolly")
