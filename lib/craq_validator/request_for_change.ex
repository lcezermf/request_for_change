defmodule CraqValidator.RequestForChange do
  @moduledoc """
  Context to handle business logic when complete CRAQ form
  """

  alias CraqValidator.RequestForChange.Question
  alias CraqValidator.Repo

  import Ecto.Query

  @doc "List all questions"
  @spec list_questions() :: [Question.t()] | []
  def list_questions do
    Question
    |> preload([:options])
    |> Repo.all()
  end
end
