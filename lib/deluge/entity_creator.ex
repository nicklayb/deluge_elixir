defmodule Deluge.EntityCreator do
  def create(structure, key_mapping, params, extra_keys \\ []) do
    attributes =
      case Map.keys(params) do
        [string | _] when is_binary(string) ->
          Enum.map(key_mapping, fn {atom_key, string_key} ->
            {atom_key, Map.get(params, string_key)}
          end)

        [atom | _] when is_binary(atom) ->
          Enum.map(key_mapping, fn {atom_key, _} -> {atom_key, Map.get(params, atom_key)} end)

        [] ->
          []
      end

    struct(structure, extra_keys ++ attributes)
  end
end
