# frozen_string_literal: true

# monkey patch time
class Time
  def to_s
    iso8601
  end
end
