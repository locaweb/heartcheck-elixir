defmodule HeartCheck.PlugTest do
  use ExUnit.Case

  @moduletag capture_log: true

  setup _tags do
    Application.ensure_all_started(:httpoison)
    Application.ensure_all_started(:cowboy)

    TestServer.start
  end

  test "it initializes the options" do
    assert %{} = HeartCheck.Plug.init([])
  end

  test "it serves the content as json", %{port: port} do
    assert {"content-type", "application/json"} = get_content_type(port, "/")
    assert {"content-type", "application/json"} = get_content_type(port, "/functional")
    assert {"content-type", "application/json"} = get_content_type(port, "/health_check")
  end

  test "it starts the server", %{port: port} do
    assert {:ok, _} = get_and_parse(port, "/")
  end

  test "it serves the regular test on /", %{port: port} do
    {:ok, body} = get_and_parse(port, "/")

    assert Enum.any? body, fn
      (%{"redis" => %{"status" => "ok"}}) -> true
      (_) -> false
    end
  end

  test "it serves the status: ok on /health_check", %{port: port} do
    assert {:ok, body} = get_and_parse(port, "/health_check")
    assert %{"status" => "ok"} = body
  end

  test "it returns 404 on other routes", %{port: port} do
    assert {:error, :not_found} = get_and_parse(port, "/api")
  end

  test "it dispatches even if functional is not set in initializing", %{port: port} do
    {:ok, %HTTPoison.Response{status_code: 200}} = HTTPoison.get("http://localhost:#{port}/non-functional/")
  end

  test "it returns 404 when funcional module is not set on /functional", %{port: port} do
    {:ok, %HTTPoison.Response{status_code: 404}} = HTTPoison.get("http://localhost:#{port}/non-functional/funcional/")
  end

  def get_content_type(port, path) do
    case HTTPoison.get("http://localhost:#{port}/monitoring#{path}") do
      {:ok, %HTTPoison.Response{headers: headers}} ->
        Enum.find headers, fn
          ({"content-type", _value}) -> true
          _ -> false
        end

      _ ->
        {:error, :unknown}
    end
  end

  def get_and_parse(port, path) do
    case HTTPoison.get("http://localhost:#{port}/monitoring#{path}") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode(body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}

      _ ->
        {:error, :unknown}
    end
  end
end
