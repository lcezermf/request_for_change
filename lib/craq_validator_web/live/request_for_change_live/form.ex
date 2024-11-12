defmodule CraqValidatorWeb.RequestForChangeLive.Form do
  @moduledoc """
  TBD
  """

  use CraqValidatorWeb, :live_view

  import Phoenix.HTML.Form

  alias CraqValidator.RequestForChange

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
      |> assign(:selected_options, %{})
      |> assign(:errors, %{})

    {:ok, socket}
  end

  @impl true
  def handle_event("select_option", params, socket) do
    selected_options = socket.assigns.selected_options

    %{"question_id" => question_id, "option_id" => option_id} = Map.drop(params, ["value"])

    updated_selected_options =
      Map.put(selected_options, String.to_integer(question_id), String.to_integer(option_id))

    socket =
      socket
      |> assign(:selected_options, updated_selected_options)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "save",
        _,
        %{
          assigns: %{
            questions: questions,
            selected_options: selected_options
          }
        } = socket
      ) do
    question_ids_with_options_selected = Map.keys(selected_options)

    required_questions = Enum.filter(questions, &(&1.kind == "multiple_choice"))

    errors =
      Enum.reduce(required_questions, %{}, fn question, acc ->
        if question.id not in question_ids_with_options_selected do
          Map.put(acc, question.id, "Required")
        else
          %{}
        end
      end)

    if errors != %{} do
      socket =
        socket
        |> assign(:errors, errors)

      {:noreply, socket}
    else
      # Save later
      # {:ok, _} = RequestForChange.save(selected_options)

      socket =
        socket
        |> assign(:selected_options, %{})
        |> assign(:errors, %{})
        |> assign(:form_submission, %{})
        |> put_flash(:info, "CRAQ submitted successfully!")

      {:noreply, socket}
    end
  end
end
