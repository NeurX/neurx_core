defmodule NeurxCore.MixProject do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :neurx_core,
      
      version: @version,
      elixir: "~> 1.6",
      deps: deps(),
      package: package(),
      
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,

      name: "neurx_core",
      docs: [source_ref: "v#{@version}", main: "NeurX"],
      source_url: "https://github.com/neurx/neurx_core",
      description: "
        NN library for Elixir
      ",

      preferred_cli_env: [
        "coveralls": :test,
        "coveralls.html": :test,
        "coveralls.json": :test,
      ],
      test_coverage: [tool: ExCoveralls],
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:excoveralls, "~> 0.8.2", only: :test},

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp package do
    [ 
      maintainers: [
        "Jakob Roberts",
        "Joshua Portelance",
        "Jim Galloway",
        "Claudia Li",
      ],
      licenses: ["MIT"],
      links: %{github: "https://github.com/neurx/neurx_core"},
    ]
  end
end
