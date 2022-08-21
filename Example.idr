module Main

import CustomElement

import Example.OnsPage
import Example.OnsTabbar
import Example.OnsTab
import Example.OnsToolbar

%default total

main : IO ()
main = do customElement "ons-page" onsPage
          customElement "ons-tabbar" onsTabbar
          customElement "ons-tab" onsTab
          customElement "ons-toolbar" onsToolbar
