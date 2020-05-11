# frozen_string_literal: true

module Models
  # threads table
  class Thread < Sequel::Model(:threads)
    one_to_many :comments
    one_to_one :first_comment, class: :Comment, order: :id
  end
end
