-- comp9311 21T1 Project 1 sql part
--
-- MyMyUNSW Solutions


-- Q1:
create or replace view Q1(subject_longname, subject_num) 
as
select longname,count(longname)
from subjects
where longname like '%PhD%'
group by longname
having count(longname)>1
;
--... SQL statements, possibly using other views/functions defined by you ...


-- Q2:
create or replace view Q2(OrgUnit_id, OrgUnit, OrgUnit_type, Program) 
as
select OrgUnits.id, OrgUnits.name, OrgUnit_types.name, Programs.name
from orgunits, orgunit_types, programs
where OrgUnits.id = Programs.offeredby 
and Programs.uoc>300
and OrgUnits.utype = OrgUnit_types.id 
;
--... SQL statements, possibly using other views/functions defined by you ...


-- Q3:
create or replace view Q3a(course)
as
select course
from
(
    select courses.id as course
    from staff_roles, course_staff,courses
    where courses.id=course_staff.course 
    and course_staff.role = staff_roles.id 
    and staff_roles.name = 'Course Tutor'
) as temp
except
(
    select courses.id as course
    from staff_roles, course_staff,courses
    where courses.id=course_staff.course 
    and course_staff.role = staff_roles.id 
    and staff_roles.name != 'Course Tutor'
)
;

create or replace view Q3(course,student_num,avg_mark)
as 
select Q3a.course, count(course_enrolments.student), round(avg(Course_enrolments.mark),2)
from  course_enrolments, Q3a
where course_enrolments.course = Q3a.course
and course_enrolments.mark is not null
group by Q3a.course
having avg(Course_enrolments.mark)>70 
and count(course_enrolments.student)>10 
;

--... SQL statements, possibly using other views/functions defined by you ...


-- Q4:
create or replace view Q4a1(course)
as 
select courses.id
from classes, class_types, rooms, courses, buildings 
where buildings.name = 'Quadrangle' 
and class_types.name = 'Lecture' 
and classes.course = courses.id  
and rooms.building = buildings.id 
and classes.room = rooms.id  
and class_types.id = classes.ctype 
;
create or replace view Q4a2(course)
as 
select courses.id
from classes, class_types, rooms, courses, buildings 
where buildings.name = 'Red Centre' 
and class_types.name = 'Lecture' 
and classes.course = courses.id  
and rooms.building = buildings.id 
and classes.room = rooms.id  
and class_types.id = classes.ctype 
;
create or replace view Q41(course)
as 
select * from Q4a1
intersect
select * from Q4a2;
create or replace view Q4(student_num)
as 
select count(distinct course_enrolments.student)
from course_enrolments, Q41
where course_enrolments.course = Q41.course
;
--... SQL statements, possibly using other views/functions defined by you ...

--Q5:
create or replace view Q51(staff, min_mark, course)
as
select staff.id, min(Course_enrolments.mark), Courses.id
from staff, courses, course_enrolments, orgunits,  course_staff,subjects
where OrgUnits.Name = 'School of Law'
and subjects.offeredby=orgunits.id
and courses.subject=Subjects.id
and staff.id = course_staff.staff 
and courses.id = course_staff.course
and courses.id = course_enrolments.course
and course_enrolments.mark is not null
group by staff.id,  Courses.id
ORDER BY min(Course_enrolments.mark) DESC
;
create or replace view Q52(staff, min_mark, course)
as
select staff.id, min(Course_enrolments.mark), Courses.id
from staff, courses, course_enrolments, orgunits,  course_staff,subjects
where OrgUnits.Name = 'School of Law'
and subjects.offeredby=orgunits.id
and courses.subject=Subjects.id
and staff.id = course_staff.staff 
and courses.id = course_staff.course
and courses.id = course_enrolments.course
and course_enrolments.mark is not null
group by staff.id,  Courses.id
ORDER BY min(Course_enrolments.mark) DESC
;
create view Q5(staff,min_mark,course)
as
select Q51.staff,Q51.min_mark,Q51.course
from Q51
where Q51.min_mark=(select min(Q52.min_mark)
from Q52
where Q52.staff=Q51.staff)
;
--... SQL statements, possibly using other views/functions defined by you ...

-- Q6:
create or replace view Q6a(course_id, student_num, course_avg)
as
select  Courses.id, count(student), avg(course_enrolments.mark)
from semesters, courses, Course_enrolments
where (Semesters.year = 2009 or Semesters.year = 2010)
and courses.id is not null
and course_enrolments.mark is not null
and course_enrolments.course = courses.id
and semesters.id = courses.semester
group by courses.id
having count(student)>10
;
create or replace view Q6b(course_id, student_num)
as
select Q6a.course_id, count(student)
from Q6a, course_enrolments, courses
where Q6a.course_avg < course_enrolments.mark
and Q6a.course_id = course_enrolments.course
and course_enrolments.course = courses.id
group by Q6a.course_id
;

create or replace view Q6(course_id)
as
select courses.id
from Q6a, Q6b, course_enrolments, courses
where Q6a.course_id = courses.id
and Q6b.course_id = courses.id
and course_enrolments.course = courses.id
group by courses.id, Q6a.student_num, Q6b.student_num
having Q6b.student_num::float / Q6a.student_num::float < 0.4
;
--... SQL statements, possibly using other views/functions defined by you ...


-- Q7:
create or replace view Q7a1( course,student_num,semester )
as
select courses.id, count(course_enrolments.student),Semesters.longname
from courses, course_enrolments, semesters
where Semesters.year in ('2005' ,'2006' ,'2007')
and semesters.id = courses.semester
and courses.id = course_enrolments.course
and courses.semester is not null
group by courses.id,semesters.longname
having count(course_enrolments.student)>=20
;
create or replace view Q7a2(staff_name, semester, course_num)
as
select People.name, Q7a1.semester, count(*)
from  staff,course_staff,people,Q7a1
where  people.id = course_staff.staff
and  course_staff.staff=staff.id
and course_staff.course=Q7a1.course
group by people.name,Q7a1.semester

;

create or replace view q7b1( semester, max_course_num)
as
select Q7a2.semester, max(Q7a2.course_num)
from Q7a2
group by Q7a2.semester
;

create or replace view Q7(staff_name, semester, course_num)
as
select Q7a2.staff_name, Q7a2.semester, Q7a2.course_num
from Q7a2, Q7b1
where Q7a2.course_num = q7b1.max_course_num
and Q7a2.semester = q7b1.semester
;

--... SQL statements, possibly using other views/functions defined by you ...

-- Q8: 
create or replace view Q8a(staff, Course, role)
as
select course_staff.staff, courses.id, course_staff.role
from Orgunits, Semesters, course_staff, Affiliations, courses
where Semesters.year = 2010
and Orgunits.longname = 'School of Computer Science and Engineering'
and semesters.id = courses.semester
and course_staff.Course = courses.id
and course_staff.staff = Affiliations.staff
and Affiliations.Orgunit = Orgunits.id
group by course_staff.staff, courses.id, course_staff.role
;
create or replace view Q8b(role, student)
as
select distinct Q8a.role, course_enrolments.student
from Q8a, course_enrolments
where Q8a.course = course_enrolments.course
;
create or replace view Q8(role_id, role_name, num_students)
as
select Staff_roles.id, Staff_roles.name, count(Q8b.student)
from Staff_roles, Q8a, Q8b
where Staff_roles.id = Q8a.role
and Staff_roles.id = Q8b.role
group by Staff_roles.id, Staff_roles.name, Q8b.student
;
--... SQL statements, possibly using other views/functions defined by you ...


-- Q9:
create or replace view Q9(year, term, stype, average_mark)
as
select distinct Semesters.year, Semesters.term, Students.stype, avg(course_enrolments.mark)::numeric(4,2)
from semesters, students, course_enrolments, subjects, courses
where Subjects.name = 'Data Management'
and course_enrolments.mark is not null
and semesters.id = courses.semester
and students.id = course_enrolments.student
and course_enrolments.course = courses.id
and subjects.id = courses.subject
group by Semesters.year, Semesters.term, Students.stype
;
--... SQL statements, possibly using other views/functions defined by you ...


-- Q10:
create or replace view Q10a(room, capacity, num)
as
select distinct Rooms.longname, Rooms.capacity, count(facilities.id)
from rooms, room_facilities, facilities
where rooms.id = room_facilities.room 
and rooms.capacity>=100
and rooms.capacity is not null
and room_facilities.facility = facilities.id
group by Rooms.longname, Rooms.capacity
having count(facilities.id) is not null
;

create or replace view Q10b(capacity, num)
as
select Q10a.capacity, max(Q10a.num)
from Q10a
group by Q10a.capacity
;
create or replace view Q10(room, capacity, num)
as
select Q10a.room, Q10a.capacity, Q10a.num
from Q10a, Q10b
where Q10a.capacity = Q10b.capacity
and Q10a.num = Q10b.num
;
--... SQL statements, possibly using other views/functions defined by you ...


-- Q11:
create or replace view Q11(staff, subject, num)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q12:
create or replace view Q12(staff, role, hd_rate)
as
--... SQL statements, possibly using other views/functions defined by you ...
;
