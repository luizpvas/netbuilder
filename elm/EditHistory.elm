module EditHistory exposing (EditHistory, empty, pop, push)

import Data.LandingPage exposing (LandingPage)


type alias EditHistory a =
    List a


empty : EditHistory a
empty =
    []


{-| We do some logic to prevent the same state being pushed twice.
-}
push : EditHistory a -> a -> EditHistory a
push history landingPage =
    case history of
        first :: rest ->
            if first == landingPage then
                first :: rest

            else
                landingPage :: first :: rest

        [] ->
            [ landingPage ]


pop : EditHistory a -> ( Maybe a, EditHistory a )
pop history =
    case history of
        latest :: rest ->
            ( Just latest, rest )

        [] ->
            ( Nothing, [] )
