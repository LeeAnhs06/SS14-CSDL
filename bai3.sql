use social_network;
delimiter $$
create procedure flower(in from_flower int,in to_flower int)
begin
    declare r_flow int default 0;
    start transaction ;
    if from_flower=to_flower then
        rollback ;
        signal sqlstate '45000'
        set message_text ='khong tu flow chinh minh';
    end if;
    select count(*) into r_flow from followers
        where follower_id=from_flower;
    if r_flow>0 then
       rollback ;
        signal sqlstate '45000'
        set message_text ='tai khoan da dc follow';
    end if ;
    insert into followers (follower_id, followee_id)
        values
            (from_flower,to_flower);
    update users
        set follower_count=follower_count+1
    where user_id=to_flower;
    commit ;
end $$;
call flower(1,2);