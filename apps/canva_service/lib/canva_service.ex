defmodule CanvaService do
  @moduledoc """
  Responsible for providing user actions functions.

  Same actions as in Canva and CanvaFiles but combined and slightly
  different meaning, and with less scope.

  User actions are:

    - list canvases - same as the CanvaFiles module provides
    - create canvas - build a canvas, save it
    - add operation - load a canvas, add and apply an operation, save a canvas
    - generate random canvas - generate, save

  This is the place to handle user land errors.

  If user can do something with an error and error is meaningful for him,
  context function should return an error (for example: given bad name,
  item not found, etc.).

  If it is something cryptic, comprehendable only by site admins, it should be
  logged, function should return a dull :error tuple, and user should see
  generic error message (for example: vendor api failed by timeout,
  database not responded in time, unable to create a file because
  of insufficient rights, found in incosistent state, etc...)

  A good way to introduce caching is to have normal implementation without it
  and a wrapper module implementing same behaviour focused only on caching
  and delegating real actions to normal module.
  """

  defmodule Behaviour do
    @moduledoc false

    @type id :: String.t()
    @type operation :: %{}

    @doc """
    List all available canvases
    """
    @callback list_canvases() :: {:ok, [id]} | :error

    @doc """
    Creates an empty canvas
    """
    @callback create_canvas() :: {:ok, id} | :error

    @doc """
    Returns a canvas ascii image
    """
    @callback show_canvas(id) :: {:ok, String.t()} | {:error, :not_found} | :error

    @doc """
    Adds an operation
    """
    @callback add_operation(id, operation()) ::
                {:ok, id} | {:error, :not_found} | {:error, changeset :: %{}}

    @doc """
    Creates a random canvas
    """
    @callback generate_canvas() :: {:ok, id} | :error

    # It is optional until it will not be used in service
    @optional_callbacks create_canvas: 0, add_operation: 2
  end

  defmodule Impl do
    @moduledoc false

    @behaviour Behaviour

    @dialyzer :no_return

    require Logger

    def list_canvases() do
      CanvaFiles.list_canvas_files()
      |> case do
        {:ok, list} ->
          {:ok, list}

        {:error, e} ->
          Logger.error(Exception.message(e))
          :error
      end
    end

    def generate_canvas() do
      # canvas 100x100 with 1-30 operations
      canvas = Canva.Generators.canvas_generator(50..50, 50..50, 1..30) |> Enum.at(0)
      CanvaFiles.save_canvas_to_file(canvas)
    end

    def show_canvas(id) do
      CanvaFiles.load_canvas_from_file(id)
      |> case do
        {:ok, canvas} ->
          {:ok, Canva.render_canvas(canvas)}

        {:error, %{reason: :enoent}} ->
          {:error, :not_found}

        {:error, e} ->
          Logger.error(Exception.message(e))
          :error
      end
    end
  end

  @dialyzer :no_return

  @behaviour Behaviour
  @adapter Application.compile_env(:canva_service, :module, Impl)

  defdelegate list_canvases(), to: @adapter
  defdelegate generate_canvas(), to: @adapter
  defdelegate show_canvas(id), to: @adapter
end
