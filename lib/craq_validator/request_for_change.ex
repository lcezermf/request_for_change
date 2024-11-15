defmodule CraqValidator.RequestForChange do
  @moduledoc """
  Context to handle business logic when complete CRAQ form
  """

  alias CraqValidator.RequestForChange.Question
  alias CraqValidator.RequestForChange.Response
  alias CraqValidator.RequestForChange.Option
  alias CraqValidator.Repo

  import Ecto.Query

  @doc "List all questions"
  @spec list_questions() :: [Question.t()] | []
  def list_questions do
    Question
    |> preload([:options])
    |> order_by([q], asc: q.id)
    |> Repo.all()
  end

  @doc "Return question by given id"
  @spec get_question_by_id(integer()) :: Question.t() | nil
  def get_question_by_id(nil), do: nil

  def get_question_by_id(id) do
    Repo.get(Question, id)
  end

  @doc "Return option by given id"
  @spec get_option_by_id(integer()) :: Option.t() | nil
  def get_option_by_id(nil), do: nil

  def get_option_by_id(id) do
    Repo.get(Option, id)
  end

  @spec save_responses(map) :: [Response.t()] | []
  def save_responses(responses) do
    Enum.map(responses, fn {_, response} ->
      {:ok, response} = Repo.insert(response)
      response
    end)
  end
end
