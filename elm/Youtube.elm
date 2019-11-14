module Youtube exposing (isValid, thumbnailUrl, videoId)

import Maybe.Extra
import Url
import Url.Parser
import Url.Parser.Query


{-| Checks if the given string is a valid Youtube URL.
-}
isValid : String -> Bool
isValid url =
    Maybe.Extra.isJust (videoId url)


parser : Url.Parser.Parser (Maybe String -> a) a
parser =
    Url.Parser.query (Url.Parser.Query.string "v")


{-| Attempts to extract the video ID from given url
-}
videoId : String -> Maybe String
videoId url =
    Url.fromString url
        |> Maybe.map (\parsed -> { parsed | path = "" })
        -- https://github.com/elm/url/issues/17
        |> Maybe.map (Url.Parser.parse parser)
        |> Maybe.Extra.join
        |> Maybe.Extra.join


{-| Gets the thumbnail URL for the given video URL.
-}
thumbnailUrl : String -> Maybe String
thumbnailUrl url =
    case videoId url of
        Just id ->
            Just ("https://img.youtube.com/vi/" ++ id ++ "/sddefault.jpg")

        Nothing ->
            Nothing
