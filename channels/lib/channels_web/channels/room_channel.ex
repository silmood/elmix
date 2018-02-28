defmodule Elmix.ChannelsWeb.RoomChannel do

  use Elmix.ChannelsWeb, :channel
  require Logger

  def join("room:" <> name, _, socket) do
    {:ok, socket}
  end


end