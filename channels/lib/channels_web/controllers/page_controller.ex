defmodule Elmix.ChannelsWeb.PageController do
  use Elmix.ChannelsWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
