<%@page import="java.sql.*"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%!
    // Grade helper (0 - 5 scale)
    public String gradeByScore(double s) {
        if (s >= 4.50) return "A+";
        if (s >= 4.00) return "A";
        if (s >= 3.50) return "B+";
        if (s >= 3.00) return "B";
        if (s >= 2.50) return "C";
        if (s >= 2.00) return "D";
        return "F";
    }

    // CSS class helper
    public String gradeClass(String g) {
        if ("A+".equals(g) || "A".equals(g)) return "gA";
        if ("B+".equals(g) || "B".equals(g)) return "gB";
        if ("C".equals(g)) return "gC";
        if ("D".equals(g)) return "gD";
        return "gF";
    }
%>

<%
    // 1) Session check
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2) DB Config (عدّلها إذا قاعدة البيانات/الباسورد مختلف)
    String DB_URL  = "jdbc:mysql://localhost:3306/studentms?useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "Aseel#2424";

    String msg = "";
    String student_code = request.getParameter("student_code");
    String semesterStr  = request.getParameter("semester");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    // Data for header
    String studentName = "";
    int semester = -1;

    // GPA/Avg
    double semesterAvg = 0.0;
    int countRows = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        // Parse semester
        if (semesterStr != null && !semesterStr.trim().isEmpty()) {
            semester = Integer.parseInt(semesterStr.trim());
        }

        // If search requested
        if (student_code != null && !student_code.trim().isEmpty() && semester != -1) {

            // Get student name
            ps = con.prepareStatement("SELECT name FROM students WHERE student_code=?");
            ps.setString(1, student_code.trim());
            rs = ps.executeQuery();
            if (rs.next()) {
                studentName = rs.getString("name");
            }
            rs.close(); ps.close();

            if (studentName == null || studentName.trim().isEmpty()) {
                msg = "❌ Student not found!";
            } else {

                // Check if scores exist for that student+semester
                ps = con.prepareStatement(
                    "SELECT COUNT(*) " +
                    "FROM scores sc " +
                    "JOIN students s ON s.student_id=sc.student_id " +
                    "WHERE s.student_code=? AND sc.semester=?"
                );
                ps.setString(1, student_code.trim());
                ps.setInt(2, semester);
                rs = ps.executeQuery();
                rs.next();
                int found = rs.getInt(1);
                rs.close(); ps.close();

                if (found == 0) {
                    msg = "⚠️ No scores found for this student in this semester. Add scores first (Score module).";
                } else {
                    msg = "✅ Marksheet loaded.";
                }
            }
        }

    } catch (Exception e) {
        msg = "❌ Error: " + e.getMessage();
    }
%>

<html>
<head>
    <meta charset="UTF-8" />
    <title>Marksheet</title>
    <style>
        body{font-family:Arial; background:#f6f6f6;}
        .wrap{width:1100px; margin:20px auto; background:#fff; padding:15px; border-radius:10px;}
        .topbar{display:flex; justify-content:space-between; align-items:center;}
        .nav a{margin-left:12px; text-decoration:none; color:#5a2ea6;}
        .nav a:hover{text-decoration:underline;}
        .msg{margin:12px 0; padding:10px; background:#eef; border:1px solid #ccd; border-radius:8px;}
        .grid{display:grid; grid-template-columns: 420px 1fr; gap:15px; margin-top:10px;}
        label{display:block; margin-top:10px; font-weight:bold; font-size:13px;}
        input{width:100%; padding:9px; margin-top:5px;}
        button{padding:10px 14px; cursor:pointer;}
        table{width:100%; border-collapse:collapse; margin-top:10px;}
        th,td{border:1px solid #ddd; padding:9px; font-size:13px; text-align:left;}
        th{background:#f0f0f0;}
        .summary{margin-top:12px; padding:10px; background:#fafafa; border:1px solid #eee; border-radius:8px;}
        .badge{display:inline-block; padding:6px 10px; border-radius:999px; font-weight:bold; font-size:12px;}
        .gA{background:#eaffea; color:#0a6b0a;}
        .gB{background:#e7f1ff; color:#0b4ea2;}
        .gC{background:#fff8db; color:#8a6d00;}
        .gD{background:#ffe9cc; color:#a65b00;}
        .gF{background:#ffecec; color:#b30000;}
        .printBtn{background:#111; color:#fff; border:none; border-radius:8px;}
        @media print{
            .nav, .noPrint { display:none; }
            body{background:#fff;}
            .wrap{width:100%; margin:0; border-radius:0;}
        }
    </style>
</head>

<body>
<div class="wrap">

    <div class="topbar">
        <h2>STUDENT MANAGEMENT SYSTEM - Marksheet</h2>
        <div class="nav noPrint">
            <a href="dashboard.jsp">Dashboard</a>
            <a href="student.jsp">Student</a>
            <a href="course.jsp">Course</a>
            <a href="score.jsp">Score</a>
            <a href="logout.jsp">Logout</a>
        </div>
    </div>

    <div class="msg"><b>Status:</b> <%= msg %></div>

    <div class="grid">
        <!-- LEFT: Search -->
        <div class="noPrint">
            <h3>Search Marksheet</h3>

            <form method="get" action="marksheet.jsp">
                <label>Student Code</label>
                <input type="text" name="student_code" placeholder="S001" value="<%= student_code==null?"":student_code %>" required>

                <label>Semester</label>
                <input type="number" name="semester" placeholder="1" value="<%= (semesterStr==null?"":semesterStr) %>" required>

                <div style="margin-top:12px; display:flex; gap:10px;">
                    <button type="submit">Search</button>
                    <button type="button" class="printBtn" onclick="window.print()">Print</button>
                    <a href="marksheet.jsp"><button type="button">Clear</button></a>
                </div>
            </form>

            <div class="summary">
                <div><b>Tip:</b> Make sure you already saved scores in <b>Score</b> module.</div>
            </div>
        </div>

        <!-- RIGHT: Marksheet -->
        <div>
            <h3>Marksheet</h3>

            <%
                if (student_code != null && !student_code.trim().isEmpty() && semester != -1 && studentName != null && !studentName.trim().isEmpty()) {

                    // Fetch rows
                    try {
                        ps = con.prepareStatement(
                            "SELECT s.student_code, s.name, sc.semester, c.course_code, c.course_name, sc.score " +
                            "FROM scores sc " +
                            "JOIN students s ON s.student_id = sc.student_id " +
                            "JOIN courses c ON c.course_id = sc.course_id " +
                            "WHERE s.student_code = ? AND sc.semester = ? " +
                            "ORDER BY c.course_code"
                        );
                        ps.setString(1, student_code.trim());
                        ps.setInt(2, semester);
                        rs = ps.executeQuery();
            %>

            <div class="summary">
                <div><b>Student:</b> <%= studentName %> (<%= student_code %>)</div>
                <div><b>Semester:</b> <%= semester %></div>
            </div>

            <table>
                <tr>
                    <th>Course Code</th>
                    <th>Course Name</th>
                    <th>Score</th>
                    <th>Grade</th>
                </tr>

                <%
                    semesterAvg = 0.0;
                    countRows = 0;

                    while(rs.next()){
                        double sc = rs.getDouble("score");
                        String g = gradeByScore(sc);
                        String cls = gradeClass(g);

                        semesterAvg += sc;
                        countRows++;
                %>
                    <tr>
                        <td><%= rs.getString("course_code") %></td>
                        <td><%= rs.getString("course_name") %></td>
                        <td><%= String.format("%.2f", sc) %></td>
                        <td><span class="badge <%=cls%>"><%= g %></span></td>
                    </tr>
                <%
                    }
                %>
            </table>

            <%
                    rs.close(); ps.close();

                    double avg = (countRows == 0) ? 0.0 : (semesterAvg / countRows);
                    String overallGrade = gradeByScore(avg);
                    String overallClass = gradeClass(overallGrade);
            %>

            <div class="summary">
                <div><b>Total Courses:</b> <%= countRows %></div>
                <div><b>Semester Average (GPA style):</b> <%= String.format("%.2f", avg) %></div>
                <div><b>Overall Grade:</b> <span class="badge <%=overallClass%>"><%= overallGrade %></span></div>
            </div>

            <%
                    } catch(Exception ex2){
            %>
                        <div class="msg" style="background:#ffecec;border-color:#ffb3b3;">
                            ❌ Error loading marksheet: <%= ex2.getMessage() %>
                        </div>
            <%
                    }
                } else {
            %>
                <div class="summary">
                    Enter <b>Student Code</b> and <b>Semester</b>, then click <b>Search</b>.
                </div>
            <%
                }
            %>

        </div>
    </div>

</div>

<%
    // Close connection safely
    try { if(con != null) con.close(); } catch(Exception ignore){}
%>

</body>
</html>
