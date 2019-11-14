port module Interop exposing (ctrlZPressed, movingDownFinished, movingUpFinished, startMovingContainerDown, startMovingContainerUp)

-- Global shortcuts


port ctrlZPressed : (() -> msg) -> Sub msg



-- Moving animation


port startMovingContainerUp : String -> Cmd msg


port startMovingContainerDown : String -> Cmd msg


port movingDownFinished : (Int -> msg) -> Sub msg


port movingUpFinished : (Int -> msg) -> Sub msg
