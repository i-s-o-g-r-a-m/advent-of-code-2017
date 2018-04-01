module Main exposing (..)

import Html exposing (..)
import Input exposing (input)
import ProcessInput exposing (process)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { output : Int }


initialModel : Model
initialModel =
    { output = ProcessInput.process (Input.input) }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div [] [ text "The answer should be 5221: ", text (toString model.output) ]
