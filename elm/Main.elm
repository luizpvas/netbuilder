module Main exposing (main)

import BlockId exposing (BlockId)
import Browser
import Browser.Events
import CodeMirror
import ContainerId exposing (ContainerId)
import Data.LandingPage as LandingPage exposing (LandingPage)
import EditHistory exposing (EditHistory)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import I18n
import Icon
import Interop
import Json.Decode as Decode
import Trix
import Youtube


type alias Flags =
    ()


type alias Model =
    { landingPage : LandingPage
    , editingBlock : Maybe BlockId
    , containerMenu : Maybe ContainerId
    , nextId : Int
    , editHistory : EditHistory
    }


init : Flags -> ( Model, Cmd Msg )
init () =
    ( { landingPage =
            LandingPage.new
                |> LandingPage.changeContainerLayout (ContainerId.fromInt 1) "SingleColumn" 1
                |> .landingPage
                |> LandingPage.addPlaceholderAfter (ContainerId.fromInt 1) 2
                |> .landingPage
      , editingBlock = Nothing
      , containerMenu = Nothing
      , nextId = 99
      , editHistory = EditHistory.empty
      }
    , Cmd.none
    )



-- Update


type Msg
    = Ignored
    | Undo
    | AddContainerAfter ContainerId
    | ChangeContainerLayout ContainerId String
    | ChangeBlockLayout BlockId String
    | StartMovingContainerUp ContainerId
    | StartMovingContainerDown ContainerId
    | MoveContainerUp ContainerId
    | MoveContainerDown ContainerId
    | OpenContainerMenu ContainerId
    | CloseContainerMenu
    | RemoveContainer ContainerId
    | StartEditing BlockId
    | StopEditing
    | RemoveBlock BlockId
    | SetBlockHtmlContent BlockId String
    | SetBlockHtmlCode BlockId String
    | SetBlockYoutubeUrl BlockId String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Ignored ->
            ( model, Cmd.none )

        Undo ->
            let
                ( maybeLandingPage, editHistory ) =
                    EditHistory.pop model.editHistory
            in
            case maybeLandingPage of
                Just landingPage ->
                    ( { model | landingPage = landingPage, editHistory = editHistory }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        AddContainerAfter containerId ->
            let
                result =
                    LandingPage.addPlaceholderAfter containerId model.nextId model.landingPage
            in
            ( { model | nextId = result.nextId } |> track result.landingPage
            , Cmd.none
            )

        ChangeContainerLayout containerId layout ->
            let
                result =
                    LandingPage.changeContainerLayout containerId layout model.nextId model.landingPage
            in
            ( { model | nextId = result.nextId } |> track result.landingPage
            , Cmd.none
            )

        ChangeBlockLayout blockId layout ->
            ( { model | editingBlock = Just blockId }
                |> track (LandingPage.changeBlockLayout blockId layout model.landingPage)
            , Cmd.none
            )

        StartMovingContainerUp id ->
            ( model, Interop.startMovingContainerUp (ContainerId.toString id) )

        StartMovingContainerDown id ->
            ( model, Interop.startMovingContainerDown (ContainerId.toString id) )

        MoveContainerUp id ->
            ( model |> track (LandingPage.moveContainerUp id model.landingPage)
            , Cmd.none
            )

        MoveContainerDown id ->
            ( model |> track (LandingPage.moveContainerDown id model.landingPage)
            , Cmd.none
            )

        OpenContainerMenu containerId ->
            ( { model | containerMenu = Just containerId }, Cmd.none )

        CloseContainerMenu ->
            ( { model | containerMenu = Nothing }, Cmd.none )

        RemoveContainer id ->
            ( model |> track (LandingPage.removeContainer id model.landingPage)
            , Cmd.none
            )

        StartEditing blockId ->
            ( { model | editingBlock = Just blockId }, Cmd.none )

        StopEditing ->
            ( { model | editingBlock = Nothing } |> track model.landingPage
            , Cmd.none
            )

        RemoveBlock blockId ->
            ( model |> track (LandingPage.removeBlock blockId model.landingPage)
            , Cmd.none
            )

        SetBlockHtmlContent blockId html ->
            let
                nextLandingPage =
                    model.landingPage
                        |> LandingPage.updateBlock
                            (\block ->
                                if block.id == blockId then
                                    case block.layout of
                                        LandingPage.HtmlContent _ ->
                                            { block | layout = LandingPage.HtmlContent html }

                                        _ ->
                                            block

                                else
                                    block
                            )
            in
            ( { model | landingPage = nextLandingPage }, Cmd.none )

        SetBlockHtmlCode blockId html ->
            let
                nextLandingPage =
                    model.landingPage
                        |> LandingPage.updateBlock
                            (\block ->
                                if block.id == blockId then
                                    case block.layout of
                                        LandingPage.HtmlCode _ ->
                                            { block | layout = LandingPage.HtmlCode html }

                                        _ ->
                                            block

                                else
                                    block
                            )
            in
            ( { model | landingPage = nextLandingPage }, Cmd.none )

        SetBlockYoutubeUrl blockId url ->
            let
                nextLandingPage =
                    model.landingPage
                        |> LandingPage.updateBlock
                            (\block ->
                                if block.id == blockId then
                                    case block.layout of
                                        LandingPage.YoutubeVideo _ ->
                                            { block | layout = LandingPage.YoutubeVideo url }

                                        _ ->
                                            block

                                else
                                    block
                            )
            in
            ( { model | landingPage = nextLandingPage }, Cmd.none )


track : LandingPage -> Model -> Model
track nextLandingPage model =
    { model | landingPage = nextLandingPage, editHistory = EditHistory.push model.editHistory model.landingPage }



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        mouse =
            case model.containerMenu of
                Just _ ->
                    Browser.Events.onMouseUp (Decode.succeed CloseContainerMenu)

                Nothing ->
                    Sub.none
    in
    Sub.batch
        [ mouse
        , Interop.movingDownFinished (ContainerId.fromInt >> MoveContainerDown)
        , Interop.movingUpFinished (ContainerId.fromInt >> MoveContainerUp)
        , Interop.ctrlZPressed (\_ -> Undo)
        ]



-- View


view : Model -> Html Msg
view model =
    div [ class "editor" ]
        [ div [] (List.map (viewEditingContainer model.editingBlock model.containerMenu) (LandingPage.containers model.landingPage))
        ]


viewEditingContainer : Maybe BlockId -> Maybe ContainerId -> LandingPage.Container -> Html Msg
viewEditingContainer editing containerMenu container =
    case editing of
        Just blockId ->
            case LandingPage.findBlockInContainer container blockId of
                Just block ->
                    viewBlockEditor block

                Nothing ->
                    viewContainer container containerMenu

        Nothing ->
            viewContainer container containerMenu


viewContainer : LandingPage.Container -> Maybe ContainerId -> Html Msg
viewContainer container containerMenu =
    case container.layout of
        LandingPage.ContainerPlaceholder ->
            viewContainerColumns container
                containerMenu
                [ ( "placeholder", viewContainerPlaceholder container.id )
                ]

        LandingPage.SingleColumn block ->
            viewContainerColumns container
                containerMenu
                [ ( BlockId.toString block.id, div [ class "column-100" ] [ viewBlock block ] )
                ]

        LandingPage.TwoColumns50x50 left right ->
            viewContainerColumns container
                containerMenu
                [ ( BlockId.toString left.id, div [ class "column-50" ] [ viewBlock left ] )
                , ( BlockId.toString right.id, div [ class "column-50" ] [ viewBlock right ] )
                ]

        LandingPage.TwoColumns30x70 left right ->
            viewContainerColumns container
                containerMenu
                [ ( BlockId.toString left.id, div [ class "column-30" ] [ viewBlock left ] )
                , ( BlockId.toString right.id, div [ class "column-70" ] [ viewBlock right ] )
                ]

        LandingPage.TwoColumns70x30 left right ->
            viewContainerColumns container
                containerMenu
                [ ( BlockId.toString left.id, div [ class "column-70" ] [ viewBlock left ] )
                , ( BlockId.toString right.id, div [ class "column-30" ] [ viewBlock right ] )
                ]

        LandingPage.ThreeColumns33x33x33 left center right ->
            viewContainerColumns container
                containerMenu
                [ ( BlockId.toString left.id, div [ class "column-33" ] [ viewBlock left ] )
                , ( BlockId.toString center.id, div [ class "column-33" ] [ viewBlock center ] )
                , ( BlockId.toString right.id, div [ class "column-33" ] [ viewBlock right ] )
                ]

        LandingPage.ThreeColumns25x25x50 left center right ->
            viewContainerColumns container
                containerMenu
                [ ( BlockId.toString left.id, div [ class "column-25" ] [ viewBlock left ] )
                , ( BlockId.toString center.id, div [ class "column-25" ] [ viewBlock center ] )
                , ( BlockId.toString right.id, div [ class "column-50" ] [ viewBlock right ] )
                ]

        LandingPage.ThreeColumns50x25x25 left center right ->
            viewContainerColumns container
                containerMenu
                [ ( BlockId.toString left.id, div [ class "column-50" ] [ viewBlock left ] )
                , ( BlockId.toString center.id, div [ class "column-25" ] [ viewBlock center ] )
                , ( BlockId.toString right.id, div [ class "column-25" ] [ viewBlock right ] )
                ]

        LandingPage.FourColumns25x25x25x25 left1 left2 right1 right2 ->
            viewContainerColumns container
                containerMenu
                [ ( BlockId.toString left1.id, div [ class "column-25" ] [ viewBlock left1 ] )
                , ( BlockId.toString left2.id, div [ class "column-25" ] [ viewBlock left2 ] )
                , ( BlockId.toString right1.id, div [ class "column-25" ] [ viewBlock right1 ] )
                , ( BlockId.toString right2.id, div [ class "column-25" ] [ viewBlock right2 ] )
                ]


viewContainerColumns : LandingPage.Container -> Maybe ContainerId -> List ( String, Html Msg ) -> Html Msg
viewContainerColumns container containerMenu columns =
    div []
        [ Html.Keyed.node "div"
            [ class "container", id (ContainerId.toString container.id) ]
            (( "container-menu", viewContainerMenu container containerMenu ) :: columns)
        , div [ onClick (AddContainerAfter container.id) ] [ text "Add" ]
        ]


viewContainerMenu : LandingPage.Container -> Maybe ContainerId -> Html Msg
viewContainerMenu container containerMenu =
    let
        className =
            if containerMenu == Just container.id then
                "container-menu-options open"

            else
                "container-menu-options"
    in
    div []
        [ div [ class "container-menu-trigger", onClick (OpenContainerMenu container.id) ] [ Icon.more ]
        , div [ class className ]
            [ div [ class "container-menu-option", onClick (StartMovingContainerUp container.id) ] [ Icon.arrowUp, text I18n.moveUp ]
            , div [ class "container-menu-option", onClick (StartMovingContainerDown container.id) ] [ Icon.arrowDown, text I18n.moveDown ]
            , div [ class "container-menu-option" ] [ Icon.spacing, text I18n.spacing ]
            , div [ class "container-menu-option" ] [ Icon.styling, text I18n.styling ]
            , div [ class "container-menu-option", onClick (RemoveContainer container.id) ] [ Icon.remove, text I18n.remove ]
            ]
        ]


viewContainerPlaceholder : ContainerId -> Html Msg
viewContainerPlaceholder containerId =
    div [ class "container-placeholder" ]
        [ div [ class "container-layouts" ]
            [ div
                [ class "container-layout-item"
                , onClick (ChangeContainerLayout containerId "SingleColumn")
                , title I18n.editorSingleColumn
                ]
                [ div [ class "container-layout-column", style "width" "100%" ] [] ]
            , div
                [ class "container-layout-item"
                , onClick (ChangeContainerLayout containerId "TwoColumns50x50")
                , title I18n.editorTwoColumns50x50
                ]
                [ div [ class "container-layout-column", style "width" "50%" ] []
                , div [ class "container-layout-column", style "width" "50%" ] []
                ]
            , div
                [ class "container-layout-item"
                , onClick (ChangeContainerLayout containerId "TwoColumns30x70")
                , title I18n.editorTwoColumns30x70
                ]
                [ div [ class "container-layout-column", style "width" "30%" ] []
                , div [ class "container-layout-column", style "width" "70%" ] []
                ]
            , div
                [ class "container-layout-item"
                , onClick (ChangeContainerLayout containerId "TwoColumns70x30")
                , title I18n.editorTwoColumns70x30
                ]
                [ div [ class "container-layout-column", style "width" "70%" ] []
                , div [ class "container-layout-column", style "width" "30%" ] []
                ]
            ]
        , div [ class "container-layouts" ]
            [ div
                [ class "container-layout-item mr-5"
                , onClick (ChangeContainerLayout containerId "ThreeColumns33x33x33")
                , title I18n.editorThreeColumns33x33x33
                ]
                [ div [ class "container-layout-column", style "width" "33.3%" ] []
                , div [ class "container-layout-column", style "width" "33.3%" ] []
                , div [ class "container-layout-column", style "width" "33.3%" ] []
                ]
            , div
                [ class "container-layout-item mr-5"
                , onClick (ChangeContainerLayout containerId "ThreeColumns25x25x50")
                , title I18n.editorThreeColumns25x25x50
                ]
                [ div [ class "container-layout-column", style "width" "25%" ] []
                , div [ class "container-layout-column", style "width" "25%" ] []
                , div [ class "container-layout-column", style "width" "50%" ] []
                ]
            , div
                [ class "container-layout-item"
                , onClick (ChangeContainerLayout containerId "ThreeColumns50x25x25")
                , title I18n.editorThreeColumns50x25x25
                ]
                [ div [ class "container-layout-column", style "width" "50%" ] []
                , div [ class "container-layout-column", style "width" "25%" ] []
                , div [ class "container-layout-column", style "width" "25%" ] []
                ]
            , div
                [ class "container-layout-item"
                , onClick (ChangeContainerLayout containerId "FourColumns25x25x25x25")
                , title I18n.editorFourColumns25x25x25x25
                ]
                [ div [ class "container-layout-column", style "width" "25%" ] []
                , div [ class "container-layout-column", style "width" "25%" ] []
                , div [ class "container-layout-column", style "width" "25%" ] []
                , div [ class "container-layout-column", style "width" "25%" ] []
                ]
            ]
        ]


viewBlockEditor : LandingPage.Block -> Html Msg
viewBlockEditor block =
    case block.layout of
        LandingPage.BlockPlaceholder ->
            viewBlockPlaceholder block.id

        LandingPage.HtmlCode html ->
            div [ class "block-editor-panel" ]
                [ div [ class "block-editor-panel-header" ]
                    [ text "Editor de HTML"
                    , button [ class "netbuilder-button", onClick StopEditing ] [ text "Salvar" ]
                    ]
                , div [ class "block-editor-panel-body" ]
                    [ CodeMirror.editor html (SetBlockHtmlCode block.id)
                    ]
                ]

        LandingPage.HtmlContent html ->
            div [ class "block-editor-panel" ]
                [ div [ class "block-editor-panel-header" ]
                    [ text "Editor de texto"
                    , button [ class "netbuilder-button", onClick StopEditing ] [ text "Salvar" ]
                    ]
                , div [ class "block-editor-panel-body" ]
                    [ Trix.editor html (SetBlockHtmlContent block.id)
                    ]
                ]

        LandingPage.YoutubeVideo url ->
            div [ class "block-editor-panel" ]
                [ div [ class "block-editor-panel-header" ]
                    [ text "Vídeo do Youtube"
                    , button [ class "netbuilder-button", onClick StopEditing ] [ text "Salvar" ]
                    ]
                , div [ class "block-editor-panel-body" ]
                    [ label []
                        [ text "Copie e cole a URL do vídeo:"
                        , input
                            [ class "netbuilder-input"
                            , onInput (SetBlockYoutubeUrl block.id)
                            , placeholder "https://www.youtube.com/watch?v=..."
                            , value url
                            ]
                            []
                        ]
                    , div [ class "youtube-preview-image-editor-container" ]
                        [ case Youtube.thumbnailUrl url of
                            Just thumbnailUrl ->
                                img [ class "youtube-preview-image", src thumbnailUrl ] []

                            Nothing ->
                                div [] [ text "Invalid URL" ]
                        ]
                    ]
                ]

        LandingPage.Image url ->
            div [] [ text "Image" ]

        LandingPage.CallToAction url ->
            div [] [ text "Call to action" ]


viewBlock : LandingPage.Block -> Html Msg
viewBlock block =
    case block.layout of
        LandingPage.BlockPlaceholder ->
            viewBlockPlaceholder block.id

        LandingPage.HtmlCode html ->
            div [ class "block-content" ]
                [ viewBlockHoverOptions block.id
                , Html.node "netbuilder-html-content" [ attribute "data-html" html ] []
                ]

        LandingPage.HtmlContent html ->
            div [ class "block-content" ]
                [ viewBlockHoverOptions block.id
                , Html.node "netbuilder-html-content" [ attribute "data-html" html ] []
                ]

        LandingPage.YoutubeVideo url ->
            case Youtube.thumbnailUrl url of
                Just thumbnailUrl ->
                    div [ class "block-content" ]
                        [ viewBlockHoverOptions block.id
                        , img [ src thumbnailUrl, class "youtube-preview-image" ] []
                        ]

                Nothing ->
                    div [ class "block-content" ]
                        [ viewBlockHoverOptions block.id
                        , text "URL Inválida."
                        ]

        LandingPage.Image url ->
            div [ class "block-content" ] [ text "Image" ]

        LandingPage.CallToAction url ->
            div [ class "block-content" ] [ text "Call to action" ]


viewBlockHoverOptions : BlockId -> Html Msg
viewBlockHoverOptions blockId =
    div [ class "block-content-hover-options" ]
        [ div [ class "block-content-hover-option", onClick (StartEditing blockId) ] [ Icon.edit ]
        , div [ class "block-content-hover-option", onClick (RemoveBlock blockId) ] [ Icon.remove ]
        ]


viewBlockPlaceholder : BlockId -> Html Msg
viewBlockPlaceholder blockId =
    div [ class "block-layout-options" ]
        [ div
            [ class "block-layout-option-container"
            , onClick (ChangeBlockLayout blockId "HtmlContent")
            , title I18n.blockHtmlContentLayoutOption
            ]
            [ Icon.htmlContent
            ]
        , div
            [ class "block-layout-option-container"
            , onClick (ChangeBlockLayout blockId "HtmlCode")
            ]
            [ Icon.htmlCode
            ]
        , div
            [ class "block-layout-option-container"
            , onClick (ChangeBlockLayout blockId "YoutubeVideo")
            ]
            [ Icon.youtube
            ]
        , div
            [ class "block-layout-option-container"
            , onClick (ChangeBlockLayout blockId "Image")
            ]
            [ Icon.image
            ]
        , div
            [ class "block-layout-option-container"
            , onClick (ChangeBlockLayout blockId "CallToAction")
            ]
            [ Icon.callToAction
            ]
        ]


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
