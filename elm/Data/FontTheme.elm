module Data.FontTheme exposing (FontTheme, systemSansSerif)


type alias FontTheme =
    { primary : String
    , secondary : String
    }


systemSansSerif : FontTheme
systemSansSerif =
    { primary = "arial"
    , secondary = "sans-serif"
    }
