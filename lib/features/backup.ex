defmodule Reuploader.Backup do
  def is_media_url?(uri_map),
    do: uri_map.scheme != nil and String.contains?(uri_map.path, ["jpg", "jpeg", "mp4"])

  def downloadFx(file_uri, cache_location, destination_uri) do
    File.mkdir_p!(cache_location)
    # %HTTPoison.Response{body: body} = HTTPoison.get!(file_uri)
    # File.write!(Path.join(cache_location, file_name_from_response), body)

    {:ok, :saved_to_file} =
      :httpc.request(:get, {to_charlist(file_uri), []}, [], stream: to_charlist(cache_location))

    # Downloaded ${index} file of ${total}
    IO.puts(file_uri)
    {file_uri, destination_uri}
  end

  def entity_fork(data, cache_location, destination_uri) do
    only_mutable =
      Map.filter(data, fn {_key, value} ->
        is_bitstring(value) and URI.parse(value) |> is_media_url?
      end)

    Map.keys(only_mutable)
    |> Enum.each(fn selected_key ->
      Map.get_and_update!(only_mutable, selected_key, fn selected_value ->
        downloadFx(
          selected_value,
          Path.join(cache_location, data["pubDate"]),
          Enum.join([destination_uri, data["pubDate"]], "/")
        )
      end)
    end)

    # URI.parse() |> Map.get :path |> String.split("/")[0] # <- file_name
  end

  def main(options) do
    %{
      cache_location: cache_location,
      dataset_file: dataset_file,
      destination_uri: destination_uri
    } = Enum.into(options, %{})

    with {:ok, body} <- File.read(dataset_file),
         {:ok, json} <- Poison.decode(body),
         do:
           json
           |> Enum.map(fn data -> entity_fork(data, cache_location, destination_uri) end)
           |> Poison.encode!()
           |> File.write!(Path.join(cache_location, "dataset.json"))
  end

  def start do
    main(Reuploader.env())
  end
end
