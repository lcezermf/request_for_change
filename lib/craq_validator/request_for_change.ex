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

  @doc "Save a group of responses"
  @spec save_responses(map) :: [Response.t()] | []
  def save_responses(responses) do
    Enum.map(responses, fn {_, response} ->
      {:ok, response} = Repo.insert(response)
      response
    end)
  end

  @doc """
  Determines which questions should be disabled based on the given parameters.

  Expects a map containing:
    - `:questions` - A list of questions with IDs.
    - `:is_terminal` - A boolean indicating if the option is terminal.
    - `:question_id` - The ID of the question related to the selected option.
    - `:disabled_questions_ids` - (Optional) A list of already disabled question IDs.
    - `:disabled_question_id` - (Optional) The ID of the currently disabled question.

  Returns a tuple `{list_of_disabled_question_ids, disabled_question_id}`.
  """
  @spec get_disabled_questions_ids(map()) :: tuple()
  def get_disabled_questions_ids(%{
        questions: questions,
        is_terminal: true,
        question_id: question_id
      }) do
    disabled_questions =
      questions
      |> Enum.map(& &1.id)
      |> Enum.filter(&(&1 > question_id))

    {disabled_questions, question_id}
  end

  def get_disabled_questions_ids(%{
        is_terminal: false,
        question_id: question_id,
        disabled_question_id: question_id
      }) do
    {[], nil}
  end

  def get_disabled_questions_ids(%{
        is_terminal: false,
        question_id: _question_id,
        disabled_questions_ids: disabled_questions_ids,
        disabled_question_id: disabled_question_id
      }) do
    {disabled_questions_ids, disabled_question_id}
  end
end
