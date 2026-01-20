defmodule FileSniffer do
  @signature_map %{
    "exe" => %{media_type: "application/octet-stream", signature: <<0x7F, 0x45, 0x4C, 0x46>>},
    "bmp" => %{media_type: "image/bmp", signature: <<0x42, 0x4D>>},
    "png" => %{
      media_type: "image/png",
      signature: <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>
    },
    "jpg" => %{media_type: "image/jpg", signature: <<0xFF, 0xD8, 0xFF>>},
    "gif" => %{media_type: "image/gif", signature: <<0x47, 0x49, 0x46>>}
  }

  def type_from_extension(extension) do
    file_type = @signature_map[extension]
    if file_type, do: file_type.media_type, else: nil
  end

  def type_from_binary(file_binary) do
    Enum.find_value(@signature_map, fn {_, v} ->
      sig = v.signature

      if match?(<<^sig::binary, _rest::binary>>, file_binary) do
        v.media_type
      else
        nil
      end
    end)
  end

  def verify(file_binary, extension) do
    extension_type = type_from_extension(extension)
    matches = type_from_binary(file_binary) == extension_type

    if matches and extension_type do
      {:ok, extension_type}
    else
      {:error, "Warning, file format and file extension do not match."}
    end
  end
end
