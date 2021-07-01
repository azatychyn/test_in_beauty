defmodule InBeauty.UploadsPath do
  @moduledoc """
    Module provides creation uploads path by enviroment and saves it localy
  """

  def get_path, do: :in_beauty |> Application.get_env(:env) |> do_get_path()

  @spec do_get_path(atom()) :: Path.t()
  defp do_get_path(:prod),  do: :in_beauty |> Application.get_env(:upload_path)
  defp do_get_path(_env),   do: :in_beauty |> :code.priv_dir() |> Path.join('static/uploads')

  @spec insert_file(Path.t(), Path.t()) :: :ok | {:error, atom()}
  defp insert_file(temp_path, full_path) do
    full_path |> Path.dirname |> File.mkdir_p
    :ok = File.cp(temp_path, full_path)
  end

  @spec put_local(Image.t(), map()) :: {:ok, Path.t()}
  def put_local(%{id: id}, %{filename: name, path: temp_path}) do
    filename = "#{id}-#{name}"
    directory = "/uploads/images/"
    full_path = get_path() <> directory <> filename
    insert_file(temp_path, full_path)
    {:ok, directory <> filename}
  end

  @spec remove_local(map()) :: :ok | {:error, atom()}
  def remove_local(%{path: path}) do
    full_path = get_path() <> path
    File.rm(full_path)
  end
end
