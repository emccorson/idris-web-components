-- %default total

--------------------------------------------------------------------------------
-- JS helpers
--------------------------------------------------------------------------------

This : Type
This = AnyPtr

%foreign "browser:lambda: makeProp"
prim__makeProp : String -> PrimIO AnyPtr

makeProp : String -> IO AnyPtr
makeProp name = primIO $ prim__makeProp name

%foreign "browser:lambda: makeListener"
prim__makeListener : String -> (This -> PrimIO ()) -> PrimIO AnyPtr

makeListener : String -> (This -> IO ()) -> IO AnyPtr
makeListener event callback = primIO $ prim__makeListener event (\self => toPrim $ callback self)

%foreign "browser:lambda: makeBind"
prim__makeBind : AnyPtr -> AnyPtr -> PrimIO AnyPtr

makeBind : AnyPtr -> AnyPtr -> IO AnyPtr
makeBind f g = primIO $ prim__makeBind f g

%foreign "browser:lambda: defineCustomElement"
prim__defineCustomElement : String -> AnyPtr -> PrimIO ()

defineCustomElement : String -> AnyPtr -> IO ()
defineCustomElement tagName make = primIO $ prim__defineCustomElement tagName make

%foreign "browser:lambda: setter"
prim__setter : String -> String -> PrimIO (This -> ())

setter : String -> String -> IO (This -> ())
setter prop value = primIO $ prim__setter prop value

%foreign "browser:lambda: getter"
prim__getter : String -> PrimIO (This -> String)

getter : String -> IO (This -> String)
getter prop = primIO $ prim__getter prop

--------------------------------------------------------------------------------
-- Idris
--------------------------------------------------------------------------------

Setter : Type
Setter = String -> IO (This -> ())

Getter : Type
Getter = IO (This -> String)

data CustomElement : Type -> Type where
  Prop : (name : String) -> CustomElement (Getter, Setter)        -- a string property and a synced attribute
  Listener : (event : String) -> (callback : This -> IO ()) -> CustomElement ()    -- do some side-effect on an event

  (>>=) : CustomElement a -> (a -> CustomElement b) -> CustomElement b

customElement : (tagName : String) -> CustomElement a -> IO ()
customElement tagName inp = do (_, make) <- buildClass inp
                               defineCustomElement tagName make
  where
    buildClass : CustomElement b -> IO (b, AnyPtr)
    buildClass (Prop name) = makeProp name >>= \make => pure ((getter name, setter name), make)
    buildClass (Listener event callback) = makeListener event callback >>= \make => pure ((), make)
    buildClass (x >>= f) = do (res1, make1) <- buildClass x
                              (res2, make2) <- buildClass (f res1)
                              bothMakes <- makeBind make1 make2
                              pure (res2, bothMakes)

--------------------------------------------------------------------------------
-- test
--------------------------------------------------------------------------------

main : IO ()
main = customElement "eric-element" $ Prop "color" >>= \(_, setColor) =>
                                      Listener "click" (\self => setColor "lovely" >>= \f => pure (f self))
