module Data.LandingPageTest exposing (suite)

import BlockId
import ContainerId
import Data.LandingPage as LandingPage exposing (LandingPage)
import Expect
import Test exposing (..)


suite : Test
suite =
    describe "Data.LandingPage spec"
        [ test "starts with the first container as a placeholder" <|
            \_ ->
                LandingPage.new
                    |> toString
                    |> Expect.equal [ "1-Placeholder" ]
        , test "adds a new container after the first container" <|
            \_ ->
                LandingPage.new
                    |> LandingPage.addPlaceholderAfter (ContainerId.fromInt 1) 1
                    |> .landingPage
                    |> toString
                    |> Expect.equal [ "1-Placeholder", "2-Placeholder" ]
        , test "adds a new container after the second (and other) containers" <|
            \_ ->
                LandingPage.new
                    |> LandingPage.addPlaceholderAfter (ContainerId.fromInt 1) 1
                    |> .landingPage
                    |> LandingPage.addPlaceholderAfter (ContainerId.fromInt 2) 2
                    |> .landingPage
                    |> toString
                    |> Expect.equal [ "1-Placeholder", "2-Placeholder", "3-Placeholder" ]
        , test "changes the first container from placeholder to columns" <|
            \_ ->
                LandingPage.new
                    |> LandingPage.changeContainerLayout (ContainerId.fromInt 1) "TwoColumns50x50" 1
                    |> .landingPage
                    |> toString
                    |> Expect.equal [ "1-TwoColumns50x50 2-Placeholder 3-Placeholder" ]
        , test "changes other containers from placeholder to columns" <|
            \_ ->
                LandingPage.new
                    |> LandingPage.addPlaceholderAfter (ContainerId.fromInt 1) 1
                    |> .landingPage
                    |> LandingPage.changeContainerLayout (ContainerId.fromInt 2) "TwoColumns50x50" 2
                    |> .landingPage
                    |> toString
                    |> Expect.equal [ "1-Placeholder", "2-TwoColumns50x50 3-Placeholder 4-Placeholder" ]
        , test "removes a container from the landing page" <|
            \_ ->
                LandingPage.new
                    |> LandingPage.addPlaceholderAfter (ContainerId.fromInt 1) 1
                    |> .landingPage
                    |> LandingPage.removeContainer (ContainerId.fromInt 2)
                    |> toString
                    |> Expect.equal [ "1-Placeholder" ]
        , test "moves second container to first when removing the first" <|
            \_ ->
                LandingPage.new
                    |> LandingPage.addPlaceholderAfter (ContainerId.fromInt 1) 1
                    |> .landingPage
                    |> LandingPage.removeContainer (ContainerId.fromInt 1)
                    |> toString
                    |> Expect.equal [ "2-Placeholder" ]
        , test "changes the container to placeholder when trying to remove the last container" <|
            \_ ->
                LandingPage.new
                    |> LandingPage.changeContainerLayout (ContainerId.fromInt 1) "TwoColumns50x50" 1
                    |> .landingPage
                    |> LandingPage.removeContainer (ContainerId.fromInt 1)
                    |> toString
                    |> Expect.equal [ "1-Placeholder" ]
        , test "changes a block from placeholder to content" <|
            \_ ->
                LandingPage.new
                    |> LandingPage.changeContainerLayout (ContainerId.fromInt 1) "TwoColumns50x50" 1
                    |> .landingPage
                    |> LandingPage.changeBlockLayout (BlockId.fromInt 2) "HtmlCode"
                    |> toString
                    |> Expect.equal [ "1-TwoColumns50x50 2-HtmlCode 3-Placeholder" ]
        , test "changes a block from placeholder to content second block" <|
            \_ ->
                LandingPage.new
                    |> LandingPage.changeContainerLayout (ContainerId.fromInt 1) "TwoColumns50x50" 1
                    |> .landingPage
                    |> LandingPage.changeBlockLayout (BlockId.fromInt 3) "HtmlCode"
                    |> toString
                    |> Expect.equal [ "1-TwoColumns50x50 2-Placeholder 3-HtmlCode" ]
        , test "removes a block from other contents back to placeholder" <|
            \_ ->
                LandingPage.new
                    |> LandingPage.changeContainerLayout (ContainerId.fromInt 1) "TwoColumns50x50" 1
                    |> .landingPage
                    |> LandingPage.changeBlockLayout (BlockId.fromInt 2) "FreeHtml"
                    |> LandingPage.removeBlock (BlockId.fromInt 2)
                    |> toString
                    |> Expect.equal [ "1-TwoColumns50x50 2-Placeholder 3-Placeholder" ]
        , test "moves a container down" <|
            \_ ->
                LandingPage.new
                    |> LandingPage.addPlaceholderAfter (ContainerId.fromInt 1) 1
                    |> .landingPage
                    |> LandingPage.moveContainerDown (ContainerId.fromInt 1)
                    |> toString
                    |> Expect.equal [ "2-Placeholder", "1-Placeholder" ]
        , test "moves a container up" <|
            \_ ->
                LandingPage.new
                    |> LandingPage.addPlaceholderAfter (ContainerId.fromInt 1) 1
                    |> .landingPage
                    |> LandingPage.moveContainerUp (ContainerId.fromInt 2)
                    |> toString
                    |> Expect.equal [ "2-Placeholder", "1-Placeholder" ]
        ]


toString : LandingPage -> List String
toString landingPage =
    LandingPage.map LandingPage.containerToString landingPage
