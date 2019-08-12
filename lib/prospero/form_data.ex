defmodule Prospero.FormData do
  @doc """
  Defines the Prospero.FormData struct.

  Its fields are:

  * `:action` — the action being taken on the step.  Will be `:fill` by default
    and `:revise` if the form has actionable errors.
  * `:active_step` — the step number that is currently active.
  * `:changeset` — the changeset that is being used to process and validate user
    input.
  * `:store` — a collection of all the data that has been submitted by the form
    after each step.
  """

  alias Ecto.Changeset

  defstruct action: :fill,
            active_step: 1,
            changeset: nil,
            store: %{}

  @type t :: %__MODULE__{
          action: atom,
          active_step: integer,
          changeset: Changeset.t(),
          store: map
        }
end

if Code.ensure_loaded?(Phoenix.HTML.FormData) do
  defimpl Phoenix.HTML.FormData, for: Prospero.FormData do
    alias Phoenix.HTML.FormData, as: PhoenixFormData

    def to_form(%{changeset: changeset} = form_data, opts) do
      opts = opts_with_submit_callback(opts)
      {_, opts} = Keyword.pop(opts, :as)

      changeset
      |> PhoenixFormData.to_form(opts)
      |> Map.put(:errors, form_errors(form_data))
      |> Map.put(:source, form_data)
      |> Map.put(:impl, __MODULE__)
    end

    def to_form(%{changeset: changeset}, form, field, opts) do
      opts = opts_with_submit_callback(opts)
      PhoenixFormData.to_form(changeset, form, field, opts)
    end

    def input_value(%{changeset: changeset}, form, field) do
      PhoenixFormData.input_value(changeset, form, field)
    end

    def input_type(%{changeset: changeset}, form, field) do
      PhoenixFormData.input_type(changeset, form, field)
    end

    def input_validations(%{changeset: changeset}, form, field) do
      PhoenixFormData.input_validations(changeset, form, field)
    end

    defp opts_with_submit_callback(opts) do
      Keyword.put(opts, :"phx-submit", "submit_active_step")
    end

    defp form_errors(%{action: :fill}), do: []
    defp form_errors(%{action: :revise, changeset: changeset}), do: changeset.errors
  end
end
