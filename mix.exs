defmodule ExModbus.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_modbus,
     version: "0.0.3",
     elixir: ">= 1.0.0",
     description: "An Elixir ModbusTCP client implementation.",
     package: package(),
     deps: deps()]
  end

  def package do
    [maintainers: ["Falco Hirschenberger"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/hirschenberger/ex_modbus"}
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :nerves_uart]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:nerves_uart, git: "https://github.com/dhanson358/nerves_uart" },
     {:earmark, "~> 0.1.19", only: :dev},
     {:ex_doc, "~> 0.10", only: :dev},
     {:mix_test_watch, "~> 0.3", only: :dev, runtime: false}
   ]
  end
end
