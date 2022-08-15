module JsHelpers

import Types

typeString : PropType t -> String
typeString PropString = "string"
typeString PropBool = "bool"

stringToAttr : ToAttr String

stringFromAttr : FromAttr String

boolToAttr : ToAttr Bool
boolToAttr False = Nothing
boolToAttr True = Just ""

boolFromAttr : FromAttr Bool
boolFromAttr Nothing = False
boolFromAttr (Just _) = True

%foreign "browser:lambda: makeProp"
prim__makeProp : String -> String -> PrimIO AnyPtr

export
makeProp : PropType t -> String -> IO AnyPtr
makeProp pt name = primIO $ prim__makeProp name (typeString pt)

%foreign "browser:lambda: makePropEffect"
prim__makePropEffect_string : String -> String -> (This -> String -> String -> PrimIO ()) ->
                              ToAttr String -> FromAttr String -> PrimIO AnyPtr

%foreign "browser:lambda: makePropEffect"
prim__makePropEffect_bool : String -> String -> (This -> Bool -> Bool -> PrimIO ()) ->
                            ToAttr Bool -> FromAttr Bool -> PrimIO AnyPtr

export
makePropEffect : PropType t -> String -> (This -> t -> t -> IO ()) -> IO AnyPtr
makePropEffect PropString name callback =
  primIO $ prim__makePropEffect_string name (typeString PropString) (\self, last, current => toPrim $ callback self last current) stringToAttr stringFromAttr
makePropEffect PropBool name callback =
  primIO $ prim__makePropEffect_bool name (typeString PropBool) (\self, last, current => toPrim $ callback self last current) boolToAttr boolFromAttr

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
prim__getter_bool : String -> PrimIO (This -> Int)

export
getter : PropType t -> String -> IO (This -> t)
getter PropString prop = primIO $ prim__getter_string prop
getter PropBool prop = do getInt <- primIO $ prim__getter_bool prop
                          pure (\self => case getInt self of
                                              0 => False
                                              _ => True)
