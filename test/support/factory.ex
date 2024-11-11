defmodule CraqValidator.Factory do
  @moduledoc """
  Enable to create factory on test files.
  """

  alias CraqValidator.RequestForChange.FormSubmission
  alias CraqValidator.RequestForChange.Option
  alias CraqValidator.RequestForChange.Question
  alias CraqValidator.Repo

  def build(:question) do
    %Question{
      description: "My description for question #{System.unique_integer([:positive])}",
      kind: "multiple_choice"
    }
  end

  def build(:option) do
    %Option{
      description: "My description for option #{System.unique_integer([:positive])}",
      question_id: build(:question).id
    }
  end

  def build(:form_submission) do
    %FormSubmission{
      answers: %{}
    }
  end

  def build(factory_name, attributes) do
    factory_name
    |> build()
    |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name
    |> build(attributes)
    |> Repo.insert!()
  end
end
