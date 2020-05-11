# frozen_string_literal: true

require 'sequel'

module Models
  # user
  class User < Sequel::Model
    one_to_many :comments
  end
end

# Table: users
# Columns:
#  id          | bigint                      | PRIMARY KEY DEFAULT nextval('users_id_seq'::regclass)
#  name        | character varying(255)      | NOT NULL
#  create_time | timestamp without time zone | DEFAULT now()
# Indexes:
#  users_pkey | PRIMARY KEY btree (id)
# Referenced By:
#  comments | comments_user_id_fkey | (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
