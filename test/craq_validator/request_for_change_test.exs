defmodule CraqValidator.RequestForChangeTest do
  alias Finch.Response
  alias Finch.Response
  use CraqValidator.DataCase

  alias CraqValidator.Factory
  alias CraqValidator.RequestForChange
  alias CraqValidator.RequestForChange.Response

  describe "get_question_by_id/1" do
    test "must return nil when nil is given" do
      assert is_nil(RequestForChange.get_question_by_id(nil))
    end

    test "must return question by given id" do
      question_one = question_factory()

      result = RequestForChange.get_question_by_id(question_one.id)

      assert result.id == question_one.id
    end
  end

  describe "list_questions/0" do
    test "must return empty" do
      assert Enum.empty?(RequestForChange.list_questions())
    end

    test "must return all questions" do
      question_one = question_factory()
      question_two = question_factory()

      [result_one, result_two] = RequestForChange.list_questions()

      assert result_one.id == question_one.id
      assert result_two.id == question_two.id
    end
  end

  describe "save_responses/1" do
    test "must save a single valid response" do
      question_one = question_factory()
      option_one = option_factory(%{question: question_one})

      responses = %{
        question_one.id =>
          Response.changeset(%Response{}, %{
            "question_id" => question_one.id,
            "selected_option_id" => option_one.id
          })
      }

      :ok = RequestForChange.save_responses(responses)
    end
  end

  defp question_factory(attrs \\ %{}), do: Factory.insert!(:question, attrs)
  defp option_factory(attrs \\ %{}), do: Factory.insert!(:option, attrs)
end
