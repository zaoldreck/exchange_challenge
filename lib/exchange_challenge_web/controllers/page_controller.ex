defmodule ExchangeChallengeWeb.PageController do
  use ExchangeChallengeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
