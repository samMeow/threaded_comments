# frozen_string_literal: true

module Models
  # user
  class User < Sequel::Model(:users)
    one_to_many :comments
  end
end
