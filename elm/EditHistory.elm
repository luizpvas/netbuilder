module EditHistory exposing (EditHistory, empty, pop, push)

import Data.LandingPage exposing (LandingPage)


type alias EditHistory =
    List LandingPage


empty : EditHistory
empty =
    []


{-| We do some logic to prevent the same state being pushed twice.
-}
push : EditHistory -> LandingPage -> EditHistory
push history landingPage =
    case history of
        first :: rest ->
            if first == landingPage then
                first :: rest

            else
                landingPage :: first :: rest

        [] ->
            [ landingPage ]


pop : EditHistory -> ( Maybe LandingPage, EditHistory )
pop history =
    case history of
        latest :: rest ->
            ( Just latest, rest )

        [] ->
            ( Nothing, [] )
