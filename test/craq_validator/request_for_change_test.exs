defmodule CraqValidator.RequestForChangeTest do
  alias Finch.Response
  alias Finch.Response
  use CraqValidator.DataCase

  alias CraqValidator.Factory
  alias CraqValidator.RequestForChange
  alias CraqValidator.RequestForChange.Response

  describe "build_responses/1" do
    test "must return empty map when given empty list data" do
      assert RequestForChange.build_responses([]) == %{}
    end

    test "must build changesets with given data" do
      question_one = question_factory()
      question_two = question_factory()

      questions = [question_one, question_two]

      responses = RequestForChange.build_responses(questions)

      assert Map.has_key?(responses, question_one.id)
      assert Map.has_key?(responses, question_two.id)
    end
  end

  describe "get_question_from_list/2" do
    test "must return nil when not found" do
      question_one = question_factory()
      question_two = question_factory()

      questions = [question_one, question_two]

      assert is_nil(RequestForChange.get_question_from_list(questions, 999))
    end

    test "must return question" do
      question_one = question_factory()
      question_two = question_factory()

      questions = [question_one, question_two]

      %{id: result_id} = RequestForChange.get_question_from_list(questions, question_one.id)

      assert result_id == question_one.id
    end
  end

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

  describe "get_option_by_id/1" do
    test "must return nil when nil is given" do
      assert is_nil(RequestForChange.get_option_by_id(nil))
    end

    test "must return option by given id" do
      option_one = option_factory()

      result = RequestForChange.get_option_by_id(option_one.id)

      assert result.id == option_one.id
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
            "option_id" => option_one.id
          })
      }

      [result] = RequestForChange.save_responses(responses)

      assert result.question_id == question_one.id
      assert result.option_id == option_one.id
    end

    test "must save a multiple valid response" do
      question_one = question_factory()
      option_one = option_factory(%{question: question_one})

      question_two = question_factory()
      option_two = option_factory(%{question: question_two})

      question_three = question_factory(%{kind: "free_text"})
      question_four = question_factory(%{kind: "free_text"})

      responses = %{
        question_one.id =>
          Response.changeset(%Response{}, %{
            "question_id" => question_one.id,
            "option_id" => option_one.id
          }),
        question_two.id =>
          Response.changeset(%Response{}, %{
            "question_id" => question_two.id,
            "option_id" => option_two.id
          }),
        question_three =>
          Response.changeset(%Response{}, %{
            "question_id" => question_three.id
          }),
        question_four =>
          Response.changeset(%Response{}, %{
            "question_id" => question_four.id,
            "comment" => "My comment"
          })
      }

      responses = RequestForChange.save_responses(responses)

      assert length(responses) == 4
      assert List.last(responses).comment == "My comment"
    end
  end

  defp question_factory(attrs \\ %{}), do: Factory.insert!(:question, attrs)
  defp option_factory(attrs \\ %{}), do: Factory.insert!(:option, attrs)
end
