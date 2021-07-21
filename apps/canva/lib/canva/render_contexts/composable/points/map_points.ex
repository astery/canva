defmodule Canva.RenderContexts.Composable.Points.MapPoints do
  @moduledoc """
  Points based on Map module.

  Stores {x, y} tuple as key and character as value.
  """

  defstruct map: %{}, size: nil

  alias Canva.RenderContexts.Composable.Points
  alias Canva.Size

  @type t() :: %__MODULE__{
          size: Size.t(),
          map: %{}
        }

  @doc """
  Returns empty map. Has nothing to preallocate.
  """
  @spec build(Size.t()) :: t()
  def build(size), do: %__MODULE__{size: size}

  defimpl Points do
    import Canva.Size

    def get(c, x, y) when out_of_bounds(c.size, x, y), do: :out_of_bounds
    def get(c, x, y), do: Map.get(c.map, {x, y})

    def set(c, x, y, _) when out_of_bounds(c.size, x, y), do: :out_of_bounds

    def set(c, x, y, char) do
      put_in(c, [Access.key!(:map), {x, y}], char)
    end
  end
end
