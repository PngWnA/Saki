defmodule Saki.MixProject do
  use Mix.Project

  def project do
    [
      app: :saki,
      # headVer를 변형하여 사용합니다.
      # 즉, Mix project의 semantic versioning 제약을 무시합니다.
      # https://techblog.lycorp.co.jp/ko/headver-new-versioning-system-for-product-teams
      version: "#{head_ver()}.#{cal_ver()}.#{git_ver()}",
      description: "Saki-Chan",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # 해당 버전값만 수정합니다.
  defp head_ver do
    1
  end

  # 릴리즈시의 연월
  defp cal_ver do
    {{year, month, _}, _} = :calendar.universal_time()

    with short_year <- rem(year, 100) do
      cond do
        month in 1..9 -> "#{short_year}0#{month}"
        month in 10..12 -> "#{short_year}#{month}"
      end
    end
  end

  # 커밋 버전
  # semantic version으로 인식되도록 하기 위하여 git commit id를 10진수로 변환하여 표현합니다.
  defp git_ver do
    with {sha, 0} <- System.cmd("git", ["rev-parse", "--short", "HEAD"]) do
      sha
        |> String.trim()
        |> String.to_integer(16)
    end
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Saki.Application, []},
      extra_applications: [:logger]
    ]
  end

  # 의존성을 정의합니다.
  defp deps do
    [
      {:plug_cowboy, "~> 2.6"},
      {:jason, "~> 1.4"},
      {:oban, "~> 2.16"},
      {:ecto_sql, "~> 3.10"},
      {:ecto_sqlite3, "~> 0.12"},
      {:uuid, "~> 1.1"},
      # Development dependencies
      {:mix_test_watch, "~> 1.1", only: [:dev, :test], runtime: false},
      {:reloader, "~> 0.1", only: :dev}
    ]
  end
end
