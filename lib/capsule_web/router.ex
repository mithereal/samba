defmodule CapsuleWeb.Router do
  use Spaceboy.Router

  alias CapsuleWeb.Controller

  route "/", Controller, :index
  route "/forums", Controller, :forums
  route "/forum", Controller, :forum
  route "/topics", Controller, :topics
  route "/topic", Controller, :topic
end
