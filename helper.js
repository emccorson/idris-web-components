const defineCustomElement = () => {
  class Eric extends HTMLElement {
  }

  customElements.define('eric-element', Eric);
}
