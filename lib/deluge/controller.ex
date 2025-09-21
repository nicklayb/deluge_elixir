defmodule Deluge.Controller do
  use GenServer

  require Logger

  alias Deluge.Client
  alias Deluge.Session

  @default_name __MODULE__
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: Keyword.get(args, :name, @default_name))
  end

  def init(args) do
    session = Session.init(args)
    {:ok, %{session: session}, {:continue, :login}}
  end

  def get_torrents(pid \\ @default_name) do
    GenServer.call(pid, :get_torrents)
  end

  def get_torrent_files(pid \\ @default_name, torrent_id) do
    GenServer.call(pid, {:get_torrent_files, torrent_id})
  end

  def handle_continue(:login, %{session: session} = state) do
    with {:ok, %Session{} = session} <- Client.login(session),
         {:ok, %Session{} = session} <- Client.get_daemons(session),
         {:ok, %Session{} = session} <- Client.get_daemon(session) do
      Logger.info("[#{inspect(__MODULE__)}] Authenticated")
      {:noreply, Map.put(state, :session, session)}
    else
      error ->
        Logger.error("[#{inspect(__MODULE__)}] #{inspect(error)}")
        {:noreply, session}
    end
  end

  def handle_call(:get_torrents, _, %{session: session} = state) do
    response = Client.get_torrents(session)
    {:reply, response, state}
  end

  def handle_call({:get_torrent_files, torrent_id}, _, %{session: session} = state) do
    response = Client.get_torrent_files(session, torrent_id)
    {:reply, response, state}
  end
end
