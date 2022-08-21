module CustomElement.Types

%default total

public export
data PropType : Type -> Type where
  PropString : PropType String
  PropBool : PropType Bool

public export
This : Type
This = AnyPtr

public export
Target : Type
Target = AnyPtr

public export
Setter : Type -> Type
Setter t = t -> IO (This -> ())

public export
Getter : Type -> Type
Getter t = IO (This -> t)

public export
EventDispatcher : Type
EventDispatcher = IO (This -> ())

public export
ToAttr : Type -> Type
ToAttr t = t -> Maybe String

public export
FromAttr : Type -> Type
FromAttr t = Maybe String -> t

mutual
  public export
  data CustomElement : Type -> Type where
    Prop : (t : Type) -> {auto pt : PropType t} -> (name : String) -> CustomElement (Getter t, Setter t)        -- a property and a synced attribute

    PropEffect : (t : Type) -> {auto pt : PropType t} -> (name : String) ->              -- a property that does some side-effect when set
                 (callback : This -> t -> t -> IO ()) -> CustomElement (Getter t, Setter t)

    Listener : (event : String) -> (callback : This -> Target -> IO ()) -> CustomElement ()    -- do some side-effect on an event
    Template : (template : String) -> CustomElement ()              -- add a Shadow DOM with an HTML template

    Event : (name : String) -> CustomElement EventDispatcher        -- an event with a function to trigger the event

    State : {t : Type} -> (key : String) -> (initialValue : t) -> CustomElement (IO (This -> t), t -> IO (This -> ()))

    Depend : (want : CustomElement a) -> (dep : CustomElement b) ->   -- use some functionality from another custom element
             {auto has : Has want dep} -> CustomElement a

    FirstConnected : (callback : This -> IO ()) -> CustomElement ()     -- do something the first time the element is connected

    (>>=) : CustomElement a -> (a -> CustomElement b) -> CustomElement b
    (>>) : CustomElement a -> CustomElement b -> CustomElement b
    Pure : t -> CustomElement t

  -- TODO: Fix this!
  -- The first problem is that Always is not strictly positive.
  -- The second problem is that AlwaysBind1 has g : b -> CustomElement b, but I want g : b -> CustomElement c.
  --public export
  --data Always : (want : CustomElement b) -> (f : a -> CustomElement b) -> Type where
  --  AlwaysHere : ((x : a) -> f x = want) -> Always want f
  --  AlwaysBind1 : Always want f -> Always want (\x => f x >>= g)
  --  AlwaysBind2 : Always want f -> Always want (\x => f x >> g)

  public export
  data Has : (want : CustomElement a) -> (ce : CustomElement b) -> Type where
    HasHere : Has x x
    HasBind1 : Has x y -> Has x (y >>= f)
    -- HasBind2 : Always x f -> Has x (y >>= f)
    HasBind3 : Has x y -> Has x (y >> z)
    HasBind4 : Has x z -> Has x (y >> z)
    HasPropEffect : {pt : PropType t} -> Has (Prop t name) (PropEffect t name f)
