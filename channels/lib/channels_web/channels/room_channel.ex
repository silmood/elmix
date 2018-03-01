defmodule Elmix.ChannelsWeb.RoomChannel do

  use Elmix.ChannelsWeb, :channel
  require Logger

  def join("room:" <> name, _, socket) do
    {:ok, socket}
  end

  def handle_in("new_msg", %{"msg" => msg}, socket) do
    Logger.info "Message: #{inspect(msg)}"
    broadcast! socket, "new_msg", %{msg: msg}
    {:reply, :ok, socket}
  end

end