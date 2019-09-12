defmodule Prospero.LiveFormTest do
  require IEx

  use ExUnit.Case

  alias Prospero.FormData
  alias Prospero.LiveViewTest.FormLive
  alias Phoenix.LiveView.Socket

  defp build_socket(attrs \\ %{}) do
    live_form = Map.merge(%FormData{}, attrs)
    %Socket{assigns: %{live_form: live_form}}
  end

  describe "prepare_live_form/2" do
    test "creates form data and assigns it to :live_form" do
      {res, %{assigns: assigns}} = FormLive.mount(%{}, %Socket{})


      assert res == :ok
      assert assigns |> Map.get(:live_form) |> is_map()
    end

    test "assigns preset data from the session" do
      name = "name"
      {res, %{assigns: assigns}} = FormLive.mount(%{data: %{name: name}}, %Socket{})
      form_name =
        assigns
        |> Map.get(:live_form, %{})
        |> Map.get(:changeset, %{})
        |> Map.get(:data, %{})
        |> Map.get(:name)

      assert res == :ok
      assert form_name == name
    end
  end

  describe "handle_event/3 'submit_active_step'" do
    test "updates the socket to move to the next step when inputs are valid" do
      value = %{ "test_schema" => %{ "name" => "Rusty Shackleform" } }
      {res, %{assigns: %{live_form: live_form}}} = 
        FormLive.handle_event("submit_active_step", value, build_socket())

      assert live_form.active_step == 2
    end

    test "updates the socket to stay on the active step when there are errors" do
      value = %{ "test_schema" => %{ "name" => "" } }
      {res, %{assigns: %{live_form: live_form}}} =
        FormLive.handle_event("submit_active_step", value, build_socket())

      assert live_form.active_step == 1
    end
  end

  describe "handle_event/3 'move_back'" do
    test "updates the socket to move to the previous step" do
      socket = build_socket(%{active_step: 2})
      {res, %{assigns: %{live_form: live_form}}} =
        FormLive.handle_event("move_back", %{}, socket)

      assert live_form.active_step == 1
    end
  end
end