defmodule Canva.Operations.Rectangle do
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

  alias Canva.AsciiChar

  @type t() :: %__MODULE__{
          x: integer(),
          y: integer(),
          outline_char: AsciiChar.t(),
          fill_char: AsciiChar.t()
        }
end
