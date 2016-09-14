module Main exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Debounce


type alias Model =
    { counterA : Int
    , counterB : Int
    , deb : Debounce.State
    }


type Msg
    = ClickedA
    | ClickedB
    | Deb (Debounce.Msg Msg)


main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


init =
    ( { counterA = 0, counterB = 0, deb = Debounce.init }, Cmd.none )


update msg model =
    case msg of
        ClickedA ->
            ( { model | counterA = model.counterA + 1 }, Cmd.none )

        ClickedB ->
            ( { model | counterB = model.counterB + 1 }, Cmd.none )

        Deb a ->
            Debounce.update cfg a model


view model =
    h1 []
        [ text ("CounterA: " ++ (toString model.counterA) ++ " CounterB: " ++ (toString model.counterB))
        , button [ onClick (deb ClickedA) ] [ text "inc A" ]
        , button [ onClick (deb ClickedB) ] [ text "inc B" ]
        ]


cfg =
    Debounce.config
        .deb
        (\model state -> { model | deb = state })
        Deb
        1000


deb =
    Debounce.debounce cfg
