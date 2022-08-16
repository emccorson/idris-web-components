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


%foreign "browser:lambda: makeProp"
prim__makeProp_string : String -> String ->
                        ToAttr String -> FromAttr String ->
                        PrimIO AnyPtr

%foreign "browser:lambda: makeProp"
prim__makeProp_bool : String -> String ->
                      ToAttr Bool -> FromAttr Bool ->
                      PrimIO AnyPtr

export
makeProp : PropType t -> String -> IO AnyPtr
makeProp PropString name = primIO $ prim__makeProp_string name (typeString PropString) (toAttr stringAttr) (fromAttr stringAttr)
makeProp PropBool name = primIO $ prim__makeProp_bool name (typeString PropBool) (toAttr boolAttr) (fromAttr boolAttr)

%foreign "browser:lambda: makeProp"
prim__makePropEffect_string : String -> String ->
                              ToAttr String -> FromAttr String ->
                              (This -> String -> String -> PrimIO ()) -> PrimIO AnyPtr

%foreign "browser:lambda: makeProp"
prim__makePropEffect_bool : String -> String ->
                            ToAttr Bool -> FromAttr Bool ->
                            (This -> Bool -> Bool -> PrimIO ()) -> PrimIO AnyPtr

export
makePropEffect : PropType t -> String -> (This -> t -> t -> IO ()) -> IO AnyPtr
makePropEffect PropString name callback =
  primIO $ prim__makePropEffect_string name (typeString PropString) (toAttr stringAttr) (fromAttr stringAttr) (\self, last, current => toPrim $ callback self last current)
makePropEffect PropBool name callback =
  primIO $ prim__makePropEffect_bool name (typeString PropBool) (toAttr boolAttr) (fromAttr boolAttr) (\self, last, current => toPrim $ callback self last current)

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
prim__setter_string : String -> String -> PrimIO (This -> ())

%foreign "browser:lambda: setter"
prim__setter_bool : String -> Bool -> PrimIO (This -> ())

export
setter : PropType t -> String -> t -> IO (This -> ())
setter pt prop value = let f = case pt of
                                    PropString => prim__setter_string
                                    PropBool => prim__setter_bool
                       in primIO $ f prop value

%foreign "browser:lambda: getter"
prim__getter_string : String -> PrimIO (This -> String)

%foreign "browser:lambda: getter_bool"
prim__getter_bool : String -> PrimIO (This -> Bool)

export
getter : PropType t -> String -> IO (This -> t)
getter PropString prop = primIO $ prim__getter_string prop
getter PropBool prop = primIO $ prim__getter_bool prop
