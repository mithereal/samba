defmodule SambaWeb.UploadController do
  use SambaWeb, :controller

  def upload(conn, %{"file" => upload}) do
    # 1. Handle the upload (e.g., store in S3)
    # 2. Return the public URL
    json(conn, %{url: "https://my-bucket.s3.amazonaws.com/..."})
  end
end