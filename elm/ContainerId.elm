module ContainerId exposing (ContainerId, fromInt, toString)


type ContainerId
    = ContainerId Int


fromInt : Int -> ContainerId
fromInt id =
    ContainerId id


toString : ContainerId -> String
toString (ContainerId id) =
    String.fromInt id
