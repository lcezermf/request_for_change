defmodule CraqValidator.RequestForChange do
  @moduledoc """
  Context to handle business logic when complete CRAQ form
  """

  alias CraqValidator.RequestForChange.Question
  alias CraqValidator.Repo

  @doc "List all questions"
  @spec list_questions() :: [Question.t()] | []
  def list_questions do
    Repo.all(Question)
  end
end
