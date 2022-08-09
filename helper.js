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
