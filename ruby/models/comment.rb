# frozen_string_literal: true

module Models
  # comments table
  class Comment < Sequel::Model(:comments)
    many_to_one :user
    many_to_one :thread

    def to_public
      json_serializer_opts(except: %i[path parent_path])
      self
    end

    dataset_module do
      def to_public
        json_serializer_opts(except: %i[path parent_path])
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
