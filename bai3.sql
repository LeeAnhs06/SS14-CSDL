CREATE DATABASE IF NOT EXISTS Bai3ss14;
USE Bai3ss14;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS follow_log;
DROP TABLE IF EXISTS followers;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    following_count INT DEFAULT 0,
    followers_count INT DEFAULT 0
);

INSERT INTO users (username) VALUES
('user_a'),
('user_b'),
('user_c');

CREATE TABLE followers (
    follower_id INT NOT NULL,
    followed_id INT NOT NULL,
    PRIMARY KEY (follower_id, followed_id),
    FOREIGN KEY (follower_id) REFERENCES users(user_id),
    FOREIGN KEY (followed_id) REFERENCES users(user_id)
);

CREATE TABLE follow_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    follower_id INT,
    followed_id INT,
    error_message VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE PROCEDURE sp_follow_user(
    IN p_follower_id INT,
    IN p_followed_id INT
)
BEGIN
    DECLARE v_count INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        INSERT INTO follow_log(follower_id, followed_id, error_message)
        VALUES (p_follower_id, p_followed_id, 'SQL Exception');
    END;

    START TRANSACTION;
    IF p_follower_id = p_followed_id THEN
        INSERT INTO follow_log(follower_id, followed_id, error_message)
        VALUES (p_follower_id, p_followed_id, 'Khong the tu follow chinh minh');
        ROLLBACK;

    ELSEIF NOT EXISTS (SELECT 1 FROM users WHERE user_id = p_follower_id)
        OR NOT EXISTS (SELECT 1 FROM users WHERE user_id = p_followed_id) THEN
        INSERT INTO follow_log(follower_id, followed_id, error_message)
        VALUES (p_follower_id, p_followed_id, 'User khong ton tai');
        ROLLBACK;

    ELSE
        SELECT COUNT(*) INTO v_count
        FROM followers
        WHERE follower_id = p_follower_id
          AND followed_id = p_followed_id;

        IF v_count > 0 THEN
            INSERT INTO follow_log(follower_id, followed_id, error_message)
            VALUES (p_follower_id, p_followed_id, 'Da follow truoc do');
            ROLLBACK;

        ELSE
            INSERT INTO followers(follower_id, followed_id)
            VALUES (p_follower_id, p_followed_id);

            UPDATE users
            SET following_count = following_count + 1
            WHERE user_id = p_follower_id;

            UPDATE users
            SET followers_count = followers_count + 1
            WHERE user_id = p_followed_id;

            COMMIT;
        END IF;
    END IF;
END $$

DELIMITER ;


CALL sp_follow_user(1, 2);   -- Thành công
CALL sp_follow_user(1, 1);   -- Tự follow (FAIL)
CALL sp_follow_user(1, 99);  -- User không tồn tại (FAIL)
CALL sp_follow_user(1, 2);   -- Follow trùng (FAIL)

SELECT * FROM followers;

SELECT user_id, username, following_count, followers_count
FROM users;

SELECT * FROM follow_log;
