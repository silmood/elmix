module Main exposing (..)

import Phoenix
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel
import Json.Decode as Json
import Html exposing (Html, Attribute, text, div, h1, img, h2, button, input, ul, li)
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
    | Chat

type alias Room = 
    { name : String
    , messages : List String
    }

type alias Model = 
    { channel :  Maybe (Channel.Channel Msg)
    , stage: Stage
    , room : Room
    }

initModel : Model
initModel = 
    { stage = Login
    , channel = Maybe.Nothing
    , room = { name = "", messages = [] }
    }

init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



---- UPDATE ----

socket : Socket.Socket msg
socket = 
    Socket.init webSocketUrl

buildRoomChannel : String -> Channel.Channel Msg
buildRoomChannel room =
    Channel.init room
    |> Channel.onJoin Online

type Msg
    = RoomInput String
    | Online Json.Value
    | Enter
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RoomInput roomName ->
            let
                oldRoom = model.room
                updatedRoom =
                    { oldRoom | name = roomPath ++ roomName }
            in
                ({ model | room = updatedRoom }, Cmd.none)
        Enter ->
            let
                connectedChannel = buildRoomChannel model.room.name
            in
                ({ model | channel = Just connectedChannel}, Cmd.none)
        Online _ ->
            ({ model | stage = Chat}, Cmd.none)
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
          case model.stage of
              Login ->
                loginForm model
              Chat ->
                chatView model
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

chatView : Model -> Html Msg
chatView model =
    div 
      [ -- Attributes
      ] 
      [ chatMessagesView model
      , chatForm model
      ]

chatMessagesView : Model -> Html Msg
chatMessagesView model =
    div
      [
      ]
      [ ul [] (List.map messageView model.room.messages)
      ]

chatForm : Model -> Html Msg
chatForm model =
    Html.form
      [
      ]
      [ input [ placeholder "Type message..." ] [] 
      , button [] [ text "Send" ]
      ]

messageView : String -> Html Msg
messageView message =
    li [] [ text message ]


---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
