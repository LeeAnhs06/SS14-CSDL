CREATE DATABASE IF NOT EXISTS Bai6ss14;
USE Bai6ss14;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    friends_count INT DEFAULT 0
);

CREATE TABLE friend_requests (
    request_id INT PRIMARY KEY AUTO_INCREMENT,
    from_user_id INT NOT NULL,
    to_user_id INT NOT NULL,
    status ENUM('pending','accepted','rejected') DEFAULT 'pending',
    FOREIGN KEY (from_user_id) REFERENCES users(user_id),
    FOREIGN KEY (to_user_id) REFERENCES users(user_id)
);

CREATE TABLE friends (
    user_id INT,
    friend_id INT,
    PRIMARY KEY (user_id, friend_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (friend_id) REFERENCES users(user_id)
);

INSERT INTO users (username) VALUES
('user_a'),
('user_b'),
('user_c');

INSERT INTO friend_requests (from_user_id, to_user_id) VALUES
(1, 2),
(3, 2);

DELIMITER $$

CREATE PROCEDURE sp_accept_friend_request(
    IN p_request_id INT,
    IN p_to_user_id INT
)
BEGIN
    DECLARE v_from_user_id INT;
    DECLARE v_status VARCHAR(10);

    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    START TRANSACTION;

    SELECT from_user_id, status
    INTO v_from_user_id, v_status
    FROM friend_requests
    WHERE request_id = p_request_id
      AND to_user_id = p_to_user_id
    FOR UPDATE;

    IF v_from_user_id IS NULL OR v_status <> 'pending' THEN
        ROLLBACK;
    ELSE
        IF EXISTS (
            SELECT 1 FROM friends
            WHERE user_id = v_from_user_id
              AND friend_id = p_to_user_id
        ) THEN
            ROLLBACK;
        ELSE
            INSERT INTO friends (user_id, friend_id)
            VALUES
                (v_from_user_id, p_to_user_id),
                (p_to_user_id, v_from_user_id);

            UPDATE users
            SET friends_count = friends_count + 1
            WHERE user_id IN (v_from_user_id, p_to_user_id);

            UPDATE friend_requests
            SET status = 'accepted'
            WHERE request_id = p_request_id;

            COMMIT;
        END IF;
    END IF;
END$$

DELIMITER ;

CALL sp_accept_friend_request(1, 2);

SELECT * FROM users;
SELECT * FROM friends;
SELECT * FROM friend_requests;

CALL sp_accept_friend_request(1, 2);
