defmodule SambaWeb.PhpController do
  use SambaWeb, :controller

  def album_search(_) do
    #    ~H"""
    #    <div class="mt-4 max-w-8xl mx-auto px-2 py-4 text-zinc-900 dark:text-zinc-100 bg-white dark:bg-zinc-950 transition-colors">
    #      <!-- Breadcrumb / Navigation Index -->
    #      <div class="mb-4">
    #        <.link navigate={~p"/forum"} class="text-indigo-600 dark:text-indigo-400 hover:underline text-sm font-medium">
    #          &laquo; Forum Index
    #        </.link>
    #      </div>
    #
    #      <!-- Main Profile Box -->
    #      <div class="border border-zinc-300 dark:border-zinc-800 rounded-lg overflow-hidden shadow-sm bg-white dark:bg-zinc-900">
    #        <!-- Header -->
    #        <div class="bg-[#293F4F] text-white px-4 py-3 font-bold text-base flex justify-between items-center">
    #          <span>Viewing profile :: <%= @user.username %></span>
    #        </div>
    #
    #        <!-- Table Grid Layout matching phpBB subSilver structure -->
    #        <div class="grid grid-cols-1 md:grid-cols-12 divide-y md:divide-y-0 md:divide-x divide-zinc-200 dark:divide-zinc-800">
    #
    #          <!-- Left Column: Avatar & Actions -->
    #          <div class="md:col-span-4 p-4 bg-zinc-50 dark:bg-zinc-900/50 flex flex-col items-center text-center justify-between">
    #            <div class="space-y-4 w-full">
    #              <div class="font-bold text-sm text-zinc-700 dark:text-zinc-300 pb-2 border-b border-zinc-200 dark:border-zinc-800">
    #                Avatar
    #              </div>
    #
    #              <!-- Avatar / Offline Status Block -->
    #              <div class="py-6 flex flex-col items-center justify-center space-y-3">
    #                <div class="w-24 h-24 rounded bg-zinc-200 dark:bg-zinc-800 flex items-center justify-center text-zinc-400">
    #                  <svg class="w-12 h-12" fill="currentColor" viewBox="0 0 24 24">
    #                    <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
    #                  </svg>
    #                </div>
    #
    #                <div class="text-xs text-zinc-500 dark:text-zinc-400 space-y-1">
    #                  <div class="flex items-center justify-center space-x-1.5">
    #                    <span class="inline-block w-2.5 h-2.5 rounded-full bg-zinc-400"></span>
    #                    <span><%= @user.username %> is offline</span>
    #                  </div>
    #                </div>
    #              </div>
    #            </div>
    #
    #            <!-- Buddy & Ignore Links -->
    #            <div class="w-full pt-4 border-t border-zinc-200 dark:border-zinc-800 text-xs space-y-1 text-indigo-600 dark:text-indigo-400">
    #              <div>
    #                <.link navigate={~p"/forum/profile.php?mode=viewprofile&u=#{@user.user_id}&buddy=add&b=#{@user.user_id}"} class="hover:underline">
    #                  Add to your buddylist
    #                </.link>
    #              </div>
    #              <div>
    #                <.link navigate={~p"/forum/profile.php?mode=viewprofile&u=#{@user.user_id}&buddy=fadd&b=#{@user.user_id}"} class="hover:underline">
    #                  Add to your ignore list
    #                </.link>
    #              </div>
    #              <div>
    #                <.link navigate={~p"/forum/profile.php?mode=viewprofile&u=#{@user.user_id}&buddy=fadd_class&b=#{@user.user_id}"} class="hover:underline">
    #                  Add to your classifieds ignore list
    #                </.link>
    #              </div>
    #            </div>
    #          </div>
    #
    #          <!-- Right Column: User Stats & Contact Info -->
    #          <div class="md:col-span-8 p-4 bg-white dark:bg-zinc-900 space-y-6">
    #
    #            <!-- Section: All About User -->
    #            <div>
    #              <div class="font-bold text-sm text-zinc-700 dark:text-zinc-300 pb-2 border-b border-zinc-200 dark:border-zinc-800 mb-3">
    #                All about <%= @user.username %>
    #              </div>
    #
    #              <div class="grid grid-cols-1 sm:grid-cols-3 gap-y-2.5 text-sm">
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Joined:</div>
    #                <div class="sm:col-span-2 font-bold text-zinc-900 dark:text-zinc-100"><%= @user.joined_date %></div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Last Visited:</div>
    #                <div class="sm:col-span-2 font-bold text-zinc-900 dark:text-zinc-100"><%= @user.last_visited %></div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Total posts:</div>
    #                <div class="sm:col-span-2">
    #                  <span class="font-bold text-zinc-900 dark:text-zinc-100"><%= @user.total_posts %></span>
    #                  <div class="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
    #                    [<%= @user.posts_percentage %>% of total / <%= @user.posts_per_day %> posts per day]
    #                  </div>
    #                  <div class="text-xs mt-1">
    #                    <.link navigate={~p"/forum/search.php?search_author=#{@user.username}"} class="text-indigo-600 dark:text-indigo-400 hover:underline">
    #                      Find all posts by <%= @user.username %>
    #                    </.link>
    #                  </div>
    #                </div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Topics started:</div>
    #                <div class="sm:col-span-2 text-xs">
    #                  <.link navigate={~p"/forum/search.php?search_id=usertopics&user=#{@user.user_id}"} class="text-indigo-600 dark:text-indigo-400 hover:underline">
    #                    Find all topics started by <%= @user.username %>
    #                  </.link>
    #                </div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Total photos:</div>
    #                <div class="sm:col-span-2 text-xs">
    #                  <span class="font-bold text-zinc-900 dark:text-zinc-100"><%= @user.total_photos %></span>
    #                  <div class="mt-0.5">
    #                    <.link navigate={~p"/forum/album_search.php?search_author=#{@user.username}"} class="text-indigo-600 dark:text-indigo-400 hover:underline">
    #                      Find all photos from <%= @user.username %>
    #                    </.link>
    #                  </div>
    #                </div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Favorite photos:</div>
    #                <div class="sm:col-span-2 text-xs">
    #                  <span class="font-bold text-zinc-900 dark:text-zinc-100"><%= @user.favorite_photos %></span>
    #                  <div class="mt-0.5">
    #                    <.link navigate={~p"/forum/album_search.php?favorites_author=#{@user.username}"} class="text-indigo-600 dark:text-indigo-400 hover:underline">
    #                      Show <%= @user.username %>'s favorite photos
    #                    </.link>
    #                  </div>
    #                </div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Classified Ads:</div>
    #                <div class="sm:col-span-2 text-xs">
    #                  <span class="font-bold text-zinc-900 dark:text-zinc-100"><%= @user.classified_ads_count %></span>
    #                  <div class="text-zinc-500 dark:text-zinc-400 mt-0.5">All time: <%= @user.classified_ads_count %> ads</div>
    #                  <div class="mt-1">
    #                    <.link navigate={~p"/classifieds/search.php?username=#{@user.username}"} class="text-indigo-600 dark:text-indigo-400 hover:underline">
    #                      Find all classified ads from <%= @user.username %>
    #                    </.link>
    #                  </div>
    #                </div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Feedback:</div>
    #                <div class="sm:col-span-2 text-xs">
    #                  <.link navigate={~p"/forum/search.php?mode=results&search_terms=all&search_fields=feedback&show_results=topics&search_forum=14&search_cat=-1&search_keywords=#{@user.user_id}"} class="text-indigo-600 dark:text-indigo-400 hover:underline">
    #                    Search for feedback on <%= @user.username %>
    #                  </.link>
    #                </div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Location:</div>
    #                <div class="sm:col-span-2 font-bold text-zinc-900 dark:text-zinc-100"><%= @user.location %></div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Website:</div>
    #                <div class="sm:col-span-2 text-zinc-400">&nbsp;</div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Occupation:</div>
    #                <div class="sm:col-span-2 text-zinc-400">&nbsp;</div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Interests:</div>
    #                <div class="sm:col-span-2 text-zinc-400">&nbsp;</div>
    #              </div>
    #            </div>
    #
    #            <!-- Section: Contact Information -->
    #            <div class="pt-4 border-t border-zinc-200 dark:border-zinc-800">
    #              <div class="font-bold text-sm text-zinc-700 dark:text-zinc-300 pb-2 border-b border-zinc-200 dark:border-zinc-800 mb-3">
    #                Contact
    #              </div>
    #
    #              <div class="grid grid-cols-1 sm:grid-cols-3 gap-y-2.5 text-sm items-center">
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">E-mail address:</div>
    #                <div class="sm:col-span-2 text-zinc-400">&nbsp;</div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Private Message:</div>
    #                <div class="sm:col-span-2">
    #                  <.link navigate={~p"/forum/privmsg.php?mode=post&u=#{@user.user_id}"} class="inline-block">
    #                    <div class="bg-zinc-200 dark:bg-zinc-800 px-3 py-1 rounded text-xs font-medium hover:bg-zinc-300 dark:hover:bg-zinc-700 transition-colors inline-flex items-center space-x-1">
    #                      <span>Send private message</span>
    #                    </div>
    #                  </.link>
    #                </div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Facebook:</div>
    #                <div class="sm:col-span-2 text-zinc-400">&nbsp;</div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Twitter:</div>
    #                <div class="sm:col-span-2 text-zinc-400">&nbsp;</div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">Instagram:</div>
    #                <div class="sm:col-span-2 text-zinc-400">&nbsp;</div>
    #
    #                <div class="text-zinc-500 dark:text-zinc-400 text-right pr-4 font-medium">YouTube:</div>
    #                <div class="sm:col-span-2 text-zinc-400">&nbsp;</div>
    #
    #              </div>
    #            </div>
    #
    #          </div>
    #
    #        </div>
    #      </div>
    #    </div>
    #    """
  end
end
