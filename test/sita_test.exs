defmodule SitaTest do
  use ExUnit.Case
  import Tesla.Mock

  setup do
    mock fn
      %{method: :get, url: "https://airport.api.aero/airport/v2/airport/CPH"} ->
        %Tesla.Env{
          status: 200,
          headers: [{"content-type", "application/json"}],
          body: ~S"""
          {"processingDurationMillis":0,"authorisedAPI":true,"success":true,"airline":null,"errorMessage":null,"airports":[{"name":"Kastrup","city":"Copenhagen","country":"Denmark","timezone":"Europe/Copenhagen","lat":55.617917,"lng":12.655972,"terminal":null,"gate":null,"iatacode":"CPH","icaocode":"EKCH"}]}
          """
        }
    end

    :ok
  end

  doctest Sita
end
