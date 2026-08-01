defmodule SambaWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use SambaWeb, :html

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  attr :current_user, Samba.Accounts.User
  slot :inner_block, required: true
  attr :uri, URI, default: %URI{}

  def app(assigns) do
    ~H"""
    <div class="flex flex-col h-screen bg-gray-100">
      <!-- Top Navigation -->
      <.top_nav current_user={@current_user} />

      <!-- Main Content with Left Menu -->
      <div class="flex flex-1 overflow-hidden">
        <!-- Left Menu -->
        <aside
          class="w-64  shadow-md p-4 transform transition-all duration-300 ease-in-out md:relative md:translate-x-0"
          id="sidebar"
          x-data="{ open: false }"
          x-bind:class="{ 'translate-x-0': open, '-translate-x-full': !open }"
        >
          <button
            @click="open = !open"
            class="md:hidden absolute top-4 right-4 text-gray-600 hover:text-gray-900"
          >
            <svg
              class="h-6 w-6"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M4 6h16M4 12h16m-7 6h7"
              >
              </path>
            </svg>
          </button>
          <nav>
            <.left_nav menu={SambaWeb.Menu.left_menu(@current_user)} uri={@uri} />
          </nav>
        </aside>

        <!-- Main Content -->
        <main class="flex-1 p-2 bg-white overflow-auto">
          <div class="card card-content bg-c">{render_slot(@inner_block)}</div>
          <.flash_group flash={@flash} />
        </main>
      </div>
    </div>
    """
  end

  attr :current_user, Samba.Accounts.User, required: false
  def top(assigns) do
    ~H"""
    <!-- Top Navigation Bar -->
    <nav class="bg-gray-300 border-b border-gray-300 px-2 py-2 text-xs rounded-t-sm">
      <div class="flex justify-between">
        <div id="header_nav_block">
          <%= if @current_user do %>
            Hello, {@current_user.username}
            <span class="ml-2">
              | <.link navigate="/sign-out">Log out</.link>
              | <.link navigate="/dashboard">Control Panel</.link>
              | <.link navigate="/messages">PMs: 0 new messages</.link>
              | <.link navigate="#">Help</.link>
              | <.link navigate="#">Donate</.link>
              | <.link navigate="#">Premium Membership</.link>
              | <.link navigate="#">Merch</.link>
            </span>
          <% else %>
            Hello! <.link navigate="/sign-in" class="underline">Log in</.link>
            or <.link navigate="/register" class="underline">Register</.link>
            <span class="ml-2">
              | <.link navigate="#">Help</.link>
              | <.link navigate="#">Donate</.link>
              | <.link navigate="#">Premium Membership</.link>
              | <.link navigate="#">Merch</.link>
            </span>
          <% end %>
        </div>
        <div class="space-x-1">
          <.link navigate="/allbanners">See all banner ads</.link>
          |
          <.link navigate="/banners">
            Advertise on
            <script>
              document.write(window.location.hostname);
            </script>
          </.link>
        </div>
      </div>
    </nav>

    <header class="text-white">
            <div class="flex py-2 bg-[#293F4F] justify-between">
              <.link navigate={~p"/"}>
                <.image src="/images/logo.svg" alt="Logo" class="h-16 px-4" />
              </.link>
              <div class="flex flex-col justify-end px-2"><.theme_toggle /></div>
            </div>
            <div class="rounded-b-sm relative flex items-center justify-between bg-[#42637B] px-4 py-1 dark:bg-neutral-950">
              <!-- Empty spacer div matching the search bar width to balance the layout and keep the menu truly centered -->
              <div class="w-1/8 invisible pointer-events-none"></div>

              <div class="flex items-center flex-wrap justify-center gap-1">
                <.menu
                  id="home_dropdown"
                  open_on_hover="true"
                  side_offset={0}
                  trigger_class="flex h-8 items-center justify-center gap-1.5 dark:border-white bg-slate-550 dark:bg-neutral-950 pl-3 pr-2 text-sm font-normal text-white dark:text-white select-none hover:not-data-[disabled]:bg-slate-700 dark:hover:not-data-[disabled]:bg-slate-700 data-[popup-open]:bg-slate-700 dark:data-[popup-open]:bg-neutral-800"
                  popup_class="relative origin-[var(--transform-origin)]  dark:border-white bg-slate-700 dark:bg-neutral-950 py-1 text-white dark:text-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
                >
                  <:trigger>
                    <.link navigate="/"> Home </.link>
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M12 6H4l4 4.5z" /></svg>
                  </:trigger>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-slate-700 data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/whats_new">What's New</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/search">Search</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/products">Store</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/donate">Donate</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/contact">Contact/Feedback</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/faq">Help/FAQs</.link>
                  </:item>
                </.menu>

                <.menu
                  id="classifieds_dropdown"
                  open_on_hover="true"
                  side_offset={0}
                  trigger_class="flex h-8 items-center justify-center gap-1.5 dark:border-white bg-slate-550 dark:bg-neutral-950 pl-3 pr-2 text-sm font-normal text-white dark:text-white select-none hover:not-data-[disabled]:bg-slate-700 dark:hover:not-data-[disabled]:bg-slate-700 data-[popup-open]:bg-slate-700 dark:data-[popup-open]:bg-neutral-800"
                  popup_class="relative origin-[var(--transform-origin)]  dark:border-white bg-slate-700 dark:bg-neutral-950 py-1 text-white dark:text-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
                >
                  <:trigger>
                    <.link navigate="/classifieds">Classifieds</.link>
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M12 6H4l4 4.5z" /></svg>
                  </:trigger>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-slate-700 data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/classifieds/add">Place An Ad</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/classifieds/recent">All Recent Ads</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/classifieds/new">New Ads Only</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/classifieds/new_cars">New Cars Only</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/classifieds/search">Search</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/classifieds/manage">Manage My Ads</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/classifieds/watched">Watched Ads</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/classifieds/alerts">Alerts</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/classifieds/rules">Rules</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/classifieds/fees">Fees</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/classifieds/scam">Scam Info</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/classifieds/faq">Help/Faqs</.link>
                  </:item>
                </.menu>

                <.menu
                  id="gallery_dropdown"
                  open_on_hover="true"
                  side_offset={0}
                  trigger_class="flex h-8 items-center justify-center gap-1.5 dark:border-white bg-slate-550 dark:bg-neutral-950 pl-3 pr-2 text-sm font-normal text-white dark:text-white select-none hover:not-data-[disabled]:bg-slate-700 dark:hover:not-data-[disabled]:bg-slate-700 data-[popup-open]:bg-slate-700 dark:data-[popup-open]:bg-neutral-800"
                  popup_class="relative origin-[var(--transform-origin)]  dark:border-white bg-slate-700 dark:bg-neutral-950 py-1 text-white dark:text-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
                >
                  <:trigger>
                    <.link navigate="/gallery">Gallery</.link>
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M12 6H4l4 4.5z" /></svg>
                  </:trigger>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-slate-700 data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/gallery/add">Add Photos</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/gallery/all">View All</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/gallery/search">Search</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/gallery/faq">Help/Faqs</.link>
                  </:item>
                </.menu>

                <.menu
                  id="forums_dropdown"
                  open_on_hover="true"
                  side_offset={0}
                  trigger_class="flex h-8 items-center justify-center gap-1.5 dark:border-white bg-slate-550 dark:bg-neutral-950 pl-3 pr-2 text-sm font-normal text-white dark:text-white select-none hover:not-data-[disabled]:bg-slate-700 dark:hover:not-data-[disabled]:bg-slate-700 data-[popup-open]:bg-slate-700 dark:data-[popup-open]:bg-neutral-800"
                  popup_class="relative origin-[var(--transform-origin)]  dark:border-white bg-slate-700 dark:bg-neutral-950 py-1 text-white dark:text-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
                >
                  <:trigger>
                    <.link navigate="/forum">Forums</.link>
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M12 6H4l4 4.5z" /></svg>
                  </:trigger>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-slate-700 data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/forum/search">Search</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/forum/memberlist">Memberlist</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/forum/rules">Rules</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/chat">Chat</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/forum/rss">RSS</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/forum/faq">Help/Faqs</.link>
                  </:item>
                </.menu>

                <.menu
                  id="community_dropdown"
                  open_on_hover="true"
                  side_offset={0}
                  trigger_class="flex h-8 items-center justify-center gap-1.5 dark:border-white bg-slate-550 dark:bg-neutral-950 pl-3 pr-2 text-sm font-normal text-white dark:text-white select-none hover:not-data-[disabled]:bg-slate-700 dark:hover:not-data-[disabled]:bg-slate-700 data-[popup-open]:bg-slate-700 dark:data-[popup-open]:bg-neutral-800"
                  popup_class="relative origin-[var(--transform-origin)]  dark:border-white bg-slate-700 dark:bg-neutral-950 py-1 text-white dark:text-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
                >
                  <:trigger>
                    <.link navigate="/community">Community</.link>
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M12 6H4l4 4.5z" /></svg>
                  </:trigger>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-slate-700 data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/shows">Shows</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/clubs">Clubs</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/links">Links</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/shops">Businesses</.link>
                  </:item>
                </.menu>

                <.menu
                  id="archives_dropdown"
                  open_on_hover="true"
                  side_offset={0}
                  trigger_class="flex h-8 items-center justify-center gap-1.5 dark:border-white bg-slate-550 dark:bg-neutral-950 pl-3 pr-2 text-sm font-normal text-white dark:text-white select-none hover:not-data-[disabled]:bg-slate-700 dark:hover:not-data-[disabled]:bg-slate-700 data-[popup-open]:bg-slate-700 dark:data-[popup-open]:bg-neutral-800"
                  popup_class="relative origin-[var(--transform-origin)]  dark:border-white bg-slate-700 dark:bg-neutral-950 py-1 text-white dark:text-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
                >
                  <:trigger>
                    <.link navigate="/archives">Archives</.link>
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M12 6H4l4 4.5z" /></svg>
                  </:trigger>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-slate-700 data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/literature">Literature</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/press_photos">Press Photos</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/postcards">Postcards</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/artwork">Artwork</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/vintage_ads">Vintage Ads</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/backgrounds">Backgrounds</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/registry">Registry</.link>
                  </:item>
                </.menu>

                <.menu
                  id="technical_dropdown"
                  open_on_hover="true"
                  side_offset={0}
                  trigger_class="flex h-8 items-center justify-center gap-1.5 dark:border-white bg-slate-550 dark:bg-neutral-950 pl-3 pr-2 text-sm font-normal text-white dark:text-white select-none hover:not-data-[disabled]:bg-slate-700 dark:hover:not-data-[disabled]:bg-slate-700 data-[popup-open]:bg-slate-700 dark:data-[popup-open]:bg-neutral-800"
                  popup_class="relative origin-[var(--transform-origin)]  dark:border-white bg-slate-700 dark:bg-neutral-950 py-1 text-white dark:text-white shadow-[0.25rem_0.25rem_0] shadow-black/12 dark:shadow-none outline-hidden transition-[scale,opacity] duration-100 ease-out data-[ending-style]:scale-[0.98] data-[ending-style]:opacity-0 data-[starting-style]:scale-[0.98] data-[starting-style]:opacity-0"
                >
                  <:trigger>
                    <.link navigate="/technical">Technical</.link>
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M12 6H4l4 4.5z" /></svg>
                  </:trigger>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-slate-700 data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/manuals">Owners Manuals</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/chassis_dating">Vin/Chassis Numbers</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/m_codes">M-Codes</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/wiring">Wiring</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/colors">Paint/Upholstery</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/dictionary">Dictionary</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/tools">Tool Listing</.link>
                  </:item>
                  <:item class="flex cursor-default py-2 pr-8 pl-4 text-sm select-none outline-hidden data-[highlighted]:relative data-[highlighted]:before:absolute data-[highlighted]:before:inset-x-1 data-[highlighted]:before:inset-y-0 data-[highlighted]:before:-z-10 data-[highlighted]:before:bg-slate-500 dark:data-[highlighted]:before:bg-white data-[highlighted]:text-white dark:data-[highlighted]:text-neutral-950">
                    <.link navigate="/dealers">Dealer Listings</.link>
                  </:item>
                </.menu>
              </div>

              <div class="w-1/8">
                <.form_wrapper for={assigns[:search_form]} method="get" action={~p"/search"}>
                  <.search_field
                    name="q"
                    value=""
                    placeholder=""
                    search_button
                    class="text-xs"
                    size="extra-small"
                  />
                </.form_wrapper>
              </div>
            </div>
          </header>
    """
  end
  attr :current_user, Samba.Accounts.User, required: true
  def top_nav(assigns) do
    ~H"""
    <.top current_user={@current_user} />
    <nav class="bg-white p-4 flex justify-between items-center border border-b border-gray-200 md:flex-row flex-col">
      <div
        class="text-xl font-semibold mb-2 md:mb-0 hover:cursor-pointer text-primary  p-3 rounded-sm"
        phx-click={JS.navigate(~p"/")}
      >
        {app_name(@current_user)}
      </div>
      <.top_search_box />
      <div class="flex space-x-4">
        <span class="text-sm"></span>

        <div class="dropdown dropdown-end">
          <div tabindex="0" role="button" class="btn btn-ghost">
            <span class="text-sm">
              {@current_user.email |> to_string() |> Phoenix.Naming.humanize()}
            </span>
          </div>
          <ul tabindex="0" class="dark:text-white dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52">
            <li>
              <a
                :if={SambaWeb.Helpers.impersonated?(@current_user)}
                class="bg-warning text-warning-content"
                href={~p"/accounts/users/stop/impersonation"}
              >
                <.icon name="hero-arrow-uturn-left-solid" />{gettext("Back to My Account")}
              </a>
            </li>
            <li><a href={"/profile/#{@current_user.phpbb_user_id || @current_user.id}"}><.icon name="hero-user-circle-solid" />{gettext("Profile")}</a></li>
            <li>
              <a><.icon name="hero-cog-6-tooth-solid" />{gettext("Settings")}</a>
            </li>

            <li>
              <a href={~p"/sign-out"}>
                <.icon name="hero-arrow-right-start-on-rectangle-solid" /> {gettext("Sign Out")}
              </a>
            </li>
          </ul>
        </div>
      </div>
    </nav>
    """
  end

  attr :active, :boolean, default: false
  attr :href, :string, required: true
  attr :icon, :string, default: nil
  slot :inner_block

  def left_nav_link(assigns) do
    ~H"""
    <a
      href={@href}
      class={[
        "group -mx-2 -my-1 w-full inline-flex items-center gap-3 rounded-lg px-2 py-1 hover:text-primary hover:bg-base-100 hover:border hover:border-primary",
        @active && "w-full bg-primary text-primary-content"
      ]}
    >
      <.icon name={@icon} class="w-5 h-5" /> {render_slot(@inner_block)}
    </a>
    """
  end

  attr :uri, URI, default: %URI{path: "/"}
  attr :menu, :any, default: []

  def left_nav(assigns) do
    ~H"""
    <div :for={section <- @menu} class="mb-4">
      <h3 :if={section.title} class="text-md font-semibold text-primary/90 uppercase mb-2">
        {section.title}
      </h3>
      <ul class="space-y-2">
        <li :for={link <- section.links}>
          <.left_nav_link
            href={link.href}
            icon={link.icon}
            active={@uri.path == link.href}
          >
            {link.text}
          </.left_nav_link>
        </li>
      </ul>
    </div>
    """
  end

  defp top_search_box(assigns) do
    ~H"""
    <div class="relative w-[400px]">
      <div class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-500 pointer-events-none">
        <.icon name="hero-magnifying-glass" class="w-6 h-6" />
      </div>
      <input
        type="search"
        class="w-full pl-12 pr-4 py-3 border border-gray-200 rounded-md bg-gray-50 text-base focus:outline-none focus:ring-1 focus:ring-gray-700 focus:border-gray-700 focus:bg-white placeholder-gray-500"
        placeholder="Search members, reports and more…"
      />
    </div>
    """
  end

  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_user, Samba.Accounts.User, required: true
  slot :inner_block, required: true
  attr :uri, URI, default: %URI{}

  def merchants(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} uri={@uri}>
      <h1 class="text-3xl font-bold mb-6">{gettext("New Merchant")}</h1>

      {render_slot(@inner_block)}
    </Layouts.app>
    """
  end

  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_user, Samba.Accounts.User, required: true
  slot :inner_block, required: true
  attr :uri, URI, default: %URI{}

  def ussd(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} uri={@uri}>
      <h1 class="text-3xl font-bold mb-6">{gettext("ussd")}</h1>

      {render_slot(@inner_block)}
    </Layouts.app>
    """
  end

  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_user, Samba.Accounts.User, required: true
  slot :inner_block, required: true
  attr :uri, URI, default: %URI{}

  def account_users(assigns) do
    ~H"""
    <.app flash={@flash} current_user={@current_user} uri={@uri}>
      <h1 class="text-3xl font-bold mb-6">{gettext("Users")}</h1>
      <.button variant="primary" phx-click={JS.patch("/accounts/users/invite")}>
        {gettext("Invite User")}
      </.button>
      {render_slot(@inner_block)}
    </.app>
    """
  end

  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_user, Samba.Accounts.User, required: true
  slot :inner_block, required: true
  attr :uri, URI, default: %URI{}

  def ledger(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} uri={@uri}>
      <h1 class="text-3xl font-bold mb-6">{gettext("Ledger")}</h1>

      <.button variant="primary" phx-click={JS.patch(~p"/ledger/chart-of-accounts/new")}>
        <.icon name="hero-plus-solid" />
        {gettext("NeW Account")}
      </.button>
      {render_slot(@inner_block)}
    </Layouts.app>
    """
  end

  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_user, Samba.Accounts.User, required: true
  slot :inner_block, required: true
  attr :uri, URI, default: %URI{}

  def account_groups(assigns) do
    ~H"""
    <.app flash={@flash} current_user={@current_user} uri={@uri}>
      <h1 class="text-3xl font-bold mb-6">{gettext("User Groups")}</h1>

      <.button variant="primary" phx-click={JS.patch("/accounts/groups/new")}>
        {gettext("New Group")}
      </.button>
      {render_slot(@inner_block)}
    </.app>
    """
  end

  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_user, Samba.Accounts.User, required: true
  slot :inner_block, required: true
  attr :uri, URI, default: %URI{}

  def account_teams(assigns) do
    ~H"""
    <.app flash={@flash} current_user={@current_user} uri={@uri}>
      <.button variant="primary" phx-click={JS.patch("/accounts/teams/new")}>
        {gettext("New Team")}
      </.button>
      {render_slot(@inner_block)}
    </.app>
    """
  end

  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_user, Samba.Accounts.User, required: true
  slot :inner_block, required: true
  attr :uri, URI, default: %URI{}

  def account_profile(assigns) do
    ~H"""
    <.app flash={@flash} current_user={@current_user} uri={@uri}>
      {render_slot(@inner_block)}
    </.app>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-400 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  defp app_name(%{username: nil}), do: ""
  defp app_name(%{username: name}), do: Phoenix.Naming.humanize(name)
  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"
end
