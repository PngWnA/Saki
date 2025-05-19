# Saki

Saki is a general purpose task handler.

## Setup

Start the application with `mix run --no-halt` or `iex -S mix`

## Scheduled Tasks

Scheduled tasks are managed by Oban using the Cron plugin. To add or modify scheduled tasks, edit the crontab configuration in `config/config.exs`.

## HTTP Tasks

HTTP tasks can be triggered by sending requests to the server running on port 31413.

# Dependencies
* Elixir
* Mix

# Development
## How to run?
```bash
mix run --no-halt
```

## How to add module?
* Add module under `lib/saki/tasks`, implementing with implementing `@behavior Saki.Tasks.TaskSpecification`
