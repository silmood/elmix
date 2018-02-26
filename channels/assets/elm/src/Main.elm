module Main exposing (..)

import Phoenix
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel
import Json.Decode as Json
import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src)


---- MODEL ----


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )



---- UPDATE ----

socket : Socket.Socket msg
socket = 
    Socket.init "ws://localhost:4000/socket/websocket"

channel : Channel.Channel Msg
channel =
    Channel.init "room:lobby"
    |> Channel.on "new_msg" NewMsg

type Msg
    = NewMsg Json.Value
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


---- SUBS ----

subscriptions : Model -> Sub Msg
subscriptions model = 
    Phoenix.connect socket [channel]



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/images/logo.svg" ] []
        , h1 [] [ text "Your Elm App is working!" ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
