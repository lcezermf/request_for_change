defmodule CraqValidatorWeb.RequestForChangeLive.Form do
  @moduledoc """
  TBD
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
      |> assign(:responses, build_responses_changeset(questions))
      |> assign(:has_submitted, false)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "reply_question",
        %{"question_id" => question_id, "option_id" => option_id},
        socket
      ) do
    responses = socket.assigns.responses

    changeset =
      Response.changeset(%Response{}, %{
        "question_id" => question_id,
        "selected_option_id" => option_id
      })

    socket =
      socket
      |> assign(:responses, Map.put(responses, String.to_integer(question_id), changeset))

    {:noreply, socket}
  end

  def handle_event(
        "reply_question",
        %{"question_id" => question_id, "value" => comment},
        socket
      ) do
    responses = socket.assigns.responses

    base_struct = Map.get(responses, String.to_integer(question_id), %Response{})

    changeset =
      Response.changeset(base_struct, %{
        "question_id" => question_id,
        "comment" => comment
      })

    socket =
      socket
      |> assign(:responses, Map.put(responses, String.to_integer(question_id), changeset))

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "save",
        _,
        %{
          assigns: %{
            questions: questions,
            responses: responses
          }
        } = socket
      ) do
    all_valid? =
      Enum.all?(responses, fn {_question_id, response} ->
        response.valid?
      end)

    socket =
      if all_valid? do
        RequestForChange.save_responses(responses)

        socket
        |> assign(:questions, questions)
        |> assign(:responses, build_responses_changeset(questions))
        |> assign(:has_submitted, false)
        |> put_flash(:info, "CRAQ submitted successfully!")
      else
        socket
        |> assign(:has_submitted, true)
      end

    {:noreply, socket}
  end

  defp build_responses_changeset([]), do: %{}

  defp build_responses_changeset(questions) do
    Enum.reduce(questions, %{}, fn question, acc ->
      Map.put(
        acc,
        question.id,
        Response.changeset(%Response{}, %{question_id: question.id})
      )
    end)
  end
end
