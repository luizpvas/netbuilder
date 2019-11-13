module Icon exposing (arrowDown, arrowUp, callToAction, edit, htmlCode, htmlContent, image, more, remove, spacing, styling, youtube)

import Svg exposing (..)
import Svg.Attributes exposing (..)


htmlContent : Svg msg
htmlContent =
    svg [ viewBox "0 0 480 420", Svg.Attributes.style "width: 40px;" ] [ Svg.path [ fill "#CBD5E0", d "M180 60h60v30h60V0H0v90h60V60h60v300H60v60h180v-60h-60V60z" ] [], Svg.path [ fill "#CBD5E0", d "M240 150v90h60v-30h30v150h-30v60h120v-60h-30V210h30v30h60v-90H240z" ] [] ]


htmlCode : Svg msg
htmlCode =
    svg [ viewBox "0 0 401 551", Svg.Attributes.style "width: 35px;" ] [ Svg.path [ fill "#CBD5E0", d "M400 132l-2-7L291 4a11 11 0 00-5-4H22C10 0 1 10 1 22v507c0 12 9 22 21 22h357c12 0 21-10 21-22V133v-1zM22 22h250v110c0 6 5 11 11 11h96v224H22V22zm83 477H84v-41H48v41H26v-98h22v38h36v-38h21v98zm86-80h-26v80h-22v-80h-26v-18h74v18zm93 80l-1-37-1-41-11 38-12 39h-17l-10-38-9-39-1 41-2 37h-20l6-98h29l9 33 8 35h1l9-36 10-32h28l6 98h-22zm98 0h-60v-98h22v80h38v18z" ] [], Svg.path [ fill "#CBD5E0", d "M79 249l83 39v-19l-63-27 63-28v-18l-83 38v15zM175 294h17l37-125h-17l-37 125zM239 214l64 28-64 27v19l83-38v-16l-83-38v18z" ] [] ]


youtube : Svg msg
youtube =
    svg [ viewBox "0 0 512 359", Svg.Attributes.style "width: 50px;" ] [ Svg.path [ fill "#CBD5E0", fillRule "evenodd", d "M456 11c22 6 40 23 45 45 11 40 11 124 11 124s0 83-11 123c-5 22-23 39-45 45-40 10-200 10-200 10s-160 0-200-10c-22-6-40-24-45-46C0 263 0 179 0 179S0 96 11 56c5-22 23-40 45-45C96 0 256 0 256 0s160 0 200 11zM338 179l-133 77V102l133 77z", clipRule "evenodd" ] [] ]


image : Svg msg
image =
    svg [ viewBox "0 0 316 250", Svg.Attributes.style "width: 50px;" ] [ Svg.path [ fill "#CBD5E0", d "M311 0H5C2 0 0 3 0 5v239c0 3 2 5 5 5h306c2 0 5-2 5-5V5c0-2-3-5-5-5zm-25 209l-69-71h-3l-48 42-61-75-1-1-2 1-72 97V30h256v179z" ] [], Svg.path [ fill "#CBD5E0", d "M210 103a25 25 0 100-50 25 25 0 000 50z" ] [] ]


callToAction : Svg msg
callToAction =
    svg [ viewBox "0 0 306 146", Svg.Attributes.style "width: 70px;" ] [ Svg.path [ fill "#CBD5E0", d "M96.4 47.8h30.4C123 19.8 98.3 0 66.3 0 28.8 0 0 27 0 73 0 118 27 146 66.9 146c35.7 0 61.3-22.7 61.3-60v-18H68.9v22.6h30.4C99 108.1 87 119.3 67 119.3c-22.5 0-36.6-16.8-36.6-46.5 0-29.5 14.7-46.2 36.3-46.2 15.5 0 26 8 29.7 21.2zM198.1 146c32.2 0 52.3-22.1 52.3-55 0-33-20-55-52.3-55-32.2 0-52.3 22-52.3 55 0 32.9 20 55 52.3 55zm.1-22.9c-14.8 0-22.4-13.6-22.4-32.2s7.6-32.3 22.4-32.3c14.6 0 22.2 13.7 22.2 32.3 0 18.6-7.6 32.2-22.2 32.2zM304.8 2H274l2.7 99.4h25.4l2.7-99.5zm-15.4 143.7c8.9 0 16.5-7.4 16.6-16.6 0-9.1-7.7-16.5-16.6-16.5a16.6 16.6 0 100 33.1z" ] [] ]


edit : Svg msg
edit =
    svg [ viewBox "0 0 20 20", Svg.Attributes.style "width: 20px;" ] [ Svg.path [ d "M2 4v14h14v-6l2-2v10H0V2h10L8 4H2zm10.3-.3l4 4L8 16H4v-4l8.3-8.3zm1.4-1.4L16 0l4 4-2.3 2.3-4-4z" ] [] ]


remove : Svg msg
remove =
    svg [ viewBox "0 0 20 20", Svg.Attributes.style "width: 22px;" ] [ Svg.path [ d "M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z" ] [] ]


more : Svg msg
more =
    svg [ viewBox "0 0 20 20", Svg.Attributes.style "width: 20px;" ] [ Svg.path [ d "M4 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm6 0a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm6 0a2 2 0 1 1 0-4 2 2 0 0 1 0 4z" ] [] ]


arrowUp : Svg msg
arrowUp =
    svg [ viewBox "0 0 20 20", Svg.Attributes.style "width: 20px;" ] [ Svg.path [ d "M9 3.828L2.929 9.899 1.515 8.485 10 0l.707.707 7.778 7.778-1.414 1.414L11 3.828V20H9V3.828z" ] [] ]


arrowDown : Svg msg
arrowDown =
    svg [ viewBox "0 0 20 20", Svg.Attributes.style "width: 20px;" ] [ polygon [ points "9 16.172 2.929 10.101 1.515 11.515 10 20 10.707 19.293 18.485 11.515 17.071 10.101 11 16.172 11 0 9 0" ] [] ]


spacing : Svg msg
spacing =
    svg [ viewBox "0 0 20 20", Svg.Attributes.style "width: 20px;" ] [ Svg.path [ d "M2 19H1V1h18v18H2zm1-2h14V3H3v14zm10-8h2v2h-2V9zM9 9h2v2H9V9zM5 9h2v2H5V9zm4-4h2v2H9V5zm0 8h2v2H9v-2z" ] [] ]


styling : Svg msg
styling =
    svg [ viewBox "0 0 20 20", Svg.Attributes.style "width: 20px;" ] [ Svg.path [ d "M9 20v-1.7l.01-.24L15.07 12h2.94c1.1 0 1.99.89 1.99 2v4a2 2 0 0 1-2 2H9zm0-3.34V5.34l2.08-2.07a1.99 1.99 0 0 1 2.82 0l2.83 2.83a2 2 0 0 1 0 2.82L9 16.66zM0 1.99C0 .9.89 0 2 0h4a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V2zM4 17a1 1 0 1 0 0-2 1 1 0 0 0 0 2z" ] [] ]
