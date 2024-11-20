defmodule CraqValidatorWeb.RequestForChangeLive.Form do
  @moduledoc """
  LiveView module that handles the form
  """

  use CraqValidatorWeb, :live_view
  use Phoenix.HTML

  alias CraqValidator.RequestForChange
  alias CraqValidator.RequestForChange.Response

  @impl true
  def mount(_params, _session, socket) do
    {questions, form_public_id, disabled_confirmations} =
      if connected?(socket) do
        questions = RequestForChange.list_questions()

        {questions, RequestForChange.generate_form_public_id(),
         RequestForChange.list_confirmations(questions)}
      else
        {[], nil, %{}}
      end

    socket =
      socket
      |> assign(:questions, questions)
      |> assign(:responses, RequestForChange.build_responses(questions, form_public_id))
      |> assign(:has_submitted, false)
      |> assign(:disabled_questions_ids, [])
      |> assign(:disabled_question_id, nil)
      |> assign(:disabled_confirmations, disabled_confirmations)
      |> assign(:all_disabled_confirmations, disabled_confirmations)
      |> assign(:form_public_id, form_public_id)
      |> assign(:selected_confirmations, [])
      |> assign(:questions_with_confirmations, [])

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "reply_question",
        %{
          "question_id" => question_id,
          "option_id" => option_id,
          "option_require_confirmation" => "false"
        },
        socket
      ) do
    %{
      responses: responses,
      all_disabled_confirmations: all_disabled_confirmations,
      questions_with_confirmations: questions_with_confirmations,
      disabled_confirmations: disabled_confirmations
    } = socket.assigns

    question = RequestForChange.get_question_from_list(socket.assigns.questions, question_id)
    option = RequestForChange.get_option_by_id(option_id)

    {disabled_questions_ids, disabled_question_id} = get_disabled_questions_ids(socket, option)

    changeset =
      Response.changeset(%Response{}, %{
        form_public_id: socket.assigns.form_public_id,
        question_id: question.id,
        question_kind: question.kind,
        question_require_comment: question.require_comment,
        option_require_confirmation: option.require_confirmation,
        option_id: option_id
      })

    updated_disabled_confirmations =
      if question.id in questions_with_confirmations do
        all_disabled_confirmations
      else
        disabled_confirmations
      end

    socket =
      socket
      |> assign(:responses, Map.put(responses, String.to_integer(question_id), changeset))
      |> assign(:disabled_questions_ids, disabled_questions_ids)
      |> assign(:disabled_question_id, disabled_question_id)
      |> assign(:disabled_confirmations, updated_disabled_confirmations)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "reply_question",
        %{
          "question_id" => question_id,
          "option_id" => option_id,
          "option_require_confirmation" => "true"
        },
        socket
      ) do
    %{
      responses: responses,
      disabled_confirmations: disabled_confirmations,
      questions_with_confirmations: questions_with_confirmations
    } = socket.assigns

    question = RequestForChange.get_question_from_list(socket.assigns.questions, question_id)
    option = RequestForChange.get_option_by_id(option_id)

    {disabled_questions_ids, disabled_question_id} = get_disabled_questions_ids(socket, option)

    changeset =
      Response.changeset(%Response{}, %{
        form_public_id: socket.assigns.form_public_id,
        question_id: question.id,
        question_kind: question.kind,
        question_require_comment: question.require_comment,
        option_require_confirmation: option.require_confirmation,
        option_id: option_id
      })

    updated_disabled_confirmations =
      if Map.has_key?(disabled_confirmations, option.id) do
        Map.put(disabled_confirmations, option.id, [])
      end

    updated_questions_with_confirmations = questions_with_confirmations ++ [question.id]

    socket =
      socket
      |> assign(:responses, Map.put(responses, String.to_integer(question_id), changeset))
      |> assign(:disabled_questions_ids, disabled_questions_ids)
      |> assign(:disabled_question_id, disabled_question_id)
      |> assign(:disabled_confirmations, updated_disabled_confirmations)
      |> assign(:questions_with_confirmations, updated_questions_with_confirmations)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "reply_question",
        %{
          "question_id" => question_id,
          "option_id" => option_id,
          "confirmation_id" => confirmation_id
        },
        socket
      ) do
    confirmation_id = String.to_integer(confirmation_id)

    selected_confirmations = socket.assigns.selected_confirmations

    updated_selected_confirmations =
      if confirmation_id in selected_confirmations do
        List.delete(selected_confirmations, confirmation_id)
      else
        [confirmation_id | selected_confirmations]
      end

    question = RequestForChange.get_question_from_list(socket.assigns.questions, question_id)
    responses = socket.assigns.responses
    option = RequestForChange.get_option_by_id(option_id)

    base_struct = Map.get(responses, question.id, %Response{})

    changeset =
      Response.changeset(base_struct, %{
        form_public_id: socket.assigns.form_public_id,
        question_id: question.id,
        question_kind: question.kind,
        question_require_comment: question.require_comment,
        option_require_confirmation: option.require_confirmation,
        confirmations: updated_selected_confirmations
      })

    socket =
      socket
      |> assign(:selected_confirmations, updated_selected_confirmations)
      |> assign(:responses, Map.put(responses, question.id, changeset))

    {:noreply, socket}
  end

  def handle_event(
        "reply_question",
        %{"question_id" => question_id, "value" => comment},
        socket
      ) do
    question = RequestForChange.get_question_from_list(socket.assigns.questions, question_id)
    responses = socket.assigns.responses

    base_struct = Map.get(responses, question.id, %Response{})

    changeset =
      Response.changeset(base_struct, %{
        form_public_id: socket.assigns.form_public_id,
        question_id: question.id,
        question_kind: question.kind,
        question_require_comment: question.require_comment,
        comment: comment
      })

    socket =
      socket
      |> assign(:responses, Map.put(responses, question.id, changeset))

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "save",
        _,
        %{
          assigns: %{
            questions: questions,
            responses: responses,
            disabled_questions_ids: disabled_questions_ids,
            form_public_id: form_public_id
          }
        } = socket
      ) do
    # refactor to return a list
    responses_not_disabled =
      Enum.filter(responses, fn {question_id, _response} ->
        question_id not in disabled_questions_ids
      end)
      |> Enum.into(%{})

    # maybe extract to the context
    all_valid? =
      Enum.all?(responses_not_disabled, fn {_question_id, response} -> response.valid? end)

    socket =
      if all_valid? do
        RequestForChange.save_responses(responses_not_disabled)

        socket
        |> assign(:questions, questions)
        |> assign(
          :responses,
          RequestForChange.build_responses(questions, form_public_id)
        )
        |> assign(:has_submitted, false)
        |> put_flash(:info, "CRAQ submitted successfully!")
        |> push_navigate(to: ~p"/request_for_change")
      else
        socket
        |> assign(:has_submitted, true)
      end

    {:noreply, socket}
  end

  defp get_disabled_questions_ids(socket, params) do
    params
    |> Map.merge(%{
      questions: socket.assigns.questions,
      disabled_questions_ids: socket.assigns.disabled_questions_ids,
      disabled_question_id: socket.assigns.disabled_question_id
    })
    |> RequestForChange.get_disabled_questions_ids()
  end
end
