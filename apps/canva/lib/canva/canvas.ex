defmodule Canva.Canvas do
  @moduledoc """
  Describes drawing area and holds operations list
  """

  defstruct size: nil, empty_char: " ", operations: []

  alias Canva.Size
  alias Canva.AsciiChar
  alias Canva.Operation

  import Size

  @type t() :: %__MODULE__{
          size: Size.t(),
          operations: [Operation.t()],
          empty_char: AsciiChar.t()
        }

  @doc "Returns an empty canvas of given size"
  @spec build(Size.t()) :: t()
  def build(size) when valid_size(size), do: %__MODULE__{size: size}

  @doc "Adds operation"
  @spec add(t(), Operation.t()) :: t()
  def add(canvas, operation) do
    %{canvas | operations: canvas.operations ++ [operation]}
  end
end
