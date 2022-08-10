const defineCustomElement = klass => {
  customElements.define('eric-element', klass);
};

const makeVanilla = () => {
  return class extends HTMLElement {
  };
};

const makeProp = name => {
  const klass = class extends HTMLElement {};

  Object.defineProperty(klass.prototype, name, {
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

  return klass;
};

const makeEffect = (event, callback) => {
  return class extends HTMLElement {
    constructor() {
      super();
      this.handler = callback.bind(this);
    }

    connectedCallback() {
      this.addEventListener(event, this.handler);
    }

    disconnectedCallback() {
      this.removeEventListener(event, this.handler);
    }
  };
};

const makePropEffect = (name, callback) => {
  const klass = class extends HTMLElement {

    attributeChangedCallback() {
      callback.call(this);
    }

    static get observedAttributes() {
      return [name];
    }
  }

  Object.defineProperty(klass.prototype, name, {
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

  return klass;
};

const addClass = name => function addClass() { this.classList.add(name); };
