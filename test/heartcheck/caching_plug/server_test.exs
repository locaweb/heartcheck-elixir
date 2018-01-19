defmodule HeartCheck.CachingPlug.ServerTest do
  use ExUnit.Case

  alias HeartCheck.CachingPlug.Server

  @moduletag capture_log: true

  setup tags do
    {:ok, pid} =
      Server.start_link(
        MyHeart,
        tags[:ttl] || 300,
        Module.concat(__MODULE__, "Line#{tags[:line]}")
      )

    {:ok, pid: pid}
  end

  test "it has a result on startup", %{pid: pid} do
    assert "" != Server.fetch(pid)
  end

  test "it sets a last_run", %{pid: pid} do
    import DateTime, only: [utc_now: 0, to_unix: 1]

    last_run = Server.last_run(pid)

    assert nil != last_run
    assert to_unix(utc_now()) - to_unix(last_run) <= 1
  end

  test "it caches the run", %{pid: pid} do
    assert Server.fetch(pid) == Server.fetch(pid)
    assert Server.last_run(pid) == Server.last_run(pid)
  end

  @tag ttl: 10
  test "it runs again after the defined ttl", %{pid: pid} do
    first_run = Server.last_run(pid)
    :timer.sleep(20)
    second_run = Server.last_run(pid)

    assert first_run != second_run
  end
end
