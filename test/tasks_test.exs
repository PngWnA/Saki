defmodule Saki.TasksTest do
  use ExUnit.Case

  alias Saki.Tasks.TaskContext
  alias Saki.Tasks.Util
  alias Saki.Tasks.Ping
  alias Saki.Tasks.Clock

  describe "task registration" do
    test "ping task is registered" do
      tasks = Util.valid_tasks()
      assert Ping in tasks
    end

    test "clock task is registered" do
      tasks = Util.valid_tasks()
      assert Clock in tasks
    end

    test "ping task has correct cron schedule" do
      assert Ping.cron_schedule() == nil
    end

    test "clock task has correct cron schedule" do
      assert Clock.cron_schedule() == "* * * * *"
    end
  end

  describe "task dispatch" do
    test "ping task is dispatched for HTTP ping" do
      context = %TaskContext{
        request: %{from: :http, url: "/ping"}
      }

      assert Ping.should_handle?(context) == true
    end

    test "ping task is not dispatched for cron" do
      context = %TaskContext{
        request: %{from: :cron}
      }

      assert Ping.should_handle?(context) == false
    end

    test "clock task is dispatched for cron" do
      context = %TaskContext{
        request: %{from: :cron}
      }

      assert Clock.should_handle?(context) == true
    end

    test "clock task is not dispatched for HTTP" do
      context = %TaskContext{
        request: %{from: :http, url: "/anything"}
      }

      assert Clock.should_handle?(context) == false
    end
  end

  describe "task execution" do
    test "ping task executes successfully" do
      context = %TaskContext{
        request: %{from: :http, url: "/ping"}
      }

      assert {:ok, _updated_context} = Ping.execute(context)
    end

    test "clock task executes successfully" do
      context = %TaskContext{
        request: %{from: :cron}
      }

      assert {:ok, _updated_context} = Clock.execute(context)
    end
  end
end
