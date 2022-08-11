////////////////////////////////////////////////////////////////////////////////
// MAKE FUNCTIONS
// --------------
// Functions take an object describing a custom element and return the object
// plus some extra description. They are used to equip a custom element with
// some extra functionality, such as a property or a listener.
////////////////////////////////////////////////////////////////////////////////

const makeProp = name => obj => ({...obj, props: [...(obj.props || []), name]});

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
  };

  description.props?.forEach(name => {
    Object.defineProperty(ce.prototype, name, {
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
  });

  customElements.define(tagName, ce);
};


////////////////////////////////////////////////////////////////////////////////
// MISC.
////////////////////////////////////////////////////////////////////////////////

// note that setter has to return a traditional function
// this is because idris uses arrow functions so we can't bind this
// this also means we have to use callback().bind(this) instead of callback.bind(this)
const setter = (prop, value) => function (self) { self[prop] = value; };

const getter = prop => function (self) { return self[prop]; };
