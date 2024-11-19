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
    questions =
      if connected?(socket) do
        RequestForChange.list_questions()
      else
        []
      end

    socket =
      socket
      |> assign(:questions, questions)
      |> assign(:responses, build_responses(questions))
      |> assign(:has_submitted, false)
      |> assign(:disabled_questions_ids, [])
      |> assign(:disabled_question_id, nil)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "reply_question",
        %{"question_id" => question_id, "option_id" => option_id},
        socket
      ) do
    responses = socket.assigns.responses
    question = RequestForChange.get_question_from_list(socket.assigns.questions, question_id)
    option = RequestForChange.get_option_by_id(option_id)

    {disabled_questions_ids, disabled_question_id} = get_disabled_questions_ids(socket, option)

    changeset =
      Response.changeset(%Response{}, %{
        question_id: question.id,
        question_kind: question.kind,
        question_require_comment: question.require_comment,
        option_id: option_id
      })

    socket =
      socket
      |> assign(:responses, Map.put(responses, String.to_integer(question_id), changeset))
      |> assign(:disabled_questions_ids, disabled_questions_ids)
      |> assign(:disabled_question_id, disabled_question_id)

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
            disabled_questions_ids: disabled_questions_ids
          }
        } = socket
      ) do
    # refactor to return a list
    responses_not_disabled =
      Enum.filter(responses, fn {question_id, _response} ->
        question_id not in disabled_questions_ids
      end)
      |> Enum.into(%{})

    all_valid? =
      Enum.all?(responses_not_disabled, fn {_question_id, response} -> response.valid? end)

    socket =
      if all_valid? do
        RequestForChange.save_responses(responses_not_disabled)

        socket
        |> assign(:questions, questions)
        |> assign(:responses, build_responses(questions))
        |> assign(:has_submitted, false)
        |> put_flash(:info, "CRAQ submitted successfully!")
        |> push_navigate(to: ~p"/request_for_change")
      else
        socket
        |> assign(:has_submitted, true)
      end

    {:noreply, socket}
  end

  defp build_responses([]), do: %{}

  defp build_responses(questions) do
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

  defp get_disabled_questions_ids(socket, %{
         is_terminal: true,
         question_id: question_id
       }) do
    disabled_questions =
      socket.assigns.questions
      |> Enum.map(& &1.id)
      |> Enum.filter(&(&1 > question_id))

    {disabled_questions, question_id}
  end

  defp get_disabled_questions_ids(
         socket,
         %{
           is_terminal: false,
           question_id: question_id
         }
       ) do
    %{disabled_questions_ids: disabled_questions_ids, disabled_question_id: disabled_question_id} =
      socket.assigns

    if disabled_question_id == question_id do
      {[], nil}
    else
      {disabled_questions_ids, disabled_question_id}
    end
  end
end
