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

    socket = assign(socket, :questions, questions)

    {:ok, socket}
  end
end
