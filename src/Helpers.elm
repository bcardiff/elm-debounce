module Helpers
    exposing
        ( deferredCmd
        , deferredTask
        )

import Time exposing (Time)
import Task exposing (Task)
import Process


deferredCmd : Time -> a -> Cmd a
deferredCmd delay a =
    Task.perform (always a) (Process.sleep delay)


deferredTask : Time -> a -> Task Never a
deferredTask delay a =
    sleepSafe delay |> Task.andThen (always <| Task.succeed a)


sleepSafe : Time -> Task Never ()
sleepSafe =
    Process.sleep >> (Task.mapError never)
