defmodule Deluge.Client.Daemon do
  defstruct [:id, :host, :port, :username, methods: :not_loaded]

  alias Deluge.Client.Daemon

  def new([id, host, port, username | _]) do
    %Daemon{id: id, host: host, port: port, username: username}
  end

  def put_methods(%Daemon{} = host, methods) do
    %Daemon{host | methods: methods}
  end
end
