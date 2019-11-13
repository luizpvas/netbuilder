module Data.LandingPage exposing
    ( Block
    , BlockLayout(..)
    , Container
    , ContainerLayout(..)
    , LandingPage
    , addPlaceholderAfter
    , changeBlockLayout
    , changeContainerLayout
    , containerToString
    , containers
    , findBlockInContainer
    , map
    , moveContainerDown
    , moveContainerUp
    , new
    , removeBlock
    , removeContainer
    , updateBlock
    )

import BlockId exposing (BlockId)
import ContainerId exposing (ContainerId)
import Data.ColorTheme as ColorTheme exposing (ColorTheme)
import Data.FontTheme as FontTheme exposing (FontTheme)
import List.Extra


type alias LandingPage =
    { colors : ColorTheme
    , fonts : FontTheme
    , firstContainer : Container
    , otherContainers : List Container
    }


type alias Container =
    { id : ContainerId
    , layout : ContainerLayout
    }


type ContainerLayout
    = ContainerPlaceholder
    | SingleColumn Block
    | TwoColumns50x50 Block Block
    | TwoColumns30x70 Block Block
    | TwoColumns70x30 Block Block
    | ThreeColumns33x33x33 Block Block Block
    | ThreeColumns25x25x50 Block Block Block
    | ThreeColumns50x25x25 Block Block Block
    | FourColumns25x25x25x25 Block Block Block Block


type alias Block =
    { id : BlockId
    , layout : BlockLayout
    }


type BlockLayout
    = BlockPlaceholder
    | HtmlCode String
    | HtmlContent String
    | YoutubeVideo String
    | Image String
    | CallToAction String



-- Stuff


new : LandingPage
new =
    { colors = ColorTheme.montalcino
    , fonts = FontTheme.systemSansSerif
    , firstContainer = { id = ContainerId.fromInt 1, layout = ContainerPlaceholder }
    , otherContainers = []
    }


{-| We have a special function for getting the containers of a page
as a list because internally it's not a list: it's the first container + others.
This design ensures there is always one container available for the user to edit.
-}
containers : LandingPage -> List Container
containers landingPage =
    landingPage.firstContainer :: landingPage.otherContainers


stringToContainerLayout : String -> Int -> ( Int, ContainerLayout )
stringToContainerLayout str nextId =
    case str of
        "SingleColumn" ->
            ( nextId + 1
            , SingleColumn { id = BlockId.fromInt (nextId + 1), layout = BlockPlaceholder }
            )

        "TwoColumns50x50" ->
            ( nextId + 2
            , TwoColumns50x50
                { id = BlockId.fromInt (nextId + 1), layout = BlockPlaceholder }
                { id = BlockId.fromInt (nextId + 2), layout = BlockPlaceholder }
            )

        "TwoColumns30x70" ->
            ( nextId + 2
            , TwoColumns30x70
                { id = BlockId.fromInt (nextId + 1), layout = BlockPlaceholder }
                { id = BlockId.fromInt (nextId + 2), layout = BlockPlaceholder }
            )

        "TwoColumns70x30" ->
            ( nextId + 2
            , TwoColumns70x30
                { id = BlockId.fromInt (nextId + 1), layout = BlockPlaceholder }
                { id = BlockId.fromInt (nextId + 2), layout = BlockPlaceholder }
            )

        "ThreeColumns33x33x33" ->
            ( nextId + 3
            , ThreeColumns33x33x33
                { id = BlockId.fromInt (nextId + 1), layout = BlockPlaceholder }
                { id = BlockId.fromInt (nextId + 2), layout = BlockPlaceholder }
                { id = BlockId.fromInt (nextId + 3), layout = BlockPlaceholder }
            )

        "ThreeColumns25x25x50" ->
            ( nextId + 3
            , ThreeColumns25x25x50
                { id = BlockId.fromInt (nextId + 1), layout = BlockPlaceholder }
                { id = BlockId.fromInt (nextId + 2), layout = BlockPlaceholder }
                { id = BlockId.fromInt (nextId + 3), layout = BlockPlaceholder }
            )

        "ThreeColumns50x25x25" ->
            ( nextId + 3
            , ThreeColumns50x25x25
                { id = BlockId.fromInt (nextId + 1), layout = BlockPlaceholder }
                { id = BlockId.fromInt (nextId + 2), layout = BlockPlaceholder }
                { id = BlockId.fromInt (nextId + 3), layout = BlockPlaceholder }
            )

        "FourColumns25x25x25x25" ->
            ( nextId + 4
            , FourColumns25x25x25x25
                { id = BlockId.fromInt (nextId + 1), layout = BlockPlaceholder }
                { id = BlockId.fromInt (nextId + 2), layout = BlockPlaceholder }
                { id = BlockId.fromInt (nextId + 3), layout = BlockPlaceholder }
                { id = BlockId.fromInt (nextId + 4), layout = BlockPlaceholder }
            )

        _ ->
            let
                _ =
                    Debug.log "unknown column layout string" str
            in
            ( nextId, ContainerPlaceholder )


containerToString : Container -> String
containerToString container =
    ContainerId.toString container.id ++ "-" ++ containerLayoutToString container.layout


{-| Testing the structure of a landing page is... verbose, and hosnetly I don't feel
more confident in the test if it's `case` expressions and comparing actual types than using
strings - which are way more convenient.
-}
containerLayoutToString : ContainerLayout -> String
containerLayoutToString layout =
    case layout of
        ContainerPlaceholder ->
            "Placeholder"

        SingleColumn block ->
            "SingleColumn " ++ blockToString block

        TwoColumns50x50 left right ->
            "TwoColumns50x50 " ++ blockToString left ++ " " ++ blockToString right

        TwoColumns30x70 _ _ ->
            "TwoColumns30x70"

        TwoColumns70x30 _ _ ->
            "TwoColumns70x30"

        ThreeColumns33x33x33 _ _ _ ->
            "ThreeColumns33x33x33"

        ThreeColumns25x25x50 _ _ _ ->
            "ThreeColumns25x25x50"

        ThreeColumns50x25x25 _ _ _ ->
            "ThreeColumns50x25x25"

        FourColumns25x25x25x25 _ _ _ _ ->
            "FourColumns25x25x25x25"


blockToString : Block -> String
blockToString block =
    BlockId.toString block.id ++ "-" ++ blockLayoutToString block.layout


blockLayoutToString : BlockLayout -> String
blockLayoutToString blockLayout =
    case blockLayout of
        BlockPlaceholder ->
            "Placeholder"

        HtmlCode _ ->
            "HtmlCode"

        HtmlContent _ ->
            "HtmlContent"

        YoutubeVideo _ ->
            "YoutubeVideo"

        Image _ ->
            "Image"

        CallToAction _ ->
            "CallToAction"


stringToBlockLayout : String -> BlockLayout
stringToBlockLayout layout =
    case layout of
        "HtmlCode" ->
            HtmlCode ""

        "HtmlContent" ->
            HtmlContent ""

        "YoutubeVideo" ->
            YoutubeVideo ""

        "Image" ->
            Image ""

        "CallToAction" ->
            CallToAction ""

        _ ->
            BlockPlaceholder



-- Querying


find : ContainerId -> LandingPage -> Maybe Container
find id landingPage =
    containers landingPage
        |> List.filter (\container -> container.id == id)
        |> List.head


findBlockInContainer : Container -> BlockId -> Maybe Block
findBlockInContainer container blockId =
    let
        blocks =
            case container.layout of
                ContainerPlaceholder ->
                    []

                SingleColumn block ->
                    [ block ]

                TwoColumns50x50 left right ->
                    [ left, right ]

                TwoColumns30x70 left right ->
                    [ left, right ]

                TwoColumns70x30 left right ->
                    [ left, right ]

                ThreeColumns33x33x33 left middle right ->
                    [ left, middle, right ]

                ThreeColumns25x25x50 left middle right ->
                    [ left, middle, right ]

                ThreeColumns50x25x25 left middle right ->
                    [ left, middle, right ]

                FourColumns25x25x25x25 left1 left2 right1 right2 ->
                    [ left1, left2, right1, right2 ]
    in
    blocks |> List.filter (\block -> block.id == blockId) |> List.head



-- Update


map : (Container -> a) -> LandingPage -> List a
map fn landingPage =
    fn landingPage.firstContainer :: List.map fn landingPage.otherContainers


update : (Container -> Container) -> LandingPage -> LandingPage
update fn landingPage =
    { landingPage
        | firstContainer = fn landingPage.firstContainer
        , otherContainers = List.map fn landingPage.otherContainers
    }


updateBlock : (Block -> Block) -> LandingPage -> LandingPage
updateBlock fn =
    update
        (\container ->
            case container.layout of
                ContainerPlaceholder ->
                    container

                SingleColumn block ->
                    { container | layout = SingleColumn (fn block) }

                TwoColumns50x50 left right ->
                    { container | layout = TwoColumns50x50 (fn left) (fn right) }

                TwoColumns30x70 left right ->
                    { container | layout = TwoColumns30x70 (fn left) (fn right) }

                TwoColumns70x30 left right ->
                    { container | layout = TwoColumns70x30 (fn left) (fn right) }

                ThreeColumns33x33x33 left middle right ->
                    { container | layout = ThreeColumns33x33x33 (fn left) (fn middle) (fn right) }

                ThreeColumns25x25x50 left middle right ->
                    { container | layout = ThreeColumns25x25x50 (fn left) (fn middle) (fn right) }

                ThreeColumns50x25x25 left middle right ->
                    { container | layout = ThreeColumns25x25x50 (fn left) (fn middle) (fn right) }

                FourColumns25x25x25x25 left1 left2 right1 right2 ->
                    { container | layout = FourColumns25x25x25x25 (fn left1) (fn left2) (fn right1) (fn right2) }
        )


type alias ChangeResult =
    { nextId : Int
    , landingPage : LandingPage
    }


addPlaceholderAfter : ContainerId -> Int -> LandingPage -> ChangeResult
addPlaceholderAfter containerId latestId landingPage =
    { nextId = latestId + 1
    , landingPage = addContainerAfter containerId { id = ContainerId.fromInt (latestId + 1), layout = ContainerPlaceholder } landingPage
    }


addContainerAfter : ContainerId -> Container -> LandingPage -> LandingPage
addContainerAfter containerId container landingPage =
    if landingPage.firstContainer.id == containerId then
        { landingPage | otherContainers = container :: landingPage.otherContainers }

    else
        case List.Extra.splitWhen (\c -> c.id == containerId) landingPage.otherContainers of
            Just ( before, [] ) ->
                { landingPage | otherContainers = before ++ [ container ] }

            Just ( before, target :: after ) ->
                { landingPage | otherContainers = before ++ [ target ] ++ [ container ] ++ after }

            Nothing ->
                landingPage


changeContainerLayout : ContainerId -> String -> Int -> LandingPage -> ChangeResult
changeContainerLayout containerId layout latestId landingPage =
    let
        ( nextId, containerLayout ) =
            stringToContainerLayout layout latestId

        mapped =
            landingPage
                |> update
                    (\container ->
                        if container.id == containerId then
                            { container | layout = containerLayout }

                        else
                            container
                    )
    in
    { nextId = nextId
    , landingPage = mapped
    }


moveContainerDown : ContainerId -> LandingPage -> LandingPage
moveContainerDown containerId landingPage =
    let
        maybeCurrent =
            find containerId landingPage

        maybeTarget =
            case List.Extra.splitWhen (\c -> c.id == containerId) (containers landingPage) of
                Just ( before, [] ) ->
                    Nothing

                Just ( before, current :: after ) ->
                    List.head after

                Nothing ->
                    Nothing
    in
    case ( maybeCurrent, maybeTarget ) of
        ( Just current, Just target ) ->
            landingPage
                |> removeContainer containerId
                |> addContainerAfter target.id current

        _ ->
            landingPage


moveContainerUp : ContainerId -> LandingPage -> LandingPage
moveContainerUp containerId landingPage =
    case List.Extra.splitWhen (\c -> c.id == containerId) (containers landingPage) of
        Just ( before, after ) ->
            List.Extra.last before
                |> Maybe.map (\previous -> moveContainerDown previous.id landingPage)
                |> Maybe.withDefault landingPage

        Nothing ->
            landingPage


removeContainer : ContainerId -> LandingPage -> LandingPage
removeContainer containerId landingPage =
    if landingPage.firstContainer.id == containerId then
        case landingPage.otherContainers of
            [] ->
                { landingPage | firstContainer = { id = landingPage.firstContainer.id, layout = ContainerPlaceholder } }

            second :: rest ->
                { landingPage | firstContainer = second, otherContainers = rest }

    else
        { landingPage | otherContainers = List.filter (\c -> c.id /= containerId) landingPage.otherContainers }


changeBlockLayout : BlockId -> String -> LandingPage -> LandingPage
changeBlockLayout blockId layout =
    updateBlock
        (\block ->
            if block.id == blockId then
                { block | layout = stringToBlockLayout layout }

            else
                block
        )


removeBlock : BlockId -> LandingPage -> LandingPage
removeBlock blockId =
    updateBlock
        (\block ->
            if block.id == blockId then
                { block | layout = BlockPlaceholder }

            else
                block
        )
