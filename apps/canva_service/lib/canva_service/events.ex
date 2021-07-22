defmodule CanvaService.Events do
  @moduledoc """
  Events exchanger
  """

  defmodule Behaviour do
    @moduledoc false

    @type id :: String.t()

    @callback subscribe_on_canvas_events(id(), pid()) :: :ok

    @callback emit_canvas_updated(id()) :: :ok
  end

  defmodule PhoenixPubSub do
    @moduledoc false
    @behaviour Behaviour
    @name CanvaService.PubSub

    alias Phoenix.PubSub

    def subscribe_on_canvas_events(id, pid) do
      PubSub.subscribe(@name, topic(id), pid: pid)
    end

    def emit_canvas_updated(id) do
      PubSub.broadcast(@name, topic(id), {:canvas_updated, id})
    end

    defp topic(id) do
      "canvas:#{id}"
    end
  end

  @behaviour Behaviour
  @adapter Application.compile_env(:canva_service, :events_module, PhoenixPubSub)

  defdelegate subscribe_on_canvas_events(id, pid), to: @adapter
  defdelegate emit_canvas_updated(id), to: @adapter
end
