defmodule Prospero.LiveForm do
  @moduledoc """
  Defines Phoenix LiveView event handlers for events related to multi-step form
  functionality.

  LiveForm is built on top of the LiveView API to provide event handlers that
  will process events for when a user tries to move forward or backward within
  a multi-step form.  When a user tries to move forward, the form submission
  will be validated and processed before moving on.

  ## Using Prospero.LiveForm

  ### Configuration
  When using LiveForm, there are two options that must be provided:

  * `:schema` — the changeset schema LiveForm will use to process and validate
    user input.
  * `:steps` — the total number of steps in the multi-step form.

    use Prospero.LiveForm, schema: App.Account.User, steps: 3

  ### Setup
  When defining the `mount/2` callback required by LiveView, you must use
  the function `prepare_live_form/1` with the socket to assign all the data
  Prospero will need in the template.  This method will return the updated
  socket, which can be used to complete the callback

  ### Callbacks and Teardown
  Prospero.LiveForm requires that you define a `submit_form/2` callback in your
  LiveView file.  This callback will be invoked when the user submits the final
  step of the form.  This function should be used to perform any
  necessary actions with the data provided.  In most cases, this will involve
  creating or updating a database entry.

  `submit_form/2` will recieve two arguments.  The first is a map that
  represents tthe final parameters subitted by the form.  The second is the
  socket.  This callback can return any value expected by LiveView's
  `handle_event/3` callback.  The return value should be a response that either
  redirects the user or displays an error message.

  ## Example

    defmodule MyAppWeb.UserLive.New do
      alias MyApp.Accounts.User
      alias MyAppWeb.Router.Helpers, as: Routes

      use Prospero.LiveForm, schema: User, steps: 3

      def mount(_session, socket) do
        {:ok, prepare_live_form(socket)}
      end

      @impl true
      def submit_form(params, socket) do
        changeset = User.changeset(%User{}, params)
        case MyApp.Repo.insert(changeset) do
          {:ok, user} ->
            {
              :stop,
              socket
              |> put_flash(:info, "created profile")
              |> redirect(to: Routes.users_path(socket, :show, user))
            }
          {:error, _} ->
            {:noreply, put_flash(socket, :error, "something went wrong")}
        end
      end
    end
  """

  alias Prospero.FormData
  alias Phoenix.LiveView.Socket

  @callback submit_form(map, Socket.t()) :: {atom, Socket.t()}

  defmacro __using__(opts) do
    quote(bind_quoted: [opts: opts]) do
      use Phoenix.LiveView

      @schema Keyword.get(opts, :schema)
      @name Module.split(@schema) |> List.last() |> Macro.underscore()
      @steps Keyword.get(opts, :steps)

      @behaviour Prospero.LiveForm

      def handle_event("submit_active_step", %{@name => attrs}, socket) do
        case update_form_and_validate_step(socket.assigns.live_form, attrs) do
          {:ok, live_form} ->
            move_forward(live_form, socket)

          {:error, live_form} ->
            show_active_step_errors(live_form, socket)
        end
      end

      def handle_event("move_back", _, socket) do
        active_step =
          if socket.assigns.live_form.active_step == 1 do
            1
          else
            socket.assigns.live_form.active_step - 1
          end

        live_form =
          socket.assigns.live_form
          |> Map.put(:active_step, active_step)
          |> Map.put(:action, :fill)

        {:noreply, assign(socket, live_form: live_form)}
      end

      defp prepare_live_form(socket) do
        changeset = @schema.changeset(%@schema{}, %{})
        live_form = %FormData{changeset: changeset}
        assign(socket, live_form: live_form)
      end

      defp update_form_and_validate_step(live_form, attrs) do
        live_form = update_form(live_form, attrs)

        res =
          if inputs_of_active_step_have_errors?(live_form.changeset, attrs) do
            :error
          else
            :ok
          end

        {res, live_form}
      end

      defp update_form(live_form, attrs) do
        store =
          live_form
          |> Map.get(:store)
          |> Map.merge(attrs)

        changeset = @schema.changeset(%@schema{}, store)

        live_form
        |> Map.put(:store, store)
        |> Map.put(:changeset, changeset)
      end

      defp inputs_of_active_step_have_errors?(changeset, attrs) do
        attribute_names =
          attrs
          |> Map.keys()
          |> Enum.map(&String.to_atom/1)

        changeset.errors
        |> Keyword.take(attribute_names)
        |> Enum.any?()
      end

      defp move_forward(%{active_step: @steps, store: store}, socket) do
        submit_form(store, socket)
      end

      defp move_forward(live_form, socket) do
        live_form =
          live_form
          |> Map.put(:active_step, live_form.active_step + 1)
          |> Map.put(:action, :fill)

        {:noreply, assign(socket, live_form: live_form)}
      end

      defp show_active_step_errors(live_form, socket) do
        live_form = Map.put(live_form, :action, :revise)
        {:noreply, assign(socket, live_form: live_form)}
      end
    end
  end
end
