defmodule CanvaFiles.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :ok = CanvaFiles.init()

    children = []
    opts = [strategy: :one_for_one, name: CanvaFiles.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
