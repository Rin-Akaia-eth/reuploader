defmodule Reuploader do
  @moduledoc """
  Reuploader keeps the contexts that define domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @tag :reuploader

  def env do
    Application.get_all_env(@tag)
  end

  def env(key) do
    Application.get_env(@tag, key)
  end
end
