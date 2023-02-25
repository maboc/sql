with generator(n) as
(
	values(1)
	union all
	select n from generator
	where n<8
)
select n from generator(8)
