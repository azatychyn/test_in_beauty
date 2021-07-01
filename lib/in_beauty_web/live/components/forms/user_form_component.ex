defmodule InBeautyWeb.Forms.UserFormComponent do
  @moduledoc """

    <%= live_component(@socket, UserFormComponent,
          required_fields: [:first_name, :last_name],
          fields: [:first_name, :last_name],
          button_text: "Sigh up",
          live_action: "sight_up",
          id_prefix: "sign_up",
          mobile: false
    )
    %>
  """

  use InBeautyWeb, :live_component

  import Process, only: [send_after: 3]

  alias InBeauty.Accounts
  alias InBeauty.Accounts.User
  alias InBeautyWeb.InputComponent

  @defaults %{
    required_fields: [],
    fields: [],
    button_text: "",
    live_action: "",
    form_action: "#",
    handle_events: [],
    id_prefix: "",
    mobile: false
  }

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, @defaults)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~L"""
      <div class="flex flex-col mx-3 mb-6">
        <%= f = form_for @changeset, @form_action, @handle_events ++ [class: "grid grid-flow-row grid-cols-1 grid-rows-7 gap-2"] %>
          <%= for field <- @fields do %>
            <%= live_component(@socket, InputComponent,
                  [
                    field: field,
                    form: f,
                    label: humanize(field),
                    required: required?(field, @required_fields),
                    id_prefix: @id_prefix,
                    mobile: @mobile
                  ]
                )
            %>
          <% end %>
          <div class="col-span-1 mx-auto">
            <%= submit @button_text, phx_disable_with: gettext("Saving..."), class: "w-full text-xl text-black font-semibold uppercase mx-auto py-2 px-6 rounded-2xl bg-bright-pink-dribble text-white mt-4 hover:bg-bright-pink-dribble hover:text-white hover:shadow focus:outline-none" %>
          </div>
        </form>
      </div>
    """
  end

  def required?(field, required_fields) do
    if field in required_fields, do: true, else: false
  end
end
