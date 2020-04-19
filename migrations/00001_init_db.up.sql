CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name varchar(255) NOT NULL
);

CREATE TABLE threads (
    id BIGSERIAL PRIMARY KEY,
    title varchar(255) NOT NULL,
    create_time TIMESTAMP DEFAULT NOW()
);

CREATE TABLE comments (
    id BIGSERIAL PRIMARY KEY,
    thread_id BIGINT REFERENCES threads(id) ON UPDATE CASCADE ON DELETE CASCADE,
    parent_id BIGINT REFERENCES comments(id) ON UPDATE CASCADE ON DELETE CASCADE, 
    user_id BIGINT REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE, 
    message TEXT NOT NULL,
    depth INT NOT NULL,
    parent_path ltree NOT NULL,
    path ltree GENERATED ALWAYS AS (parent_path || LPAD(id::varchar(64), 64, '0')) STORED,
    upvote int NOT NULL DEFAULT 0,
    downvote int NOT NULL DEFAULT 0,
    score int GENERATED ALWAYS AS (upvote - downvote) STORED,
    create_time TIMESTAMP DEFAULT NOW()
);

CREATE INDEX comments_thread_id_path ON comments USING btree(thread_id, path);
CREATE INDEX comments_thread_id_score ON comments USING btree(thread_id, score);