module Debounce exposing (Config, Msg, config, update, debounce)

import Task
import Process


-- a Config msg is represented by a message wrapper and the desired timeout for the debounce


type Config msg
    = Config (Msg msg -> msg) Float


type Msg msg
    = Raw msg



--| Debounced msg


config : (Msg msg -> msg) -> Float -> Config msg
config msg delay =
    Config msg delay


update : Config msg -> Msg msg -> model -> ( model, Cmd msg )
update (Config msg delay) deb_msg model =
    case deb_msg of
        Raw m ->
            ( model
            , Task.perform unreachable
                identity
                ((Process.sleep delay) `Task.andThen` (always (Task.succeed m)))
            )



--Debounced m ->
--    ( model, performMessage m )


debounce (Config msg delay) =
    (\raw_msg -> msg (Raw raw_msg))



-- http://faq.elm-community.org/17.html#how-do-i-generate-a-new-message-as-a-command


unreachable =
    (\_ -> Debug.crash "This failure cannot happen.")


performMessage msg =
    Task.perform unreachable identity (Task.succeed msg)



--debounce :: (a -> a) -> Time -> a -> a
