defmodule UeberauthSlack.TestHelpers do

  def bypass_server(%Bypass{port: port}) do
    "http://localhost:#{port}"
  end
end
