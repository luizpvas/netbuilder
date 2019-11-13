module BlockId exposing (BlockId, fromInt, toString)


type BlockId
    = BlockId Int


fromInt : Int -> BlockId
fromInt id =
    BlockId id


toString : BlockId -> String
toString (BlockId id) =
    String.fromInt id
