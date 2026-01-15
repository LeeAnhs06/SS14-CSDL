use social_network;
alter table posts
    add column count int default 0;
delimiter $$
create procedure com(in p_postid int, in p_userid int, in content text)
begin
    start transaction ;
    INSERT INTO comments(post_id, user_id, content)
    VALUES (p_postid, p_userid, content);
    savepoint poin;
    update posts
        set count=count+1
    where post_id=p_postid;
    if row_count()=0 then
        rollback to poin;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Update post thất bại, rollback về savepoint';
    end if;
    commit ;
end $$;