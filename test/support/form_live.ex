defmodule Prospero.LiveViewTest.FormLive do
  alias Prospero.{LiveForm, TestSchema}
  use LiveForm, schema: TestSchema, steps: 2

  def mount(session, socket) do
    {:ok, prepare_live_form(socket)}
  end

  def submit_form(params, socket) do
    case TestSchema.changeset(%TestSchema{}, params) do
      %{valid?: true} -> {:stop, put_flash(socket, :info, "success")}
      _ -> {:noreply, put_flash(socket, :info, "error")}
    end
  end
end