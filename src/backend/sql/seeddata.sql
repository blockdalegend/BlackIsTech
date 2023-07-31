DROP TABLE IF EXISTS [dbo].[Students];

Create Table [dbo].[Students]
(
StudentName nvarchar(100),
StudentGrade nvarchar(100)
)

INSERT INTO Students (StudentName, StudentGrade) 
Values('Jakora Hall', '8th Grade')
,('Jakyra Hall', '5th Grade')
,('Cory Hall, Jr.', 'Kindergarten')