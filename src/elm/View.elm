module View exposing (rootView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Types exposing (..)
import Helpers exposing (isXpub, showBalance, makeQr)
import Dict

-- components

extHeader : List (Html Msg) -> Html Msg
extHeader actions = div [ class "header" ]
  [ span [ class "header-brand" ] [ text "BTC EXT" ]
  , div [ class "header-actions" ] actions
  ]

balance : Float -> Html Msg
balance satoshi =
  let
    bal = if satoshi == 0 then "No Balance" else showBalance satoshi
  in
    div [ class "maintext" ] [ text bal ]

qrCode : Int -> String -> Html Msg
qrCode qrSize address =
  img [ src (makeQr address), width qrSize, height qrSize ] []

stdButton : Msg -> Bool -> String -> Html Msg
stdButton action isDisabled str =
  button [ class "std-button", onClick action, disabled isDisabled ] [ text str ]

stdLink : Msg -> String -> Html Msg
stdLink action str =
  span [ class "std-link", onClick action ] [ text str ]

inputLabelForm : String -> String -> Html Msg
inputLabelForm xpub label = div [ class "flex-center" ]
  [ input [ class "text-input", value label, onInput (SetField << LabelField) ] []
  , stdButton (SubmitLabel xpub label) (label == "") "Save Label"
  ]

-- views

askForXpubView : String -> Html Msg
askForXpubView xpub =
  div [ class "login-view" ]
    [ div [ class "maintext mbl" ] [ text "Enter an xpub to get started" ]
    , div [ class "w100 flex-center" ]
      [ input [ class "text-input", value xpub, onInput (SetField << XpubField) ] []
      , stdButton SubmitXpub (not <| isXpub xpub) "Continue"
      ]
    ]

statusView : String -> Html Msg
statusView status = div [ class "maintext" ] [ text status ]

homeView : Model -> AccountInfo -> Html Msg
homeView model account =
  let
    address = Maybe.withDefault "" <| Dict.get model.index model.derivations
    bal = balance model.balance
    qr = qrCode 150 address
    addr = div [ class "subtext" ] [ text address ]
    derive = inputLabelForm account.xpub model.labelField
  in
    div [ class "home-view" ]
      [ qr
      , div [ class "home-info" ]
        [ div [ ] [ bal, addr ]
        , derive
        ]
      ]

labelsView : Model -> AccountInfo -> Html Msg
labelsView model account =
  let
    getText index =
      Dict.get index model.derivations
      |> Maybe.withDefault (toString index)
    getAttrs index = if Dict.member index model.derivations
      then [ ]
      else [ class "link", onClick (Derive account.xpub index) ]
    makeLabel entry = div [ class "label-entry" ]
      [ div [] [ text entry.label ]
      , a (getAttrs entry.index) [ text (getText entry.index) ]
      ]
  in
    if List.isEmpty account.labels
      then statusView "No Labels"
      else div [ class "label-view" ] (List.map makeLabel account.labels)

rootView : Model -> Html Msg
rootView model =
  let
    view =
      case model.account of
        Just account ->
          case model.view of
            Loading -> statusView "Loading..."
            LoadFailed err -> statusView err
            HomeView -> homeView model account
            LabelsView -> labelsView model account
        Nothing ->
          askForXpubView model.xpubField
    headerActions =
      if model.account /= Nothing && (model.view == HomeView || model.view == LabelsView)
        then
          [ stdLink (Show HomeView) "Home"
          , stdLink (Show LabelsView) "Labels"
          , stdLink Logout "Logout"
          ]
        else
          []
  in div [ class "container" ]
    [ extHeader headerActions
    , div [ class "body" ] [ view ]
    ]
