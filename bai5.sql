use social_network;
delimiter $$
create procedure sp_delete_post(in p_postid int ,in p_userid int)
begin
    declare ispost int default 0;
    start transaction ;
    select count(*) into ispost from posts
        where post_id=p_postid and user_id=p_userid;
    if ispost=0 then
        rollback ;
        signal sqlstate '45000'
        set message_text ='khong co bai viet nao';
    end if;
    delete from comments
    where post_id=p_postid;
    delete from likes
        where post_id=p_postid;
    delete from posts
        where post_id=p_postid;
   if row_count() = 0 then
       rollback ;
        signal sqlstate '45000'
        set message_text ='delete that bai';
   end if ;
      commit ;
end $$;