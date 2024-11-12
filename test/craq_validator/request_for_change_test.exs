defmodule CraqValidator.RequestForChangeTest do
  use CraqValidator.DataCase

  alias CraqValidator.Factory
  alias CraqValidator.RequestForChange

  # describe "save/1" do
  #   test "must save a new record" do
  #     params = %{1 => 2}

  #     {:ok, form_submission} = RequestForChange.save(params)

  #     assert form_submission.answers == %{1 => %{option: 2, comment: ""}}
  #   end
  # end

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

  defp question_factory(attrs \\ %{}), do: Factory.insert!(:question, attrs)
end
