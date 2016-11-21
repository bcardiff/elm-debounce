module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Debounce


type alias Model =
    { rawValue : String
    , value : String
    , deb : Debounce.State
    }


type Msg
    = RawInput String
    | UserInput String
    | Deb (Debounce.Msg Msg)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


init =
    ( { rawValue = "initial", value = "", deb = Debounce.init }, Cmd.none )


update msg model =
    case msg of
        RawInput s ->
            ( { model | rawValue = s }, debCmd <| UserInput s )

        UserInput s ->
            ( { model | value = s }, Cmd.none )

        Deb a ->
            Debounce.update cfg a model


view model =
    h1 []
        [ input [ onInput RawInput, value model.rawValue ] []
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


debCmd =
    Debounce.debounceCmd cfg
