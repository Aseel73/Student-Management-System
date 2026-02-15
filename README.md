# 🎓 Student Management System

A simple **Student Management System** built using **JSP, Servlets-style logic (inside JSP), and MySQL**.

This project allows managing:

* Students
* Courses
* Scores
* Marksheet (GPA + Grades)
* Authentication (Login / Logout)

---

## 📌 Technologies Used

* Java (JSP)
* MySQL
* JDBC
* Apache Tomcat
* HTML + CSS
* Git & GitHub

---

## 📂 Project Structure

```
Student-Management-System/
│
├── login.jsp
├── logout.jsp
├── dashboard.jsp
├── student.jsp
├── course.jsp
├── score.jsp
├── marksheet.jsp
├── README.md
└── WEB-INF/lib (MySQL connector)
```

---

## 🔐 Authentication

* Demo login:

```
Username: admin
Password: admin123
```

Session is checked in every module:

```java
if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
}
```

---

## 🧩 Modules Explanation

### 1️⃣ Student Module

* Add student
* Update student
* Delete student
* Search by student code
* Image preview support

Table: `students`

---

### 2️⃣ Course Module

* Add course
* Update course
* Delete course
* Search by course code

Table: `courses`

---

### 3️⃣ Score Module

* Search student + semester
* Enter/update scores
* Save GPA-style values (0–5 scale)

Table: `scores`
Relation:

* student_id → students.student_id
* course_id → courses.course_id

---

### 4️⃣ Marksheet Module

* View full marksheet
* Auto GPA calculation
* Auto Grade calculation
* Overall grade
* Print option

Grade logic example:

```java
if (s >= 4.50) return "A+";
if (s >= 4.00) return "A";
if (s >= 3.50) return "B+";
```

---

## 🗄️ Database Design

### 📌 Tables & Relationships

### 1. students

* student_id (PK)
* student_code
* name
* dob
* gender
* email
* phone
* father_name
* mother_name
* address1
* address2
* image_path

---

### 2. courses

* course_id (PK)
* course_code
* course_name
* semester

---

### 3. scores

* score_id (PK)
* student_id (FK)
* course_id (FK)
* semester
* score

---

### 🔗 Relationships

```
students (1) ---- (M) scores
courses  (1) ---- (M) scores
```

Meaning:

* One student → many scores
* One course → many student scores

---

## ⚙️ Setup Instructions

### 1️⃣ Clone Repository

```
git clone https://github.com/YOUR_USERNAME/Student-Management-System.git
```

### 2️⃣ Create Database

```sql
CREATE DATABASE studentms;
USE studentms;
```

Import your tables (students, courses, scores).

---

### 3️⃣ Configure Database in JSP

Update connection:

```java
String DB_URL  = "jdbc:mysql://localhost:3306/studentms";
String DB_USER = "root";
String DB_PASS = "your_password";
```

---

### 4️⃣ Run on Tomcat

* Place project inside `webapps`
* Start Tomcat
* Open:

```
http://localhost:8080/StudentMS/login.jsp
```

---

## 📊 Features Implemented

✔ Full CRUD operations
✔ GPA calculation
✔ Grade system
✔ Session-based authentication
✔ Image preview
✔ Clean UI layout
✔ JDBC PreparedStatement (SQL Injection safe)

---

## 🚀 Future Improvements

* Use Servlets instead of scriptlets
* Add role-based login (Admin / Student)
* Upload real images instead of path
* Export marksheet as PDF
* Add pagination
* Add dashboard statistics
* Use MVC architecture
* Convert to Spring Boot

---

## 👨‍💻 Author

Aseel Mohammed && Ahmed Alsnhany
BCA Students
---
