module JsHelpers

import Types
import Decidable.Equality

typeString : PropType t -> String
typeString PropString = "string"
typeString PropBool = "bool"

record Attr (t : Type) where
  constructor MkAttr
  toAttr : t -> Maybe String
  fromAttr : Maybe String -> t
  surjProof : (x : t) -> fromAttr (toAttr x) = x


stringAttr : Attr String
stringAttr = MkAttr toAttr fromAttr surjProof
  where
    toAttr : String -> Maybe String
    toAttr s = toAttr' s (decEq s "default")
      where
        toAttr' : (s' : String) -> (Dec (s' = "default")) -> Maybe String
        toAttr' s' (Yes prf) = Nothing
        toAttr' s' (No contra) = Just s'

    fromAttr : Maybe String -> String
    fromAttr = fst . fromAttr'
      where
        fromAttr' : Maybe String -> (s : String ** Dec (s = "default"))
        fromAttr' Nothing = ("default" ** Yes Refl)
        fromAttr' (Just x) = (x ** decEq x "default")

    surjProof : (s : String) -> fromAttr (toAttr s) = s
    surjProof s with (decEq s "default")
      surjProof s | (Yes prf) = sym prf
      surjProof s | (No contra) = Refl


boolAttr : Attr Bool
boolAttr = MkAttr toAttr fromAttr surjProof
  where
    toAttr : Bool -> Maybe String
    toAttr False = Nothing
    toAttr True = Just ""

    fromAttr : Maybe String -> Bool
    fromAttr Nothing = False
    fromAttr (Just _) = True

    surjProof : (b : Bool) -> fromAttr (toAttr b) = b
    surjProof False = Refl
    surjProof True = Refl


getAttr : PropType t -> Attr t
getAttr PropString = stringAttr
getAttr PropBool = boolAttr


%foreign "browser:lambda: makeProp"
prim__makeProp : String -> String ->
                 ToAttr t -> FromAttr t ->
                 PrimIO AnyPtr

export
makeProp : PropType t -> String -> IO AnyPtr
makeProp pt name = let attr = getAttr pt
                   in primIO $ prim__makeProp name (typeString pt) (toAttr attr) (fromAttr attr)

%foreign "browser:lambda: makeProp"
prim__makePropEffect : String -> String ->
                       ToAttr t -> FromAttr t ->
                       (This -> t -> t -> PrimIO ()) -> PrimIO AnyPtr

export
makePropEffect : PropType t -> String -> (This -> t -> t -> IO ()) -> IO AnyPtr
makePropEffect pt name callback = let
                                    attr = getAttr pt
                                    f = \self, last, current => toPrim $ callback self last current
                                  in
                                    primIO $ prim__makePropEffect name (typeString pt) (toAttr attr) (fromAttr attr) f

%foreign "browser:lambda: makeListener"
prim__makeListener : String -> (This -> PrimIO ()) -> PrimIO AnyPtr

export
makeListener : String -> (This -> IO ()) -> IO AnyPtr
makeListener event callback = primIO $ prim__makeListener event (\self => toPrim $ callback self)

%foreign "browser:lambda: makeTemplate"
prim__makeTemplate : String -> PrimIO AnyPtr

export
makeTemplate : String -> IO AnyPtr
makeTemplate template = primIO $ prim__makeTemplate template

%foreign "browser:lambda: makeState"
prim__makeState : String -> t -> PrimIO AnyPtr

export
makeState : String -> t -> IO AnyPtr
makeState key init = primIO $ prim__makeState key init

%foreign "browser:lambda: makeBind"
prim__makeBind : AnyPtr -> AnyPtr -> PrimIO AnyPtr

export
makeBind : AnyPtr -> AnyPtr -> IO AnyPtr
makeBind f g = primIO $ prim__makeBind f g

%foreign "browser:lambda: makePure"
prim__makePure : PrimIO AnyPtr

export
makePure : IO AnyPtr
makePure = primIO prim__makePure

%foreign "browser:lambda: defineCustomElement"
prim__defineCustomElement : String -> AnyPtr -> PrimIO ()

export
defineCustomElement : String -> AnyPtr -> IO ()
defineCustomElement tagName make = primIO $ prim__defineCustomElement tagName make

%foreign "browser:lambda: setter"
prim__setter : String -> t -> PrimIO (This -> ())

export
setter : PropType t -> String -> t -> IO (This -> ())
setter pt prop value = primIO $ prim__setter prop value

%foreign "browser:lambda: getter"
prim__getter_string : String -> PrimIO (This -> String)

%foreign "browser:lambda: getter_bool"
prim__getter_bool : String -> PrimIO (This -> Bool)

export
getter : PropType t -> String -> IO (This -> t)
getter PropString prop = primIO $ prim__getter_string prop
getter PropBool prop = primIO $ prim__getter_bool prop

%foreign "browser:lambda: eventDispatcher"
prim__eventDispatcher : String -> PrimIO (This -> ())

export
eventDispatcher : String -> IO (This -> ())
eventDispatcher name = primIO $ prim__eventDispatcher name

%foreign "browser:lambda: getState"
prim__getState : String -> PrimIO (This -> t)

export
getState : String -> IO (This -> t)
getState key = primIO $ prim__getState key

%foreign "browser:lambda: setState"
prim__setState : String -> t -> PrimIO (This -> ())

export
setState : String -> t -> IO (This -> ())
setState key value = primIO $ prim__setState key value
