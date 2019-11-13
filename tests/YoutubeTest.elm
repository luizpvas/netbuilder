module YoutubeTest exposing (suite)

import Expect
import Test exposing (..)
import Url
import Url.Parser
import Url.Parser.Query
import Youtube


parser =
    Url.Parser.query (Url.Parser.Query.string "search")


suite : Test
suite =
    describe "Youtube spec"
        [ test "validates a url" <|
            \_ ->
                Expect.true "Short url is valid" (Youtube.isValid "https://www.youtube.com/watch?v=ftXmvnL0ZOc")
        , test "validates a url with more params" <|
            \_ ->
                Expect.true "URL with params is valid" (Youtube.isValid "https://www.youtube.com/watch?v=ftXmvnL0ZOc&list=RDftXmvnL0ZOc&start_radio=1")
        , test "extracts the video id from short url" <|
            \_ ->
                "https://page.com/foo?search=123"
                    |> Url.fromString
                    |> Maybe.map (Url.Parser.parse parser)
                    |> Expect.equal Nothing
        ]
