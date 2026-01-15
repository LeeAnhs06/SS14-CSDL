CREATE DATABASE IF NOT EXISTS Bai1ss14;
USE Bai1ss14;

DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    posts_count INT DEFAULT 0
);

CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO users (username) VALUES
('user_a'),
('user_b');

START TRANSACTION;
INSERT INTO posts (user_id, content)
VALUES (1, 'Bai viet dau tien');
UPDATE users
SET posts_count = posts_count + 1
WHERE user_id = 1;
COMMIT;

START TRANSACTION;
INSERT INTO posts (user_id, content)
VALUES (1, 'Bai viet loi');
UPDATE users
SET posts_count = posts_count + 1
WHERE user_id = 1;
ROLLBACK;

SELECT * FROM users;
SELECT * FROM posts;
