# frozen_string_literal: true

require 'sequel'

module Models
  # comments table
  class Comment < Sequel::Model
    many_to_one :user, class: 'Models::User'
    many_to_one :thread, class: 'Models::Thread'

    def to_public
      json_serializer_opts(except: %i[path parent_path], include: :user)
      self
    end

    dataset_module do
      def to_public
        json_serializer_opts(except: %i[path parent_path], include: :user)
        self
      end

      def grouped_order_with_time(dir = 'asc')
        temp = Sequel.function('subpath', :path, 0, 1)
        first_layer = dir == 'desc' ? Sequel.desc(temp) : temp
        order(first_layer).order_append(:path)
      end

      # SELECT c.*
      # FROM comments c
      # LEFT JOIN (
      #     SELECT id, score AS root_score
      #     FROM comments
      # ) p
      # ON TRIM('0' FROM subpath(c.path, 0, 1)::text)::BIGINT = p.id
      # WHERE thread_id = 1
      # ORDER BY root_score desc, path;
      def order_with_popular
        join(
          Comment.select(:id, Sequel.as(:score, 'root_score')),
          id: Sequel.lit('ltrim(subpath(path, 0, 1)::TEXT, \'0\')::bigint')
        )
          .reverse_order(Sequel.lit('root_score'))
          .order_append(Sequel.desc(Sequel.function('subpath', :path, 0, 1)))
          .order_append(:path)
          .select_all(:comments)
      end
    end
  end
end

# Table: comments
# Columns:
#  id          | bigint                      | PRIMARY KEY DEFAULT nextval('comments_id_seq'::regclass)
#  thread_id   | bigint                      |
#  parent_id   | bigint                      |
#  user_id     | bigint                      |
#  message     | text                        | NOT NULL
#  depth       | integer                     | NOT NULL DEFAULT 0
#  parent_path | ltree                       | NOT NULL DEFAULT ''::ltree
#  path        | ltree                       | DEFAULT (parent_path || lpad(((id)::character varying(64))::text, 64, '0'::text))
#  upvote      | integer                     | NOT NULL DEFAULT 0
#  downvote    | integer                     | NOT NULL DEFAULT 0
#  score       | integer                     | DEFAULT (upvote - downvote)
#  create_time | timestamp without time zone | DEFAULT now()
# Indexes:
#  comments_pkey            | PRIMARY KEY btree (id)
#  comments_thread_id_path  | btree (thread_id, path)
#  comments_thread_id_score | btree (thread_id, score)
# Foreign key constraints:
#  comments_parent_id_fkey | (parent_id) REFERENCES comments(id) ON UPDATE CASCADE ON DELETE CASCADE
#  comments_thread_id_fkey | (thread_id) REFERENCES threads(id) ON UPDATE CASCADE ON DELETE CASCADE
#  comments_user_id_fkey   | (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
# Referenced By:
#  comments | comments_parent_id_fkey | (parent_id) REFERENCES comments(id) ON UPDATE CASCADE ON DELETE CASCADE
