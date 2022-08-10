////////////////////////////////////////////////////////////////////////////////
// MAKER FUNCTIONS
// ---------------
// Functions take an object describing a custom element and return the object
// plus some extra description. They are used to equip a custom element with
// some extra functionality, such as a property or a listener.
////////////////////////////////////////////////////////////////////////////////

const makerProp = name => obj => ({...obj, props: [...(obj.props || []), name]});


////////////////////////////////////////////////////////////////////////////////
// DEFINE FUNCTION
// ---------------
// Function that takes an object describing a custom element and creates a
// custom element.
////////////////////////////////////////////////////////////////////////////////

const defineCustomElement = maker => {
  const description = maker({});

  console.log(description);

  const ce = class extends HTMLElement {};

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

  customElements.define('eric-element', ce);
};


////////////////////////////////////////////////////////////////////////////////
// MISC.
////////////////////////////////////////////////////////////////////////////////
