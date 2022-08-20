module Example.OnsGlobal

onsenuiCoreCss : String
onsenuiCoreCss =
  """
  @import 'onsenui.css';
  """

onsenCssComponents : String
onsenCssComponents =
  """
  @import 'onsen-css-components.css';
  """

export
globalCss : String
globalCss =
  """
  \{onsenuiCoreCss}
  \{onsenCssComponents}
  """
