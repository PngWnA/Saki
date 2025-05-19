defmodule Saki.CronSchedulerTest do
  use ExUnit.Case

  alias Saki.Core.CronScheduler
  alias Saki.Tasks.Clock

  describe "cron_scheduler" do
    test "scheduler initializes correctly" do
      # We can't easily test the actual scheduling in a unit test,
      # but we can test that the init function doesn't crash
      assert is_map(CronScheduler.init(%{}))
    end

    test "clock task has a valid cron schedule" do
      schedule = Clock.cron_schedule()
      assert is_binary(schedule)
      assert {:ok, _parsed} = Crontab.CronExpression.Parser.parse(schedule)
    end
  end
end
