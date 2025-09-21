defmodule Deluge.Client.FileTree do
  defmodule File do
    alias Deluge.EntityCreator

    @keys [
      :index,
      :offset,
      :path,
      :priority,
      :progress,
      :size
    ]
    @key_mapping Enum.map(@keys, &{&1, to_string(&1)})
    defstruct [:name] ++ @keys

    def new(name, params) do
      EntityCreator.create(File, @key_mapping, params, name: name)
    end
  end

  defmodule Folder do
    defstruct [:name, :content]
  end

  def new(%{"contents" => _, "type" => "dir"} = root_dir) do
    new({"/", root_dir})
  end

  def new({name, %{"contents" => content, "type" => "dir"}}) do
    content =
      Enum.reduce(content, [], fn item, acc ->
        [new(item) | acc]
      end)

    %Folder{name: name, content: content}
  end

  def new({name, %{"type" => "file"} = params}) do
    File.new(name, params)
  end
end
