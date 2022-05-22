import Config

config :reuploader,
       System.argv()
       |> OptionParser.parse(
         strict: [
           cache_location: :string,
           dataset_file: :string,
           destination_uri: :string
         ]
       )
       |> Tuple.to_list()
       |> List.first()
       |> List.insert_at(0, {:app_tag, :reuploader})
