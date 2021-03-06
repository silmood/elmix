module Main exposing (..)

import Phoenix
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import Phoenix exposing (push)
import Json.Encode as Encode
import Json.Decode as Decode exposing (Decoder)
import Html exposing (Html, Attribute, text, div, h1, img, h2, button, input, ul, li)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit, onClick)
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
    , path : String
    , messages : List String
    }

type alias Model = 
    { channel :  Maybe (Channel.Channel Msg)
    , stage: Stage
    , room : Room
    , typedMsg : String
    }

initModel : Model
initModel = 
    { stage = Login
    , channel = Maybe.Nothing
    , room = { name = "", path = "", messages = [] }
    , typedMsg = ""
    }

init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )

goLogin : Model -> Model
goLogin model =
    setStage model Login
    |> clearMessages 


setStage: Model -> Stage -> Model
setStage model stg =
    { model | stage = stg }

clearMessages : Model -> Model
clearMessages model =
    { model | room = (setMessages model.room [])}

setMessages : Room -> List String -> Room
setMessages room msgs =
    { room | messages = msgs }



---- UPDATE ----

socket : Socket.Socket msg
socket = 
    Socket.init webSocketUrl

buildRoomChannel : String -> Channel.Channel Msg
buildRoomChannel room =
    Channel.init room
    |> Channel.withDebug
    |> Channel.on "new_msg" NewMsg
    |> Channel.onJoin Online

type Msg
    = RoomInput String
    | Online Encode.Value
    | Enter
    | Leave
    | SendMsg
    | TypeMsg String
    | NewMsg Decode.Value
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RoomInput roomName ->
            { model | room = (updateRoomPath roomName model.room)  } ! []

        Enter ->
            let
                connectedChannel = buildRoomChannel model.room.path
            in
                { model | channel = Just connectedChannel} ! []

        TypeMsg typed ->
            { model | typedMsg = typed } ! []

        SendMsg ->
            { model | typedMsg = ""} ! [ sendMsg model ]

        NewMsg payload ->
            { model | room = (appendMsg model.room payload) } ! []
        Online _ ->
            { model | stage = Chat} ! []

        Leave ->
            (goLogin model) ! [] 
        _ ->
            model ! []

updateRoomPath : String -> Room -> Room
updateRoomPath name room =
        { room | path = roomPath ++ name, name = name }

appendMsg : Room -> Decode.Value ->  Room
appendMsg room msg =
    case Decode.decodeValue decodeNewMsg msg of
        Ok msgReceived ->
            let
                messagesUpdated =
                    List.append room.messages [msgReceived]
            in
                { room | messages = messagesUpdated}
        Err err ->
            room


-- Decoder

decodeNewMsg : Decoder String
decodeNewMsg =
    Decode.field "msg" Decode.string

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

sendMsg : Model -> Cmd Msg
sendMsg model =
    let
        payload =
            Encode.object [("msg", Encode.string model.typedMsg)]

        message =
            Push.init model.room.path "new_msg"
            |> Push.withPayload payload
    in
        push webSocketUrl message



---- VIEW ----

view : Model -> Html Msg
view model =
    div []
        [
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
        [] 
        [ chatMessagesView model
        , chatForm model
        , button [ onClick Leave ] [ text "Leave" ]
        ]

chatMessagesView : Model -> Html Msg
chatMessagesView model =
    div
        []
        [ h2 [] [ text ("Welcome to " ++ model.room.name) ]
        , ul [] (List.map messageView model.room.messages)
        ]

chatForm : Model -> Html Msg
chatForm model =
    Html.form
        [ onSubmit SendMsg ]
        [ input 
            [ placeholder "Type message..."
            , value model.typedMsg
            , onInput TypeMsg ] 
            [] 
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
