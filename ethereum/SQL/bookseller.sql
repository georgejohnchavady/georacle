INSERT INTO public.user(
	user_id, username, password, enabled)
	VALUES (1, 'george', '$2a$10$slYQmyNdGzTn7ZLBXBChFOC9f6kFjAqPhccnP6DxlWXx2lPk1C3G6', true);
	
select * from public.user

update public.user set password = '$2a$10$slYQmyNdGzTn7ZLBXBChFOC9f6kFjAqPhccnP6DxlWXx2lPk1C3G6' where user_id = 1;

delete from public.user

alter table public.user alter column password type varchar(500);