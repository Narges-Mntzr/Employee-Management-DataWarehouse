import pyodbc
import random
from datetime import datetime, timedelta

# Database connection
conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost;DATABASE=EmployeeManagement;UID=sa;PWD=nargesMntzr81"
)
cursor = conn.cursor()


# Helper function to generate random dates
def random_date(start, end):
    return start + timedelta(days=random.randint(0, (end - start).days))


def random_end_date(start, min_time_delta, max_time_delta, time_now):
    end_date = start + timedelta(days=random.randint(min_time_delta, max_time_delta))
    return end_date if end_date <= time_now else None


# Sample data for Employees
employees = []
for i in range(1, 1001):  # 1000 employees
    start_date = random_date(datetime(2020, 1, 1), datetime.now())
    end_date = random_end_date(start_date, 1, 365 * 5, datetime.now())

    employees.append(
        (
            f"FirstName{i}",
            f"LastName{i}",
            random.choice(["M", "F"]),
            random.randint(1, 20),
            random_date(datetime(1970, 1, 1), datetime(2000, 12, 31)).strftime(
                "%Y-%m-%d"
            ),
            f"{random.randint(1000000000, 9999999999)}",
            start_date.strftime("%Y-%m-%d"),
            end_date.strftime("%Y-%m-%d") if end_date else None,
            random.randint(1, 100),
        )
    )

# Sample data for Departments
departments = []
for i in range(1, 21):  # 20 departments
    departments.append((f"DepartmentName{i}", random.randint(5, 50)))

# Sample data for Cities
cities = []
for i in range(1, 101):  # 100 cities
    cities.append((f"CityName{i}", f"Country{i % 10}"))

# Sample data for Projects
projects = []
for i in range(1, 201):  # 200 projects
    start_date = random_date(datetime(2022, 1, 1), datetime.now())
    end_date = random_end_date(start_date, 1, 365, datetime.now())
    status = "Completed" if end_date else "In Progress"

    projects.append(
        (
            f"ProjectName{i}",
            f"Description of Project {i}",
            start_date.strftime("%Y-%m-%d"),
            end_date.strftime("%Y-%m-%d") if end_date else None,
            status,
        )
    )

# Sample data for Tasks
tasks = []
for i in range(1, 1000001):  # 1,000,000 tasks
    project_id = random.randint(1, 200)

    if projects[project_id - 1][3]:
        project_start_date_datetime = datetime.strptime(
            projects[project_id - 1][2], "%Y-%m-%d"
        )
        project_end_date_datetime = datetime.strptime(
            projects[project_id - 1][3], "%Y-%m-%d"
        )

        start_date = random_date(
            project_start_date_datetime,
            project_end_date_datetime,
        )
        end_date = random_date(start_date, project_end_date_datetime)
    else:
        project_start_date_datetime = datetime.strptime(
            projects[project_id - 1][2], "%Y-%m-%d"
        )

        start_date = random_date(project_start_date_datetime, datetime.now())
        end_date = random_date(start_date, datetime.now())

    tasks.append(
        (
            f"TaskName{i}",
            project_id,
            random.randint(1, 1000),
            start_date.strftime("%Y-%m-%d"),
            end_date.strftime("%Y-%m-%d"),
            f"Description of Task {i}",
        )
    )

# Sample data for TimeEntries
time_entries = []
for i in range(1, 1000001):  # 1,000,000 time entries
    task_id = random.randint(1, 1000000)

    task_start_date_datetime = datetime.strptime(tasks[task_id - 1][3], "%Y-%m-%d")
    task_end_date_datetime = datetime.strptime(tasks[task_id - 1][4], "%Y-%m-%d")

    time_entries.append(
        (
            task_id,
            random.randint(1, 1000),
            round(random.uniform(1, 8), 2),
            random_date(task_start_date_datetime, task_end_date_datetime).strftime(
                "%Y-%m-%d"
            ),
        )
    )

# Insert data into tables
print("Start inserting data into tables...")

cursor.executemany(
    "INSERT INTO Projects (ProjectName, Description, StartDate, EndDate, Status) VALUES (?, ?, ?, ?, ?)",
    projects,
)
print("Table Projects inserted successfully.")

cursor.executemany(
    "INSERT INTO Departments (Name, MaxEmployeeSize) VALUES (?, ?)", departments
)
print("Table Departments inserted successfully.")

cursor.executemany("INSERT INTO Cities (Name, Country) VALUES (?, ?)", cities)
print("Table Cities inserted successfully.")

cursor.executemany(
    "INSERT INTO Employees (FirstName, LastName, Gender, DepartmentID, Birthday, PhoneNumber, StartDate, EndDate, BirthCity) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
    employees,
)
print("Table Employees inserted successfully.")


# Batch insert tasks and time entries due to their large size
batch_size = 10000
for i in range(0, len(tasks), batch_size):
    batch = tasks[i : i + batch_size]
    cursor.executemany(
        "INSERT INTO Tasks (TaskName, ProjectID, AssignedTo, StartDate, EndDate, Description) VALUES (?, ?, ?, ?, ?, ?)",
        batch,
    )
    print(f"Inserted {i + batch_size} tasks")
print("Table Tasks inserted successfully.")


for i in range(0, len(time_entries), batch_size):
    batch = time_entries[i : i + batch_size]
    cursor.executemany(
        "INSERT INTO TimeEntries (TaskID, EmployeeID, HoursWorked, EntryDate) VALUES (?, ?, ?, ?)",
        batch,
    )
    print(f"Inserted {i + batch_size} time entries")
print("Table TimeEntries inserted successfully.")

# Commit and close connection
conn.commit()
conn.close()
