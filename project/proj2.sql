-- comp9311 21T1 Project 1 plpgsql part
--
-- MyMyUNSW Solutions


-- Q13:
create type EmploymentRecord as (unswid integer, staff_name text, roles text);
create or replace function Q13(integer) 
	returns setof EmploymentRecord 
as $$
begin
SELECT Affiliations.unswid, staff_roles.name, string_agg(staff_roles.name, orgunits.name, Affiliations.starting, Affiliations.ending, ',') 
--into roles
FROM  Affiliations, staff_roles, orgunits
where Affiliations.staff = staff_roles.id
and orgunits.id = Affiliations.orgunit
GROUP BY Affiliations.unswid
having count(Affiliations.roles)>2;

--return roles;
end;
$$ language plpgsql;


