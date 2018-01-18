defmodule Heartcheck.CachingPlugTest do
  use ExUnit.Case
  use Plug.Test

  import ExUnit.CaptureLog

  alias HeartCheck.CachingPlug

  @moduletag capture_log: true

  @opts CachingPlug.init(heartcheck: MyHeart, functional: MyFunctionalHeart)

  test "it initializes the options" do
    assert %{} = CachingPlug.init([])
  end

  test "it runs the heartcheck" do
    conn = CachingPlug.call(conn(:get, "/"), @opts)

    assert {:ok, content} = Poison.decode(conn.resp_body)

    assert Enum.any?(content, fn
             %{"redis" => %{"status" => "ok"}} -> true
             _ -> false
           end)
  end

  test "it runs only the requested check" do
    log =
      capture_log(fn ->
        CachingPlug.call(conn(:get, "/"), @opts)
      end)

    functional_log =
      capture_log(fn ->
        CachingPlug.call(conn(:get, "/functional"), @opts)
      end)

    # only in MyHeart
    assert log =~ ~r/redis/
    # only in MyFunctionalHeart
    refute log =~ ~r/memcached/

    # only in MyHeart
    refute functional_log =~ ~r/redis/
    # only in MyFunctionalHeart
    assert functional_log =~ ~r/memcached/
  end

  test "it runs the heartcheck only once" do
    log =
      capture_log(fn ->
        CachingPlug.call(conn(:get, "/"), @opts)
        CachingPlug.call(conn(:get, "/"), @opts)
      end)

    assert 1 ==
             ~r/(Performing cas)/m
             |> Regex.scan(log)
             |> length
  end
end
