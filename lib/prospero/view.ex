defmodule Prospero.View do
  @moduledoc """
  Helpers related to producing multi-step HTML forms.
  """

  import Phoenix.HTML, only: [html_escape: 1]
  import Phoenix.HTML.Tag, only: [content_tag: 3]

  @doc """
  Generates markup for the given step.

  Markup is only inserted into the DOM if the active step of the current form is
  the same as `step_num`.

    <%= form_step form, 1 do %>
      <h1>This is the first step</h1>
      <%= label form, :name %>
      <%= text_input form, :name %>
      <%= submit "Next Step" %>
    <% end %> 
  """
  @spec form_step(Phoenix.HTML.FormData.t(), integer, Keyword.t()) :: Phoenix.HTML.safe() | nil
  def form_step(%{source: %{active_step: active_step}}, step_num, do: content) do
    if active_step == step_num, do: html_escape(content)
  end

  @doc """
  Generates a `<button>` tag that will decrease the form's active step back by 1
  when clicked.

  Can be given a string or a block to generate content within the button tag.

    <%= back_button "Back" %>

    <%= back_button do %>
      <span class="back-arrow-icon"></span>
      Back
    <% end %>
  """
  @spec back_button(Keyword.t() | String.t()) :: Phoenix.HTML.safe()
  def back_button(do: content) do
    content_tag(:button, content, "phx-click": "move_back", type: "button")
  end

  def back_button(content) when is_binary(content) do
    content_tag(:button, content, "phx-click": "move_back", type: "button")
  end

  @doc ~S"""
  Generates a `<button>` tag which, when clicked, will change the active step
  of the form to the step before the current active step.  The first argument
  can be the text that should be used as the buttons content, followed by a
  keyword list of attributes that should be applied to the button tag.  Or the
  first argument can be the keyword list of attributes, followed by a content
  block that should be used as the button's content.

    <%= back_button "Back", [role: :button] %>

    <%= back_button [role: :button] do %>
      <span class="back-arrow-icon"></span>
      Back
    <% end %>
  """
  @spec back_button(Keyword.t() | String.t(), Keyword.t()) :: Phoenix.HTML.safe()
  def back_button(attrs, do: content) do
    merged_attrs = Keyword.merge(attrs, [type: "button"])
    back_button(content, merged_attrs)
  end

  def back_button(content, attrs) when is_list(attrs) do
    merged_attrs = Keyword.merge(attrs, ["phx-click": "move_back", type: "button"])
    content_tag(:button, content, merged_attrs)
  end
end
