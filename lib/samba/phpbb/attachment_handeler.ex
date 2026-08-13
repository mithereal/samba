defmodule PhpBB.AttachmentHandler do
  @doc """
  Saves an uploaded file to the local filesystem using a phpBB2-style obfuscated
  filename, creates the AttachmentDesc record, and links it via PhpBB.Attachment.
  """
  def create_attachment(upload_params, association_params, upload_dir \\ "priv/static/files") do
    File.mkdir_p!(upload_dir)

    original_filename = upload_params.filename
    tmp_path = upload_params.path
    file_size = file_size!(tmp_path)

    extension =
      original_filename
      |> Path.extname()
      |> String.trim_leading(".")
      |> String.downcase()

    mimetype = MIME.from_path(original_filename)

    physical_filename = generate_physical_filename(extension)
    destination_path = Path.join(upload_dir, physical_filename)

    case File.cp(tmp_path, destination_path) do
      :ok ->
        desc_attrs = %{
          physical_filename: physical_filename,
          real_filename: original_filename,
          filesize: file_size,
          filetime: System.system_time(:second),
          extension: extension,
          mimetype: mimetype,
          thumbnail: if(image_mimetype?(mimetype), do: 1, else: 0)
        }

        desc_changeset =
          Ash.Changeset.for_create(
            PhpBB.AttachmentDesc,
            :create,
            desc_attrs
          )

        case Ash.create(desc_changeset) do
          {:ok, desc} ->
            link_attrs =
              Map.put(association_params, :attach_id, desc.attach_id)

            link_changeset =
              Ash.Changeset.for_create(
                PhpBB.Attachment,
                :create,
                link_attrs
              )

            case Ash.create(link_changeset) do
              {:ok, _attachment} ->
                {:ok, desc}

              {:error, reason} ->
                {:error, reason}
            end

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, {:file_system_error, reason}}
    end
  end

  defp generate_physical_filename(extension) do
    random_hex =
      :crypto.strong_rand_bytes(8)
      |> Base.encode16(case: :lower)

    timestamp = System.system_time(:second)

    "#{timestamp}_#{random_hex}.#{extension}"
  end

  defp file_size!(path) do
    case File.stat(path) do
      {:ok, %File.Stat{size: size}} ->
        size

      {:error, _reason} ->
        0
    end
  end

  defp image_mimetype?(mimetype) do
    String.starts_with?(mimetype, "image/")
  end
end
