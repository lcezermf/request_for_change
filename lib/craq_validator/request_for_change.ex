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

  @doc "Return question by given id"
  @spec get_question_by_id(integer()) :: Question.t() | nil
  def get_question_by_id(nil), do: nil

  def get_question_by_id(id) do
    Repo.get(Question, id)
  end

  def save_responses(responses) do
    Enum.map(responses, fn {_, response} ->
      {:ok, response} = Repo.insert(response)
      response
    end)
  end
end
