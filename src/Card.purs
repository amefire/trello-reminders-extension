module Main where -- Card where


import Data.Maybe
import Prelude

import Control.Monad.Maybe.Trans (runMaybeT, MaybeT(..))
import Control.Monad.Trans.Class (lift)
import Control.MonadZero (guard)
import Data.Array (head)
import Effect (Effect)
import Effect.Timer (setInterval, setTimeout)
import Helpers.Card (getCardIdFromUrl, getFirstElementByClassName, nextSibling, alert, getElementById, showDialog, documentHead, setOnLoad,
                     jqry, dialog, JQuery, JQueryDialog, showModal, show) as Helpers
import Partial.Unsafe (unsafePartial)
import React as React
import React.DOM (text, a, div, div', h5, span, span', img, form', fieldset', label', dialog, button', button, select', option') as DOM
import React.DOM.Props as Props
import ReactDOM as ReactDOM
import Unsafe.Coerce (unsafeCoerce)
import Web.DOM.Document (Document, getElementsByClassName, createElement, url) as DOM
import Web.DOM.Element (setAttribute, toNode, Element) as DOM
import Web.DOM.HTMLCollection (item, length)
import Web.DOM.HTMLCollection (toArray)
import Web.DOM.Node (firstChild, insertBefore, appendChild) as DOM
import Web.HTML (window) as DOM
import Web.HTML.HTMLDocument (toDocument, body) as DOM
import Web.HTML.Window (document) as DOM
import Data.DateTime

main :: Effect Unit
main = do
 void $ setInterval 300 $ void $ do
   tryDisplay

tryDisplay :: Effect Boolean
tryDisplay = do
  window <- DOM.window
  document <- DOM.document window
  url <- DOM.url $ DOM.toDocument document
  result <- runMaybeT $ tryDisplayBtn url (DOM.toDocument document)
  case result of
    Nothing -> pure false
    Just _ -> pure true
  where
    doesElementExist :: Maybe DOM.Element -> Maybe Boolean
    doesElementExist Nothing  = Just true
    doesElementExist (Just _) = Nothing
    
    tryDisplayBtn :: String -> DOM.Document -> MaybeT Effect Unit
    tryDisplayBtn url document = do

      -- Do NOT display button if it's already been displayed
      _ <- MaybeT $ doesElementExist <$> (Helpers.getElementById "trello-reminders-btn" document)

      -- Do NOT display button if we are not in the context of a Card (we check this by verifying the URL)
      _ <- MaybeT $ pure $ Helpers.getCardIdFromUrl url
      
      otherActions <- MaybeT $ Helpers.getFirstElementByClassName "other-actions" document
      
      trelloRemindersBtnDivElt <- lift $ DOM.createElement "a" document
      _ <- lift $ DOM.setAttribute "id" "trello-reminders-btn" trelloRemindersBtnDivElt
      _ <- lift $ DOM.setAttribute "class" "button-link" trelloRemindersBtnDivElt
      _ <- lift $ DOM.setAttribute "title" "Click to set a reminder on this card" trelloRemindersBtnDivElt

      -- Get the first child of other-actions/actionPane => <h3>Actions</h3>
      -- Get the next sibling of <h3>Actions</h3>
      -- In the next sibling of <h3>Actions</h3>:
      --   * Get the first child
      --   * Add a new child before the first child
      firstChildOfOtherActions <- MaybeT $ DOM.firstChild (unsafeCoerce otherActions)
      secondChildOfOtherActions <- MaybeT $ Helpers.nextSibling (unsafeCoerce firstChildOfOtherActions)

      -- Add a new child before the first child of secondChildofotheractions
      pointOfInsertion <- MaybeT $ DOM.firstChild secondChildOfOtherActions
      _ <- lift $ DOM.insertBefore (unsafeCoerce trelloRemindersBtnDivElt) pointOfInsertion secondChildOfOtherActions
      _ <- lift $ ReactDOM.render (React.createLeafElement setReminderClass { }) trelloRemindersBtnDivElt
      pure unit


modalClass :: React.ReactClass {}
modalClass = React.component "Modal" component
  where
    component this =
      pure {
             state: {},
             render: render $ React.getState this
           }
      where
        render state = do
          pure $
            DOM.div
              [ Props.className "modal fade", Props._id "setreminderModal", Props.role "dialog", Props.unsafeMkProps "aria-labelledby" "setReminderCenterTitle", Props.unsafeMkProps "aria-hidden" "true" ]
              [
                DOM.div
                  [ Props.className "modal-dialog modal-dialog-centered", Props.role "document" ]
                  [
                    DOM.div
                      [ Props.className "modal-content" ]
                      [
                        DOM.div
                          [ Props.className "modal-header" ]
                          [
                            DOM.h5
                              [ Props.className "modal-title", Props._id "setReminderModalLongTitle" ]
                              [
                                DOM.text "Modal title"
                              ],
                            DOM.button
                              [ Props._type "button", Props.className "close", Props.unsafeMkProps "data-dismiss" "modal", Props.unsafeMkProps "aria-label" "Close" ]
                              [
                                DOM.span
                                  [ Props.unsafeMkProps "aria-hidden" "true" ]
                                  [
                                    DOM.text "x"
                                  ]
                              ]
                          ],
                        
                        DOM.div
                          [ Props.className "modal-body" ]
                          [
                            DOM.text "..."
                          ],

                        DOM.div
                          [ Props.className "modal-footer" ]
                          [
                            DOM.button
                              [ Props._type "button", Props.className "btn btn-secondary", Props.unsafeMkProps "data-dismiss" "modal" ]
                              [
                                DOM.text "Close"
                              ],
                            
                            DOM.button
                              [ Props._type "button", Props.className "btn btn-primary", Props.unsafeMkProps "data-dismiss" "modal" ]
                              [
                                DOM.text "Save changes"
                              ]
                          ]
                      ]
                  ]
              ]

setReminderClass :: React.ReactClass { }
setReminderClass = React.component "Main" component
  where
  component this =
    pure {
            render: render
         }

    where
      render = do
        pure $
          DOM.div'
          [
            DOM.span
            [
              Props.unsafeMkProps "data-toggle" "modal",
              Props.unsafeMkProps "data-target" "#setreminderModal"
            ]
            [ DOM.text "Set reminder" ],
            
            React.createLeafElement modalClass { }
          ]
          
