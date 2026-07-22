defmodule PhpBB.CSVParser do
  NimbleCSV.define(C, separator: ",", escape: "\"")

  # Delegate or alias the parser functions directly to your defined parser module (C)
  defdelegate parse_string(data, opts \\ []), to: C
  defdelegate parse_stream(stream, opts \\ []), to: C
  defdelegate stream_decoder(stream, opts \\ []), to: C
  defdelegate dump(rows), to: C
end
