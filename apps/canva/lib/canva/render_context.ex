defprotocol Canva.RenderContext do
  @moduledoc """
  Represents intermediate render result.

  This protocol gives ability to have different
  rendering strategies.
  """

  alias Canva.Size
  alias Canva.Operation

  @doc "Changes size of render area"
  @spec set_size(t(), Size.t()) :: t()
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
