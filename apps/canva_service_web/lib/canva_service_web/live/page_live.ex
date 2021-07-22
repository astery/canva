defmodule CanvaServiceWeb.PageLive do
  @moduledoc false

  @dialyzer [:no_return, :no_unused]

  use CanvaServiceWeb, :live_view

  alias CanvaServiceWeb.PageLive.Messages

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign_current_canvas(id)
     |> assign_canvases_ids()}
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_current_canvas(nil)
     |> assign_canvases_ids()}
  end

  @impl true
  def handle_event("generate", _params, socket) do
    CanvaService.generate_canvas()
    |> case do
      {:ok, id} ->
        {:noreply,
         socket
         |> assign_id_into_canvases_ids(id)
         |> assign_current_canvas(id)
         |> push_patch(to: Routes.page_path(socket, :show, id))}

      :error ->
        {:noreply,
         socket
         |> put_flash(:error, Messages.something_wrong())
         |> assign(canvases_ids: [])}
    end
  end

  @impl true
  def handle_params(unsigned_params, _uri, socket) do
    {:noreply, assign_current_canvas(socket, unsigned_params["id"])}
  end

  defp assign_canvases_ids(socket) do
    CanvaService.list_canvases()
    |> case do
      {:ok, ids} ->
        assign(socket, canvases_ids: ids)

      :error ->
        socket
        |> put_flash(:error, Messages.something_wrong())
        |> assign(canvases_ids: [])
    end
  end

  defp assign_current_canvas(socket, nil) do
    assign(
      socket,
      current_id: nil,
      current_ascii_image: nil,
      not_found?: socket.assigns.live_action == :show
    )
  end

  defp assign_current_canvas(socket, id) do
    CanvaService.show_canvas(id)
    |> case do
      {:ok, string} ->
        assign(
          socket,
          current_id: id,
          current_ascii_image: string,
          not_found?: false
        )

      {:error, :not_found} ->
        assign_current_canvas(socket, nil)

      :error ->
        socket
        |> put_flash(:error, Messages.something_wrong())
        |> assign_current_canvas(nil)
    end
  end

  defp assign_id_into_canvases_ids(socket, id) do
    canvases_ids = [id] ++ socket.assigns.canvases_ids
    assign(socket, canvases_ids: canvases_ids)
  end
end

defmodule CanvaServiceWeb.PageLive.Messages do
  @moduledoc false

  def not_found() do
    "Not found"
  end

  def no_canvases_present() do
    "No canvases present"
  end

  def something_wrong() do
    "Something wrong happened"
  end
end
