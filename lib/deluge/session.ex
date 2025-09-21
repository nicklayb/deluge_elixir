defmodule Deluge.Session do
  defstruct [:cookie, :host, :password, daemon: :not_loaded]

  alias Deluge.Session
  alias Deluge.Client.Daemon

  def init(args) do
    host = Keyword.fetch!(args, :host)
    password = Keyword.fetch!(args, :password)

    %Session{
      password: password,
      host: host
    }
  end

  def put_cookie(%Session{} = state, cookie) do
    %Session{state | cookie: cookie}
  end

  def clear_cookie(%Session{} = session) do
    %Session{session | cookie: nil}
  end

  def put_daemon(%Session{} = session, %Daemon{} = daemon) do
    %Session{session | daemon: daemon}
  end

  def map_daemon(%Session{daemon: daemon} = session, function) do
    %Session{session | daemon: function.(daemon)}
  end
end
