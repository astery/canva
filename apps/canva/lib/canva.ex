defmodule Canva do
  @moduledoc """
  `Canva` is main point to interact with render functions of canvas

  ## Examples:

  iex> alias Canva.Size
  iex> alias Canva.Operations.Rectangle
  iex> canvas = Canva.build_canvas(%Size{width: 4, height: 5})
  iex> canvas = Canva.apply_operations(canvas, [
  ...>   %Rectangle{
  ...>     x: 0,
  ...>     y: 0,
  ...>     size: %Size{width: 4, height: 5},
  ...>     fill_char: "."
  ...>   },
  ...>   %Rectangle{
  ...>     x: 1,
  ...>     y: 1,
  ...>     size: %Size{width: 3, height: 3},
  ...>     outline_char: "@"
  ...>   }
  ...> ])
  iex> Canva.render_canvas(canvas)
  "....
  .@@@
  .@ @
  .@@@
  ....
  "
  """

  defmodule Size do
    @moduledoc false
    defstruct width: 0, height: 0

    @type t() :: %__MODULE__{width: integer(), height: integer()}

    defguard out_of_bounds(size, x, y)
             when x < 0 or x >= size.width or
                    y < 0 or y >= size.height
  end

  defmodule AsciiChar do
    @moduledoc """
    We assume that only ascii chars will be used.
    But do not enforce that anythere, so any utf symbol is valid.
    """

    @type t() :: String.t()
  end

  defmodule Operation do
    @moduledoc """
    Operation is a struct that describe changes to make
    on canvas.

    This particular module stores type descriptions.

    Operations used by Canvas and RenderContexts.
    """

    alias Canva.Operations.Rectangle
    alias Canva.Operations.Flood

    @type t() :: Rectangle.t() | Flood.t()
  end

  alias Canva.Canvas
  alias Canva.RenderableCanvas
  alias Canva.RenderContexts
  alias Canva.RenderContexts.Composable
  alias Canva.RenderContexts.Composable.Points.MapPoints
  alias Canva.RenderContexts.Composable.Points.ArrayPoints

  @doc """
  Uses ArrayPoints rendering strategy
  """
  @spec build_array_based_canvas(Size.t()) :: RenderableCanvas.t()
  def build_array_based_canvas(size),
    do:
      RenderableCanvas.build(
        Canvas.build(size),
        RenderContexts.Composable.build(
          size,
          &ArrayPoints.build/1,
          &Composable.Algorithms.Rectangle.apply/2,
          &Composable.Algorithms.Flood.apply/2
        )
      )

  @doc """
  Uses MapPoints rendering strategy
  """
  @spec build_map_based_canvas(Size.t()) :: RenderableCanvas.t()
  def build_map_based_canvas(size),
    do:
      RenderableCanvas.build(
        Canvas.build(size),
        RenderContexts.Composable.build(
          size,
          &MapPoints.build/1,
          &Composable.Algorithms.Rectangle.apply/2,
          &Composable.Algorithms.Flood.apply/2
        )
      )

  @doc """
  Default canvas builder (uses &build_map_based_canvas/1)
  """
  def build_canvas(size), do: build_map_based_canvas(size)

  @doc """
  Look for &RenderableCanvas.add_and_apply/2
  """
  @spec apply_operations(RenderableCanvas.t(), [Operation.t()]) :: RenderableCanvas.t()
  def apply_operations(canvas, operations),
    do: Enum.reduce(operations, canvas, &RenderableCanvas.add_and_apply(&2, &1))

  @doc """
  Returns string representation of canvas
  """
  @spec render_canvas(RenderableCanvas.t()) :: String.t()
  def render_canvas(canvas), do: RenderableCanvas.render(canvas)
end
