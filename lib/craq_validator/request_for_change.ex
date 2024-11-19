defmodule CraqValidator.RequestForChange do
  @moduledoc """
  Context to handle business logic

  This context must run the core operations such as filtering data, mounting the data to be used on the LV module
  and store data.
  """

  alias CraqValidator.RequestForChange.Question
  alias CraqValidator.RequestForChange.Response
  alias CraqValidator.RequestForChange.Option
  alias CraqValidator.Repo

  import Ecto.Query

  @doc "Build the initial responses based on a list of loaded questions"
  @spec build_responses([Question.t()]) :: map()
  def build_responses([]), do: %{}

  def build_responses(questions) do
    Enum.reduce(questions, %{}, fn question, acc ->
      Map.put(
        acc,
        question.id,
        Response.changeset(%Response{}, %{
          question_kind: question.kind,
          question_require_comment: question.require_comment
        })
      )
    end)
  end

  @doc "Returns a question extracting from a given list of questions"
  @spec get_question_from_list([Question.t()], integer()) :: Question.t() | nil
  def get_question_from_list(questions, question_id) when is_binary(question_id) do
    get_question_from_list(questions, String.to_integer(question_id))
  end

  def get_question_from_list(questions, question_id) when is_integer(question_id) do
    Enum.find(questions, &(&1.id == question_id))
  end

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
