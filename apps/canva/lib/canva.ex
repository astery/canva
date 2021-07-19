defmodule Canva do
  @moduledoc """
  Documentation for `Canva`.
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

  defprotocol Canvas do
    @moduledoc """
    Drawing space area to apply drawing operations
    """

    @doc "Changes canvas state"
    @spec apply(t(), Operation.t()) :: t()
    def apply(canvas, operation)

    @doc "Returns string representation"
    @spec render(t()) :: String.t()
    def render(canvas)
  end

  defmodule MapCanvas do
    @moduledoc """
    Canvas based on Map
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

    defimpl Canvas do
      alias Canva.Operations.Rectangle
      alias Canva.Operations.Flood

      def apply(%MapCanvas{} = canvas, %Rectangle{} = rect) do
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

            MapCanvas.set(canvas, x, y, char)
            |> case do
              :out_of_bounds -> canvas
              canvas -> canvas
            end
        end
      end

      def apply(%MapCanvas{} = canvas, %Flood{} = flood) do
        flood(canvas, flood.x, flood.y, flood.fill_char)
      end

      defp flood(canvas, x, y, fill_char) do
        MapCanvas.get(canvas, x, y)
        |> case do
          nil ->
            MapCanvas.set(canvas, x, y, fill_char)
            |> flood(x + 1, y, fill_char)
            |> flood(x - 1, y, fill_char)
            |> flood(x, y + 1, fill_char)
            |> flood(x, y - 1, fill_char)

          _ ->
            canvas
        end
      end

      def render(%MapCanvas{size: size} = canvas) do
        for y <- 0..(size.height - 1) do
          for x <- 0..(size.width - 1) do
            MapCanvas.get(canvas, x, y)
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

  def build_canvas(size), do: MapCanvas.build(size)

  def apply_operations(canvas, operations),
    do: Enum.reduce(operations, canvas, &Canvas.apply(&2, &1))

  def render_canvas(canvas), do: Canvas.render(canvas)
end
