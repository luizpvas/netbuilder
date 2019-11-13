module Data.ColorTheme exposing (ColorTheme, montalcino)


type alias ColorTheme =
    { primary : String
    , primaryText : String
    , secondary : String
    , secondaryText : String
    }


montalcino : ColorTheme
montalcino =
    { primary = "red"
    , primaryText = "white"
    , secondary = "gray"
    , secondaryText = "black"
    }
