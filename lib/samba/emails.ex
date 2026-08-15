defmodule Samba.Emails do
  use PhoenixEmail

  def welcome(assigns) do
    ~H"""
    <.email>
      <.head />
      <.preview>You're in — let's get you set up</.preview>
      <.body style="background-color:#ffffff;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif">
        <.container style="padding:20px 48px">
          <.heading as="h1" style="font-size:24px;color:#1a1a1a">Hello {@name}</.heading>
          <.text style="color:#525f7f">Thanks for signing up. Click the button below to get started.</.text>
          <.button href={@url} style="background-color:#5e6ad2;color:#ffffff;padding:12px 20px;border-radius:8px;font-size:14px">
            Get started
          </.button>
          <.hr style="margin:24px 0" />
          <.link href="https://example.com" style="font-size:12px">example.com</.link>
        </.container>
      </.body>
    </.email>
    """
  end
end

