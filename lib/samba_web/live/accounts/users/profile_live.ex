defmodule SambaWeb.Accounts.Users.ProfileLive do
  use SambaWeb, :live_view
  on_mount {SambaWeb.LiveUserAuth, :live_user_required}

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.account_profile flash={@flash} current_user={@current_user} uri={@uri}>
  <div class="max-w-4xl mx-auto bg-white rounded-lg shadow overflow-hidden my-6">
          <.form for={@form} phx-change="validate" phx-submit="save" id="user-profile-form" class="divide-y divide-gray-200">

    <!-- Profile Information Section Header -->
    <div class="bg-gray-50 px-4 py-3 sm:px-6">
    <h2 class="text-base font-semibold leading-6 text-gray-900">
     {gettext("Profile Information")}
    </h2>
    <p class="mt-1 text-xs text-gray-500">
     {gettext("This information will be publicly viewable")}
    </p>
    </div>

    <!-- Fields Grid -->
    <div class="divide-y divide-gray-200 bg-white">

    <!-- Facebook -->
    <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
     <div class="text-sm font-medium text-gray-700">{gettext("Facebook:")}</div>
     <div class="sm:col-span-2"><input type="text" name="facebook" maxlength="255" class="w-full sm:w-64 rounded-md border-gray-300 shadow-sm border p-2 text-sm"></div>
    </div>

    <!-- Twitter -->
    <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
     <div class="text-sm font-medium text-gray-700">{gettext("Twitter:")}</div>
     <div class="sm:col-span-2"><input type="text" name="twitter" maxlength="255" class="w-full sm:w-64 rounded-md border-gray-300 shadow-sm border p-2 text-sm"></div>
    </div>

    <!-- Instagram -->
    <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
     <div class="text-sm font-medium text-gray-700">{gettext("Instagram:")}</div>
     <div class="sm:col-span-2"><input type="text" name="instagram" maxlength="255" class="w-full sm:w-64 rounded-md border-gray-300 shadow-sm border p-2 text-sm"></div>
    </div>

    <!-- YouTube -->
    <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
     <div class="text-sm font-medium text-gray-700">{gettext("YouTube:")}</div>
     <div class="sm:col-span-2"><input type="text" name="youtube" maxlength="255" class="w-full sm:w-64 rounded-md border-gray-300 shadow-sm border p-2 text-sm"></div>
    </div>

    <!-- Website -->
    <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
     <div class="text-sm font-medium text-gray-700">{gettext("Website:")}</div>
     <div class="sm:col-span-2"><input type="text" name="website" maxlength="255" class="w-full sm:w-72 rounded-md border-gray-300 shadow-sm border p-2 text-sm"></div>
    </div>

    <!-- Location -->
    <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
     <div class="text-sm font-medium text-gray-700">{gettext("Location:")}</div>
     <div class="sm:col-span-2"><input type="text" name="location" value="" maxlength="100" class="w-full sm:w-72 rounded-md border-gray-300 shadow-sm border p-2 text-sm"></div>
    </div>

    <!-- Occupation -->
    <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
     <div class="text-sm font-medium text-gray-700">{gettext("Occupation:")}</div>
     <div class="sm:col-span-2"><input type="text" name="occupation" value="" maxlength="100" class="w-full sm:w-72 rounded-md border-gray-300 shadow-sm border p-2 text-sm"></div>
    </div>

    <!-- Interests -->
    <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
     <div class="text-sm font-medium text-gray-700">{gettext("Interests:")}</div>
     <div class="sm:col-span-2"><input type="text" name="interests" value="" maxlength="150" class="w-full sm:w-72 rounded-md border-gray-300 shadow-sm border p-2 text-sm"></div>
    </div>

    <!-- Signature -->
    <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-start">
     <div>
       <div class="flex items-center space-x-2 text-sm font-medium text-gray-700">
         <span>{gettext("Signature:")}</span>
       </div>
       <p class="mt-1 text-xs text-gray-500">
         {gettext("This is a block of text that can be added to posts you make. There is a 500 character limit")}
         <br><br>
         {gettext("HTML is")} <u>ON</u><br>
         {gettext("Smilies are")} <u>ON</u>
       </p>
     </div>
     <div class="sm:col-span-2">
       <textarea name="signature" rows="6" class="w-full rounded-md border-gray-300 shadow-sm border p-2 text-sm"></textarea>
     </div>
    </div>

    <!-- Classifieds Signature -->
    <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-start">
     <div>
       <span class="text-sm font-medium text-gray-700">{gettext("Classifieds Signature:")}</span>
       <p class="mt-1 text-xs text-gray-500">{gettext("This block of text will be added to the bottom of every Classified Ad you post. Advertisers who have a lot of ads commonly use this for shipping or payment instructions. There is a 500 character limit")}</p>
     </div>
     <div class="sm:col-span-2">
       <textarea name="signature_class" rows="6" class="w-full rounded-md border-gray-300 shadow-sm border p-2 text-sm"></textarea>
     </div>
    </div>

    </div>

    <!-- Avatar Control Panel Section Header -->
    <div class="bg-gray-50 px-4 py-3 sm:px-6">
    <h2 class="text-base font-semibold leading-6 text-gray-900">
     {gettext("Avatar")}
    </h2>
    <p class="mt-1 text-xs text-gray-500">
     {gettext("Display a small graphic image below your details in posts. Only one image can be displayed at a time, its width can be no greater than 100 pixels, the height no greater than 100 pixels, and the file size no more than 65KB.")}
    </p>
    </div>

    <!-- Avatar Control Panel Fields Grid -->
    <div class="divide-y divide-gray-200 bg-white">

       <!-- Current Avatar -->
    <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
     <div class="text-sm font-medium text-gray-700">{gettext("Current Avatar:")}</div>
     <div class="sm:col-span-2 flex items-center space-x-4">
       <img src="/vw/images/avatars/gallery/blank.gif" alt="Avatar" class="h-16 w-16 object-cover border rounded">
       <label class="inline-flex items-center text-sm text-gray-700">
         <input type="checkbox" name="avatardel" value="1" class="text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
         <span class="ml-2">{gettext("Delete Avatar")}</span>
       </label>
     </div>
    </div>

    <!-- Upload Avatar from local PC -->
    <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-center">
     <div class="text-sm font-medium text-gray-700">{gettext("Upload Avatar from your local PC:")}</div>
     <div class="sm:col-span-2">
       <input type="file" name="avatar" class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100">
     </div>
    </div>

    <!-- Upload Avatar from a URL -->
    <div class="grid grid-cols-1 sm:grid-cols-3 px-4 py-4 sm:px-6 gap-4 items-start">
     <div>
       <span class="text-sm font-medium text-gray-700">{gettext("Upload Avatar from a URL:")}</span>
       <p class="mt-1 text-xs text-gray-500">{gettext("Enter the URL of the location of the Avatar image you wish to link, it will be copied to this site.")}</p>
     </div>
     <div class="sm:col-span-2">
       <input type="text" name="avatarurl" maxlength="255" class="w-full sm:w-72 rounded-md border-gray-300 shadow-sm border p-2 text-sm">
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
