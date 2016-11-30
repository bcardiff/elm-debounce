module Helpers
    exposing
        ( deferredCmd
        )

import Time exposing (Time)
import Task exposing (Task)
import Process


deferredCmd : Time -> a -> Cmd a
deferredCmd delay a =
    Task.perform (always a) (Process.sleep delay)


