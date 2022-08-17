////////////////////////////////////////////////////////////////////////////////
// MAKE FUNCTIONS
// --------------
// Functions take an object describing a custom element and return the object
// plus some extra description. They are used to equip a custom element with
// some extra functionality, such as a property or a listener.
////////////////////////////////////////////////////////////////////////////////

// the first argument is _ because it's an implicit from Idris that we can ignore
const makeProp = (_, name, type, toAttr, fromAttr, callback = undefined) => obj => {
  let to, from, cb;
  switch (type) {
    case 'string':
      to = str => fromIdrisMaybe(toAttr(str));
      from = attr => fromAttr(toIdrisMaybe(attr));
      cb = typeof callback === "function" ?
        (self, last, current) => callback(self)(last)(current)() :
        null;
      break;
    case 'bool':
      to = bool => fromIdrisMaybe(toAttr(toIdrisBool(bool)));
      from = attr => fromIdrisBool(fromAttr(toIdrisMaybe(attr)));
      cb = typeof callback === "function" ?
        (self, last, current) => callback(self)(toIdrisBool(last))(toIdrisBool(current))() :
        null;
      break;
  }

  return {...obj, props: [...(obj.props || []), {name, type, callback: cb, toAttr: to, fromAttr: from}]};
};

const makeListener = (event, callback) => obj => (
  {...obj, listeners: [...(obj.listeners || []), {event, callback}]}
);

const makeTemplate = template => obj => ({...obj, template});

const makeState = (_, key, initialValue) => obj => ({...obj, state: {...(obj.state || {}), [key]: initialValue}});

const makeBind = (f, g) => obj => g(f(obj));

const makePure = () => obj => obj;

////////////////////////////////////////////////////////////////////////////////
// DEFINE FUNCTION
// ---------------
// Function that takes an object describing a custom element and creates a
// custom element.
////////////////////////////////////////////////////////////////////////////////

const defineCustomElement = (tagName, make) => {
  const description = make({});

  console.log(description);
  window.d = description;

  let template;
  if (description.template) {
    template = document.createElement('template');
    template.innerHTML = description.template;
  }

  const ce = class extends HTMLElement {
    constructor() {
      super();

      this.listeners = (description.listeners || [])
        .map(({event, callback}) => ({event, handler: ({target}) => callback(this)(target)()}));

      if (template) {
        this.attachShadow({mode: 'open'});
        this.shadowRoot.appendChild(template.content.cloneNode(true));
      }

      this._state = {...(d.state || {})};
    }

    connectedCallback() {
      this.listeners.forEach(({event, handler}) =>
        this.addEventListener(event, handler));
    }

    disconnectedCallback() {
      this.listeners.forEach(({event, handler}) =>
        this.removeEventListener(event, handler));
    }

    attributeChangedCallback(name, last, current) {
      const p = description.props.find(p => p.name === name);
      if (p && p.callback) {
        p.callback(this, p.fromAttr(last), p.fromAttr(current));
      }
    };

    static get observedAttributes() {
      return (description.props || [])
        .filter(p => p.callback)
        .map(p => p.name);
    }
  };

  description.props?.forEach(({name, type, toAttr, fromAttr}) => {
    Object.defineProperty(ce.prototype, name, {
      get() {
        const attr = this.hasAttribute(name) ? this.getAttribute(name) : null;
        return fromAttr(attr);
      },
      set(value) {
        const attr = toAttr(value);
        if (attr === null) {
          this.removeAttribute(name);
        } else {
          this.setAttribute(name, attr);
        }
      }
    });
  });

  customElements.define(tagName, ce);
};


////////////////////////////////////////////////////////////////////////////////
// IDRIS/JS CONVERSION FUNCTIONS
////////////////////////////////////////////////////////////////////////////////

const toIdrisMaybe = x => x === null ? {h: 0} : {a1: x};

const fromIdrisMaybe = ({h, a1}) => h === 0 ? null : a1;

const toIdrisBool = x => x ? 1 : 0;

const fromIdrisBool = x => x === 0 ? false : true;


////////////////////////////////////////////////////////////////////////////////
// MISC.
////////////////////////////////////////////////////////////////////////////////

const setter = (_, prop, value) => self => self[prop] = value;

const getter = prop => self => self[prop];

// this returns an int that corresponds to the Idris constructors False and True
// see https://github.com/idris-lang/Idris2/issues/2620
const getter_bool = prop => self => toIdrisBool(self[prop]);

const eventDispatcher = name => self => self.dispatchEvent(new CustomEvent(name, { bubbles: true }));

const getState = (_, key) => self => self._state[key];

const setState = (_, key, value) => self => self._state[key] = value;
