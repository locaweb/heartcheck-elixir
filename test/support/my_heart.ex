defmodule MyHeart do
  @moduledoc false

  use HeartCheck, timeout: 1000

  add :redis do
    :ok
  end

  add "string_test" do
    :ok
  end

  add :failing do
    {:error, "I always fail"}
  end

  add :cas do
    {:error, "failed"}
  end

  firewall :domain_name, "http://doesnot.exist"

  firewall :domain_lazy, "http://doesnot.exist.acme", timeout: 10

  firewall localhost: Application.get_env(:heartcheck, :config)

  add :config_test do
    case Application.get_env(:heartcheck, :config) do
      "http://localhost" -> :ok
      other -> {:error, "unexpected value: #{inspect(other)}"}
    end
  end

  add :module, MyTestModule
end
