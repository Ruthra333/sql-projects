use ig_clone;
select * from photos;

-- question no 1----How many times does the average user post?

select round(avg(posts),1) as average_user_posts
FROM (
    SELECT user_id, COUNT(*) as posts FROM photos
    GROUP BY user_id
) AS user_posts;

-- question no 2---Find the top 5 most used hashtags.

select tag_name, count(*) as cont from tags as t
join photo_tags as pt on pt.tag_id=t.id
group by tag_name
order by cont desc
limit 5;


-- question no 3 -- Find users who have liked every single photo on the site

SELECT id,username
FROM users
WHERE id NOT IN (
    SELECT DISTINCT l.user_id
    FROM likes l
    LEFT JOIN photos p ON l.photo_id = p.id
    WHERE p.id IS NULL
);


-- question no 4 -- Retrieve a list of users along with their usernames and the rank of their account creation, ordered by the creation date in ascending order.

select *,dense_rank() OVER (ORDER BY created_at) as acc_creation_rank FROM users;



-- question no 5 -- List the comments made on photos with their comment texts, photo URLs, and usernames of users who posted the comments. Include the comment count for each photo

select p.image_url as photo_url,c.comment_text,u.username as commenter_username,cc.comment_count from photos as p
join comments AS c ON p.id = c.photo_id
join users AS u ON c.user_id = u.id
join (
    select photo_id,COUNT(*) as comment_count from comments
   group by photo_id
) as cc on p.id = cc.photo_id
order by p.id, c.id;
    
    
    
-- question no 6 -- For each tag, show the tag name and the number of photos associated with that tag. Rank the tags by the number of photos in descending order.

select id,t.tag_name,COUNT(pt.photo_id) as num_photos from tags as t
left join photo_tags as pt on t.id = pt.tag_id
group by t.tag_name,id
order by num_photos DESC;

-- question no 7 -- List the usernames of users who have posted photos along with the count of photos they have posted. Rank them by the number of photos in descending order.

select username ,count(image_url) as photos_count from users as u
join photos as p on u.id=p.user_id
group by username
order by photos_count desc;

-- question no 8 -- Display the username of each user along with the creation date of their first posted photo and the creation date of their next posted photo.

with first_posted_photo as
(select p.user_id,min(p.created_at) as firstpost from photos as p
group by p.user_id),

next_posted_photo as  
(select p.user_id,min(p.created_at) as secondpost from photos as p 
where p.created_at>(select min(p.created_at) from photos as p )
group by p.user_id)

select username,firstpost,secondpost from users as u
left join first_posted_photo as uf on uf.user_id=u.id
left join  next_posted_photo as un on un.user_id=u.id;


-- question no 9 -- For each comment, show the comment text, the username of the commenter, and the comment text of the previous comment made on the same photo.


select  photo_id,comment_text as current_comment ,username,
lag(comment_text) over(partition by c.photo_id order by c.id) as previous_comment from comments as c
join users as u on u.id=c.user_id;


-- question no 10 --  Show the username of each user along with the number of photos they have posted and the number of photos posted by the user before them and after them, based on the creation date.

select u.username,COUNT(p.id) as photos_posted,
lag(COUNT(p.id)) over (order by MIN(p.created_at)) as photos_before,
lead(COUNT(p.id)) OVER (order by MIN(p.created_at)) as photos_after
from users as u
left join photos as p on u.id = p.user_id
group by u.username
order by photos_posted;







