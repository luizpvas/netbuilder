port module Interop exposing (movingDownFinished, movingUpFinished, startMovingContainerDown, startMovingContainerUp)


port startMovingContainerUp : String -> Cmd msg


port startMovingContainerDown : String -> Cmd msg


port movingDownFinished : (Int -> msg) -> Sub msg


port movingUpFinished : (Int -> msg) -> Sub msg
