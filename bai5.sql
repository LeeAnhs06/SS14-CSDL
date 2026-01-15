CREATE DATABASE IF NOT EXISTS Bai5ss14;
USE Bai5ss14;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS delete_log;
DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

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

CREATE TABLE likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE delete_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    deleted_by INT,
    deleted_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (username, posts_count) VALUES
('user_a', 2),
('user_b', 1),
('user_c', 0);

INSERT INTO posts (user_id, content) VALUES
(1, 'Bai viet cua user_a - 1'),
(1, 'Bai viet cua user_a - 2'),
(2, 'Bai viet cua user_b - 1');

INSERT INTO likes (post_id, user_id) VALUES
(1, 2),
(1, 3),
(2, 2),
(3, 1);

INSERT INTO comments (post_id, user_id, content) VALUES
(1, 2, 'Binh luan 1 cho post 1'),
(1, 3, 'Binh luan 2 cho post 1'),
(2, 1, 'Binh luan 1 cho post 2'),
(3, 1, 'Binh luan 1 cho post 3'),
(3, 2, 'Binh luan 2 cho post 3');
DELIMITER $$

CREATE PROCEDURE sp_delete_post(
    IN p_post_id INT,
    IN p_user_id INT
)
BEGIN
    DECLARE v_owner INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    SELECT user_id INTO v_owner
    FROM posts
    WHERE post_id = p_post_id;

    IF v_owner IS NULL OR v_owner <> p_user_id THEN
        ROLLBACK;
    ELSE
        DELETE FROM likes WHERE post_id = p_post_id;

        DELETE FROM comments WHERE post_id = p_post_id;

        DELETE FROM posts WHERE post_id = p_post_id;

        UPDATE users
        SET posts_count = posts_count - 1
        WHERE user_id = p_user_id;

        INSERT INTO delete_log(post_id, deleted_by)
        VALUES (p_post_id, p_user_id);

        COMMIT;
    END IF;
END $$

DELIMITER ;
CALL sp_delete_post(1, 1);

CALL sp_delete_post(1, 2);

SELECT * FROM posts;
SELECT * FROM likes;
SELECT * FROM comments;
SELECT * FROM users;
SELECT * FROM delete_log;
