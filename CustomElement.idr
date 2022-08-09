%default total

--------------------------------------------------------------------------------
-- JS helpers
--------------------------------------------------------------------------------

%inline
jscall : (fname : String) -> (ty : Type) -> {auto fty : FTy FFI_JS [] ty} -> ty
jscall fname ty = foreign FFI_JS fname ty

defineCustomElement : JS_IO ()
defineCustomElement = jscall "defineCustomElement()" (JS_IO ())

--------------------------------------------------------------------------------
-- Idris
--------------------------------------------------------------------------------

data CustomElement : Type -> Type where
  Vanilla : CustomElement ()               -- the most basic custom element

-- I am going to define this in the style of the hakyll function.
-- That means we have a monad CustomElement and the function says how to turn it into IO.
customElement : CustomElement a -> JS_IO ()
customElement Vanilla = defineCustomElement

--------------------------------------------------------------------------------
-- test
--------------------------------------------------------------------------------

main : JS_IO ()
main = customElement Vanilla
