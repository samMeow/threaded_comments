# frozen_string_literal: true

require 'sequel'

module Models
  # threads table
  class Thread < Sequel::Model
    one_to_many :comments, class: 'Models::Comment'
    one_to_one :first_comment, class: 'Models::Comment', order: :id
  end
end

# Table: threads
# Columns:
#  id          | bigint                      | PRIMARY KEY DEFAULT nextval('threads_id_seq'::regclass)
#  title       | character varying(255)      | NOT NULL
#  create_time | timestamp without time zone | DEFAULT now()
# Indexes:
#  threads_pkey | PRIMARY KEY btree (id)
# Referenced By:
#  comments | comments_thread_id_fkey | (thread_id) REFERENCES threads(id) ON UPDATE CASCADE ON DELETE CASCADE
