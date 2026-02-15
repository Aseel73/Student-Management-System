<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<html>
<head>
    <title>Dashboard</title>
    <style>
        body{font-family:Arial;}
        .nav a{margin-right:15px;}
    </style>
</head>
<body>
    <h1>Student Management System</h1>
    <p>Welcome, <b><%=session.getAttribute("username")%></b></p>

    <div class="nav">
        <a href="student.jsp">Student</a>
        <a href="course.jsp">Course</a>
        <a href="score.jsp">Score</a>
        <a href="marksheet.jsp">Marks Sheet</a>
        <a href="logout.jsp">Logout</a>
    </div>

    <hr>
    <h3>Choose a module from the menu.</h3>
</body>
</html>
