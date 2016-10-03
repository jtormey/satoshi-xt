
module Helpers exposing (..)

import Json.Decode as Json exposing (object2, float, int, (:=))
import Http
import Task exposing (..)
import Types exposing (..)

fromSatoshi : Float -> Float
fromSatoshi = flip (/) 100000000

append : String -> String -> String
append = flip (++)

showBalance : Float -> String
showBalance = (append " BTC") << toString << fromSatoshi

makeQr : String -> String
makeQr = (++) "https://blockchain.info/qr?data="

multiAddr : String -> String
multiAddr = (++) "https://blockchain.info/multiaddr?cors=true&active="

xpubDecoder : Json.Decoder XpubInfo
xpubDecoder =
  object2 XpubInfo
    ("final_balance" := float)
    ("account_index" := int)

getInfo : String -> Cmd Msg
getInfo xpub =
  let
    url = multiAddr xpub
    decodeUrl = Json.at [ "addresses", "0" ] xpubDecoder
  in
    Task.perform Failed Info (Http.get decodeUrl url)
