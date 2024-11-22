defmodule CraqValidatorWeb.PendingResponsesComponent do
  @moduledoc """
  Component to render a message based on the amount of pending responses
  """

  use Phoenix.Component

  attr :total, :integer, required: true

  def show_progress_message(%{total: 0} = assigns) do
    ~H"""
    <div
      class="mt-2 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative"
      role="alert"
      id="progress_message"
    >
      <p>All set!</p>
    </div>
    """
  end

  def show_progress_message(assigns) do
    ~H"""
    <div
      class="mt-2 bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded relative"
      role="alert"
      id="progress_message"
    >
      <p>You have pending responses, please check the form.</p>
    </div>
    """
  end
end
