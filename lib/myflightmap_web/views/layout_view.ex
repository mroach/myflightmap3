defmodule MyflightmapWeb.LayoutView do
  use MyflightmapWeb, :view

  def error_class("error"), do: "danger"
  def error_class(type), do: type
end
