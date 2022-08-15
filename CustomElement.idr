module CustomElement

import public JsHelpers
import public Types

-- %default total

export
customElement : (tagName : String) -> CustomElement a -> IO ()
customElement tagName inp = do (_, make) <- buildClass inp
                               defineCustomElement tagName make
  where
    buildClass : CustomElement b -> IO (b, AnyPtr)
    buildClass (Prop {pt} _ name) = makeProp pt name >>= \make => pure ((getter pt name, setter pt name), make)
    buildClass (PropEffect {pt} _ name callback) =
      makePropEffect pt name callback >>= \make => pure ((getter pt name, setter pt name), make)
    buildClass (Listener event callback) = makeListener event callback >>= \make => pure ((), make)
    buildClass (Template template) = makeTemplate template >>= \make => pure ((), make)
    buildClass (x >>= f) = do (res1, make1) <- buildClass x
                              (res2, make2) <- buildClass (f res1)
                              bothMakes <- makeBind make1 make2
                              pure (res2, bothMakes)
    buildClass (x >> y) = do (_, make1) <- buildClass x
                             (res, make2) <- buildClass y
                             bothMakes <- makeBind make1 make2
                             pure (res, bothMakes)
    buildClass (Pure x) = makePure >>= \make => pure (x, make)
