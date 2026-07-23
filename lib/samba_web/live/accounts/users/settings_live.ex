defmodule SambaWeb.Accounts.Users.SettingsLive do
  use SambaWeb, :live_view
  on_mount {SambaWeb.LiveUserAuth, :live_user_required}

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.account_profile flash={@flash} current_user={@current_user} uri={@uri}>
    <div class="max-w-4xl mx-auto bg-white rounded-lg shadow overflow-hidden my-6">
   <.form for={@form} phx-change="validate" phx-submit="save" id="user-preferences-form" class="divide-y divide-gray-200">



    <!-- Registration Information Section -->
    <div class="bg-gray-50 px-4 py-3 sm:px-6">
      <h2 class="text-base font-semibold leading-6 text-gray-900">
        {gettext("Registration Information")}
      </h2>
      <p class="mt-1 text-xs text-gray-500">
        {gettext("Some of the boxes below will not apply to you or may be confusing so if in doubt, leave the field(s) blank or at the default settings.")}
      </p>
    </div>

    <div class="px-4 py-2 bg-amber-50 sm:px-6 text-xs text-amber-800">
      {gettext("Items marked with a * are required unless stated otherwise.")}
    </div>

    <!-- Fields Grid -->
    <div class="divide-y divide-gray-200 bg-white">

      <!-- Username -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
        <div class="flex items-center space-x-2 text-sm font-medium text-gray-700">
          <span>{gettext("Username:")} *</span>
        </div>
        <div class="sm:col-span-2 flex items-center space-x-2">
          <input type="hidden" name="username" value="">
          <span class="text-sm font-bold text-gray-900"></span>
        </div>
      </div>

      <!-- E-mail address -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-start">
        <div>
          <div class="flex items-center space-x-2 text-sm font-medium text-gray-700">
            <span>{gettext("E-mail address:")} *</span>
          </div>
          <p class="mt-1 text-xs text-gray-500">
            {gettext("Note: If you are changing your email on the site, this could break your classifieds feedback link.  If you have a feedback thread, please")} <a href="mailto:everettb@thesamba.com?subject=Email change - Update Feedback link for datatwister" class="text-blue-600 underline">{gettext("Email Everett")}</a> {gettext("to update your feedback thread.  Nothing else will be affected.")}
          </p>
        </div>
        <div class="sm:col-span-2 flex flex-col sm:flex-row gap-2 items-start sm:items-center">
          <input type="text" name="email" value="" maxlength="255" class="w-full sm:w-72 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm border p-2">
        </div>
      </div>

      <!-- Confirm your email address -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
        <div class="text-sm font-medium text-gray-700">
          {gettext("Confirm your email address:")} *
        </div>
        <div class="sm:col-span-2">
          <input type="text" name="email_confirm" value="" maxlength="255" class="w-full sm:w-72 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm border p-2">
        </div>
      </div>

      <!-- Current password -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-start">
        <div>
          <span class="text-sm font-medium text-gray-700">{gettext("Current password:")} *</span>
          <p class="mt-1 text-xs text-gray-500">{gettext("You must confirm your current password if you wish to change it or alter your e-mail address")}</p>
        </div>
        <div class="sm:col-span-2">
          <input type="password" name="cur_password" maxlength="32" class="w-full sm:w-72 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm border p-2">
        </div>
      </div>

      <!-- New password -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-start">
        <div>
          <span class="text-sm font-medium text-gray-700">{gettext("New password:")} *</span>
          <p class="mt-1 text-xs text-gray-500">{gettext("You only need to supply a password if you want to change it")}</p>
        </div>
        <div class="sm:col-span-2">
          <input type="password" name="new_password" maxlength="32" class="w-full sm:w-72 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm border p-2">
        </div>
      </div>

      <!-- Confirm password -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-start">
        <div>
          <span class="text-sm font-medium text-gray-700">{gettext("Confirm password:")} *</span>
          <p class="mt-1 text-xs text-gray-500">{gettext("You only need to confirm your password if you changed it above")}</p>
        </div>
        <div class="sm:col-span-2">
          <input type="password" name="password_confirm" maxlength="32" class="w-full sm:w-72 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm border p-2">
        </div>
      </div>

    </div>

    <!-- Actions Footer -->
    <div class="bg-gray-50 px-4 py-3 sm:px-6 flex items-center justify-center space-x-4">
      <input type="submit" name="submit" value="Submit" class="inline-flex justify-center rounded-md bg-blue-600 py-2 px-4 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600 cursor-pointer">
      <input type="reset" value="Reset" name="reset" class="inline-flex justify-center rounded-md bg-white py-2 px-4 text-sm font-semibold text-gray-950 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 cursor-pointer">
    </div>

    </.form>
    </div>
    </Layouts.account_profile>
    """
  end

  defp get_query(current_user) do
    require Ash.Query

    if SambaWeb.Helpers.is_super_user?(current_user) do
      Ash.Query.for_read(
        Samba.Accounts.User,
        :read,
        %{},
        authorize?: false,
        actor: current_user
      )
    else
      Ash.Query.for_read(
        Samba.Accounts.User,
        :admin_read,
        %{},
        authorize?: false,
        actor: current_user
      )
    end
  end
  def mount(_params, _session, socket) do
    socket
    |> assign(:after_submit_url, ~p"/accounts/users")
    |> assign_invite_form()
    |> ok()
  end

  defp assign_invite_form(socket) do
    form =
      Samba.Accounts.User
      |> AshPhoenix.Form.for_create(:invite,
           actor: socket.assigns.current_user,
           authorize?: false
         )
      |> to_form()

    assign(socket, :form, form)
  end
end
