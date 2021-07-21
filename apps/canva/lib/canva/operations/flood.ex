defmodule Canva.Operations.Flood do
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

  alias Canva.AsciiChar

  @type t() :: %__MODULE__{
          x: integer(),
          y: integer(),
          fill_char: AsciiChar.t()
        }
end
