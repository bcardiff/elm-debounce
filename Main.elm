module Main exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Debounce


type alias Model =
    { counter : Int }


type Msg
    = Clicked
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
    ( { counter = 0 }, Cmd.none )


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
    Debounce.config Deb 1000


deb =
    Debounce.debounce cfg
