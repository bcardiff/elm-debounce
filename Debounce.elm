module Debounce exposing (Config, State, Msg, init, config, update, debounce, debounce1)

import Task
import Process


-- a Config msg is represented by a message wrapper and the desired timeout for the debounce


type Config model msg
    = Config (model -> State) (model -> State -> model) (Msg msg -> msg) Float


type alias State =
    { incarnation : Int }


type Msg msg
    = Raw msg
    | Deferred Int msg


init : State
init =
    { incarnation = 0 }


config : (model -> State) -> (model -> State -> model) -> (Msg msg -> msg) -> Float -> Config model msg
config getState updateState msg delay =
    Config getState updateState msg delay


update : Config model msg -> Msg msg -> model -> ( model, Cmd msg )
update (Config getState updateState msg delay) deb_msg model =
    case deb_msg of
        Raw m ->
            let
                oldState =
                    (getState model)

                newIncarnation =
                    oldState.incarnation + 1

                deferredTask =
                    ((Process.sleep delay) `Task.andThen` (always (Task.succeed (msg <| Deferred newIncarnation m))))
            in
                ( (updateState model { oldState | incarnation = newIncarnation })
                , (Task.perform unreachable identity deferredTask)
                )

        Deferred incarnation m ->
            let
                validIncarnation =
                    (getState model).incarnation == incarnation
            in
                ( model
                , if validIncarnation then
                    (performMessage m)
                  else
                    Cmd.none
                )


debounce (Config _ _ msg delay) =
    (\raw_msg -> msg (Raw raw_msg))


debounce1 (Config _ _ msg delay) =
    (\raw_msg a -> msg (Raw (raw_msg a)))



-- http://faq.elm-community.org/17.html#how-do-i-generate-a-new-message-as-a-command


unreachable =
    (\_ -> Debug.crash "This failure cannot happen.")


performMessage msg =
    Task.perform unreachable identity (Task.succeed msg)
