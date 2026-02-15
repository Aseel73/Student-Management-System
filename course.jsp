<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@page import="java.sql.*"%>
<%
    // 1) Session check
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2) DB Config (مهم مع MySQL 8)
    String DB_URL  = "jdbc:mysql://localhost:3306/studentms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "Aseel#2424";

    Connection con = null;

    String msg = "";

    // Form values
    String course_id = "";
    String course_code = "";
    String course_name = "";
    String semester = "";

    // Search query
    String q = request.getParameter("q"); // course_code
    String action = request.getParameter("action"); // add / update / delete / search

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        // ===== ADD =====
        if ("add".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
            request.setCharacterEncoding("UTF-8");

            course_code = request.getParameter("course_code");
            course_name = request.getParameter("course_name");
            semester    = request.getParameter("semester");

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO courses (course_code, course_name, semester) VALUES (?,?,?)"
            );
            ps.setString(1, course_code);
            ps.setString(2, course_name);
            ps.setInt(3, Integer.parseInt(semester));
            ps.executeUpdate();
            ps.close();

            msg = "✅ Course added successfully!";
            course_id = course_code = course_name = semester = "";
        }

        // ===== SEARCH (Load for edit) =====
        if ("search".equals(action) && q != null && !q.trim().isEmpty()) {
            PreparedStatement ps = con.prepareStatement("SELECT * FROM courses WHERE course_code=?");
            ps.setString(1, q.trim());
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                course_id   = String.valueOf(rs.getInt("course_id"));
                course_code = rs.getString("course_code");
                course_name = rs.getString("course_name");
                semester    = String.valueOf(rs.getInt("semester"));
                msg = "✅ Course found. You can update/delete now.";
            } else {
                msg = "❌ Course not found!";
            }

            rs.close();
            ps.close();
        }

        // ===== UPDATE =====
        if ("update".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
            request.setCharacterEncoding("UTF-8");

            course_id   = request.getParameter("course_id");
            course_code = request.getParameter("course_code");
            course_name = request.getParameter("course_name");
            semester    = request.getParameter("semester");

            PreparedStatement ps = con.prepareStatement(
                "UPDATE courses SET course_code=?, course_name=?, semester=? WHERE course_id=?"
            );
            ps.setString(1, course_code);
            ps.setString(2, course_name);
            ps.setInt(3, Integer.parseInt(semester));
            ps.setInt(4, Integer.parseInt(course_id));

            int rows = ps.executeUpdate();
            ps.close();

            msg = (rows > 0) ? "✅ Course updated successfully!" : "❌ Update failed!";
        }

        // ===== DELETE =====
        if ("delete".equals(action)) {
            String delId = request.getParameter("course_id");
            if (delId != null && !delId.trim().isEmpty()) {
                PreparedStatement ps = con.prepareStatement("DELETE FROM courses WHERE course_id=?");
                ps.setInt(1, Integer.parseInt(delId));
                int rows = ps.executeUpdate();
                ps.close();

                msg = (rows > 0) ? "✅ Course deleted successfully!" : "❌ Delete failed!";
                course_id = course_code = course_name = semester = "";
            }
        }

    } catch (Exception e) {
        msg = "❌ Error: " + e.getMessage();
    }
%>

<html>
<head>
    <meta charset="UTF-8" />
    <title>Course Module</title>
    <style>
        body{font-family:Arial; background:#f6f6f6;}
        .wrap{width:1100px; margin:20px auto; background:#fff; padding:15px; border-radius:8px;}
        .topbar{display:flex; justify-content:space-between; align-items:center;}
        .nav a{margin-right:12px; text-decoration:none;}
        .msg{margin:10px 0; padding:10px; background:#eef; border:1px solid #ccd;}
        .grid{display:grid; grid-template-columns: 380px 1fr; gap:15px; margin-top:10px;}
        label{display:block; margin-top:8px; font-weight:bold; font-size:13px;}
        input{width:100%; padding:8px; margin-top:4px;}
        .btns{margin-top:12px; display:flex; gap:10px; flex-wrap:wrap;}
        button{padding:10px 14px; cursor:pointer;}
        table{width:100%; border-collapse:collapse; margin-top:10px;}
        th,td{border:1px solid #ddd; padding:8px; font-size:13px; text-align:left;}
        th{background:#f0f0f0;}
        .small{font-size:12px; color:#666;}
        .searchRow{display:flex; gap:10px; align-items:center;}
        .searchRow input{flex:1;}
    </style>
</head>
<body>
<div class="wrap">

    <div class="topbar">
        <h2>STUDENT MANAGEMENT SYSTEM - Course</h2>
        <div class="nav">
            <a href="dashboard.jsp">Dashboard</a>
            <a href="student.jsp">Student</a>
            <a href="score.jsp">Score</a>
            <a href="marksheet.jsp">Marks Sheet</a>
            <a href="logout.jsp">Logout</a>
        </div>
    </div>

    <div class="msg"><b>Status:</b> <%=msg%></div>

    <div class="grid">

        <!-- LEFT: Form -->
        <div>
            <h3>Course Form</h3>
            <p class="small">Tip: Search by Course Code (e.g., C101) to update/delete.</p>

            <!-- Search -->
            <form method="get" action="course.jsp">
                <input type="hidden" name="action" value="search">
                <label>Search by Course Code</label>
                <div class="searchRow">
                    <input type="text" name="q" placeholder="Enter Course Code (C101)" value="<%=(q==null?"":q)%>" />
                    <button type="submit">Search</button>
                </div>
            </form>

            <hr>

            <!-- Add/Update -->
            <form method="post" action="course.jsp?action=<%= (course_id==null || course_id.isEmpty()) ? "add" : "update" %>">
                <input type="hidden" name="course_id" value="<%=course_id%>"/>

                <label>Course Code</label>
                <input type="text" name="course_code" required value="<%=course_code==null?"":course_code%>"/>

                <label>Course Name</label>
                <input type="text" name="course_name" required value="<%=course_name==null?"":course_name%>"/>

                <label>Semester</label>
                <input type="number" name="semester" min="1" max="12" required value="<%=semester==null?"":semester%>"/>

                <div class="btns">
                    <button type="submit"><%= (course_id==null || course_id.isEmpty()) ? "Add New" : "Update" %></button>

                    <% if(course_id != null && !course_id.isEmpty()) { %>
                        <form method="get" action="course.jsp" style="display:inline;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="course_id" value="<%=course_id%>">
                            <button type="submit" onclick="return confirm('Delete this course?');"
                                    style="background:#ffdddd;">Delete</button>
                        </form>
                    <% } %>

                    <a href="course.jsp"><button type="button">Clear</button></a>
                </div>
            </form>
        </div>

        <!-- RIGHT: Table List -->
        <div>
            <h3>Courses List</h3>

            <table>
                <tr>
                    <th>ID</th>
                    <th>Code</th>
                    <th>Name</th>
                    <th>Semester</th>
                    <th>Action</th>
                </tr>

                <%
                    try {
                        PreparedStatement psList = con.prepareStatement(
                            "SELECT course_id, course_code, course_name, semester FROM courses ORDER BY course_id DESC"
                        );
                        ResultSet rsList = psList.executeQuery();
                        while(rsList.next()){
                %>
                    <tr>
                        <td><%=rsList.getInt("course_id")%></td>
                        <td><%=rsList.getString("course_code")%></td>
                        <td><%=rsList.getString("course_name")%></td>
                        <td><%=rsList.getInt("semester")%></td>
                        <td>
                            <a href="course.jsp?action=search&q=<%=rsList.getString("course_code")%>">Edit</a>
                        </td>
                    </tr>
                <%
                        }
                        rsList.close();
                        psList.close();
                    } catch(Exception e2){
                        out.println("<tr><td colspan='5'>Error loading list: " + e2.getMessage() + "</td></tr>");
                    } finally {
                        if(con != null) con.close();
                    }
                %>
            </table>
        </div>

    </div>
</div>
</body>
</html>
