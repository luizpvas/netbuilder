module Youtube exposing (isValid, thumbnailUrl, videoId)

import Maybe.Extra
import Url
import Url.Parser
import Url.Parser.Query


{-| Checks if the given string is a valid Youtube URL.
-}
isValid : String -> Bool
isValid =
    String.startsWith "https://www.youtube.com/watch"


parser : Url.Parser.Parser (Maybe String -> a) a
parser =
    Url.Parser.query (Url.Parser.Query.string "v")


{-| Attempts to extract the video ID from given url
-}
videoId : String -> Maybe String
videoId url =
    Url.fromString url
        -- https://github.com/elm/url/issues/17
        |> Maybe.map (\parsed -> { parsed | path = "" })
        |> Maybe.map (Url.Parser.parse parser)
        |> Maybe.Extra.join
        |> Maybe.Extra.join


thumbnailUrl : String -> String
thumbnailUrl =
    String.replace "https://www.youtube.com/watch?v=" ""
