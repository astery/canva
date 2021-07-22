defmodule CanvaServiceWeb.PageLiveTest do
  use CanvaServiceWeb.ConnCase

  import Hammox
  import Phoenix.LiveViewTest
  import CanvaServiceWeb.PageLive.Messages

  setup :verify_on_exit!

  test "should show a message if no canvases present", %{conn: conn} do
    CanvaServiceMock
    |> expect(:list_canvases, 2, fn -> {:ok, []} end)

    {:ok, page_live, disconnected_html} = live(conn, "/")

    assert disconnected_html =~ no_canvases_present()
    assert render(page_live) =~ no_canvases_present()
  end

  test "should list a canvases ids if available", %{conn: conn} do
    canvases_ids =
      Stream.repeatedly(&CanvaFiles.generate_id/0)
      |> Enum.take(:rand.uniform(20))

    CanvaServiceMock
    |> expect(:list_canvases, 2, fn -> {:ok, canvases_ids} end)

    {:ok, page_live, disconnected_html} = live(conn, "/")

    refute disconnected_html =~ no_canvases_present()
    refute render(page_live) =~ no_canvases_present()

    for id <- canvases_ids do
      assert disconnected_html =~ id
      assert render(page_live) =~ id
    end
  end

  test "should show new canvas if generate button clicked", %{conn: conn} do
    canvas_id = CanvaFiles.generate_id()

    canvas_string = """
    ***
    * *
    ***
    """

    CanvaServiceMock
    |> expect(:list_canvases, 2, fn -> {:ok, []} end)
    |> expect(:generate_canvas, fn -> {:ok, canvas_id} end)
    |> expect(:show_canvas, 2, fn ^canvas_id -> {:ok, canvas_string} end)

    {:ok, view, _} = live(conn, "/")

    assert view
           |> element("button#generate")
           |> render_click() =~ canvas_string
  end

  test "should show canvas if exists", %{conn: conn} do
    canvas_id = CanvaFiles.generate_id()

    canvas_string = """
    ***
    * *
    ***
    """

    CanvaServiceMock
    |> expect(:list_canvases, 2, fn -> {:ok, []} end)
    |> expect(:show_canvas, 4, fn ^canvas_id -> {:ok, canvas_string} end)

    {:ok, page_live, disconnected_html} = live(conn, "/" <> canvas_id)

    assert disconnected_html =~ canvas_string
    assert render(page_live) =~ canvas_string
  end

  test "should show error if not exists", %{conn: conn} do
    canvas_id = CanvaFiles.generate_id()

    CanvaServiceMock
    |> expect(:list_canvases, 2, fn -> {:ok, []} end)
    |> expect(:show_canvas, 4, fn ^canvas_id -> {:error, :not_found} end)

    {:ok, page_live, disconnected_html} = live(conn, "/" <> canvas_id)

    assert disconnected_html =~ not_found()
    assert render(page_live) =~ not_found()
  end

  test "should change canvas if link clicked", %{conn: conn} do
    canvas_id = CanvaFiles.generate_id()
    canvas_string = "current"

    CanvaServiceMock
    |> expect(:list_canvases, 2, fn -> {:ok, [canvas_id]} end)
    |> expect(:show_canvas, 1, fn ^canvas_id -> {:ok, canvas_string} end)

    {:ok, view, _} = live(conn, "/")

    assert view
           |> element(".canvas-link[data-id='#{canvas_id}']")
           |> render_click() =~ canvas_string
  end

  test "should update if canvas changed", %{conn: conn} do
    canvas_id = CanvaFiles.generate_id()
    canvas_string = "current"

    CanvaServiceMock
    |> expect(:list_canvases, 2, fn -> {:ok, [canvas_id]} end)
    |> expect(:show_canvas, 4, fn ^canvas_id -> {:ok, canvas_string} end)

    {:ok, view, _} = live(conn, "/" <> canvas_id)

    new_canvas_string = "updated"

    CanvaServiceMock
    |> expect(:show_canvas, 2, fn ^canvas_id -> {:ok, new_canvas_string} end)

    CanvaService.Events.emit_canvas_updated(canvas_id)

    html = view |> render()

    assert html =~ new_canvas_string
    refute html =~ canvas_string
  end
end
