defmodule CraqValidator.RequestForChange do
  @moduledoc """
  Context to handle business logic when complete CRAQ form
  """

  alias CraqValidator.RequestForChange.Question
  alias CraqValidator.RequestForChange.FormSubmission
  alias CraqValidator.Repo

  import Ecto.Query

  @doc "List all questions"
  @spec list_questions() :: [Question.t()] | []
  def list_questions do
    Question
    |> preload([:options])
    |> Repo.all()
  end

  @doc "Save a new form submission"
  @spec save(map()) :: {:ok, Ecto.Changeset.t()} | {:error, Ecto.Changeset.t()}
  def save(selected_options) do
    answers =
      Enum.reduce(selected_options, %{}, fn {key, value}, acc ->
        Map.put(acc, key, %{option: value, comment: ""})
      end)

    %FormSubmission{}
    |> FormSubmission.changeset(%{answers: answers})
    |> Repo.insert()
  end
end
