# New Samba

This is a port of one of the oldest websites on the internet from php to elixir/phoenix

## FEATURES

1. Responsive Website vs Tables
2. Secure (passes modern security audits)
3. Websockets for Instant Notification
4. Modern Chat System
5. Modern Classifieds System
6. Adapted PhpBB Table structure for postgres
7. Routing Structure Preserved (this will not break users bookmarks etc)
8. Import Tools
9. Business Maps
10. Seo Friendly
11. Swagger API

###### User Impersonation

1. Super user is added to the `super_users` list in the config/config.exs  
2. Super users can go to Settings > Users > and see Impersonate button
3. If clicked, super users access the application as if they are the user they are impersonating
4. Super Users can Go back to their account by clicking on top right menu and select "Go Back to My Account"


## Installation

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Dump your phpbb2 database and place in `priv/data_dumps` then run the migration script `mix run priv/repo/migrate_dumps.exs`
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

### Phoenix
* https://www.phoenixframework.org/
* https://hexdocs.pm/phoenix/overview.html
* Forum: https://elixirforum.com/c/phoenix-forum

### Ash
* https://ash-hq.org/
* https://hexdocs.pm/ash/readme.html
* https://elixirforum.com/c/ash-framework-forum/
