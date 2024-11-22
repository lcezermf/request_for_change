defmodule CraqValidator.RequestForChange do
  @moduledoc """
  Context to handle business logic.

  This context must run core operations such as filtering data, mounting the data to be used in the LiveView module,
  and storing data.
  """

  alias CraqValidator.RequestForChange.Question
  alias CraqValidator.RequestForChange.Response
  alias CraqValidator.RequestForChange.Option
  alias CraqValidator.Repo

  import Ecto.Query

  @doc """
  Builds the initial responses based on a list of loaded questions.

  Returns a map where the keys are question IDs and the values are changesets
  for the `Response` schema, preloaded with the question's attributes.
  """
  @spec build_responses([Question.t()], binary()) :: map()
  def build_responses([], _), do: %{}

  def build_responses(questions, form_public_id) do
    Enum.reduce(questions, %{}, fn question, acc ->
      Map.put(
        acc,
        question.id,
        Response.changeset(%Response{}, %{
          form_public_id: form_public_id,
          question_kind: question.kind,
          question_require_comment: question.require_comment
        })
      )
    end)
  end

  @doc """
  Retrieves a question from a list of questions by its ID.

  The `question_id` can be either an integer or a binary string.
  Returns `nil` if no matching question is found.
  """
  @spec get_question_from_list([Question.t()], integer() | binary()) :: Question.t() | nil
  def get_question_from_list(questions, question_id) when is_binary(question_id) do
    get_question_from_list(questions, String.to_integer(question_id))
  end

  def get_question_from_list(questions, question_id) when is_integer(question_id) do
    Enum.find(questions, &(&1.id == question_id))
  end

  @doc """
  Returns a map of options and their associated confirmation IDs.

  Each key in the returned map is the `id` of an option, and the value is a list of confirmation IDs associated with that option.

  ## Parameters

  - `questions` (list): A list of questions, where each question contains a list of options, and each option contains a list of confirmations.
  """
  @spec list_confirmations([Question.t()]) :: map()
  def list_confirmations([]), do: %{}

  def list_confirmations(questions) do
    questions
    |> Enum.flat_map(& &1.options)
    |> Enum.map(fn option ->
      {option.id, Enum.map(option.confirmations, fn confirmation -> confirmation.id end)}
    end)
    |> Map.new()
  end

  @doc "List all questions"
  @spec list_questions() :: [Question.t()] | []
  def list_questions do
    Question
    |> preload(options: :confirmations)
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

  @doc """
  Saves a group of responses.

  Accepts a map of responses where each value is a valid `Response` changeset.

  Returns a list of the inserted responses.
  """
  @spec save_responses(list()) :: {:ok, any()} | {:error, any()}
  def save_responses(responses) do
    Repo.transaction(fn ->
      Enum.reduce(responses, [], fn response, acc ->
        case Repo.insert(response) do
          {:ok, record} -> [record | acc]
          {:error, response} -> Repo.rollback(response.errors)
        end
      end)
    end)
  end

  @doc """
  Filters a map of responses to exclude any responses associated with disabled question IDs.
  """
  @spec filter_enabled_responses(map(), [integer()]) :: list()
  def filter_enabled_responses(responses, disabled_questions_ids) do
    responses
    |> Enum.filter(fn {question_id, _response} ->
      question_id not in disabled_questions_ids
    end)
    |> Enum.map(fn {_question_id, response} -> response end)
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
        disabled_questions_ids: disabled_questions_ids,
        disabled_question_id: disabled_question_id
      }) do
    {disabled_questions_ids, disabled_question_id}
  end

  @doc """
  Generates a public_id that will be used for a group of responses.

  This public id will identify that a set of questions belongs to the same submission.
  """
  @spec generate_form_public_id() :: binary()
  def generate_form_public_id, do: Ecto.UUID.generate()
end
