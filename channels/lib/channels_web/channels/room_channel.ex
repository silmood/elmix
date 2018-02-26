defmodule Elmix.ChannelsWeb.RoomChannel do

  use Elmix.ChannelsWeb, :channel
  require Logger

  def join("room:lobby", _, socket) do
    {:ok, socket}
  end


end