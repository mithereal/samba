defmodule SambaWeb.Accounts.Users.PreferencesLive do
  use SambaWeb, :live_view
  on_mount {SambaWeb.LiveUserAuth, :live_user_required}

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.account_profile flash={@flash} current_user={@current_user} uri={@uri}>
   <div class="max-w-4xl mx-auto bg-white rounded-lg shadow overflow-hidden my-6">
    <.form for={@form} phx-change="validate" phx-submit="save" id="user-preferences-form" class="divide-y divide-gray-200">


    <!-- Preferences Section Header -->
    <div class="bg-gray-50 px-4 py-3 sm:px-6">
      <h2 class="text-base font-semibold leading-6 text-gray-900">
        {gettext("Preferences")}
      </h2>
      <p class="mt-1 text-xs text-gray-500">
        {gettext("Manage your display options, board settings, and notification preferences.")}
      </p>
    </div>

    <!-- Fields Grid -->
    <div class="divide-y divide-gray-200 bg-white">

      <!-- Users can contact me by email -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
        <div class="text-sm font-medium text-gray-700">{gettext("Users can contact me by email:")}</div>
        <div class="sm:col-span-2 flex items-center space-x-6">
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="viewemail" value="1" checked class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("Yes")}</span>
          </label>
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="viewemail" value="0" class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("No")}</span>
          </label>
        </div>
      </div>

      <!-- Hide your online status -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
        <div class="text-sm font-medium text-gray-700">{gettext("Hide your online status:")}</div>
        <div class="sm:col-span-2 flex items-center space-x-6">
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="hideonline" value="1" class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("Yes")}</span>
          </label>
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="hideonline" value="0" checked class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("No")}</span>
          </label>
        </div>
      </div>

      <!-- Always notify me of replies -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-start">
        <div>
          <span class="text-sm font-medium text-gray-700">{gettext("Always notify me of replies:")}</span>
          <p class="mt-1 text-xs text-gray-500">{gettext("Sends an e-mail when someone replies to a topic you have posted in. This can be changed whenever you post.")}</p>
        </div>
        <div class="sm:col-span-2 flex items-center space-x-6">
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="notifyreply" value="1" class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("Yes")}</span>
          </label>
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="notifyreply" value="0" checked class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("No")}</span>
          </label>
        </div>
      </div>

      <!-- Notify on new Private Message -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
        <div class="text-sm font-medium text-gray-700">{gettext("Notify on new Private Message:")}</div>
        <div class="sm:col-span-2 flex items-center space-x-6">
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="notifypm" value="1" checked class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("Yes")}</span>
          </label>
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="notifypm" value="0" class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("No")}</span>
          </label>
        </div>
      </div>

      <!-- Pop up window on new Private Message -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-start">
        <div>
          <span class="text-sm font-medium text-gray-700">{gettext("Pop up window on new Private Message:")}</span>
          <p class="mt-1 text-xs text-gray-500">{gettext("Some templates may open a new window to inform you when new private messages arrive.")}</p>
        </div>
        <div class="sm:col-span-2 flex items-center space-x-6">
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="popup_pm" value="1" checked class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("Yes")}</span>
          </label>
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="popup_pm" value="0" class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("No")}</span>
          </label>
        </div>
      </div>

      <!-- Always attach my signature -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
        <div class="text-sm font-medium text-gray-700">{gettext("Always attach my signature:")}</div>
        <div class="sm:col-span-2 flex items-center space-x-6">
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="attachsig" value="1" checked class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("Yes")}</span>
          </label>
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="attachsig" value="0" class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("No")}</span>
          </label>
        </div>
      </div>

      <!-- Always allow BBCode -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
        <div class="text-sm font-medium text-gray-700">{gettext("Always allow BBCode:")}</div>
        <div class="sm:col-span-2 flex items-center space-x-6">
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="allowbbcode" value="1" checked class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("Yes")}</span>
          </label>
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="allowbbcode" value="0" class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("No")}</span>
          </label>
        </div>
      </div>

      <!-- Always allow HTML -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
        <div class="text-sm font-medium text-gray-700">{gettext("Always allow HTML:")}</div>
        <div class="sm:col-span-2 flex items-center space-x-6">
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="allowhtml" value="1" checked class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("Yes")}</span>
          </label>
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="allowhtml" value="0" class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("No")}</span>
          </label>
        </div>
      </div>

      <!-- Always enable Smilies -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
        <div class="text-sm font-medium text-gray-700">{gettext("Always enable Smilies:")}</div>
        <div class="sm:col-span-2 flex items-center space-x-6">
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="allowsmilies" value="1" checked class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("Yes")}</span>
          </label>
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="allowsmilies" value="0" class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("No")}</span>
          </label>
        </div>
      </div>

      <!-- Display signatures in posts -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
        <div class="text-sm font-medium text-gray-700">{gettext("Display signatures in posts:")}</div>
        <div class="sm:col-span-2 flex items-center space-x-6">
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="signposts" value="1" checked class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("Yes")}</span>
          </label>
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="signposts" value="0" class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("No")}</span>
          </label>
        </div>
      </div>

      <!-- Display avatars in posts -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
        <div class="text-sm font-medium text-gray-700">{gettext("Display avatars in posts:")}</div>
        <div class="sm:col-span-2 flex items-center space-x-6">
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="avatars" value="1" checked class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("Yes")}</span>
          </label>
          <label class="inline-flex items-center text-sm text-gray-700">
            <input type="radio" name="avatars" value="0" class="text-blue-600 focus:ring-blue-500 border-gray-300">
            <span class="ml-2">{gettext("No")}</span>
          </label>
        </div>
      </div>

      <!-- Board Style -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
        <div class="text-sm font-medium text-gray-700">{gettext("Board Style:")}</div>
        <div class="sm:col-span-2">
          <select name="layout" class="w-full sm:w-72 rounded-md border-gray-300 shadow-sm border p-2 text-sm bg-white">
            <option value="subSilver" selected>subSilver</option>
          </select>
        </div>
      </div>

      <!-- Board Language -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
        <div class="text-sm font-medium text-gray-700">{gettext("Board Language:")}</div>
        <div class="sm:col-span-2">
          <select name="language" class="w-full sm:w-72 rounded-md border-gray-300 shadow-sm border p-2 text-sm bg-white">
            <option value="english" selected>English</option>
          </select>
        </div>
      </div>

      <!-- Timezone -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
        <div class="text-sm font-medium text-gray-700">{gettext("Timezone:")}</div>
        <div class="sm:col-span-2">
          <select name="timezone" class="w-full sm:w-72 rounded-md border-gray-300 shadow-sm border p-2 text-sm bg-white">
            <option value="-12">(GMT -12 Hrs) Eniwetok, Kwajalein</option>
            <option value="-11">(GMT -11 Hrs) Midway Island, Samoa</option>
            <option value="-10">(GMT -10 Hrs) Hawaii</option>
            <option value="-9">(GMT -9 Hrs) Alaska</option>
            <option value="-8">(GMT -8 Hrs) Pacific Time (US & Canada)</option>
            <option value="-7" selected>(GMT -7 Hrs) Mountain Time/Pacific Daylight Savings Time (US & Canada)</option>
            <option value="-6">(GMT -6 Hrs) Central Time (US & Canada), Mexico City</option>
            <option value="-5">(GMT -5 Hrs) Eastern Time (US & Canada), Bogota</option>
            <option value="-4">(GMT -4 Hrs) Atlantic (Canada), Caracas</option>
            <option value="-3.5">(GMT -3.5 Hrs) Newfoundland</option>
            <option value="-3">(GMT -3 Hrs) Brazil, Buenos Aires, Georgetown</option>
            <option value="-2">(GMT -2 Hrs) Mid-Atlantic</option>
            <option value="-1">(GMT -1 Hrs) Azores, Cape Verde Islands</option>
            <option value="0">(GMT) Western Europe, London</option>
            <option value="1">(GMT +1 Hr) CET, Brussels, Paris</option>
            <option value="2">(GMT +2 Hrs) EET, South Africa</option>
            <option value="3">(GMT +3 Hrs) Bagdad, Riyadh, Moscow, St Petersburg</option>
            <option value="3.5">(GMT +3.5 Hrs) Tehran</option>
            <option value="4">(GMT +4 Hrs) Abu Dhabi, Muscat, Baku, Tbilisi</option>
            <option value="4.5">(GMT +4.5 Hrs) Kabul</option>
            <option value="5">(GMT +5 Hrs) Ekaterinburg, Islamabad, Karachi, Tashkent</option>
            <option value="5.5">(GMT +5.5 Hrs) Bombay, Calcutta, Madras, New Delhi</option>
            <option value="6">(GMT +6 Hrs) Almaty, Dhaka, Columbo</option>
            <option value="6.5">(GMT +6.5 Hrs)</option>
            <option value="7">(GMT +7 Hrs) Bankok, Hanoi, Jakarta</option>
            <option value="8">(GMT +8 Hrs) Beijing, Perth, Singapore, Hong Kong</option>
            <option value="9">(GMT +9 Hrs) Tokyo, Seoul, Osaka, Sapporo, Yakutsk</option>
            <option value="9.5">(GMT +9.5 Hrs) Adelaide, Darwin</option>
            <option value="10">(GMT +10 Hrs) Guam, Melbourne, Sydney</option>
            <option value="11">(GMT +11 Hrs) Magadan, Solomon Islands, New Caledonia</option>
            <option value="12">(GMT +12 Hrs) Auckland, Wellington, Fiji, Kamchatka</option>
            <option value="13">GMT + 13 Hours</option>
          </select>
        </div>
      </div>

      <!-- Date format -->
      <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-start">
        <div>
          <span class="text-sm font-medium text-gray-700">{gettext("Date format:")}</span>
          <p class="mt-1 text-xs text-gray-500">{gettext("The syntax used is identical to the PHP date() function. DO NOT CHANGE THIS unless you understand what you are doing.")}</p>
        </div>
        <div class="sm:col-span-2">
          <input type="text" name="dateformat" value="Y-m-d H:i:s" maxlength="30" class="w-full sm:w-72 rounded-md border-gray-300 shadow-sm border p-2 text-sm">
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
