USE social_network;

START TRANSACTION;
INSERT INTO likes (post_id, user_id, liked_at)
VALUES (3, 1, NOW());
UPDATE posts
SET like_count=like_count+1
WHERE post_id = 3;
COMMIT;
START TRANSACTION;
UPDATE posts
SET like_count=like_count+1
WHERE post_id = 3;
rollback ;