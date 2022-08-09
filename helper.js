const defineCustomElement = klass => {
  customElements.define('eric-element', klass);
}

const makeVanilla = () => {
  return class extends HTMLElement {
  };
}
