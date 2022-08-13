module CustomElement.Types

public export
data PropType : Type -> Type where
  PropString : PropType String
  PropBool : PropType Bool

public export
This : Type
This = AnyPtr

public export
Setter : Type -> Type
Setter t = t -> IO (This -> ())

public export
Getter : Type -> Type
Getter t = IO (This -> t)

public export
data CustomElement : Type -> Type where
  Prop : (t : Type) -> {auto pt : PropType t} -> (name : String) -> CustomElement (Getter t, Setter t)        -- a property and a synced attribute

  PropEffect : (t : Type) -> {auto pt : PropType t} -> (name : String) ->              -- a property that does some side-effect when set
               (callback : This -> String -> String -> IO ()) -> CustomElement (Getter t, Setter t)

  Listener : (event : String) -> (callback : This -> IO ()) -> CustomElement ()    -- do some side-effect on an event
  Template : (template : String) -> CustomElement ()              -- add a Shadow DOM with an HTML template

  (>>=) : CustomElement a -> (a -> CustomElement b) -> CustomElement b
  (>>) : CustomElement a -> CustomElement b -> CustomElement b
