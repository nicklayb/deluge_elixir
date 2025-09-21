defmodule Deluge.Client do
  alias Deluge.Client.FileTree
  alias Deluge.Client.Daemon
  alias Deluge.Client.Torrent
  alias Deluge.Session

  @default_headers [{"Content-Type", "application/json"}, {"Accept", "application/json"}]

  def login(%Session{password: password} = session) do
    session
    |> Session.clear_cookie()
    |> request("auth.login", [password])
    |> on_success(fn true, %{"set-cookie" => set_cookie} ->
      session_id = extract_cookie(set_cookie, "_session_id")
      {:ok, %Session{session | cookie: session_id}}
    end)
  end

  def get_daemons(%Session{} = session) do
    session
    |> request("web.get_hosts")
    |> on_success(fn [daemon_params | _], _ ->
      daemon = Daemon.new(daemon_params)
      {:ok, Session.put_daemon(session, daemon)}
    end)
  end

  def get_daemon(%Session{daemon: %Daemon{id: daemon_id}} = session) do
    session
    |> request("web.connect", [daemon_id])
    |> on_success(fn methods, _ ->
      {:ok, Session.map_daemon(session, &Daemon.put_methods(&1, methods))}
    end)
  end

  @keys Torrent.remote_keys()
  def get_torrents(session, filter \\ %{}) do
    session
    |> request("core.get_torrents_status", [filter, @keys])
    |> on_success(fn result, _ ->
      {:ok, Enum.map(result, fn {id, torrent_params} -> Torrent.new(id, torrent_params) end)}
    end)
  end

  def get_torrent_files(session, torrent_id) do
    session
    |> request("web.get_torrent_files", [torrent_id])
    |> on_success(fn result, _ ->
      {:ok, FileTree.new(result)}
    end)
  end

  def call_method(session, method, params \\ []) do
    session
    |> request(method, params)
    |> on_success(fn result, _ -> result end)
  end

  defp request(%Session{host: host} = session, method, params \\ []) do
    Req.post(
      base_url: host,
      url: "/json",
      json: %{id: 1, method: method, params: params},
      headers: with_cookie(session, @default_headers)
    )
  end

  defp with_cookie(%Session{cookie: nil}, headers), do: headers

  defp with_cookie(%Session{cookie: cookie}, headers),
    do: [
      {"Cookie", "_session_id=#{cookie}"} | headers
    ]

  defp extract_cookie(cookies, lookup_cookie) do
    Enum.reduce_while(cookies, nil, fn cookie_line, _ ->
      if String.starts_with?(cookie_line, lookup_cookie <> "=") do
        cookie_line
        |> String.split(";", parts: 2)
        |> List.first()
        |> String.replace(lookup_cookie <> "=", "")
        |> then(&{:halt, &1})
      else
        {:cont, nil}
      end
    end)
  end

  defp on_success(
         {:ok,
          %Req.Response{
            status: 200,
            body: %{"error" => nil, "result" => result},
            headers: headers
          }},
         function
       ) do
    function.(result, headers)
  end

  defp on_success({_, response}, _) do
    {:error, response}
  end
end
