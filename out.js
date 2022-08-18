class IdrisError extends Error { }

function __prim_js2idris_array(x){
  if(x.length === 0){
    return {h:0}
  } else {
    return {a1:x[0],a2: __prim_js2idris_array(x.slice(1))}
  }
}

function __prim_idris2js_array(x){
  const result = Array();
  while (x.h === undefined) {
    result.push(x.a1); x = x.a2;
  }
  return result;
}

function __lazy(thunk) {
  let res;
  return function () {
    if (thunk === undefined) return res;
    res = thunk();
    thunk = undefined;
    return res;
  };
};

function __prim_stringIteratorNew(str) {
  return 0
}

function __prim_stringIteratorToString(_, str, it, f) {
  return f(str.slice(it))
}

function __prim_stringIteratorNext(str, it) {
  if (it >= str.length)
    return {h: 0};
  else
    return {a1: str.charAt(it), a2: it + 1};
}

function __tailRec(f,ini) {
  let obj = ini;
  while(true){
    switch(obj.h){
      case 0: return obj.a1;
      default: obj = f(obj);
    }
  }
}

const _idrisworld = Symbol('idrisworld')

const _crashExp = x=>{throw new IdrisError(x)}

const _bigIntOfString = s=> {
  try {
    const idx = s.indexOf('.')
    return idx === -1 ? BigInt(s) : BigInt(s.slice(0, idx))
  } catch (e) { return 0n }
}

const _numberOfString = s=> {
  try {
    const res = Number(s);
    return isNaN(res) ? 0 : res;
  } catch (e) { return 0 }
}

const _intOfString = s=> Math.trunc(_numberOfString(s))

const _truncToChar = x=> String.fromCodePoint(
  (x >= 0 && x <= 55295) || (x >= 57344 && x <= 1114111) ? x : 0
)

// Int8
const _truncInt8 = x => {
  const res = x & 0xff;
  return res >= 0x80 ? res - 0x100 : res;
}

const _truncBigInt8 = x => {
  const res = Number(x & 0xffn);
  return res >= 0x80 ? res - 0x100 : res;
}

const _add8s = (a,b) => _truncInt8(a + b)
const _sub8s = (a,b) => _truncInt8(a - b)
const _mul8s = (a,b) => _truncInt8(a * b)
const _div8s = (a,b) => _truncInt8(Math.trunc(a / b))
const _shl8s = (a,b) => _truncInt8(a << b)
const _shr8s = (a,b) => _truncInt8(a >> b)

// Int16
const _truncInt16 = x => {
  const res = x & 0xffff;
  return res >= 0x8000 ? res - 0x10000 : res;
}

const _truncBigInt16 = x => {
  const res = Number(x & 0xffffn);
  return res >= 0x8000 ? res - 0x10000 : res;
}

const _add16s = (a,b) => _truncInt16(a + b)
const _sub16s = (a,b) => _truncInt16(a - b)
const _mul16s = (a,b) => _truncInt16(a * b)
const _div16s = (a,b) => _truncInt16(Math.trunc(a / b))
const _shl16s = (a,b) => _truncInt16(a << b)
const _shr16s = (a,b) => _truncInt16(a >> b)

//Int32
const _truncInt32 = x => x & 0xffffffff

const _truncBigInt32 = x => {
  const res = Number(x & 0xffffffffn);
  return res >= 0x80000000 ? res - 0x100000000 : res;
}

const _add32s = (a,b) => _truncInt32(a + b)
const _sub32s = (a,b) => _truncInt32(a - b)
const _div32s = (a,b) => _truncInt32(Math.trunc(a / b))

const _mul32s = (a,b) => {
  const res = a * b;
  if (res <= Number.MIN_SAFE_INTEGER || res >= Number.MAX_SAFE_INTEGER) {
    return _truncInt32((a & 0xffff) * b + (b & 0xffff) * (a & 0xffff0000))
  } else {
    return _truncInt32(res)
  }
}

//Int64
const _truncBigInt64 = x => {
  const res = x & 0xffffffffffffffffn;
  return res >= 0x8000000000000000n ? res - 0x10000000000000000n : res;
}

const _add64s = (a,b) => _truncBigInt64(a + b)
const _sub64s = (a,b) => _truncBigInt64(a - b)
const _mul64s = (a,b) => _truncBigInt64(a * b)
const _div64s = (a,b) => _truncBigInt64(a / b)
const _shl64s = (a,b) => _truncBigInt64(a << b)
const _shr64s = (a,b) => _truncBigInt64(a >> b)

//Bits8
const _truncUInt8 = x => x & 0xff

const _truncUBigInt8 = x => Number(x & 0xffn)

const _add8u = (a,b) => (a + b) & 0xff
const _sub8u = (a,b) => (a - b) & 0xff
const _mul8u = (a,b) => (a * b) & 0xff
const _div8u = (a,b) => Math.trunc(a / b)
const _shl8u = (a,b) => (a << b) & 0xff
const _shr8u = (a,b) => (a >> b) & 0xff

//Bits16
const _truncUInt16 = x => x & 0xffff

const _truncUBigInt16 = x => Number(x & 0xffffn)

const _add16u = (a,b) => (a + b) & 0xffff
const _sub16u = (a,b) => (a - b) & 0xffff
const _mul16u = (a,b) => (a * b) & 0xffff
const _div16u = (a,b) => Math.trunc(a / b)
const _shl16u = (a,b) => (a << b) & 0xffff
const _shr16u = (a,b) => (a >> b) & 0xffff

//Bits32
const _truncUBigInt32 = x => Number(x & 0xffffffffn)

const _truncUInt32 = x => {
  const res = x & -1;
  return res < 0 ? res + 0x100000000 : res;
}

const _add32u = (a,b) => _truncUInt32(a + b)
const _sub32u = (a,b) => _truncUInt32(a - b)
const _mul32u = (a,b) => _truncUInt32(_mul32s(a,b))
const _div32u = (a,b) => Math.trunc(a / b)

const _shl32u = (a,b) => _truncUInt32(a << b)
const _shr32u = (a,b) => _truncUInt32(a <= 0x7fffffff ? a >> b : (b == 0 ? a : (a >> b) ^ ((-0x80000000) >> (b-1))))
const _and32u = (a,b) => _truncUInt32(a & b)
const _or32u = (a,b)  => _truncUInt32(a | b)
const _xor32u = (a,b) => _truncUInt32(a ^ b)

//Bits64
const _truncUBigInt64 = x => x & 0xffffffffffffffffn

const _add64u = (a,b) => (a + b) & 0xffffffffffffffffn
const _mul64u = (a,b) => (a * b) & 0xffffffffffffffffn
const _div64u = (a,b) => a / b
const _shl64u = (a,b) => (a << b) & 0xffffffffffffffffn
const _shr64u = (a,b) => (a >> b) & 0xffffffffffffffffn
const _sub64u = (a,b) => (a - b) & 0xffffffffffffffffn

//String
const _strReverse = x => x.split('').reverse().join('')

const _substr = (o,l,x) => x.slice(o, o + l)

const OnsToolbar_prim__addClass = ( self => self.classList.add('toolbar'));
const JsHelpers_prim__setter = ( setter);
const JsHelpers_prim__setState = ( setState);
const JsHelpers_prim__makeTemplate = ( makeTemplate);
const JsHelpers_prim__makeState = ( makeState);
const JsHelpers_prim__makePure = ( makePure);
const JsHelpers_prim__makePropEffect = ( makeProp);
const JsHelpers_prim__makeProp = ( makeProp);
const JsHelpers_prim__makeListener = ( makeListener);
const JsHelpers_prim__makeFirstConnected = ( makeFirstConnected);
const JsHelpers_prim__makeBind = ( makeBind);
const JsHelpers_prim__getter_string = ( getter);
const JsHelpers_prim__getter_bool = ( getter_bool);
const JsHelpers_prim__getState = ( getState);
const JsHelpers_prim__eventDispatcher = ( eventDispatcher);
const JsHelpers_prim__defineCustomElement = ( defineCustomElement);
const OnsTab_uncheck = ( self => self.shadowRoot.querySelector('input').checked = false);
const OnsTab_check = ( self => self.shadowRoot.querySelector('input').checked = true);
const OnsTabbar_prim__removeActive = ( (index, self) => self.shadowRoot.querySelector('slot[name=tabs]').assignedNodes()[index].active = false);
const OnsTabbar_prim__moveSwiper = ( (index, self) => { const swiper = self.shadowRoot.querySelector('.ons-swiper-target'); swiper.style.transform = `translate3d(${0 - index * swiper.offsetWidth}px, 0, 0)` });
const OnsTabbar_prim__getIndex = ( (tab, self) => self.shadowRoot.querySelector('slot[name=tabs]').assignedNodes().findIndex(t => t === tab));
const OnsTabbar_prim__firstTabListener = ( self => self.shadowRoot.querySelector('slot[name=tabs]').addEventListener('slotchange', e => e.target.assignedNodes()[0].active = true));
const OnsPage_prim__toolbarListener = ( self => { const toolbarSlot = self.shadowRoot.querySelector('slot[name=toolbar]'); toolbarSlot.addEventListener('slotchange', () => toolbarSlot.assignedNodes().length === 0 ? toolbarSlot.classList.remove('has-toolbar') : toolbarSlot.classList.add('has-toolbar')) });
const __mainExpression_0 = __lazy(function () {
 return PrimIO_unsafePerformIO(Main_main());
});

const csegen_1 = __lazy(function () {
 const $b = b => a => $c => $d => $e => {
  const $f = $c($e);
  const $12 = $d($e);
  return $f($12);
 };
 const $0 = {a1: b => a => func => $2 => $3 => Prelude_IO_map_Functor_IO(func, $2, $3), a2: a => $9 => $a => $9, a3: $b};
 const $17 = b => a => $18 => $19 => $1a => {
  const $1b = $18($1a);
  return $19($1b)($1a);
 };
 const $22 = a => $23 => $24 => {
  const $25 = $23($24);
  return $25($24);
 };
 return {a1: $0, a2: $17, a3: $22};
});

function prim__add_Integer($0, $1) {
 return ($0+$1);
}

function prim__sub_Integer($0, $1) {
 return ($0-$1);
}

function prim__mul_Integer($0, $1) {
 return ($0*$1);
}

const Main_main = __lazy(function () {
 return Prelude_Interfaces_x3ex3e(csegen_1(), $4 => CustomElement_customElement('ons-page', OnsPage_onsPage(), $4), () => Prelude_Interfaces_x3ex3e(csegen_1(), $f => CustomElement_customElement('ons-tabbar', OnsTabbar_onsTabbar(), $f), () => Prelude_Interfaces_x3ex3e(csegen_1(), $1a => CustomElement_customElement('ons-tab', OnsTab_onsTab(), $1a), () => $21 => CustomElement_customElement('ons-toolbar', OnsToolbar_onsToolbar(), $21))));
});

const OnsToolbar_onsToolbar = __lazy(function () {
 return {h: 9, a1: {h: 3, a1: Prelude_Types_String_x2bx2b('<style>\n  ', Prelude_Types_String_x2bx2b(OnsToolbar_css(), '\n</style>\n<div class=\"toolbar__left\">\n  <slot name=\"left\"></slot>\n</div>\n<div class=\"toolbar__center\">\n  <slot name=\"center\"></slot>\n  <slot></slot>\n</div>\n<div class=\"toolbar__right\">\n  <slot name=\"right\"></slot>\n</div>'))}, a2: {h: 7, a1: $b => $c => OnsToolbar_addClass($b, $c)}};
});

const OnsToolbar_css = __lazy(function () {
 return OnsGlobal_globalCss();
});

function OnsToolbar_addClass($0, $1) {
 return OnsToolbar_prim__addClass($0, $1);
}

const OnsGlobal_onsenuiCoreCss = __lazy(function () {
 return '@import \'onsenui.css\';';
});

const OnsGlobal_onsenCssComponents = __lazy(function () {
 return '@import \'onsen-css-components.css\';';
});

const OnsGlobal_globalCss = __lazy(function () {
 return Prelude_Types_String_x2bx2b(OnsGlobal_onsenuiCoreCss(), Prelude_Types_String_x2bx2b('\n', OnsGlobal_onsenCssComponents()));
});

function Builtin_believe_me($0) {
 return $0;
}

function Prelude_Types_prim__integerToNat($0) {
 let $1;
 switch(((0n<=$0)?1:0)) {
  case 0: {
   $1 = 0;
   break;
  }
  default: $1 = 1;
 }
 switch($1) {
  case 1: return Builtin_believe_me($0);
  case 0: return 0n;
 }
}

function Prelude_Types_String_x2bx2b($0, $1) {
 return ($0+$1);
}

function Prelude_EqOrd_x3dx3d_Eq_String($0, $1) {
 switch((($0===$1)?1:0)) {
  case 0: return 0;
  default: return 1;
 }
}

function Prelude_EqOrd_x3dx3d_Eq_Bool($0, $1) {
 switch($0) {
  case 1: {
   switch($1) {
    case 1: return 1;
    default: return 0;
   }
  }
  case 0: {
   switch($1) {
    case 0: return 1;
    default: return 0;
   }
  }
  default: return 0;
 }
}

function Prelude_EqOrd_x2fx3d_Eq_Bool($0, $1) {
 switch(Prelude_EqOrd_x3dx3d_Eq_Bool($0, $1)) {
  case 1: return 0;
  case 0: return 1;
 }
}

function Prelude_Interfaces_x3ex3e($0, $1, $2) {
 return $0.a2(undefined)(undefined)($1)($c => $2());
}

function PrimIO_unsafePerformIO($0) {
 return PrimIO_unsafeCreateWorld(w => PrimIO_unsafeDestroyWorld(undefined, $0(w)));
}

function PrimIO_unsafeDestroyWorld($0, $1) {
 return $1;
}

function PrimIO_unsafeCreateWorld($0) {
 return $0(_idrisworld);
}

function Prelude_IO_map_Functor_IO($0, $1, $2) {
 const $3 = $1($2);
 return $0($3);
}

function CustomElement_n__2518_462_buildClass($0, $1, $2, $3) {
 switch($2.h) {
  case 0: {
   const $5 = JsHelpers_makeProp($2.a2, $2.a3)($3);
   return {a1: {a1: $d => JsHelpers_getter($2.a2, $2.a3, $d), a2: $13 => $14 => JsHelpers_setter($2.a2, $2.a3, $13, $14)}, a2: $5};
  }
  case 1: {
   const $1b = JsHelpers_makePropEffect($2.a2, $2.a3, $2.a4)($3);
   return {a1: {a1: $24 => JsHelpers_getter($2.a2, $2.a3, $24), a2: $2a => $2b => JsHelpers_setter($2.a2, $2.a3, $2a, $2b)}, a2: $1b};
  }
  case 2: {
   const $32 = JsHelpers_makeListener($2.a1, $2.a2, $3);
   return {a1: 0, a2: $32};
  }
  case 3: {
   const $39 = JsHelpers_makeTemplate($2.a1, $3);
   return {a1: 0, a2: $39};
  }
  case 4: {
   const $3f = JsHelpers_makePure($3);
   return {a1: $43 => JsHelpers_eventDispatcher($2.a1, $43), a2: $3f};
  }
  case 5: {
   const $48 = JsHelpers_makeState($2.a2, $2.a3, $3);
   return {a1: {a1: $4f => JsHelpers_getState($2.a2, $4f), a2: $54 => $55 => JsHelpers_setState($2.a2, $54, $55)}, a2: $48};
  }
  case 6: {
   const $5b = CustomElement_n__2518_462_buildClass($0, $1, $2.a1, $3);
   const $62 = JsHelpers_makePure($3);
   return {a1: $5b.a1, a2: $62};
  }
  case 7: {
   const $67 = JsHelpers_makeFirstConnected($2.a1, $3);
   return {a1: 0, a2: $67};
  }
  case 8: {
   const $6d = CustomElement_n__2518_462_buildClass($0, $1, $2.a1, $3);
   const $74 = CustomElement_n__2518_462_buildClass($0, $1, $2.a2($6d.a1), $3);
   const $7d = JsHelpers_makeBind($6d.a2, $74.a2, $3);
   return {a1: $74.a1, a2: $7d};
  }
  case 9: {
   const $84 = CustomElement_n__2518_462_buildClass($0, $1, $2.a1, $3);
   const $8b = CustomElement_n__2518_462_buildClass($0, $1, $2.a2, $3);
   const $92 = JsHelpers_makeBind($84.a2, $8b.a2, $3);
   return {a1: $8b.a1, a2: $92};
  }
  case 10: {
   const $99 = JsHelpers_makePure($3);
   return {a1: $2.a1, a2: $99};
  }
 }
}

function CustomElement_customElement($0, $1, $2) {
 const $3 = CustomElement_n__2518_462_buildClass($1, $0, $1, $2);
 return JsHelpers_defineCustomElement($0, $3.a2, $2);
}

function JsHelpers_with__stringAttrx2csurjProof_670($0, $1) {
 switch($1.h) {
  case 0: return 0;
  case 1: return 0;
 }
}

function JsHelpers_n__2657_594_toAttrx27($0, $1, $2) {
 switch($2.h) {
  case 0: return {h: 0};
  case 1: return {a1: $1};
 }
}

function JsHelpers_n__2756_692_toAttr($0) {
 switch($0) {
  case 0: return {h: 0};
  case 1: return {a1: ''};
 }
}

function JsHelpers_n__2656_590_toAttr($0) {
 return JsHelpers_n__2657_594_toAttrx27($0, $0, Decidable_Equality_decEq_DecEq_String($0, 'default'));
}

function JsHelpers_n__2756_694_surjProof($0) {
 switch($0) {
  case 0: return 0;
  case 1: return 0;
 }
}

function JsHelpers_n__2656_592_surjProof($0) {
 return JsHelpers_with__stringAttrx2csurjProof_670($0, Decidable_Equality_decEq_DecEq_String($0, 'default'));
}

function JsHelpers_n__2658_618_fromAttrx27($0) {
 switch($0.h) {
  case 0: return {a1: 'default', a2: {h: 0, a1: 0}};
  case undefined: return {a1: $0.a1, a2: Decidable_Equality_decEq_DecEq_String($0.a1, 'default')};
 }
}

function JsHelpers_n__2756_693_fromAttr($0) {
 switch($0.h) {
  case 0: return 0;
  case undefined: return 1;
 }
}

function JsHelpers_n__2656_591_fromAttr($0) {
 const $1 = JsHelpers_n__2658_618_fromAttrx27($0);
 return $1.a1;
}

function JsHelpers_typeString($0) {
 switch($0) {
  case 0: return 'string';
  case 1: return 'bool';
 }
}

const JsHelpers_stringAttr = __lazy(function () {
 return {a1: $1 => JsHelpers_n__2656_590_toAttr($1), a2: $5 => JsHelpers_n__2656_591_fromAttr($5), a3: $9 => JsHelpers_n__2656_592_surjProof($9)};
});

function JsHelpers_setter($0, $1, $2, $3) {
 return JsHelpers_prim__setter(undefined, $1, $2, $3);
}

function JsHelpers_setState($0, $1, $2) {
 return JsHelpers_prim__setState(undefined, $0, $1, $2);
}

function JsHelpers_makeTemplate($0, $1) {
 return JsHelpers_prim__makeTemplate($0, $1);
}

function JsHelpers_makeState($0, $1, $2) {
 return JsHelpers_prim__makeState(undefined, $0, $1, $2);
}

function JsHelpers_makePure($0) {
 return JsHelpers_prim__makePure($0);
}

function JsHelpers_makePropEffect($0, $1, $2) {
 const $3 = JsHelpers_getAttr($0);
 const $6 = self => last => current => $2(self)(last)(current);
 return $d => JsHelpers_prim__makePropEffect(undefined, $1, JsHelpers_typeString($0), $3.a1, $3.a2, $6, $d);
}

function JsHelpers_makeProp($0, $1) {
 const $2 = JsHelpers_getAttr($0);
 return $5 => JsHelpers_prim__makeProp(undefined, $1, JsHelpers_typeString($0), $2.a1, $2.a2, $5);
}

function JsHelpers_makeListener($0, $1, $2) {
 return JsHelpers_prim__makeListener($0, self => target => $1(self)(target), $2);
}

function JsHelpers_makeFirstConnected($0, $1) {
 return JsHelpers_prim__makeFirstConnected(self => $0(self), $1);
}

function JsHelpers_makeBind($0, $1, $2) {
 return JsHelpers_prim__makeBind($0, $1, $2);
}

function JsHelpers_getter($0, $1, $2) {
 switch($0) {
  case 0: return JsHelpers_prim__getter_string($1, $2);
  case 1: return JsHelpers_prim__getter_bool($1, $2);
 }
}

function JsHelpers_getState($0, $1) {
 return JsHelpers_prim__getState(undefined, $0, $1);
}

function JsHelpers_getAttr($0) {
 switch($0) {
  case 0: return JsHelpers_stringAttr();
  case 1: return JsHelpers_boolAttr();
 }
}

function JsHelpers_eventDispatcher($0, $1) {
 return JsHelpers_prim__eventDispatcher($0, $1);
}

function JsHelpers_defineCustomElement($0, $1, $2) {
 return JsHelpers_prim__defineCustomElement($0, $1, $2);
}

const JsHelpers_boolAttr = __lazy(function () {
 return {a1: $1 => JsHelpers_n__2756_692_toAttr($1), a2: $5 => JsHelpers_n__2756_693_fromAttr($5), a3: $9 => JsHelpers_n__2756_694_surjProof($9)};
});

function Decidable_Equality_n__4471_1648_primitiveNotEq($0, $1, $2) {
 return Builtin_believe_me(0);
}

function Decidable_Equality_n__4471_1647_primitiveEq($0, $1) {
 return Builtin_believe_me(0);
}

function Decidable_Equality_decEq_DecEq_String($0, $1) {
 switch(Prelude_EqOrd_x3dx3d_Eq_String($0, $1)) {
  case 1: return {h: 0, a1: Decidable_Equality_n__4471_1647_primitiveEq($1, $0)};
  case 0: return {h: 1, a1: $b => Decidable_Equality_n__4471_1648_primitiveNotEq($1, $0, $b)};
 }
}

function OnsTab_toggleCheck($0, $1, $2) {
 switch($0) {
  case 0: return OnsTab_uncheck($1, $2);
  case 1: return OnsTab_check($1, $2);
 }
}

const OnsTab_onsTab = __lazy(function () {
 const $c = triggerActive => {
  const $d = self => last => current => {
   switch(Prelude_EqOrd_x2fx3d_Eq_Bool(last, current)) {
    case 1: {
     return Prelude_Interfaces_x3ex3e(csegen_1(), $16 => OnsTab_toggleCheck(current, self, $16), () => $1c => {
      const $1d = triggerActive($1c);
      const $20 = self;
      return $1d($20);
     });
    }
    case 0: return $23 => 0;
   }
  };
  const $29 = $2a => {
   const $2e = self => $2f => $30 => {
    const $31 = $2a.a2(1)($30);
    const $36 = self;
    return $31($36);
   };
   const $2c = {h: 2, a1: 'click', a2: $2e};
   return {h: 9, a1: $2c, a2: {h: 10, a1: 0}};
  };
  return {h: 8, a1: {h: 1, a1: {h: 'Prelude.Basics.Bool'}, a2: 1, a3: 'active', a4: $d}, a2: $29};
 };
 const $9 = {h: 8, a1: {h: 4, a1: 'active'}, a2: $c};
 return {h: 9, a1: {h: 3, a1: Prelude_Types_String_x2bx2b('<style>\n  ', Prelude_Types_String_x2bx2b(OnsTab_css(), '\n</style>\n  <input type=\"radio\" style=\"display:none\">\n  <button class=\"tabbar__button\">\n    <div class=\"tabbar__label\">\n      <slot></slot>\n    </div>\n  </button>'))}, a2: $9};
});

const OnsTab_css = __lazy(function () {
 return OnsGlobal_globalCss();
});

function OnsTabbar_removeActive($0, $1, $2) {
 return OnsTabbar_prim__removeActive($0, $1, $2);
}

const OnsTabbar_onsTabbar = __lazy(function () {
 const $f = $10 => {
  const $1c = self => target => $1d => {
   const $1f = $10.a1($1d);
   const $22 = self;
   const $1e = $1f($22);
   const $29 = $2a => {
    switch($1e.h) {
     case 0: return 0;
     case undefined: return OnsTabbar_removeActive($1e.a1, self, $2a);
    }
   };
   const $25 = Prelude_Interfaces_x3ex3e(csegen_1(), $29, () => $31 => {
    const $32 = OnsTabbar_getIndex(target, self, $31);
    const $3b = $3c => {
     const $3d = $10.a2({a1: $32})($3c);
     const $43 = self;
     return $3d($43);
    };
    const $37 = Prelude_Interfaces_x3ex3e(csegen_1(), $3b, () => $47 => OnsTabbar_moveSwiper($32, self, $47));
    return $37($31);
   });
   return $25($1d);
  };
  const $1a = {h: 2, a1: 'active', a2: $1c};
  const $19 = {h: 9, a1: $1a, a2: {h: 10, a1: 0}};
  return {h: 9, a1: {h: 7, a1: $14 => $15 => OnsTabbar_firstTabListener($14, $15)}, a2: $19};
 };
 const $9 = {h: 8, a1: {h: 5, a1: {h: 'Prelude.Types.Maybe', a1: {h: 'Int'}}, a2: 'activeIndex', a3: {h: 0}}, a2: $f};
 return {h: 9, a1: {h: 3, a1: Prelude_Types_String_x2bx2b('<style>\n  ', Prelude_Types_String_x2bx2b(OnsTabbar_css(), '\n</style>\n<div class=\"tabbar__content ons-swiper\">\n  <slot name=\"pages\" class=\"ons-swiper-target active\" style=\"transition: all 0.3s cubic-bezier(0.4, 0.7, 0.5, 1) 0s\">\n  </slot>\n  <div class=\"ons-swiper-blocker\"></div>\n</div>\n<div class=\"tabbar\">\n  <slot name=\"tabs\"></slot>\n</div>'))}, a2: $9};
});

function OnsTabbar_moveSwiper($0, $1, $2) {
 return OnsTabbar_prim__moveSwiper($0, $1, $2);
}

function OnsTabbar_getIndex($0, $1, $2) {
 return OnsTabbar_prim__getIndex($0, $1, $2);
}

function OnsTabbar_firstTabListener($0, $1) {
 return OnsTabbar_prim__firstTabListener($0, $1);
}

const OnsTabbar_css = __lazy(function () {
 return Prelude_Types_String_x2bx2b(OnsGlobal_globalCss(), '\n::slotted([slot=pages]) {\n  height: inherit;\n  -webkit-flex-shrink: 0;\n          flex-shrink: 0;\n  box-sizing: border-box;\n  width: 100%;\n  position: relative !important;\n}');
});

function OnsPage_toolbarListener($0, $1) {
 return OnsPage_prim__toolbarListener($0, $1);
}

const OnsPage_onsPage = __lazy(function () {
 return {h: 9, a1: {h: 3, a1: Prelude_Types_String_x2bx2b('<style>\n  ', Prelude_Types_String_x2bx2b(OnsPage_css(), '\n</style>\n<div class=\"page\" style=\"width: 100%\" shown>\n  <slot name=\"toolbar\"></slot>\n  <div class=\"page__background\"></div>\n  <div class=\"page__content\">\n    <slot></slot>\n  </div>\n</ons-page>'))}, a2: {h: 9, a1: {h: 7, a1: $c => $d => OnsPage_toolbarListener($c, $d)}, a2: {h: 10, a1: 0}}};
});

const OnsPage_css = __lazy(function () {
 return Prelude_Types_String_x2bx2b(OnsGlobal_globalCss(), '\n.has-toolbar + .page__background + .page__content {\n  top: 44px;\n  top: var(--toolbar-height);\n  padding-top: 0;\n}');
});


try{__mainExpression_0()}catch(e){if(e instanceof IdrisError){console.log('ERROR: ' + e.message)}else{throw e} }
