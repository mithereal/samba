defmodule SambaWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides
  alias AshAuthentication.Phoenix.{Components, SignInLive, ResetLive}

  # Target the main sign-in live container
  override SignInLive do
    set :root_class, "rounded-sm min-h-screen bg-gradient-to-b from-gray-300 from-70% to-gray-600 to-90%  text-gray-900 flex flex-col justify-between py-12 px-4 sm:px-6 lg:px-8"
  end

  # Override the standard sign-in live container and ensure base text is light
  override Components.SignIn do
    set :root_class, "w-full max-w-md mx-auto text-gray-900 [&_label]:text-gray-900 [&_input]:text-gray-300 [&_input]:bg-gray-500"
  end

  # Target the identity/email input field component
  override Components.Password.IdentityField do
    set :label_class, "block text-sm font-medium text-gray-200"
    set :input_class, "mt-1 block w-full rounded-md border-gray-700 bg-gray-300 text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm [&_input]:bg-gray-300"
  end

  # If using standard password sign-in forms
  override Components.Password.SignInForm do
    set :form_class, "space-y-6 "
    set :label_class, "block text-sm font-medium text-gray-900"
    set :input_class, "mt-1 block w-full rounded-md border-gray-700 bg-gray-300 text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
  end

  # If using standard password registration forms
  override Components.Password.RegisterForm do
    set :form_class, "space-y-6"
    set :label_class, "block text-sm font-medium text-gray-900"
  end
end