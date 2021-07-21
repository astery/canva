defmodule Canva.RenderableCanvas do
  @moduledoc """
  Combines canvas and render context
  """

  alias Canva.RenderContext
  alias Canva.Canvas
  alias Canva.Operation

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
      |> then(fn render_ctx ->
        Enum.reduce(canvas.operations, render_ctx, &RenderContext.apply/2)
      end)

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
