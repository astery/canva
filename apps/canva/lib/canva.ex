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
    @moduledoc false
    @type t() :: String.t()
  end

  defmodule Operations do
    @moduledoc false

    defmodule Rectangle do
      @moduledoc """
      A rectangle parameterised with…
        - Coordinates for the **upper-left corner**.
        - **width** and **height**.
        - an optional **fill** character.
        - an optional **outline** character.
        - One of either **fill** or **outline** should always be present.

      Example:

      %Rectangle{x: 3, y: 2, size: size(5, 3), outline_char: "@", fill_char: "X"}

      ```

        @@@@@
        @XXX@
        @@@@@
      ```
      """

      defstruct ~w(x y size outline_char fill_char)a

      @type t() :: %__MODULE__{
              x: integer(),
              y: integer(),
              outline_char: AsciiChar.t(),
              fill_char: AsciiChar.t()
            }
    end

    defmodule Flood do
      @moduledoc """
      A flood fill operation, parameterised with…
        - the **start coordinates** from where to begin the flood fill.
        - a **fill** character.

      A flood fill operation draws the fill character to the start coordinate, and continues to attempt drawing the character around (up, down, left, right) in each direction from the position it was drawn at, as long as a different character, or a border of the canvas, is not reached.

      Example:

      %Flood{x: 0, y: 0, fill_char: "-"}

      ```
      --------------.......
      --------------.......
      --------------.......
      OOOOOOOO------.......
      O      O------.......
      O    XXXXX----.......
      OOOOOXXXXX-----------
           XXXXX-----------
      ````
      """

      defstruct ~w(x y fill_char)a

      @type t() :: %__MODULE__{
              x: integer(),
              y: integer(),
              fill_char: AsciiChar.t()
            }
    end
  end

  defmodule Operation do
    @moduledoc false

    alias Operations.Rectangle
    alias Operations.Flood

    @type t() :: Rectangle.t() | Flood.t()
  end

  defmodule Canvas do
    @moduledoc """
    Describes drawing area and holds operations list
    """

    defstruct size: nil, empty_char: " ", operations: []

    @type t() :: %__MODULE__{
            size: Size.t(),
            operations: [Operation.t()],
            empty_char: AsciiChar.t()
          }

    @doc "Returns an empty canvas of given size"
    @spec build(Size.t()) :: t()
    def build(size), do: %__MODULE__{size: size}

    @doc "Adds operation"
    @spec add(t(), Operation.t()) :: t()
    def add(canvas, operation) do
      %{canvas | operations: canvas.operations ++ [operation]}
    end
  end

  defprotocol RenderContext do
    @moduledoc """
    Represents intermediate render result.

    This protocol gives ability to have different
    rendering strategies.
    """

    @doc "Changes size of render area"
    @spec apply(t(), Size.t()) :: t()
    def set_size(renderer, size)

    @doc "Changes "
    @spec set_whitespace_char(t(), String.t()) :: t()
    def set_whitespace_char(renderer, char)

    @doc "Makes intermediate changes to show operation changes later at render stage"
    @spec apply(t(), Operation.t()) :: t()
    def apply(renderer, operation)

    @doc "Returns string representation"
    @spec render(t()) :: String.t()
    def render(renderer)
  end

  defmodule RenderableCanvas do
    @moduledoc """
    Combines canvas and render context
    """

    @type t() :: %__MODULE__{
            canvas: Canvas.t(),
            render_ctx: RenderContext.t()
          }

    defstruct ~w(canvas render_ctx)a

    @doc """
    Initializes render context with given canvas.

    And returns empty renderable canvas ready to apply operations.
    """
    @spec build(Canvas.t(), RenderContext.t()) :: t()
    def build(canvas, render_ctx) do
      render_ctx =
        render_ctx
        |> RenderContext.set_size(canvas.size)
        |> RenderContext.set_whitespace_char(canvas.empty_char)

      %__MODULE__{
        canvas: canvas,
        render_ctx: render_ctx
      }
    end

    @doc "Adds operation to canvas and apply it to render context"
    @spec add_and_apply(t(), Operation.t()) :: t()
    def add_and_apply(renderable_canvas, operation) do
      %{
        renderable_canvas
        | canvas: Canvas.add(renderable_canvas.canvas, operation),
          render_ctx: RenderContext.apply(renderable_canvas.render_ctx, operation)
      }
    end

    @doc "Returns string representation"
    @spec render(t()) :: String.t()
    def render(renderable_canvas) do
      RenderContext.render(renderable_canvas.render_ctx)
    end
  end

  defmodule RenderContextes do
    defmodule MapBased do
      @moduledoc """
      RenderContext based on Map module.
      """

      defstruct size: nil, map: %{}, empty_char: " "

      import Size

      @type t() :: %__MODULE__{
              size: Size.t(),
              map: %{},
              empty_char: AsciiChar.t()
            }

      @doc "Returns an empty canvas of given size"
      @spec build(Size.t()) :: t()
      def build(size), do: %__MODULE__{size: size}

      def get(c, x, y) when out_of_bounds(c.size, x, y), do: :out_of_bounds

      def get(c, x, y) do
        Map.get(c.map, {x, y})
      end

      def set(c, x, y, _) when out_of_bounds(c.size, x, y), do: :out_of_bounds

      def set(c, x, y, char) do
        put_in(c, [Access.key!(:map), {x, y}], char)
      end

      defimpl RenderContext do
        alias Canva.Operations.Rectangle
        alias Canva.Operations.Flood

        def set_size(renderer, size), do: %{renderer | size: size}

        def set_whitespace_char(renderer, char), do: %{renderer | empty_char: char}

        def apply(%MapBased{} = canvas, %Rectangle{} = rect) do
          left = rect.x
          top = rect.y
          right = rect.x + rect.size.width - 1
          bottom = rect.y + rect.size.height - 1
          fill_char = rect.fill_char
          outline_char = rect.outline_char || rect.fill_char

          for y <- top..bottom, x <- left..right, reduce: canvas do
            canvas ->
              inside? = y > top and y < bottom and x > left and x < right
              char = if(inside?, do: fill_char, else: outline_char)

              MapBased.set(canvas, x, y, char)
              |> case do
                :out_of_bounds -> canvas
                canvas -> canvas
              end
          end
        end

        def apply(%MapBased{} = canvas, %Flood{} = flood) do
          flood(canvas, flood.x, flood.y, flood.fill_char)
        end

        defp flood(canvas, x, y, fill_char) do
          MapBased.get(canvas, x, y)
          |> case do
            nil ->
              MapBased.set(canvas, x, y, fill_char)
              |> flood(x + 1, y, fill_char)
              |> flood(x - 1, y, fill_char)
              |> flood(x, y + 1, fill_char)
              |> flood(x, y - 1, fill_char)

            _ ->
              canvas
          end
        end

        def render(%MapBased{size: size} = canvas) do
          for y <- 0..(size.height - 1) do
            for x <- 0..(size.width - 1) do
              MapBased.get(canvas, x, y)
              |> case do
                nil -> canvas.empty_char
                char -> char
              end
            end ++ ["\n"]
          end
          |> IO.iodata_to_binary()
        end
      end
    end
  end

  @doc """
  Uses MapBased rendring strategy
  """
  def build_canvas(size),
    do: RenderableCanvas.build(Canvas.build(size), %RenderContextes.MapBased{})

  def apply_operations(canvas, operations),
    do: Enum.reduce(operations, canvas, &RenderableCanvas.add_and_apply(&2, &1))

  def render_canvas(canvas), do: RenderableCanvas.render(canvas)
end
