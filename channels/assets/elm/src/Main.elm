module Main exposing (..)

import Phoenix
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel
import Json.Decode as Json
import Html exposing (Html, Attribute, text, div, h1, img, h2, button, input)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Html.Attributes exposing (src)


---- MODEL ----

webSocketUrl : String
webSocketUrl = "ws://localhost:4000/socket/websocket"

roomPath : String
roomPath = "room:"

type Stage
    = Login
    | Room

type alias Model =
    {
        channel :  Maybe (Channel.Channel Msg),
        stage: Stage,
        room : String
    }

initModel : Model
initModel = 
    {
        stage = Login,
        channel = Maybe.Nothing,
        room = ""
    }

init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



---- UPDATE ----

socket : Socket.Socket msg
socket = 
    Socket.init webSocketUrl

-- channel : Channel.Channel Msg
-- channel =
    -- Channel.init "room:lobby"
    -- |> Channel.on "new_msg" NewMsg

type Msg
    = NewMsg Json.Value
    | RoomInput String
    | Enter
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
      RoomInput roomName ->
        ({ model | room = roomName}, Cmd.none)
      Enter ->
        let
          connectedChannel = 
            Channel.init model.room 
            |> Channel.on "new_msg" NewMsg
        in
          ({ model | channel = Just connectedChannel}, Cmd.none)
      _ ->
        ( model, Cmd.none )


---- SUBS ----

subscriptions : Model -> Sub Msg
subscriptions model = 
    connectChannel model


connectChannel : Model -> Sub Msg
connectChannel model =
  case model.channel of
      Nothing ->
        Sub.none
      Just channel ->
          Phoenix.connect socket [channel]
          

---- VIEW ----

view : Model -> Html Msg
view model =
    div [] [
          loginForm model
        ]


loginForm : Model -> Html Msg
loginForm model = 
    Html.form 
        [ onSubmit Enter ]
        [ h2 [] [ text "Login" ]
        , input [ placeholder "Room name"
                 , onInput RoomInput
                 ] []
        , button [] [ text "Enter" ]
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
