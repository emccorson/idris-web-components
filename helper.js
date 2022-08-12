////////////////////////////////////////////////////////////////////////////////
// MAKE FUNCTIONS
// --------------
// Functions take an object describing a custom element and return the object
// plus some extra description. They are used to equip a custom element with
// some extra functionality, such as a property or a listener.
////////////////////////////////////////////////////////////////////////////////

const makeProp = (name, type) => obj => ({...obj, props: [...(obj.props || []), {name, type}]});

const makePropEffect = (name, callback, type) => obj => (
  {...obj, props: [...(obj.props || []), {name, type, callback}]}
);

const makeListener = (event, callback) => obj => (
  {...obj, listeners: [...(obj.listeners || []), {event, callback}]}
);

const makeTemplate = template => obj => ({...obj, template});

const makeBind = (f, g) => obj => g(f(obj));

////////////////////////////////////////////////////////////////////////////////
// DEFINE FUNCTION
// ---------------
// Function that takes an object describing a custom element and creates a
// custom element.
////////////////////////////////////////////////////////////////////////////////

const stringGetterSetter = name => ({
  get() {
    return this.getAttribute(name);
  },
  set(value) {
    if (value === null || value === undefined) {
      this.removeAttribute(name);
    } else {
      this.setAttribute(name, value);
    }
  }
});

const boolGetterSetter = name => ({
  get() {
    return this.hasAttribute(name);
  },
  set(value) {
    if (value) {
      this.setAttribute(name, '');
    } else {
      this.removeAttribute(name);
    }
  }
});

const defineCustomElement = (tagName, make) => {
  const description = make({});

  console.log(description);

  const {event, callback} = description.listeners[0];

  let template;
  if (description.template) {
    template = document.createElement('template');
    template.innerHTML = description.template;
  }

  const ce = class extends HTMLElement {
    constructor() {
      super();
      this.handler = callback(this);

      if (template) {
        this.attachShadow({mode: 'open'});
        this.shadowRoot.appendChild(template.content.cloneNode(true));
      }
    }

    connectedCallback() {
      this.addEventListener(event, this.handler);
    }

    disconnectedCallback() {
      this.removeEventListener(event, this.handler);
    }

    attributeChangedCallback(name, last, current) {
      description.props.find(p => p.name === name)?.callback?.(this)(last)(current)();
    };

    static get observedAttributes() {
      return (description.props || [])
        .filter(p => p.callback)
        .map(p => p.name);
    }
  };

  description.props?.forEach(({name, type}) => {

    let getterSetter;
    switch (type) {
      case 'string':
        getterSetter = stringGetterSetter;
        break;
      case 'bool':
        getterSetter = boolGetterSetter;
        break;
    }

    Object.defineProperty(ce.prototype, name, getterSetter(name));
  });

  customElements.define(tagName, ce);
};


////////////////////////////////////////////////////////////////////////////////
// MISC.
////////////////////////////////////////////////////////////////////////////////

const setter = (prop, value) => self => self[prop] = value;

const getter = prop => self => self[prop];

// this returns an int that corresponds to the Idris constructors False and True
// see https://github.com/idris-lang/Idris2/issues/2620
const getter_bool = prop => self => self[prop] ? 1 : 0;


//const switchClass = prop => (self, last, current) => {
const switchClass = prop => self => last => current => {
  self.classList.remove(`${prop}--${last}`);
  self.classList.add(`${prop}--${current}`);
};
