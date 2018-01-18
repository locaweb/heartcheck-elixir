defmodule HeartCheck.FormatterTest do
  use ExUnit.Case

  alias HeartCheck.Formatter

  @success {:test, {1000, :ok}}
  @error {:test, {1000, {:error, "failed"}}}

  describe "format/1" do
    test "it converts the tuple result to a status => ok map on success" do
      assert %{test: %{status: :ok}} = Formatter.format(@success)
    end

    test "it converts the nanoseconds to milliseconds on success" do
      assert %{time: 1.0} = Formatter.format(@success)
    end

    test "it handles unknown errors" do
      error = {:test, {1000, :error}}

      assert %{test: %{status: :error, message: [%{type: :error, message: "UNKNOWN ERROR"}]}} =
               Formatter.format(error)
    end

    test "it converts {:error, reason} to a map on error" do
      assert %{test: %{status: :error, message: [%{type: :error, message: "failed"}]}} =
               Formatter.format(@error)
    end

    test "it converts time from nanoseconds to milliseconds on error" do
      assert %{time: 1.0} = Formatter.format(@error)
    end
  end
end
