-- Cleaning data

-- copy data
CREATE TABLE `score_student2` (
  `ID` double DEFAULT NULL,
  `Gender` text,
  `EthnicGroup` text,
  `ParentEduc` text,
  `LunchType` text,
  `TestPrep` text,
  `MathScore` double DEFAULT NULL,
  `ReadingScore` double DEFAULT NULL,
  `WritingScore` double DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



-- remove duplicate data
insert into students_exam_scores.score_student2
select *,
	row_number() over( partition by ID, MathScore, ReadingScore, WritingScore ) as row_num
    from score ;
delete from students_exam_scores.score_student2 where row_num > 1;




-- standardized data
update students_exam_scores.score_student2
	set  Gender = (trim(Gender));
update students_exam_scores.score_student2
	set  EthnicGroup = (trim(EthnicGroup));
update students_exam_scores.score_student2
	set  ParentEduc = (trim(ParentEduc));
update students_exam_scores.score_student2
	set   LunchType = (trim(LunchType));
update students_exam_scores.score_student2
	set  TestPrep = (trim(TestPrep));


--  Fill in and view missing values ​​of each column
select * from score_student2
where gender = "" ;
update students_exam_scores.score_student2
set Gender = "female" where Gender = ""; 

select * from score_student2
where EthnicGroup = "";
update students_exam_scores.score_student2
set EthnicGroup = "group B" where EthnicGroup = "";

select * from score_student2
where ParentEduc = "";
update students_exam_scores.score_student2
set ParentEduc = "some college" where ParentEduc = "";

select * from score_student2
where LunchType = "";
update students_exam_scores.score_student2
set LunchType = "standard" where LunchType = "";

select * from score_student2
where TestPrep = "";
update students_exam_scores.score_student2
set TestPrep = "none" where TestPrep = "";

-- delete column row_num
alter table score_student2
drop row_num;



-- total score table and average score of each group
create view Total_and_AVG_Group as
SELECT 
    EthnicGroup,
	AVG(MathScore) AS AvgMathScore, 
    AVG(ReadingScore) AS AvgReadingScore, 
    AVG(WritingScore) AS AvgWritingScore,
    SUM(MathScore) AS TotalMathScore,
    SUM(ReadingScore) AS TotalReadingScore,
    SUM(WritingScore) AS TotalWritingScore
FROM  score_student2
GROUP BY EthnicGroup;


-- total and average for each student
create view Total_AVG_Student  as
select row_number() over (order by ID ) as ID_student,
	   Gender,MathScore,ReadingScore,WritingScore,
       (MathScore + ReadingScore + WritingScore) / 3 as AVGER_Score,
       (MathScore + ReadingScore + WritingScore) as Total_Score
from score_student2
order by  ID_student;
       
-- the results of whether the student took the exam preparation course or not
create view Total_Group  as
select TestPrep , 
	AVG(MathScore) AS AvgMathScore, 
    AVG(ReadingScore) AS AvgReadingScore, 
    AVG(WritingScore) AS AvgWritingScore,
    SUM(MathScore) AS TotalMathScore,
    SUM(ReadingScore) AS TotalReadingScore,
    SUM(WritingScore) AS TotalWritingScore
from score_student2
group by  TestPrep ;

--  Student outcomes are based on parents' educational level
create view score_by_ParentEduc as
select ParentEduc,
	count(students_exam_scores.score_student2.ParentEduc) as Count_ParentEduc,
	AVG(MathScore) AS AvgMathScore, 
    AVG(ReadingScore) AS AvgReadingScore, 
    AVG(WritingScore) AS AvgWritingScore,
    SUM(MathScore) AS TotalMathScore,
    SUM(ReadingScore) AS TotalReadingScore,
    SUM(WritingScore) AS TotalWritingScore
	from score_student2
group by ParentEduc;
    
 
