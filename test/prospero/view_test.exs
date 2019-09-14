defmodule Prospero.ViewTest do
  use ExUnit.Case

  import Phoenix.HTML
  import Phoenix.HTML.Tag, only: [content_tag: 3]

  describe "form_step/3" do
    test "returns escaped content when active step matches the step number" do
      live_form_data = %Prospero.FormData{active_step: 1}
      form = %Phoenix.HTML.Form{source: live_form_data}
      content = ~e"<h1>Hello World</h1>"

      result = Prospero.View.form_step form, 1, do: content

      assert result == html_escape(content)
    end

    test "returns nothing when active step does not match the step number" do
      live_form_data = %Prospero.FormData{active_step: 2}
      form = %Phoenix.HTML.Form{source: live_form_data}
      content = ~e"<h1>Hello World!</h1>"

      result = Prospero.View.form_step form, 1, do: content

      assert result == nil
    end
  end

  describe "back_button/1" do
    test "it returns an escaped button with the given string content" do
      content = "Back"
      opts = ["phx-click": "move_back", type: "button"]

      result = Prospero.View.back_button(content)

      assert result == content_tag(:button, content, opts)
    end

    test "it returns an escaped button with the html content given" do
      content = ~E"<span class='icon'></span>Back"
      opts = ["phx-click": "move_back", type: "button"]

      result = Prospero.View.back_button(do: content)

      assert result == content_tag(:button, opts, do: content)
    end
  end

  describe "back_button/2" do
    test "it returns an escaped button with the given attributes and string content" do
      content = "Back"
      attributes = [role: "button"]
      opts = Keyword.merge(attributes, ["phx-click": "move_back", type: "button"])

      result = Prospero.View.back_button(content, attributes)

      assert result == content_tag(:button, content, opts)
    end

    test "it returns an escaped button with the given attributes and html content" do
      content = ~E"<span class='icon'></span>Back"
      attributes = [role: "button"]
      opts = Keyword.merge(attributes, ["phx-click": "move_back", type: "button"])

      result = Prospero.View.back_button(attributes, do: content)

      assert result == content_tag(:button, content, opts)
    end
  end
end