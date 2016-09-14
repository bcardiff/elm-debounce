module Debounce exposing (Config, config, update, debounce)

import Task


type Config msg
    = Config (msg -> msg) Int


config : (msg -> msg) -> Int -> Config msg
config msg delay =
    Config msg delay


update (Config msg delay) =
    (\raw_msg model -> ( model, performMessage raw_msg ))


debounce (Config msg delay) =
    (\raw_msg -> msg raw_msg)



-- http://faq.elm-community.org/17.html#how-do-i-generate-a-new-message-as-a-command


performMessage msg =
    Task.perform (\_ -> Debug.crash "This failure cannot happen.") identity (Task.succeed msg)



--debounce :: (a -> a) -> Time -> a -> a
