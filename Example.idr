module Main

import CustomElement

import OnsTab
import OnsTabbar

main : IO ()
main = do customElement "ons-tab" onsTab
          customElement "ons-tabbar" onsTabbar
