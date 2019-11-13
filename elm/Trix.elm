module Trix exposing (editor)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode


editor : String -> (String -> msg) -> Html msg
editor html toMsg =
    Html.node "netbuilder-html-content-editor"
        [ attribute "data-html" html
        , on "trix-change" (Decode.map toMsg (Decode.field "detail" Decode.string))
        ]
        []
