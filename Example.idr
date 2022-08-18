module Main

import CustomElement

import OnsPage
import OnsTabbar
import OnsTab

main : IO ()
main = do customElement "ons-page" onsPage
          customElement "ons-tabbar" onsTabbar
          customElement "ons-tab" onsTab
