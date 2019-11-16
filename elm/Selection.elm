module Selection exposing (Selection(..))

import BlockId exposing (BlockId)
import Browser.Events
import Json.Decode as Decode exposing (Decoder)


type Selection
    = Nothing
    | Block BlockId


click toMsg =
    Browser.Events.onClick targetsDecoder


targetsDecoder =
    Decode.at [ "target", "id" ] Decode.string
