module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Debounce


type alias Model =
    { value : String
    , deb : Debounce.State
    }


type Msg
    = UserInput String
    | Deb (Debounce.Msg Msg)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


init =
    ( { value = "", deb = Debounce.init }, Cmd.none )


update msg model =
    case msg of
        UserInput s ->
            ( { model | value = s }, Cmd.none )

        Deb a ->
            Debounce.update cfg a model


view model =
    h1 []
        [ input [ onInput (deb1 UserInput) ] []
        , br []
            []
        , text
            ("Copy " ++ (model.value))
        ]


cfg =
    Debounce.config
        .deb
        (\model state -> { model | deb = state })
        Deb
        1000


deb1 =
    Debounce.debounce1 cfg
