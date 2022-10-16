defmodule Worldmate.ParseResult do
  @moduledoc """
  Parsed result of a Worldmate parsing result
  """

  alias Worldmate.ItineraryParser

  defstruct status: nil,
            request_id: nil,
            headers: %{},
            flights: []

  @status_codes ~w[
    SUCCESS
    PARTIAL_SUCCESS
    UNSUPPORTED
    NO_DATA
    INSUFFICIENT_DATA
    NO_ITEMS
    EXTERNAL_ERROR
    INTERNAL_ERROR
    UNRECOGNIZED_FORMAT
    REPEATED_FAILURE
    ACCOUNT_SUSPENDED
    QUOTA_EXCEDEED
  ]

  # Define a question method for each known status code
  # For example: success?(%ParseResult{status: "SUCCESS"}) => true
  for code <- @status_codes do
    def unquote(:"#{String.downcase(code)}?")(%__MODULE__{status: "#{unquote(code)}"}), do: true
    def unquote(:"#{String.downcase(code)}?")(%__MODULE__{}), do: false
  end

  def from_xml(xmlstr) do
    xmlstr
    |> ItineraryParser.parse_xml()
    |> case do
      {:ok, doc} -> {:ok, ItineraryParser.to_parse_result(doc)}
      {:error, _} = res -> res
      _ -> {:error, :unknown_result}
    end
  end
end
