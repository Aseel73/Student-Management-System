<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@page import="java.sql.*"%>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String DB_URL  = "jdbc:mysql://localhost:3306/studentms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "Aseel#2424";

    Connection con = null;
    String msg = "";

    String studentCode = request.getParameter("student_code");
    String semesterStr = request.getParameter("semester");
    String action = request.getParameter("action"); // search / save

    Integer studentId = null;
    String studentName = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        // ===== SAVE SCORES =====
        if ("save".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
            studentCode = request.getParameter("student_code");
            semesterStr = request.getParameter("semester");

            // get student_id
            PreparedStatement psS = con.prepareStatement("SELECT student_id, name FROM students WHERE student_code=?");
            psS.setString(1, studentCode);
            ResultSet rsS = psS.executeQuery();
            if (rsS.next()) {
                studentId = rsS.getInt("student_id");
                studentName = rsS.getString("name");
            } else {
                msg = "❌ Student not found!";
            }
            rsS.close(); psS.close();

            if (studentId != null) {
                int sem = Integer.parseInt(semesterStr);

                // get all course_ids for this semester
                PreparedStatement psC = con.prepareStatement("SELECT course_id FROM courses WHERE semester=?");
                psC.setInt(1, sem);
                ResultSet rsC = psC.executeQuery();

                int saved = 0;
                while (rsC.next()) {
                    int courseId = rsC.getInt("course_id");
                    String fieldName = "score_" + courseId; // input name
                    String scoreVal = request.getParameter(fieldName);

                    if (scoreVal != null && !scoreVal.trim().isEmpty()) {
                        // upsert
                        PreparedStatement psUp = con.prepareStatement(
                            "INSERT INTO scores (student_id, semester, course_id, score) VALUES (?,?,?,?) " +
                            "ON DUPLICATE KEY UPDATE score=VALUES(score)"
                        );
                        psUp.setInt(1, studentId);
                        psUp.setInt(2, sem);
                        psUp.setInt(3, courseId);
                        psUp.setBigDecimal(4, new java.math.BigDecimal(scoreVal));
                        psUp.executeUpdate();
                        psUp.close();
                        saved++;
                    }
                }
                rsC.close(); psC.close();

                msg = "✅ Saved/Updated scores: " + saved;
            }
        }

        // ===== SEARCH STUDENT + SEMESTER =====
        if ("search".equals(action) && studentCode != null && !studentCode.trim().isEmpty()
                && semesterStr != null && !semesterStr.trim().isEmpty()) {

            PreparedStatement psS = con.prepareStatement("SELECT student_id, name FROM students WHERE student_code=?");
            psS.setString(1, studentCode.trim());
            ResultSet rsS = psS.executeQuery();
            if (rsS.next()) {
                studentId = rsS.getInt("student_id");
                studentName = rsS.getString("name");
                msg = "✅ Student found. Enter scores then click Save.";
            } else {
                msg = "❌ Student not found!";
            }
            rsS.close(); psS.close();
        }

    } catch (Exception e) {
        msg = "❌ Error: " + e.getMessage();
    }
%>

<html>
<head>
    <meta charset="UTF-8" />
    <title>Score Module</title>
    <style>
        body{font-family:Arial; background:#f6f6f6;}
        .wrap{width:1100px; margin:20px auto; background:#fff; padding:15px; border-radius:8px;}
        .topbar{display:flex; justify-content:space-between; align-items:center;}
        .nav a{margin-right:12px; text-decoration:none;}
        .msg{margin:10px 0; padding:10px; background:#eef; border:1px solid #ccd;}
        label{display:block; margin-top:8px; font-weight:bold; font-size:13px;}
        input{padding:8px; margin-top:4px;}
        table{width:100%; border-collapse:collapse; margin-top:10px;}
        th,td{border:1px solid #ddd; padding:8px; font-size:13px; text-align:left;}
        th{background:#f0f0f0;}
        .grid{display:grid; grid-template-columns: 1fr 1fr; gap:15px;}
        .card{border:1px solid #eee; padding:12px; border-radius:8px;}
        .row{display:flex; gap:10px; align-items:end; flex-wrap:wrap;}
        .row > div{min-width:200px;}
        button{padding:10px 14px; cursor:pointer;}
        .small{font-size:12px; color:#666;}
    </style>
</head>
<body>
<div class="wrap">

    <div class="topbar">
        <h2>STUDENT MANAGEMENT SYSTEM - Score</h2>
        <div class="nav">
            <a href="dashboard.jsp">Dashboard</a>
            <a href="student.jsp">Student</a>
            <a href="course.jsp">Course</a>
            <a href="marksheet.jsp">Marks Sheet</a>
            <a href="logout.jsp">Logout</a>
        </div>
    </div>

    <div class="msg"><b>Status:</b> <%=msg%></div>

    <div class="grid">
        <div class="card">
            <h3>Search Student + Semester</h3>
            <form method="get" action="score.jsp">
                <input type="hidden" name="action" value="search">
                <div class="row">
                    <div>
                        <label>Student Code</label>
                        <input type="text" name="student_code" placeholder="S001"
                               value="<%= (studentCode==null?"":studentCode) %>" required>
                    </div>
                    <div>
                        <label>Semester</label>
                        <input type="number" name="semester" min="1" max="12"
                               value="<%= (semesterStr==null?"":semesterStr) %>" required>
                    </div>
                    <div>
                        <button type="submit">Search</button>
                    </div>
                </div>
            </form>

            <hr>

            <h3>Enter Scores</h3>
            <p class="small">After search, you will see semester courses. Fill scores and press Save.</p>

            <%
                if (studentId != null && semesterStr != null && !semesterStr.trim().isEmpty()) {
                    int sem = Integer.parseInt(semesterStr);

                    // fetch semester courses
                    PreparedStatement ps = con.prepareStatement(
                        "SELECT c.course_id, c.course_code, c.course_name, " +
                        " (SELECT score FROM scores s WHERE s.student_id=? AND s.semester=? AND s.course_id=c.course_id) AS existing_score " +
                        "FROM courses c WHERE c.semester=? ORDER BY c.course_id"
                    );
                    ps.setInt(1, studentId);
                    ps.setInt(2, sem);
                    ps.setInt(3, sem);
                    ResultSet rs = ps.executeQuery();
            %>

            <form method="post" action="score.jsp?action=save">
                <input type="hidden" name="student_code" value="<%=studentCode%>">
                <input type="hidden" name="semester" value="<%=semesterStr%>">

                <div><b>Student:</b> <%=studentName%> (<%=studentCode%>) | <b>Semester:</b> <%=sem%></div>

                <table>
                    <tr>
                        <th>Course</th>
                        <th>Course Name</th>
                        <th>Score</th>
                    </tr>
                    <%
                        boolean any = false;
                        while (rs.next()) {
                            any = true;
                            int courseId = rs.getInt("course_id");
                            String ccode = rs.getString("course_code");
                            String cname = rs.getString("course_name");
                            String exScore = rs.getString("existing_score");
                    %>
                    <tr>
                        <td><%=ccode%></td>
                        <td><%=cname%></td>
                        <td>
                            <input type="number" step="0.01" min="0" max="10"
                                   name="score_<%=courseId%>"
                                   value="<%=(exScore==null?"":exScore)%>"
                                   placeholder="e.g. 3.75">
                        </td>
                    </tr>
                    <% } %>

                    <% if(!any){ %>
                        <tr><td colspan="3">No courses found for this semester.</td></tr>
                    <% } %>
                </table>

                <br>
                <button type="submit">Save / Update Scores</button>
                <a href="score.jsp"><button type="button">Clear</button></a>
            </form>

            <%
                    rs.close(); ps.close();
                }
            %>
        </div>

        <div class="card">
            <h3>Scores List (Latest)</h3>
            <table>
                <tr>
                    <th>Student Code</th>
                    <th>Name</th>
                    <th>Semester</th>
                    <th>Course</th>
                    <th>Score</th>
                </tr>
                <%
                    try {
                        PreparedStatement psList = con.prepareStatement(
                            "SELECT st.student_code, st.name, sc.semester, c.course_name, sc.score " +
                            "FROM scores sc " +
                            "JOIN students st ON st.student_id=sc.student_id " +
                            "JOIN courses c ON c.course_id=sc.course_id " +
                            "ORDER BY sc.score_id DESC LIMIT 30"
                        );
                        ResultSet rsList = psList.executeQuery();
                        while(rsList.next()){
                %>
                <tr>
                    <td><%=rsList.getString("student_code")%></td>
                    <td><%=rsList.getString("name")%></td>
                    <td><%=rsList.getInt("semester")%></td>
                    <td><%=rsList.getString("course_name")%></td>
                    <td><%=rsList.getBigDecimal("score")%></td>
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
