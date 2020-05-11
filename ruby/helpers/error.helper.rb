# frozen_string_literal: true

# for sinatra
module ErrorHelper
  def json_error(code, message)
    halt code, { code: code, message: message }.to_json
  end
end
