defmodule CanvaFiles.DiskStorage do
  @moduledoc """
  Simple files behaviour implementation that saves files on disk

  It uses :erlang.binary_to_term/1, so if storage location is
  can be modified by untrusted entities, we should avoid that
  location or change convertation method (json, protobuf, etc.)
  """

  @behaviour CanvaFiles.Behaviour

  alias CanvaFiles.Error

  def init() do
    File.mkdir_p!(storage_dir())
    :ok
  end

  def load_canvas_from_file(id) do
    id
    |> file_path()
    |> File.read()
    |> case do
      {:ok, contents} -> {:ok, :erlang.binary_to_term(contents)}
      {:error, reason} -> {:error, %Error{reason: reason}}
    end
  end

  def save_canvas_to_file(id, canvas) do
    id
    |> file_path()
    |> File.write(:erlang.term_to_binary(canvas))
    |> case do
      :ok -> :ok
      {:error, reason} -> {:error, %Error{reason: reason}}
    end
  end

  def list_canvas_files() do
    storage_dir()
    |> File.ls()
    |> case do
      {:ok, list} -> {:ok, list}
      {:error, reason} -> {:error, %Error{reason: reason}}
    end
  end

  def remove_canvas_file(id) do
    id
    |> file_path()
    |> File.rm()
    |> case do
      :ok -> :ok
      {:error, reason} -> {:error, %Error{reason: reason}}
    end
  end

  def clear_storage() do
    Path.join(storage_dir(), "*")
    |> Path.wildcard()
    |> Enum.each(fn file -> :ok = File.rm(file) end)
  end

  defp file_path(id) do
    Path.join(storage_dir(), sanitize(id))
  end

  # contains alphanumeric, underscore and dash
  defp sanitize(id) do
    allowed = CanvaFiles.generate_id_alphabet()
    String.replace(id, ~r/[^#{allowed}]/, "")
  end

  defp storage_dir() do
    Application.get_env(:canva_files, DiskStorage)
    |> Access.get(:storage_dir, "/tmp/canva_files")
  end
end
