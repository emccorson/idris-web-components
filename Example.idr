module Main

import CustomElement

import OnsPage
import OnsTabbar
import OnsTab
import OnsToolbar

main : IO ()
main = do customElement "ons-page" onsPage
          customElement "ons-tabbar" onsTabbar
          customElement "ons-tab" onsTab
          customElement "ons-toolbar" onsToolbar
