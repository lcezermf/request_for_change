defmodule CraqValidatorWeb.RequestForChangeLive.Form do
  @moduledoc """
  TBD
  """
  use CraqValidatorWeb, :live_view

  alias CraqValidator.RequestForChange

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
      |> assign(:form, %{})

    {:ok, socket}
  end

  def handle_event("save", params, socket) do
    IO.inspect(params, label: :params)

    {:noreply, socket}
  end
end
