USE social_network;

START TRANSACTION;

-- 1. Thêm bài viết mới (user_id = 1 tồn tại)
INSERT INTO posts (user_id, content, created_at)
VALUES (1, 'Transaction test - success case', NOW());


UPDATE users
SET post_count = post_count + 1
WHERE user_id = 1;


COMMIT;
START TRANSACTION;
INSERT INTO posts (user_id, content, created_at)
VALUES (999, 'Transaction test - error case', NOW());
UPDATE users
SET post_count = post_count + 1
WHERE user_id = 999;
ROLLBACK;