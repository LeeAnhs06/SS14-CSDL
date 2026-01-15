CREATE DATABASE IF NOT EXISTS social_network;
USE social_network;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    posts_count INT DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    comments_count INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

INSERT INTO users (username) VALUES
('user_a'),
('user_b');

INSERT INTO posts (user_id, content) VALUES
(1, 'Bai viet so 1');

CREATE TABLE comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

DELIMITER $$

CREATE PROCEDURE sp_post_comment(
    IN p_post_id INT,
    IN p_user_id INT,
    IN p_content TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO comments(post_id, user_id, content)
    VALUES (p_post_id, p_user_id, p_content);

    SAVEPOINT after_insert;

    UPDATE posts
    SET comments_count = comments_count + 1
    WHERE post_id = p_post_id;

    IF ROW_COUNT() = 0 THEN
        ROLLBACK TO after_insert;
    ELSE
        COMMIT;
    END IF;
END $$

DELIMITER ;

CALL sp_post_comment(1, 1, 'Binh luan dau tien');

CALL sp_post_comment(999, 1, 'Binh luan loi');

SELECT * FROM comments;
SELECT post_id, content, comments_count FROM posts;
