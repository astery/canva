defmodule CanvaFiles do
  @moduledoc """
  In this context canvas file is a file stored on disk
  """

  defmodule Error do
    @moduledoc """
    Represents any error related to files interaction
    """

    defexception message: nil, reason: nil
  end

  defmodule Behaviour do
    @moduledoc false

    @type path :: String.t()
    @type error :: {:error, %Error{reason: any()}}

    alias Canva.Canvas

    @doc """
    Performs start up preparations at application start
    """
    @callback init() :: :ok | error()

    @doc """
    Loads Canvas from file by file path
    """
    @callback load_canvas_from_file(path()) :: {:ok, Canvas.t()} | error()

    @doc """
    Returns saved Canvas path
    """
    @callback save_canvas_to_file(path(), Canvas.t()) :: :ok | error()

    @doc """
    List all available to load files
    """
    @callback list_canvas_files() :: {:ok, [path()]} | error()

    @doc """
    After removing Canvas is no longer appear in list
    and cannot be loaded
    """
    @callback remove_canvas_file(path) :: :ok | error()
  end

  @behaviour Behaviour
  @adapter Application.compile_env(:canva_files, :module, CanvaFiles.DiskStorage)

  def generate_id(), do: Nanoid.generate()
  def generate_id_alphabet(), do: Application.fetch_env!(:nanoid, :alphabet)

  defdelegate init(), to: @adapter
  defdelegate load_canvas_from_file(path), to: @adapter
  defdelegate save_canvas_to_file(path, canvas), to: @adapter
  defdelegate list_canvas_files(), to: @adapter
  defdelegate remove_canvas_file(path), to: @adapter

  def save_canvas_to_file(canvas) do
    id = generate_id()

    with :ok <- save_canvas_to_file(id, canvas) do
      {:ok, id}
    end
  end
end
