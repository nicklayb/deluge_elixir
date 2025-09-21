defmodule Deluge.Client.Torrent do
  @keys [
    :queue,
    :name,
    :total_wanted,
    :state,
    :progress,
    :num_seeds,
    :total_seeds,
    :num_peers,
    :total_peers,
    :download_payload_rate,
    :upload_payload_rate,
    :eta,
    :ratio,
    :distributed_copies,
    :is_auto_managed,
    :time_added,
    :tracker_host,
    :download_location,
    :last_seen_complete,
    :total_done,
    :total_uploaded,
    :max_download_speed,
    :max_upload_speed,
    :seeds_peers_ratio,
    :total_remaining,
    :completed_time,
    :time_since_transfer,
    :label
  ]

  defstruct [:id | @keys]

  alias Deluge.EntityCreator
  alias Deluge.Client.Torrent

  @remote_keys Enum.map(@keys, &to_string/1)
  @key_mapping Enum.map(@keys, &{&1, to_string(&1)})
  def remote_keys, do: @remote_keys

  def new(id, map) do
    EntityCreator.create(Torrent, @key_mapping, map, id: id)
  end
end
