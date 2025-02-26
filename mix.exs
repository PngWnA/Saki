defmodule Saki.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      # headVer를 변형하여 사용합니다.
      # https://techblog.lycorp.co.jp/ko/headver-new-versioning-system-for-product-teams
      version: "#{head_ver()}.#{cal_ver()}.#{git_ver()}",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # 해당 버전을 수정합니다.
  defp head_ver do
    1
  end

  # 릴리즈시의 연월
  defp cal_ver do
    {{year, month, _}, _} = :calendar.local_time()
    with short_year <- rem(year, 100) do
      cond do
        month in 1..9 -> "#{short_year}0#{month}"
        month in 10..12 -> "#{short_year}#{month}"
      end
    end
  end

  # 커밋 버전
  defp git_ver do
    with {sha, 0} <- System.cmd("git", ["rev-parse", "--short", "HEAD"]) do
      sha |> String.trim
    end
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Saki.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
