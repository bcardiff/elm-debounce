module Debounce
    exposing
        ( Config
        , State
        , Msg
        , init
        , config
        , update
        , debounce
        , debounce1
        , debounceCmd
        )

{-| This module allows easy usage of debounced events from the view.

# Functions to create `deb` `deb1` `debCmd` nice helpers

@docs debounce
@docs debounce1
@docs debounceCmd

# Boilerplate functions

@docs init
@docs config
@docs update

# Opaque structures

@docs Config
@docs State
@docs Msg

-}

import Task
import Process
import Helpers


{-| Configuration of a debounce component.
A Config msg is represented by a message wrapper
and the desired timeout for the debounce.
-}
type Config model msg
    = Config (model -> State) (model -> State -> model) (Msg msg -> msg) Float


{-| State to be included in model.

    type alias Model = { ... , deb : Debounce.State }
    initialModel = { ... , deb = Debounce.init }
    -- you can choose any name for `deb`
-}
type State
    = State Int


{-| Initial state for the model.
-}
init : State
init =
    State 0


{-| Creates a configured debounce component.
-}
config : (model -> State) -> (model -> State -> model) -> (Msg msg -> msg) -> Float -> Config model msg
config getState updateState msg delay =
    Config getState updateState msg delay


{-| Messages to be wrapped.
-}
type Msg msg
    = Raw msg
    | Deferred Int msg


{-| Handle update messages for the debounce component.

    update : Msg -> Model -> (Model, Cmd Msg)
    update msg model =
        case msg of
            ...
            Clicked -> -- perform update for Clicked --
            ...
            Deb a ->
                Debounce.update cfg a model
-}
update : Config model msg -> Msg msg -> model -> ( model, Cmd msg )
update (Config getState updateState msg delay) deb_msg model =
    case deb_msg of
        Raw m ->
            let
                oldState =
                    (getState model)

                newIncarnation =
                    (incarnation oldState) + 1
            in
                ( (updateState model (setIncarnation oldState newIncarnation))
                , Helpers.deferredCmd delay (msg <| Deferred newIncarnation m)
                )

        Deferred i m ->
            let
                validIncarnation =
                    (incarnation (getState model)) == i
            in
                ( model
                , if validIncarnation then
                    (performMessage m)
                  else
                    Cmd.none
                )


{-| Helper function for Msg without parameters.

    view model = ... button [ onClick (deb Clicked) ] [ text "click me!" ] ...

    deb : Msg -> Msg
    deb = Debounce.debounce cfg
-}
debounce : Config model msg -> msg -> msg
debounce (Config _ _ msg delay) =
    (\raw_msg -> msg (Raw raw_msg))


{-| Helper function for Msg with 1 parameter.

    view model = ... input [ onInput (deb1 UserInput) ] [] ...

    deb1 : (a -> Msg) -> (a -> Msg)
    deb1 = Debounce.debounce1 cfg
-}
debounce1 : Config model msg -> (a -> msg) -> (a -> msg)
debounce1 (Config _ _ msg delay) =
    (\raw_msg a -> msg (Raw (raw_msg a)))


{-| Helper function for deboucing a Cmd.

    update msg model =
        case msg of
            ... s ... ->
                ( ... , debCmd <| UserInput s )

            UserInput s ->
                ( ... , Cmd.none )

            Deb a ->
                Debounce.update cfg a model

    debCmd =
        Debounce.debounceCmd cfg
-}
debounceCmd : Config model msg -> msg -> Cmd msg
debounceCmd cfg msg =
    performMessage <| debounce cfg msg


incarnation (State i) =
    i


setIncarnation (State _) i =
    State i


unreachable =
    (\_ -> Debug.crash "This failure cannot happen.")


performMessage : msg -> Cmd msg
performMessage msg =
    Task.perform (always msg) (Task.succeed never)
