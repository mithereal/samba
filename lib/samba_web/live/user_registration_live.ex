defmodule SambaWeb.UserRegistrationLive do
  use SambaWeb, :live_view
  import Phoenix.Component

  def mount(_params, _session, socket) do
    form =
      Samba.Accounts.User
      |> AshPhoenix.Form.for_create(:register_with_password, as: "user")
      |> to_form()

    {:ok, assign(socket, form: form, altcha_token: nil)}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-md mx-auto mt-12 p-6 bg-white rounded-lg shadow">
      <h2 class="text-2xl font-bold mb-6">Register</h2>

      <.form for={@form} phx-submit="save" phx-change="validate">
        <.input field={@form[:email]} type="email" label="Email" />
        <.input field={@form[:password]} type="password" label="Password" />

        <div class="mt-4" id="altcha-root" phx-hook="AltchaHook" phx-update="ignore">
          <input type="hidden" name="user[altcha]" id="altcha-token-input" value="" />
          <div id="altcha-box">
            <altcha-widget challenge="/challenge"></altcha-widget>
          </div>
        </div>

        <div class="mt-6">
          <button type="submit" class="w-full py-2 px-4 bg-indigo-600 text-white rounded">
            Sign Up
          </button>
        </div>
      </.form>
    </div>
    """
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    form =
      Samba.Accounts.User
      |> AshPhoenix.Form.for_create(:register_with_password, as: "user")
      |> AshPhoenix.Form.validate(user_params)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    # When the form submits, params will include "user" => %{"altcha" => token, ...}
    case AshPhoenix.Form.submit(socket.assigns.form, params: user_params) do
      {:ok, _user} ->
        {:noreply, redirect(socket, to: ~p"/")}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end
end
