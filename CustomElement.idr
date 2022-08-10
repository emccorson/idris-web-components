-- %default total
%include JavaScript "helper.js"

--------------------------------------------------------------------------------
-- JS helpers
--------------------------------------------------------------------------------

%inline
jscall : (fname : String) -> (ty : Type) -> {auto fty : FTy FFI_JS [] ty} -> ty
jscall fname ty = foreign FFI_JS fname ty

defineCustomElement : Ptr -> JS_IO ()
defineCustomElement = jscall "defineCustomElement(%0)" (Ptr -> JS_IO ())

makeVanilla : JS_IO Ptr
makeVanilla = jscall "makeVanilla()" (JS_IO Ptr)

makeProp : String -> JS_IO Ptr
makeProp = jscall "makeProp(%0)" (String -> JS_IO Ptr)

makeEffect : String -> (() -> JS_IO ()) -> JS_IO Ptr
makeEffect event callback = jscall "makeEffect(%0, %1)" (String -> JsFn (() -> JS_IO ()) -> JS_IO Ptr) event (MkJsFn callback)

makePropEffect : String -> JS_IO Ptr -> JS_IO Ptr
makePropEffect name callback = callback >>= \c => jscall "makePropEffect(%0, %1)" (String -> Ptr -> JS_IO Ptr) name c

addClass : JS_IO Ptr
addClass = jscall ("addClass('victory')") (JS_IO Ptr)

--------------------------------------------------------------------------------
-- Idris
--------------------------------------------------------------------------------

data CustomElement : Type -> Type where
  Vanilla : CustomElement ()                        -- the most basic custom element
  Prop : (name : String) -> CustomElement ()        -- a custom element with a string property and a synced attribute
  Effect : (event : String) -> (callback : JS_IO ()) -> CustomElement ()    -- a custom element that does something on an event
  PropEffect : (name : String) -> (callback : JS_IO Ptr) -> CustomElement ()  -- a custom element with a prop that has a side-effect

customElement : CustomElement a -> JS_IO ()
customElement inp = buildClass inp >>= defineCustomElement
  where
    buildClass : CustomElement a -> JS_IO Ptr
    buildClass Vanilla = makeVanilla
    buildClass (Prop name) = makeProp name
    buildClass (Effect event callback) = makeEffect event (\_ => callback)
    buildClass (PropEffect name callback) = makePropEffect name callback

--------------------------------------------------------------------------------
-- test
--------------------------------------------------------------------------------

main : JS_IO ()
main = customElement $ PropEffect "color" addClass
