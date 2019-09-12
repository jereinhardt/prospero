# Prospero

Prospero is a tool that helps you easily build multi-step forms in Phoenix.  Because Prospero works through Phoenix LiveView, these forms are completely client-side.  Prospero also leverages Ecto Changesets for easy client-side validation.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `prospero` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:prospero, github: "https://github.com/jereinhardt/prospero"}
  ]
end
```

## Setup

### In the LiveView File

Most of the configuration for Prospero will be done in the live view file.  There are two required options when using Prospero:
  
- `:steps` - the total number of steps your form has.
- `:schema` - The changeset schema Prospero should use to manage and validate user input.

When you mount your live view file, you will need to call `prepare_live_form/2` with the socket to update the socket with all the necessary assigns.  You can pass in an optional second argument to assign any preset data to the schema struct the form will be initialized with.

Finally, you will need to define a `submit_form/2` callback.  This callback will perform any actions necessary to complete the form submission.  In most cases, this will be applying CRUD actions to the database.  It will take two arguments.  The first is a map—which is the final parameters submitted by the form—and the second is the socket.  It can return any value that is an expected return value of `Phoenix.LiveView.handle_callback/3`.  The return value should be a response that either redirects the user or displays an error message.

```elixir
defmodule DnDApplicationWeb.CharacterLive.New do
  alias DnDApplication.{Character, Repo}
  alias DnDApplicationWeb.Router.Helpers, as: Routes

  use Prospero.LiveForm, schema: Character, steps: 3

  def mount(session, socket) do
    data = Map.get(session, :character, %{})
    {:ok, prepare_live_form(socket, data)}
  end

  @impl true
  def submit_form(params, socket) do
    changeset = Character.changeset(%Character{}, params)
    case Repo.insert(changeset) do
      {:ok, character} ->
        {
          :stop
          socket
          |> put_flash(:info, "character created")
          |> redirect(to: Routes.characters_path(socket, :show, character))
        }
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Something went wrong"}
    end
  end
end
```

### In your Views and Templates

Make sure to import `Prospero.View` in the rendered view.  This will allow you to access Prospero's helper methods in your template.

```elixir
  defmodule DnDApplicationWeb.CharacterView do
    import Prospero.View
  end
```

Prospero creates an assign in your templates called `@live_form`.  Use this assign with Phoenix's `form_for` functions to begin building your multi-step form.  Whenever you want to enclose a part of your template in step, use Prospero's `form_step/3` function.

```eex
<%= form_for @live_form, "#", fn f -> %>
  <%= form_step f, 1 do %>
    <%= label f, :name %>
    <%= text_input f, :name %>
    <%= error_tag f, :name %>

    <%= submit "Next" %>
  <%= end %>

  <%= form_step f, 2 do %>
    <%= label f, :race %>
    <%= text_input f, :race %>
    <%= error_tag f, :race %>

    <%= label f, :class %>
    <%= text_input f, :class %>
    <%= error_tag f, :race %>
  
    <%= back_button "Back" %>
    <%= submit "Next" %>
  <% end %>

  <%= form_step f, 3 do %>
    <%= label f, :description %>
    <%= textarea f, :description %>

    <%= back_button "Back" %>
    <%= submit "Create Character" %>
  <% end %>
<% end %>
```