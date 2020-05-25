DROP INDEX idx_reply_like_history_user_id_reply_id;

DROP TABLE reply_like_history;

DROP INDEX idx_replues_post_id_parent_id_create_time;
DROP INDEX idx_replies_user_id_create_time;
DROP INDEX idx_replies_parent_id_post_id_likes;

DROP TABLE replies;

DROP INDEX idx_posts_users_id_create_time;
DROP TABLE posts;
