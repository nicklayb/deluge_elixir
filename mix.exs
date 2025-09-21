defmodule Deluge.MixProject do
  use Mix.Project

  def project do
    [
      app: :deluge,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.5.15"}
    ]
  end
end
