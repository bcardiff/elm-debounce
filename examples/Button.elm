module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Debounce


type alias Model =
    { counter : Int
    , deb : Debounce.State
    }


type Msg
    = Clicked
    | Deb (Debounce.Msg Msg)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


init =
    ( { counter = 0, deb = Debounce.init }, Cmd.none )


update msg model =
    case msg of
        Clicked ->
            ( { model | counter = model.counter + 1 }, Cmd.none )

        Deb a ->
            Debounce.update cfg a model


view model =
    h1 []
        [ text ("Counter " ++ (toString model.counter))
        , button [ onClick (deb Clicked) ] [ text "inc" ]
        ]


cfg =
    Debounce.config
        .deb
        (\model state -> { model | deb = state })
        Deb
        1000


deb =
    Debounce.debounce cfg
