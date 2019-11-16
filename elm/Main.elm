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


{-| The editor is a union of the email being created and the block
being edited. We this both of those as a unit to track the edit history so we can:
"Click on a block, start editing, save changes" and hit ctrl-z 3 times to reverse
those changes.
-}
type alias Editor =
    { landingPage : LandingPage
    , editingBlock : Maybe BlockId
    }


type Selection
    = NothingSelected
    | BlockSelected BlockId


type alias Model =
    { editor : Editor
    , editHistory : EditHistory Editor
    , containerMenu : Maybe ContainerId
    , nextId : Int
    , selection : Selection
    }


init : Flags -> ( Model, Cmd Msg )
init () =
    ( { editor =
            { landingPage = LandingPage.new
            , editingBlock = Nothing
            }
      , containerMenu = Nothing
      , nextId = 99
      , editHistory = EditHistory.empty
      , selection = NothingSelected
      }
    , Cmd.none
    )



-- Update


type Msg
    = Ignored
    | Undo
    | SelectBlock BlockId
    | AddContainerAfter ContainerId
    | RemoveContainer ContainerId
    | ChangeContainerLayout ContainerId String
    | ChangeBlockLayout BlockId String
    | StartMovingContainerUp ContainerId
    | StartMovingContainerDown ContainerId
    | MoveContainerUp ContainerId
    | MoveContainerDown ContainerId
    | OpenContainerMenu ContainerId
    | CloseContainerMenu
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
                ( maybeEditor, editHistory ) =
                    EditHistory.pop model.editHistory
            in
            case maybeEditor of
                Just editor ->
                    ( { model | editor = editor, editHistory = editHistory }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        SelectBlock blockId ->
            ( { model | selection = BlockSelected blockId }, Cmd.none )

        AddContainerAfter containerId ->
            let
                result =
                    LandingPage.addPlaceholderAfter containerId model.nextId model.editor.landingPage
            in
            ( { model | nextId = result.nextId }
                |> trackEditor (\editor -> { editor | landingPage = result.landingPage })
            , Cmd.none
            )

        RemoveContainer id ->
            ( model |> trackEditor (\editor -> { editor | landingPage = LandingPage.removeContainer id model.editor.landingPage })
            , Cmd.none
            )

        ChangeContainerLayout containerId layout ->
            let
                result =
                    LandingPage.changeContainerLayout containerId layout model.nextId model.editor.landingPage
            in
            ( { model | nextId = result.nextId }
                |> trackEditor (\editor -> { editor | landingPage = result.landingPage })
            , Cmd.none
            )

        ChangeBlockLayout blockId layout ->
            ( model
                |> trackEditor
                    (\editor ->
                        { editor
                            | editingBlock = Just blockId
                            , landingPage = LandingPage.changeBlockLayout blockId layout model.editor.landingPage
                        }
                    )
            , Cmd.none
            )

        StartMovingContainerUp id ->
            ( model, Interop.startMovingContainerUp (ContainerId.toString id) )

        StartMovingContainerDown id ->
            ( model, Interop.startMovingContainerDown (ContainerId.toString id) )

        MoveContainerUp id ->
            ( model
                |> trackEditor (\editor -> { editor | landingPage = LandingPage.moveContainerUp id model.editor.landingPage })
            , Cmd.none
            )

        MoveContainerDown id ->
            ( model |> trackEditor (\editor -> { editor | landingPage = LandingPage.moveContainerDown id model.editor.landingPage })
            , Cmd.none
            )

        OpenContainerMenu containerId ->
            ( { model | containerMenu = Just containerId }, Cmd.none )

        CloseContainerMenu ->
            ( { model | containerMenu = Nothing }, Cmd.none )

        StartEditing blockId ->
            ( model |> mapEditor (\editor -> { editor | editingBlock = Just blockId })
            , Cmd.none
            )

        StopEditing ->
            ( model |> trackEditor (\editor -> { editor | editingBlock = Nothing })
            , Cmd.none
            )

        RemoveBlock blockId ->
            ( model |> trackEditor (\editor -> { editor | landingPage = LandingPage.removeBlock blockId model.editor.landingPage })
            , Cmd.none
            )

        SetBlockHtmlContent blockId html ->
            let
                nextLandingPage =
                    model.editor.landingPage
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
            ( model |> mapEditor (\editor -> { editor | landingPage = nextLandingPage })
            , Cmd.none
            )

        SetBlockHtmlCode blockId html ->
            let
                nextLandingPage =
                    model.editor.landingPage
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
            ( model |> mapEditor (\editor -> { editor | landingPage = nextLandingPage })
            , Cmd.none
            )

        SetBlockYoutubeUrl blockId url ->
            let
                nextLandingPage =
                    model.editor.landingPage
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
            ( model |> mapEditor (\editor -> { editor | landingPage = nextLandingPage })
            , Cmd.none
            )


mapEditor : (Editor -> Editor) -> Model -> Model
mapEditor fn model =
    { model | editor = fn model.editor }


trackEditor : (Editor -> Editor) -> Model -> Model
trackEditor fn model =
    { model
        | editHistory = EditHistory.push model.editHistory model.editor
        , editor = fn model.editor
    }



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
        , Browser.Events.onClick (Decode.succeed Ignored)
        ]



-- View


view : Model -> Html Msg
view model =
    div [ class "editor" ]
        [ div [] (List.map (viewEditingContainer model) (LandingPage.containers model.editor.landingPage))
        ]


viewEditingContainer : Model -> LandingPage.Container -> Html Msg
viewEditingContainer model container =
    case model.editor.editingBlock of
        Just blockId ->
            case LandingPage.findBlockInContainer container blockId of
                Just block ->
                    viewBlockEditor block

                Nothing ->
                    viewContainer model container

        Nothing ->
            viewContainer model container


viewContainer : Model -> LandingPage.Container -> Html Msg
viewContainer model container =
    case container.layout of
        LandingPage.ContainerPlaceholder ->
            viewContainerColumns container
                model
                [ ( "placeholder", viewContainerPlaceholder container.id )
                ]

        LandingPage.SingleColumn block ->
            viewContainerColumns container
                model
                [ ( BlockId.toString block.id, div [ class "column-100" ] [ viewBlock model block ] )
                ]

        LandingPage.TwoColumns50x50 left right ->
            viewContainerColumns container
                model
                [ ( BlockId.toString left.id, div [ class "column-50" ] [ viewBlock model left ] )
                , ( BlockId.toString right.id, div [ class "column-50" ] [ viewBlock model right ] )
                ]

        LandingPage.TwoColumns30x70 left right ->
            viewContainerColumns container
                model
                [ ( BlockId.toString left.id, div [ class "column-30" ] [ viewBlock model left ] )
                , ( BlockId.toString right.id, div [ class "column-70" ] [ viewBlock model right ] )
                ]

        LandingPage.TwoColumns70x30 left right ->
            viewContainerColumns container
                model
                [ ( BlockId.toString left.id, div [ class "column-70" ] [ viewBlock model left ] )
                , ( BlockId.toString right.id, div [ class "column-30" ] [ viewBlock model right ] )
                ]

        LandingPage.ThreeColumns33x33x33 left center right ->
            viewContainerColumns container
                model
                [ ( BlockId.toString left.id, div [ class "column-33" ] [ viewBlock model left ] )
                , ( BlockId.toString center.id, div [ class "column-33" ] [ viewBlock model center ] )
                , ( BlockId.toString right.id, div [ class "column-33" ] [ viewBlock model right ] )
                ]

        LandingPage.ThreeColumns25x25x50 left center right ->
            viewContainerColumns container
                model
                [ ( BlockId.toString left.id, div [ class "column-25" ] [ viewBlock model left ] )
                , ( BlockId.toString center.id, div [ class "column-25" ] [ viewBlock model center ] )
                , ( BlockId.toString right.id, div [ class "column-50" ] [ viewBlock model right ] )
                ]

        LandingPage.ThreeColumns50x25x25 left center right ->
            viewContainerColumns container
                model
                [ ( BlockId.toString left.id, div [ class "column-50" ] [ viewBlock model left ] )
                , ( BlockId.toString center.id, div [ class "column-25" ] [ viewBlock model center ] )
                , ( BlockId.toString right.id, div [ class "column-25" ] [ viewBlock model right ] )
                ]

        LandingPage.FourColumns25x25x25x25 left1 left2 right1 right2 ->
            viewContainerColumns container
                model
                [ ( BlockId.toString left1.id, div [ class "column-25" ] [ viewBlock model left1 ] )
                , ( BlockId.toString left2.id, div [ class "column-25" ] [ viewBlock model left2 ] )
                , ( BlockId.toString right1.id, div [ class "column-25" ] [ viewBlock model right1 ] )
                , ( BlockId.toString right2.id, div [ class "column-25" ] [ viewBlock model right2 ] )
                ]


viewContainerColumns : LandingPage.Container -> Model -> List ( String, Html Msg ) -> Html Msg
viewContainerColumns container model columns =
    div []
        [ Html.Keyed.node "div"
            [ class "container", id (ContainerId.toString container.id) ]
            (( "container-menu", viewContainerMenu container model.containerMenu ) :: columns)
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
            viewBlockPanelEditor "Editor de HTML"
                [ CodeMirror.editor html (SetBlockHtmlCode block.id)
                ]

        LandingPage.HtmlContent html ->
            viewBlockPanelEditor "Editor de texto"
                [ Trix.editor html (SetBlockHtmlContent block.id)
                ]

        LandingPage.YoutubeVideo url ->
            viewBlockPanelEditor "Vídeo do Youtube"
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

        LandingPage.Image url ->
            div [] [ text "Image" ]

        LandingPage.CallToAction url ->
            div [] [ text "Call to action" ]


viewBlockPanelEditor : String -> List (Html Msg) -> Html Msg
viewBlockPanelEditor title children =
    div [ class "block-editor-panel" ]
        [ div [ class "block-editor-panel-header" ]
            [ text title
            , div [ class "block-editor-panel-header-right" ]
                [ button [ class "netbuilder-button-link", onClick StopEditing ] [ text "Cancelar" ]
                , button [ class "netbuilder-button", onClick StopEditing ] [ text "Salvar" ]
                ]
            ]
        , div [ class "block-editor-panel-body" ] children
        ]


viewBlock : Model -> LandingPage.Block -> Html Msg
viewBlock model block =
    case block.layout of
        LandingPage.BlockPlaceholder ->
            viewBlockPlaceholder block.id

        LandingPage.HtmlCode html ->
            viewBlockContent model
                block
                [ Html.node "netbuilder-html-content" [ attribute "data-html" html ] []
                ]

        LandingPage.HtmlContent html ->
            viewBlockContent model
                block
                [ Html.node "netbuilder-html-content" [ attribute "data-html" html ] []
                ]

        LandingPage.YoutubeVideo url ->
            case Youtube.thumbnailUrl url of
                Just thumbnailUrl ->
                    viewBlockContent model
                        block
                        [ img [ src thumbnailUrl, class "youtube-preview-image" ] []
                        ]

                Nothing ->
                    viewBlockContent model
                        block
                        [ text "URL Inválida"
                        ]

        LandingPage.Image url ->
            viewBlockContent model
                block
                [ text "Image"
                ]

        LandingPage.CallToAction url ->
            viewBlockContent model
                block
                [ text "Call to action"
                ]


viewBlockContent : Model -> LandingPage.Block -> List (Html Msg) -> Html Msg
viewBlockContent model block children =
    let
        className =
            case model.selection of
                NothingSelected ->
                    "block-content"

                BlockSelected blockId ->
                    if blockId == block.id then
                        "block-content selected"

                    else
                        "block-content"
    in
    div [ class className, id (BlockId.toString block.id), onClick (SelectBlock block.id) ]
        [ viewBlockHoverOptions block.id
        , div [] children
        ]


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
