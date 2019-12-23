defmodule PhoenixprojectWeb.PageController do
  use PhoenixprojectWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
