defmodule CanvaFiles.MemoryStorage do
  @moduledoc """
  Stores files in memory for testing purposes
  """

  @behaviour CanvaFiles.Behaviour

  @name :canva_files

  def init() do
    if :ets.info(@name) == :undefined do
      @name = :ets.new(@name, [:set, :public, :named_table])
    end

    :ok
  end

  def load_canvas_from_file(path) do
    :ets.lookup(@name, path)
    |> case do
      [{_, canvas}] -> {:ok, canvas}
      [] -> {:error, %CanvaFiles.Error{message: nil, reason: :enoent}}
    end
  end

  def save_canvas_to_file(canvas) do
    id = CanvaFiles.generate_id()
    true = :ets.insert(@name, {id, canvas})
    {:ok, id}
  end

  def list_canvas_files() do
    :ets.match(@name, {:"$0", :_})
    |> List.flatten()
    |> then(&{:ok, &1})
  end

  def remove_canvas_file(path) do
    true = :ets.delete(@name, path)
    :ok
  end
end
