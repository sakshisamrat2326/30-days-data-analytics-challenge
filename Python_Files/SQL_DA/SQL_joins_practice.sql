



--1)Left Join
-- SELECT *FROM table1 LEFT join table2 ON table1.C1 = table2.C1

SELECT *FROM table1 left join table2
on table1.C1=table2.C1

SELECT TABLE1.C1 , TABLE1.C2,TABLE2.C3 FROM table1 left join table2 
on table1.C1=table2.C1

SELECT a.C1 , a.C2,b.C3 FROM table1 a left join table2 b on 
a.C1=b.C1

SELECT a.C1 , a.C2,b.C3 FROM table1 a join table2 b on 
a.C1=b.C1

--2)right join
SELECT *FROM TABLE1 right join table2 
on table1.C1=table2.C1

SELECT *FROM TABLE1 right outer join TABLE2
on table1.C1=table2.C1

select a.c1,a.c2,b.c3
from table1 a right outer join table2 b
on a.c1=b.c1

--3)left and right kneee /anti join
SELECT *FROM TABLE1 left join table2
on table1.c1=table2.c1


SELECT *FROM TABLE1 left join table2
on table1.c1=table2.c1
where table2.c1 is null

SELECT *from table1 right join table2
on table1.c1=table2.c1
--right knee join
SELECT *from table1 right join table2
on table1.c1=table2.c1
where table2.c1 is null

--4)full outer join
SELECT *FROM TABLE1
SELECT * FROM TABLE2

--1:
SELECT *FROM table1 full outer join table2 
on table1.c1=table2.c1

--2:
SELECT a.c1,a.c2,b.c3 from TABLE1
as a full outer join table2 as b
on a.c1=b.c1

--5)Self_join

SELECT *FROM table1 a inner join table1 b
on a.c1=b.c1
SELECT a.c1,a.c2,b.c3