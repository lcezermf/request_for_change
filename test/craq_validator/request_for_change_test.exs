defmodule CraqValidator.RequestForChangeTest do
  use CraqValidator.DataCase, async: true

  alias CraqValidator.Factory
  alias CraqValidator.RequestForChange
  alias CraqValidator.RequestForChange.Response

  describe "build_responses/2" do
    test "must return empty map when given empty list data" do
      assert RequestForChange.build_responses([], nil) == %{}
    end

    test "must build changesets with given data" do
      question_one = question_factory()
      question_two = question_factory()

      questions = [question_one, question_two]

      form_public_id = Ecto.UUID.generate()

      responses = RequestForChange.build_responses(questions, form_public_id)

      assert Map.has_key?(responses, question_one.id)
      assert Map.has_key?(responses, question_two.id)
      assert Map.get(responses, question_one.id).changes[:form_public_id] == form_public_id
      assert Map.get(responses, question_two.id).changes[:form_public_id] == form_public_id
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

  describe "list_confirmations/0" do
    test "must return empty" do
      assert map_size(RequestForChange.list_confirmations([])) == 0
    end

    test "must return all confirmations grouped by option" do
      question_one = question_factory()

      option_one = option_factory(%{question: question_one, require_confirmation: true})

      confirmation_one = confirmation_factory(%{option: option_one})
      confirmation_two = confirmation_factory(%{option: option_one})

      option_two = option_factory(%{question: question_one, require_confirmation: true})

      confirmation_three = confirmation_factory(%{option: option_two})
      confirmation_four = confirmation_factory(%{option: option_two})

      result = RequestForChange.list_confirmations(RequestForChange.list_questions())

      assert result == %{
               option_one.id => [confirmation_one.id, confirmation_two.id],
               option_two.id => [confirmation_three.id, confirmation_four.id]
             }
    end
  end

  describe "save_responses/1" do
    test "must save a single response" do
      question_one = question_factory()
      option_one = option_factory(%{question: question_one})

      responses = [
        Response.changeset(%Response{}, %{
          question_id: question_one.id,
          option_id: option_one.id
        })
      ]

      {:ok, [response_one]} = RequestForChange.save_responses(responses)

      assert response_one.question_id == question_one.id
    end

    test "must save a multiple responses" do
      question_one = question_factory()
      option_one = option_factory(%{question: question_one})

      question_two = question_factory()
      option_two = option_factory(%{question: question_two})

      question_three = question_factory(%{kind: "free_text"})
      question_four = question_factory(%{kind: "free_text"})

      question_five = question_factory()
      option_three = option_factory(%{question: question_five, require_confirmation: true})
      confirmation_one = confirmation_factory(%{option: option_three})
      confirmation_factory(%{option: option_three})

      responses = [
        Response.changeset(%Response{}, %{
          question_id: question_one.id,
          option_id: option_one.id
        }),
        Response.changeset(%Response{}, %{
          question_id: question_two.id,
          option_id: option_two.id
        }),
        Response.changeset(%Response{}, %{
          question_id: question_three.id
        }),
        Response.changeset(%Response{}, %{
          question_id: question_four.id,
          comment: "My comment"
        }),
        Response.changeset(%Response{}, %{
          question_id: question_five.id,
          option_id: option_three.id,
          confirmations: [confirmation_one.id]
        })
      ]

      {:ok, results} = RequestForChange.save_responses(responses)

      assert length(results) == 5
    end

    test "must not save where there is one invalid" do
      question_one = question_factory()
      option_one = option_factory(%{question: question_one})

      question_two = question_factory(%{require_comment: true})
      option_factory(%{question: question_two})

      responses = [
        Response.changeset(%Response{}, %{
          question_id: question_one.id,
          option_id: option_one.id
        }),
        Response.changeset(%Response{}, %{
          question_id: question_two.id,
          question_require_comment: question_two.require_comment
        })
      ]

      {:error, _error_message} = RequestForChange.save_responses(responses)
    end
  end

  describe "get_disabled_questions_ids/1" do
    setup do
      question_one = question_factory()
      question_two = question_factory()
      question_three = question_factory()

      %{
        questions: [question_one, question_two, question_three],
        question_one: question_one,
        question_two: question_two,
        question_three: question_three
      }
    end

    test "must return a {list_of_question_ids_to_disable, terminal_question_id} for a terminal option",
         %{
           questions: questions,
           question_one: question_one,
           question_two: question_two,
           question_three: question_three
         } do
      params = %{
        questions: questions,
        is_terminal: true,
        question_id: question_one.id
      }

      {disabled_question_ids, terminal_question_id} =
        RequestForChange.get_disabled_questions_ids(params)

      assert disabled_question_ids == [question_two.id, question_three.id]
      assert terminal_question_id == question_one.id
    end

    test "returns {[], nil} when a non-terminal option matches the disabled_question_id", %{
      questions: questions,
      question_two: question_two,
      question_three: question_three
    } do
      params = %{
        questions: questions,
        is_terminal: false,
        question_id: question_two.id,
        disabled_questions_ids: [question_three.id],
        disabled_question_id: question_two.id
      }

      {disabled_question_ids, terminal_question_id} =
        RequestForChange.get_disabled_questions_ids(params)

      assert disabled_question_ids == []
      assert is_nil(terminal_question_id)
    end

    test "returns {disabled_questions_ids, disabled_question_id} when a non-terminal option does not match",
         %{
           questions: questions,
           question_one: question_one,
           question_two: question_two,
           question_three: question_three
         } do
      params = %{
        questions: questions,
        is_terminal: false,
        question_id: question_one.id,
        disabled_questions_ids: [question_three.id],
        disabled_question_id: question_two.id
      }

      {disabled_question_ids, terminal_question_id} =
        RequestForChange.get_disabled_questions_ids(params)

      assert disabled_question_ids == [question_three.id]
      assert terminal_question_id == question_two.id
    end
  end

  describe "filter_enabled_responses/2" do
    test "must return only the enabled" do
      responses = %{1 => %{id: 1}, 2 => %{id: 2}, 3 => %{id: 3}}
      disabled_questions_ids = [3]

      assert [%{id: 1}, %{id: 2}] ==
               RequestForChange.filter_enabled_responses(
                 responses,
                 disabled_questions_ids
               )
    end

    test "must return all when there are no disabled" do
      responses = %{1 => %{id: 1}, 2 => %{id: 2}, 3 => %{id: 3}}
      disabled_questions_ids = []

      assert [%{id: 1}, %{id: 2}, %{id: 3}] ==
               RequestForChange.filter_enabled_responses(
                 responses,
                 disabled_questions_ids
               )
    end
  end

  describe "calculate_total_pending_responses/2" do
    test "must return the number of pending responses (checkbox, radio button and comments) that are required" do
      question_one = question_factory(%{require_comment: true})
      option_factory(%{question: question_one})

      question_two = question_factory()
      option_factory(%{question: question_two})

      question_factory(%{kind: "free_text"})
      question_factory(%{kind: "free_text"})

      question_five = question_factory()
      option_three = option_factory(%{question: question_five, require_confirmation: true})
      confirmation_factory(%{option: option_three})
      confirmation_factory(%{option: option_three})

      questions = RequestForChange.list_questions()

      responses =
        RequestForChange.build_responses(questions, RequestForChange.generate_form_public_id())

      assert RequestForChange.calculate_total_pending_responses(responses, []) == 4
    end

    test "must return the number of pending responses (checkbox, radio button and comments) that are required considering confirmations" do
      question_one = question_factory(%{require_comment: true})
      option_factory(%{question: question_one})

      question_two = question_factory()
      option_two = option_factory(%{question: question_two})

      question_three = question_factory(%{kind: "free_text"})
      question_four = question_factory(%{kind: "free_text"})

      question_five = question_factory()
      option_three = option_factory(%{question: question_five, require_confirmation: true})
      confirmation_factory(%{option: option_three})
      confirmation_factory(%{option: option_three})

      responses = %{
        question_one.id =>
          Response.changeset(%Response{}, %{
            question_id: question_one.id,
            question_require_comment: question_one.require_comment
          }),
        question_two.id =>
          Response.changeset(%Response{}, %{
            question_id: question_two.id,
            option_id: option_two.id
          }),
        question_three.id =>
          Response.changeset(%Response{}, %{
            question_id: question_three.id
          }),
        question_four.id =>
          Response.changeset(%Response{}, %{
            question_id: question_four.id,
            comment: "My comment"
          }),
        question_five.id =>
          Response.changeset(%Response{}, %{
            question_id: question_five.id,
            option_id: option_three.id,
            option_require_confirmation: true
          })
      }

      assert RequestForChange.calculate_total_pending_responses(responses, []) == 2
    end

    test "must return the number of pending responses (checkbox, radio button and comments) that are required considering some questions are disabled" do
      question_one = question_factory(%{require_comment: true})
      option_factory(%{question: question_one})

      question_two = question_factory()
      option_two = option_factory(%{question: question_two, is_terminal: true})

      question_three = question_factory(%{kind: "free_text"})
      question_four = question_factory(%{kind: "free_text"})

      question_five = question_factory()
      option_three = option_factory(%{question: question_five, require_confirmation: true})
      confirmation_factory(%{option: option_three})
      confirmation_factory(%{option: option_three})

      responses = %{
        question_one.id =>
          Response.changeset(%Response{}, %{
            question_id: question_one.id,
            question_require_comment: true
          }),
        question_two.id =>
          Response.changeset(%Response{}, %{
            question_id: question_two.id,
            option_id: option_two.id,
            option_is_terminal: true
          }),
        question_three.id =>
          Response.changeset(%Response{}, %{
            question_id: question_three.id
          }),
        question_four.id =>
          Response.changeset(%Response{}, %{
            question_id: question_four.id,
            comment: "My comment"
          }),
        question_five.id =>
          Response.changeset(%Response{}, %{
            question_id: question_five.id,
            option_id: option_three.id,
            option_require_confirmation: true
          })
      }

      disabled_questions_ids = [question_three.id, question_four.id, question_five.id]

      assert RequestForChange.calculate_total_pending_responses(responses, disabled_questions_ids) ==
               1
    end
  end

  defp question_factory(attrs \\ %{}), do: Factory.insert!(:question, attrs)
  defp option_factory(attrs \\ %{}), do: Factory.insert!(:option, attrs)
  defp confirmation_factory(attrs), do: Factory.insert!(:confirmation, attrs)
end
