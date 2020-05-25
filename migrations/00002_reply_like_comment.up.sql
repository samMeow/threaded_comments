CREATE TABLE posts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE, 
    content TEXT DEFAULT '',
    create_time TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_posts_users_id_create_time ON posts USING btree(user_id, create_time);

CREATE TABLE replies (
    id BIGSERIAL PRIMARY KEY,
    parent_id BIGINT REFERENCES replies(id) ON UPDATE CASCADE ON DELETE CASCADE, 
    post_id BIGINT REFERENCES posts(id) ON UPDATE CASCADE ON DELETE CASCADE, 
    user_id BIGINT REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE, 
    message TEXT DEFAULT '',
    likes int NOT NULL DEFAULT 0,
    create_time TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_replues_post_id_parent_id_create_time ON replies USING btree(post_id, parent_id, create_time);
CREATE INDEX idx_replies_user_id_create_time ON replies USING btree(user_id, create_time);
CREATE INDEX idx_replies_parent_id_post_id_likes ON replies USING btree(post_id, parent_id, likes);

CREATE TABLE reply_like_history (
    user_id BIGINT REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    reply_id BIGINT REFERENCES replies(id) ON UPDATE CASCADE ON DELETE CASCADE,
    create_time TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_reply_like_history_user_id_reply_id ON reply_like_history USING btree(user_id, reply_id);