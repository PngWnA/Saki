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

  defp cal_ver do
    {{year, month, _}, _} = :calendar.local_time()
    cond do
      month in 1..9 -> "#{year}0#{month}"
      month in 10..12 -> "#{year}#{month}"
    end
  end

  defp git_ver do
    with {sha, 0} <- System.cmd("git", ["rev-parse", "--short", "HEAD"]) do
      sha |> String.trim
    end
  end
  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    []
  end
end
