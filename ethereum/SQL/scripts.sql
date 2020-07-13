INSERT INTO public.requests(
	id, "urlToQuery", "attributeToFetch", "apiFlag", granted)
	VALUES (1, 'url', 'dollar', true, false);
	
delete from public.requests where id = 1

select * from requests


update requests set  "granted"=false where id = 3;

delete from requests where id = 1