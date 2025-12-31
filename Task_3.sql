--DATABASE CREATION
CREATE DATABASE kesavan_db
GO

--USE DATABASE
use kesavan_db
GO
--Table creation
--Project Table
CREATE TABLE project
(
	project_id INT IDENTITY(1,1) PRIMARY KEY,
	project_name VARCHAR(150) UNIQUE NOT NULL,
	starts_date DATE NOT NULL,
	end_date DATE NOT NULL,
	budget MONEY ,
	statuss VARCHAR(50) DEFAULT 'Not Started',

	--Constraints for end date field
	    CONSTRAINT CHECK_end_date_After_starts_date 
        CHECK (end_date >= starts_date),
)
GO

--Inserting values:
INSERT INTO project (project_name, starts_date, end_date, budget, statuss)
VALUES 
    ('Website Redesign', '2025-01-01', '2025-06-30', 15000.00, 'In Progress'),
    ('Mobile App Development', '2025-02-15', '2025-07-15', 25000.00, 'Not Started'),
    ('Market Research', '2025-03-01', '2025-05-31', 10000.00, 'Completed'),
    ('Annual Report Preparation', '2025-04-01', '2025-12-31', 12000.00, 'In Progress')
GO



--task table creation
CREATE TABLE task(
	task_id INT IDENTITY(1,1) PRIMARY KEY,
	task_name VARCHAR(150) NOT NULL,
	descriptions VARCHAR(255) NOT NULL,
	starts_date DATE NOT NULL,
	due_date DATE NOT NULL,
		--Constraints for end date field
	    CONSTRAINT CHECK_due_date_After_starts_date 
          CHECK (due_date >= starts_date),
	prioritys VARCHAR(150) 
		CONSTRAINT CK_Task_Priority CHECK (prioritys IN ('Low', 'Medium', 'High')),
	statuss VARCHAR(70) DEFAULT 'Pending',
	project_id INT FOREIGN KEY REFERENCES project(project_id)
);
GO

--inserting task values
INSERT INTO task (task_name, descriptions, starts_date, due_date, prioritys, statuss, project_id)
VALUES 
    ('Initial Design', 'Design phase for the new website', '2025-01-02', '2025-02-28', 'High', 'Completed', 1),
    ('UI Development', 'Development of user interface components', '2025-03-01', '2025-05-15', 'Medium', 'In Progress', 1),
    ('Quality Assurance', 'Testing and quality assurance', '2025-05-16', '2025-06-15', 'High', 'Pending', 1),
    ('API Development', 'Developing APIs for the mobile app', '2025-02-16', '2025-04-30', 'Medium', 'Completed', 2),
    ('Beta Testing', 'Conducting beta testing for the mobile app', '2025-05-01', '2025-06-30', 'High', 'In Progress', 2),
    ('Survey Analysis', 'Analyzing market research surveys', '2025-03-02', '2025-04-15', 'Low', 'Completed', 3),
    ('Report Drafting', 'Drafting the final report based on research', '2025-04-16', '2025-05-30', 'Medium', 'Pending', 3),
    ('Financial Statements', 'Preparing financial statements for the annual report', '2025-04-02', '2025-07-15', 'High', 'In Progress', 4),
    ('Final Review', 'Final review and submission of the annual report', '2025-07-16', '2025-12-15', 'High', 'Pending', 4),
    ('Client Feedback Incorporation', 'Incorporating feedback from the client into the project', '2025-02-01', '2025-03-15', 'Medium', 'In Progress', 1),
    ('Launch Preparation', 'Preparing for the official launch of the mobile app', '2025-06-01', '2025-07-01', 'High', 'Pending', 2);

--Display Output;
SELECT *
FROM project
GO

SELECT *
FROM task
GO

-- Query 1: retrieve all tasks from start date
SELECT task_name, starts_date
FROM task
ORDER BY starts_date ASC;
GO


-- Query 2: Count tasks per project
SELECT 
    project.project_name,
    COUNT(task.task_id) AS total_tasks
FROM 
    project LEFT JOIN task
    ON project.project_id = task.project_id
GROUP BY 
    project.project_name
ORDER BY 
    total_tasks DESC;

-- Query 3: total number of task, budget for projects, order by total budget

SELECT 
    project.project_name,
    COUNT(task.task_id) AS total_tasks,
    SUM(project.budget) AS total_budget
FROM 
    project LEFT JOIN task
    ON project.project_id = task.project_id
GROUP BY 
    project.project_name
ORDER BY 
    total_budget;

-- Query 4: Projects with 'In Progress' status and budget between $10,000 and $50,000
SELECT 
    project_id,
    project_name,
    budget,
    statuss
FROM 
    project
WHERE 
    statuss = 'In Progress'
    AND budget BETWEEN 10000 AND 50000
ORDER BY 
    budget ;
GO 

-- Query 5: Retrieve all tasks with a start date in 2025 and a status of 'Completed'
SELECT 
    project_id,
    project_name,
    starts_date,
    statuss
FROM 
    project
WHERE 
    statuss = 'Completed'
    AND YEAR(starts_date) = 2025;
GO

-- Query 6: Retrieve all tasks with a due date in the next month and a status of 'Pending'
SELECT 
    task_id,
    task_name,
    descriptions,
    starts_date,
    due_date,
    prioritys,
    statuss
FROM 
    task
WHERE 
    statuss = 'Pending'
    AND YEAR(due_date) = 2025 
ORDER BY 
    due_date ASC;

 -- Query 7 :Retrieve all tasks that belong to the 'Website Redesign' project and have a high priority
 SELECT 
    task.task_name,
    task.starts_date,
    task.due_date,
    task.prioritys,
    task.statuss
FROM 
    task 
INNER JOIN 
    project 
    ON task.project_id = project.project_id
WHERE 
    project.project_name = 'Website Redesign'
    AND task.prioritys = 'High'
ORDER BY 
    task.due_date ASC;

-- Query 8: Retrieve projects that have at least one task that is overdue 

-- small subquery function to understand subquery

SELECT 
    project_id,
    project_name,
    starts_date,
    end_date,
    budget,
    statuss
FROM 
    project
WHERE 
    project_id IN (
        SELECT DISTINCT project_id
        FROM task
        WHERE 
            due_date < GETDATE()             
    )
ORDER BY 
    project_name;

--Query 9: Retrieve tasks that belong to the most recent project started 
SELECT 
    t.task_id,
    t.task_name,
    t.starts_date,
    t.due_date,
    t.prioritys,
    t.statuss
FROM 
    task t
WHERE 
    t.project_id = (
        SELECT TOP 1 project_id
        FROM project
        ORDER BY starts_date DESC
    );
-- Query 10: Retrieve all projects that have both tasks with 'High' priority and tasks with 'Low' priority
SELECT 
    project_id,
    project_name,
    starts_date,
    end_date,
    budget,
    statuss
FROM 
    project
WHERE 
    project_id IN (
        SELECT project_id
        FROM task
        WHERE prioritys = 'High'
    )
AND 
    project_id IN (
        SELECT project_id
        FROM task
        WHERE prioritys = 'Low'
    );
-- Query 11: Retrieve all tasks where the task name starts with 'Design'.
SELECT 
    task_id,
    task_name,
    descriptions,
    starts_date,
    due_date,
    prioritys,
    statuss
FROM 
    task
WHERE 
    task_name LIKE 'Design%';
-- Query 12: Retrieve tasks where the task name contains 'Review' but does not start with 'Pre':
SELECT 
    task_id,
    task_name,
    descriptions,
    starts_date,
    due_date,
    prioritys,
    statuss
FROM 
    task
WHERE 
    task_name LIKE '%Review%'
    AND task_name NOT LIKE 'Pre%';


-- Query 13: Retrieve tasks where the task name contains any letter from 'A' to 'M' followed by exactly three characters.
SELECT 
    task_id,
    task_name,
    descriptions,
    starts_date,
    due_date,
    prioritys,
    statuss
FROM 
    task
WHERE 
    task_name LIKE '%[A-M]___%';
