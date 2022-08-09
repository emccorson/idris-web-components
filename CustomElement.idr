%default total
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

--------------------------------------------------------------------------------
-- Idris
--------------------------------------------------------------------------------

data CustomElement : Type -> Type where
  Vanilla : CustomElement ()                        -- the most basic custom element
  Prop : (name : String) -> CustomElement ()        -- a custom element with a string property and a synced attribute

-- I am going to define this in the style of the hakyll function.
-- That means we have a monad CustomElement and the function says how to turn it into IO.
customElement : CustomElement a -> JS_IO ()
customElement inp = buildClass inp >>= defineCustomElement
  where
    buildClass : CustomElement a -> JS_IO Ptr
    buildClass Vanilla = makeVanilla
    buildClass (Prop name) = makeProp name

--------------------------------------------------------------------------------
-- test
--------------------------------------------------------------------------------

main : JS_IO ()
main = customElement (Prop "hello")
