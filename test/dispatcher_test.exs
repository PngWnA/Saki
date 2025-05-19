defmodule Saki.DispatcherTest do
  use ExUnit.Case

  alias Saki.Core.Dispatcher
  alias Saki.Tasks.TaskContext
  alias Saki.Tasks.Ping
  alias Saki.Tasks.Clock

  describe "dispatcher" do

    test "dispatcher has initialized tasks" do
      state = :sys.get_state(Dispatcher)
      assert is_list(state.tasks)
      assert length(state.tasks) > 0
    end

    test "dispatcher accepts ping task dispatch" do
      context = %TaskContext{
        request: %{from: :http, url: "/ping"},
        context: %{},
        log: %{}
      }

      # This primarily tests that dispatch doesn't crash
      assert :ok = Dispatcher.dispatch(context, [Ping])
    end

    test "dispatcher accepts clock task dispatch" do
      context = %TaskContext{
        request: %{from: :cron},
        context: %{},
        log: %{}
      }

      assert :ok = Dispatcher.dispatch(context, [Clock])
    end
  end
end
