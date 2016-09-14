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
    | Deb Msg


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
            deb_update a model


view model =
    h1 []
        [ text ("Counter " ++ (toString model.counter))
        , button [ onClick (deb Clicked) ] [ text "inc" ]
        ]


cfg =
    Debounce.config Deb 200


deb =
    Debounce.debounce cfg


deb_update =
    Debounce.update cfg
