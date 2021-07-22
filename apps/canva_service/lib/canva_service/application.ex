defmodule CanvaService.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: CanvaService.PubSub}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CanvaService.Supervisor)
  end
end
