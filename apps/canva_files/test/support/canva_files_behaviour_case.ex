defmodule CanvaFiles.BehaviourCase do
  @moduledoc """
  Tests implementation if it complies to CanvaFiles.Behaviour
  """
  use ExUnit.CaseTemplate

  using opts do
    impl = opts[:implementation]

    quote do
      import Canva.Generators

      alias unquote(impl), as: Behaviour
      alias CanvaFiles.Error

      setup_all do
        Behaviour.init()
      end

      test "saved canvas should be same as loaded" do
        canvas = build_canvas()
        id = CanvaFiles.generate_id()

        :ok = Behaviour.save_canvas_to_file(id, canvas)
        assert {:ok, [id]} == Behaviour.list_canvas_files()
        assert {:ok, canvas} == Behaviour.load_canvas_from_file(id)

        assert :ok = Behaviour.remove_canvas_file(id)
        assert {:ok, []} == Behaviour.list_canvas_files()
      end

      test "returns :enoent reason if not existed" do
        not_existing_id = CanvaFiles.generate_id()

        assert {:error, %Error{reason: :enoent}} ==
                 Behaviour.load_canvas_from_file(not_existing_id)
      end

      defp build_canvas() do
        canvas_generator(1..100, 1..100, 0..100)
        |> Enum.at(0)
      end
    end
  end
end
