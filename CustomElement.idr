-- %default total

--------------------------------------------------------------------------------
-- JS helpers
--------------------------------------------------------------------------------

data PropType : Type -> Type where
  PropString : PropType String
  PropBool : PropType Bool

This : Type
This = AnyPtr

Setter : Type -> Type
Setter t = t -> IO (This -> ())

Getter : Type -> Type
Getter t = IO (This -> t)

%foreign "browser:lambda: makeProp"
prim__makeProp : String -> String -> PrimIO AnyPtr

makeProp : PropType t -> String -> IO AnyPtr
makeProp pt name = let typeStr = case pt of
                                      PropString => "string"
                                      PropBool => "bool"
                   in primIO $ prim__makeProp name typeStr

%foreign "browser:lambda: makeListener"
prim__makeListener : String -> (This -> PrimIO ()) -> PrimIO AnyPtr

makeListener : String -> (This -> IO ()) -> IO AnyPtr
makeListener event callback = primIO $ prim__makeListener event (\self => toPrim $ callback self)

%foreign "browser:lambda: makeTemplate"
prim__makeTemplate : String -> PrimIO AnyPtr

makeTemplate : String -> IO AnyPtr
makeTemplate template = primIO $ prim__makeTemplate template

%foreign "browser:lambda: makeBind"
prim__makeBind : AnyPtr -> AnyPtr -> PrimIO AnyPtr

makeBind : AnyPtr -> AnyPtr -> IO AnyPtr
makeBind f g = primIO $ prim__makeBind f g

%foreign "browser:lambda: defineCustomElement"
prim__defineCustomElement : String -> AnyPtr -> PrimIO ()

defineCustomElement : String -> AnyPtr -> IO ()
defineCustomElement tagName make = primIO $ prim__defineCustomElement tagName make

%foreign "browser:lambda: setter"
prim__setter_string : String -> String -> PrimIO (This -> ())

%foreign "browser:lambda: setter"
prim__setter_bool : String -> Bool -> PrimIO (This -> ())

setter : PropType t -> String -> t -> IO (This -> ())
setter pt prop value = let f = case pt of
                                    PropString => prim__setter_string
                                    PropBool => prim__setter_bool
                       in primIO $ f prop value

%foreign "browser:lambda: getter"
prim__getter_string : String -> PrimIO (This -> String)

%foreign "browser:lambda: getter_bool"
prim__getter_bool : String -> PrimIO (This -> Int)

getter : PropType t -> String -> IO (This -> t)
getter PropString prop = primIO $ prim__getter_string prop
getter PropBool prop = do getInt <- primIO $ prim__getter_bool prop
                          pure (\self => case getInt self of
                                              0 => False
                                              _ => True)

--------------------------------------------------------------------------------
-- Idris
--------------------------------------------------------------------------------

data CustomElement : Type -> Type where
  Prop : (t : Type) -> {auto pt : PropType t} -> (name : String) -> CustomElement (Getter t, Setter t)        -- a property and a synced attribute
  Listener : (event : String) -> (callback : This -> IO ()) -> CustomElement ()    -- do some side-effect on an event
  Template : (template : String) -> CustomElement ()              -- add a Shadow DOM with an HTML template

  (>>=) : CustomElement a -> (a -> CustomElement b) -> CustomElement b

customElement : (tagName : String) -> CustomElement a -> IO ()
customElement tagName inp = do (_, make) <- buildClass inp
                               defineCustomElement tagName make
  where
    buildClass : CustomElement b -> IO (b, AnyPtr)
    buildClass (Prop {pt} _ name) = makeProp pt name >>= \make => pure ((getter pt name, setter pt name), make)
    buildClass (Listener event callback) = makeListener event callback >>= \make => pure ((), make)
    buildClass (Template template) = makeTemplate template >>= \make => pure ((), make)
    buildClass (x >>= f) = do (res1, make1) <- buildClass x
                              (res2, make2) <- buildClass (f res1)
                              bothMakes <- makeBind make1 make2
                              pure (res2, bothMakes)

--------------------------------------------------------------------------------
-- test
--------------------------------------------------------------------------------

main : IO ()
main = customElement "eric-element" $ Template "<h1><slot></slot></h1>" >>= \_ =>
                                      Prop Bool "good" >>= \(getGood, setGood) =>
                                      Listener "click" (\self => getGood >>= \g => let msg = case g self of
                                                                                                  False => "oh no"
                                                                                                  True => "oh yes"
                                                                                   in putStrLn msg)
