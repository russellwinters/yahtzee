defmodule Ytz.MixProject do
  use Mix.Project

  def project do
    [
      app: :ytz,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Ytz.Application, []},
      extra_applications: [:logger, :inets]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:plug_cowboy, github: "elixir-plug/plug_cowboy", tag: "v2.6.0"},
      {:plug, github: "elixir-plug/plug", tag: "v1.14.0", override: true},
      {:plug_crypto, github: "elixir-plug/plug_crypto", tag: "v1.2.5", override: true},
      {:cowboy, github: "ninenines/cowboy", tag: "2.10.0", override: true},
      {:cowboy_telemetry, github: "beam-telemetry/cowboy_telemetry", tag: "v0.4.0", override: true},
      {:cowlib, github: "ninenines/cowlib", tag: "2.12.1", override: true},
      {:ranch, github: "ninenines/ranch", tag: "2.1.0", override: true},
      {:mime, github: "elixir-plug/mime", tag: "v2.0.3", override: true},
      {:telemetry, github: "beam-telemetry/telemetry", tag: "v1.2.1", override: true},
      {:jason, github: "michalmuskala/jason", tag: "v1.4.0"}
    ]
  end
end
