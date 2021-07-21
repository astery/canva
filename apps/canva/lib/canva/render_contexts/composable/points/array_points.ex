defmodule Canva.RenderContexts.Composable.Points.ArrayPoints do
  @moduledoc """
  Points based on :array module.

  Colums contain rows
  """

  defstruct columns: nil, size: nil

  alias Canva.RenderContexts.Composable.Points
  alias Canva.Size
  alias Canva.AsciiChar

  @type t() :: %__MODULE__{
          size: Size.t(),
          columns: :array.array(:array.array(AsciiChar.t() | nil))
        }

  @doc """
  Returns empty points. Allocates array of arrays.
  """
  @spec build(Size.t()) :: t()
  def build(size),
    do: %__MODULE__{
      size: size,
      columns: :array.new(size.width, default: :array.new(size.height, default: nil))
    }

  defimpl Points do
    import Canva.Size

    def get(c, x, y) when out_of_bounds(c.size, x, y), do: :out_of_bounds

    def get(c, x, y) do
      rows = :array.get(x, c.columns)
      :array.get(y, rows)
    end

    def set(c, x, y, _) when out_of_bounds(c.size, x, y), do: :out_of_bounds

    def set(c, x, y, char) do
      rows = :array.get(x, c.columns)
      rows = :array.set(y, char, rows)
      columns = :array.set(x, rows, c.columns)
      %{c | columns: columns}
    end
  end
end
