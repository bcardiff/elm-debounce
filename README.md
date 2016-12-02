# elm-debounce [![][badge-doc]][doc] ![][badge-license]

[badge-doc]: https://img.shields.io/badge/documentation-latest-yellow.svg?style=flat-square
[doc]: http://package.elm-lang.org/packages/bcardiff/elm-debounce/latest
[badge-license]: https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square

This module enables debouncing events from the view.

## Story

Say you have an elm app where a button produce a `Clicked` message:

```elm
type alias Model = { ... }
type Msg = Clicked | ...

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ...
        Clicked -> -- perform update for Clicked
        ...

view model = ... button [ onClick Clicked ] [ text "click me!" ] ...
```

With this module you will be able to change the view using a `deb : Msg -> Msg`
function that will state that the `Clicked` message should be debounced.

```elm
view model = ... button [ onClick (deb Clicked) ] [ text "click me!" ] ...
```

You will want to specify the timeout for the debounce.
This is usually constant, hence, it does not belong to the model or state of the app.

```elm
cfg : Debounce.Config Model Msg
cfg = ... configuration of the debounce component ...

deb : Msg -> Msg
deb = Debounce.debounce cfg
```

In order to create a Debounce.Config you will need to go trough some boilerplate.

1) Extend the model with `Debounce.State` (and initialize it with `Debounce.init`)

```elm
type alias Model = { ... , d : Debounce.State }
initialModel = { ... , d = Debounce.init }
-- you can choose any name for `d`
```

2) Extend Msg with a wrapper message that will be routed to the Debounce module.

```elm
type Msg = Clicked | Deb (Debounce.Msg Msg)
-- you can choose any name for `Deb`
```

3) Extend `update`

```elm
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ...
        Clicked -> -- perform update for Clicked --
        ...
        Deb a ->
            Debounce.update cfg a model
```

4) Configure the debounce component with a record of type `Debounce.Config`

```elm
cfg : Debounce.Config Model Msg
cfg =
    Debounce.config
        .d                               -- getState   : Model -> Debounce.State
        (\model s -> { model | d = s })  -- setState   : Model -> Debounce.State -> Debounce.State
        Deb                              -- msgWrapper : Msg a -> Msg
        200                              -- timeout ms : Float
```

5) Enjoy!

## Debouncing messages with values (onInput)

If the message that is wanted to be debounced hold data:

```elm
type Msg = UserInput String
view model = ... input [ onInput UserInput ] [] ...
```

You will need to use `Debounce.debounce1`

```elm
view model = ... input [ onInput (deb1 UserInput) ] [] ...

deb1 : (a -> Msg) -> (a -> Msg)
deb1 = Debounce.debounce1 cfg
```

## Debouncing messages from the update

If you want to debounce a message generated from the `update`:

```elm
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
```

## Complete examples

Complete example files can be found in the examples folder.
To run the examples:

```shell
$ cd examples
$ elm-reactor
open http://localhost:8000/
```
