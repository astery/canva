defmodule Canva do
  @moduledoc """
  `Canva` is a main point of interaction with render functions of canvas.

  Canvas is stucture for describing canvas size, whitespace character,
  and holding operations history.

  You can `&add_operations/2` or `&add_and_apply_operations/2` operations to it,
  the difference is that the first one doesn't perform any computations
  related to rendering.

  When you call `&render_canvas/1` it will apply all operations if it was not done
  yet.

  ## Examples:

  iex> alias Canva.Size
  iex> alias Canva.Operations.Rectangle
  iex> canvas = Canva.build_canvas(%Size{width: 4, height: 5})
  iex> canvas = Canva.apply_operations(canvas, [
  ...>   %Rectangle{x: 0, y: 0, size: %Size{width: 4, height: 5}, outline_char: "."},
  ...>   %Rectangle{x: 1, y: 1, size: %Size{width: 3, height: 3}, outline_char: "@"}
  ...> ])
  iex> Canva.render_canvas(canvas)
  "....
  .@@@
  .@ @
  .@@@
  ....
  "

  RenderableCanvas is a wrapper for Canvas and its RenderContext it is created
  explicitly or implicitly when you apply operations to a canvas.

  If you want to specify render strategy explicitly, you use
  `build_renderable_context/2` function to build canvas and pass it to
  apply and render functions as usual.

  build_*_render_ctx functions define a strategy that will
  be used for rendering canvas.

  ## Examples:

  iex> alias Canva.Size
  iex> alias Canva.Operations.Rectangle
  iex> canvas = Canva.build_canvas(%Size{width: 4, height: 5})
  iex> strategy = Canva.build_composable_array_based_render_ctx()
  iex> canvas = Canva.build_renderable_canvas(canvas, strategy)
  iex> canvas = Canva.apply_operations(canvas, [
  ...>   %Rectangle{x: 0, y: 0, size: %Size{width: 4, height: 5}, outline_char: "."},
  ...>   %Rectangle{x: 1, y: 1, size: %Size{width: 3, height: 3}, outline_char: "@"}
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

    defguard valid_size(size)
             when size.width > 0 and size.height > 0
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
  alias Canva.RenderContext
  alias Canva.RenderContexts
  alias Canva.RenderContexts.Composable
  alias Canva.RenderContexts.Composable.Points.MapPoints
  alias Canva.RenderContexts.Composable.Points.ArrayPoints

  @doc """
  Creates Canvas struct

  Alias for &Canvas.build/1
  """
  def build_canvas(size), do: Canvas.build(size)

  @doc """
  Creates RenderableCanvas struct.

  Use it when you want to explicitly specify a rendering strategy
  instead of a default one.

  ## Params

  - canvas - is regular Canvas created by &build_canvas/& function
  - render_ctx - is RenderContext can be created by &build_*_render_ctx/& functions

  Alias for &Canvas.build/1
  """
  def build_renderable_canvas(canvas, render_ctx),
    do: RenderableCanvas.build(canvas, render_ctx)

  @doc """
  Creates RenderContext with specified rendering strategy

  Uses regular elixir map (Look for MapPoints module)
  """
  @spec build_composable_map_based_render_ctx() :: RenderContext.t()
  def build_composable_map_based_render_ctx() do
    RenderContexts.Composable.build(
      &MapPoints.build/1,
      &Composable.Algorithms.Rectangle.apply/2,
      &Composable.Algorithms.Flood.apply/2
    )
  end

  @doc """
  Creates RenderContext with specified rendering strategy

  Uses erlang :array (Look for ArrayPoints module)
  """
  @spec build_composable_array_based_render_ctx() :: RenderContext.t()
  def build_composable_array_based_render_ctx() do
    RenderContexts.Composable.build(
      &ArrayPoints.build/1,
      &Composable.Algorithms.Rectangle.apply/2,
      &Composable.Algorithms.Flood.apply/2
    )
  end

  @doc """
  Default render strategy to use then it not specified explicitly

  Alias for &build_composable_map_based_render_ctx/0
  """
  def build_default_render_strategy(), do: build_composable_map_based_render_ctx()

  @doc """
  Adds operations into regular Canvas.

  Use this function when you don't need to render this later.

  Look for &Canvas.add/2
  """
  @spec add_operations(Canvas.t(), [Operation.t()]) :: Canvas.t()
  def add_operations(%Canvas{} = canvas, operations),
    do: Enum.reduce(operations, canvas, &Canvas.add(&2, &1))

  @doc """
  Adds operations and calculates next RenderContext state.

  Converts regular Canvas into RenderableCanvas with default
  rendering strategy if need.

  Look for &RenderableCanvas.add_and_apply/2
  """
  @spec apply_operations(Canvas.t(), [Operation.t()]) :: RenderableCanvas.t()
  def apply_operations(%Canvas{} = canvas, operations) do
    build_renderable_canvas(canvas, build_default_render_strategy())
    |> apply_operations(operations)
  end

  @spec apply_operations(RenderableCanvas.t(), [Operation.t()]) :: RenderableCanvas.t()
  def apply_operations(%RenderableCanvas{} = canvas, operations),
    do: Enum.reduce(operations, canvas, &RenderableCanvas.add_and_apply(&2, &1))

  @doc """
  Returns string representation of canvas

  Converts regular Canvas into RenderableCanvas with default
  rendering strategy if need.
  """
  @spec render_canvas(Canvas.t()) :: String.t()
  def render_canvas(%Canvas{} = canvas) do
    build_renderable_canvas(canvas, build_default_render_strategy())
    |> render_canvas()
  end

  @spec render_canvas(RenderableCanvas.t()) :: String.t()
  def render_canvas(%RenderableCanvas{} = canvas), do: RenderableCanvas.render(canvas)
end
