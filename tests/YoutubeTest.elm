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
                "https://www.youtube.com/watch?v=ftXmvnL0ZOc"
                    |> Youtube.isValid
                    |> Expect.true "Short url is valid"
        , test "validates a url with more params" <|
            \_ ->
                "https://www.youtube.com/watch?v=ftXmvnL0ZOc&list=RDftXmvnL0ZOc&start_radio=1"
                    |> Youtube.isValid
                    |> Expect.true "URL with more params is valid"
        , test "extracts the video id from short url" <|
            \_ ->
                "https://www.youtube.com/watch?v=ftXmvnL0ZOc"
                    |> Youtube.videoId
                    |> Expect.equal (Just "ftXmvnL0ZOc")
        ]
