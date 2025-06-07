defmodule PidbitWeb.ErrorJSONTest do
  use PidbitWeb.ConnCase, async: true

  test "renders 404" do
    assert PidbitWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert PidbitWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
