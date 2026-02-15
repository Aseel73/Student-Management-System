<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@page import="java.sql.*"%>
<%
    // 1) Session check (مهم للمشروع الرئيسي)
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2) DB Config
    String DB_URL  = "jdbc:mysql://localhost:3306/studentms";
    String DB_USER = "root";
    String DB_PASS = "Aseel#2424";   // <-- عدّلها إذا مختلفة

    Connection con = null;

    // Messages
    String msg = "";

    // Form values (for prefilling)
    String student_id = "";
    String student_code = "";
    String name = "";
    String dob = "";
    String gender = "";
    String email = "";
    String phone = "";
    String father_name = "";
    String mother_name = "";
    String address1 = "";
    String address2 = "";
    String image_path = "";

    // Search query
    String q = request.getParameter("q"); // student_code search

    // action handler
    String action = request.getParameter("action"); // add / update / delete / search

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        // ===== ADD =====
        if ("add".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {

            request.setCharacterEncoding("UTF-8");

            student_code = request.getParameter("student_code");
            name = request.getParameter("name");
            dob = request.getParameter("dob");
            gender = request.getParameter("gender");
            email = request.getParameter("email");
            phone = request.getParameter("phone");
            father_name = request.getParameter("father_name");
            mother_name = request.getParameter("mother_name");
            address1 = request.getParameter("address1");
            address2 = request.getParameter("address2");
            image_path = request.getParameter("image_path");

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO students (student_code,name,dob,gender,email,phone,father_name,mother_name,address1,address2,image_path) " +
                "VALUES (?,?,?,?,?,?,?,?,?,?,?)"
            );
            ps.setString(1, student_code);
            ps.setString(2, name);
            if(dob != null && !dob.trim().isEmpty()) ps.setDate(3, java.sql.Date.valueOf(dob));
            else ps.setNull(3, Types.DATE);

            ps.setString(4, gender);
            ps.setString(5, email);
            ps.setString(6, phone);
            ps.setString(7, father_name);
            ps.setString(8, mother_name);
            ps.setString(9, address1);
            ps.setString(10, address2);
            ps.setString(11, image_path);

            ps.executeUpdate();
            ps.close();

            msg = "✅ Student added successfully!";
            // clear after add
            student_code = name = dob = gender = email = phone = father_name = mother_name = address1 = address2 = image_path = "";
        }

        // ===== LOAD FOR EDIT (search by student_code) =====
        if ("search".equals(action) && q != null && !q.trim().isEmpty()) {
            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM students WHERE student_code=?"
            );
            ps.setString(1, q.trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                student_id = String.valueOf(rs.getInt("student_id"));
                student_code = rs.getString("student_code");
                name = rs.getString("name");
                dob = (rs.getDate("dob") == null) ? "" : rs.getDate("dob").toString();
                gender = rs.getString("gender");
                email = rs.getString("email");
                phone = rs.getString("phone");
                father_name = rs.getString("father_name");
                mother_name = rs.getString("mother_name");
                address1 = rs.getString("address1");
                address2 = rs.getString("address2");
                image_path = rs.getString("image_path");
                msg = "✅ Student found. You can update/delete now.";
            } else {
                msg = "❌ Student not found!";
            }
            rs.close();
            ps.close();
        }

        // ===== UPDATE =====
        if ("update".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
            request.setCharacterEncoding("UTF-8");

            student_id = request.getParameter("student_id");
            student_code = request.getParameter("student_code");
            name = request.getParameter("name");
            dob = request.getParameter("dob");
            gender = request.getParameter("gender");
            email = request.getParameter("email");
            phone = request.getParameter("phone");
            father_name = request.getParameter("father_name");
            mother_name = request.getParameter("mother_name");
            address1 = request.getParameter("address1");
            address2 = request.getParameter("address2");
            image_path = request.getParameter("image_path");

            PreparedStatement ps = con.prepareStatement(
                "UPDATE students SET student_code=?, name=?, dob=?, gender=?, email=?, phone=?, father_name=?, mother_name=?, address1=?, address2=?, image_path=? " +
                "WHERE student_id=?"
            );

            ps.setString(1, student_code);
            ps.setString(2, name);
            if(dob != null && !dob.trim().isEmpty()) ps.setDate(3, java.sql.Date.valueOf(dob));
            else ps.setNull(3, Types.DATE);
            ps.setString(4, gender);
            ps.setString(5, email);
            ps.setString(6, phone);
            ps.setString(7, father_name);
            ps.setString(8, mother_name);
            ps.setString(9, address1);
            ps.setString(10, address2);
            ps.setString(11, image_path);
            ps.setInt(12, Integer.parseInt(student_id));

            int rows = ps.executeUpdate();
            ps.close();

            msg = (rows > 0) ? "✅ Student updated successfully!" : "❌ Update failed!";
        }

        // ===== DELETE =====
        if ("delete".equals(action)) {
            String delId = request.getParameter("student_id");
            if (delId != null && !delId.trim().isEmpty()) {
                PreparedStatement ps = con.prepareStatement("DELETE FROM students WHERE student_id=?");
                ps.setInt(1, Integer.parseInt(delId));
                int rows = ps.executeUpdate();
                ps.close();

                msg = (rows > 0) ? "✅ Student deleted successfully!" : "❌ Delete failed!";
                // clear form
                student_id = student_code = name = dob = gender = email = phone = father_name = mother_name = address1 = address2 = image_path = "";
            }
        }

    } catch (Exception e) {
        msg = "❌ Error: " + e.getMessage();
    }
%>

<html>
<head>
    <meta charset="UTF-8" />
    <title>Student Module</title>
    <style>
        body{font-family:Arial; background:#f6f6f6;}
        .wrap{width:1100px; margin:20px auto; background:#fff; padding:15px; border-radius:8px;}
        .topbar{display:flex; justify-content:space-between; align-items:center;}
        .nav a{margin-right:12px; text-decoration:none;}
        .msg{margin:10px 0; padding:10px; background:#eef; border:1px solid #ccd;}
        .grid{display:grid; grid-template-columns: 380px 1fr; gap:15px; margin-top:10px;}
        label{display:block; margin-top:8px; font-weight:bold; font-size:13px;}
        input, select{width:100%; padding:8px; margin-top:4px;}
        .btns{margin-top:12px; display:flex; gap:10px; flex-wrap:wrap;}
        button{padding:10px 14px; cursor:pointer;}
        table{width:100%; border-collapse:collapse; margin-top:10px;}
        th,td{border:1px solid #ddd; padding:8px; font-size:13px; text-align:left;}
        th{background:#f0f0f0;}
        .small{font-size:12px; color:#666;}
        .imgbox{margin-top:10px; border:1px dashed #aaa; padding:10px; text-align:center;}
        .imgbox img{max-width:160px; max-height:160px;}
        .danger{background:#ffecec; border:1px solid #ffb3b3;}
        .ok{background:#eaffea; border:1px solid #b3ffb3;}
        .searchRow{display:flex; gap:10px; align-items:center;}
        .searchRow input{flex:1;}
    </style>
</head>
<body>
<div class="wrap">

    <div class="topbar">
        <h2>STUDENT MANAGEMENT SYSTEM - Student</h2>
        <div class="nav">
            <a href="dashboard.jsp">Dashboard</a>
            <a href="course.jsp">Course</a>
            <a href="score.jsp">Score</a>
            <a href="marksheet.jsp">Marks Sheet</a>
            <a href="logout.jsp">Logout</a>
        </div>
    </div>

    <div class="msg"><b>Status:</b> <%=msg%></div>

    <div class="grid">

        <!-- LEFT: Form -->
        <div>
            <h3>Student Form</h3>
            <p class="small">Tip: Search by Student Code (e.g., S001) to load data for update/delete.</p>

            <!-- Search -->
            <form method="get" action="student.jsp">
                <input type="hidden" name="action" value="search">
                <label>Search by Student Code</label>
                <div class="searchRow">
                    <input type="text" name="q" placeholder="Enter Student Code (S001)" value="<%= (q==null?"":q) %>" />
                    <button type="submit">Search</button>
                </div>
            </form>

            <hr>

            <!-- Add/Update Form -->
            <form method="post" action="student.jsp?action=<%= (student_id==null || student_id.isEmpty()) ? "add" : "update" %>">
                <input type="hidden" name="student_id" value="<%=student_id%>"/>

                <label>Student Code</label>
                <input type="text" name="student_code" required value="<%=student_code==null?"":student_code%>"/>

                <label>Name</label>
                <input type="text" name="name" required value="<%=name==null?"":name%>"/>

                <label>Date of Birth</label>
                <input type="date" name="dob" value="<%=dob==null?"":dob%>"/>

                <label>Gender</label>
                <select name="gender">
                    <option value="">-- Select --</option>
                    <option value="Male" <%= "Male".equals(gender) ? "selected" : "" %>>Male</option>
                    <option value="Female" <%= "Female".equals(gender) ? "selected" : "" %>>Female</option>
                </select>

                <label>Email</label>
                <input type="email" name="email" value="<%=email==null?"":email%>"/>

                <label>Phone</label>
                <input type="text" name="phone" value="<%=phone==null?"":phone%>"/>

                <label>Father Name</label>
                <input type="text" name="father_name" value="<%=father_name==null?"":father_name%>"/>

                <label>Mother Name</label>
                <input type="text" name="mother_name" value="<%=mother_name==null?"":mother_name%>"/>

                <label>Address Line 1</label>
                <input type="text" name="address1" value="<%=address1==null?"":address1%>"/>

                <label>Address Line 2</label>
                <input type="text" name="address2" value="<%=address2==null?"":address2%>"/>

                <label>Image Path</label>
                <input type="text" name="image_path" placeholder="images/s001.png" value="<%=image_path==null?"":image_path%>"/>

                <div class="imgbox">
                    <div class="small">Preview (if path exists):</div>
                    <%
                        String img = (image_path==null? "" : image_path.trim());
                        if(!img.isEmpty()){
                    %>
                        <img src="<%=request.getContextPath()+"/"+img%>" alt="Student Image"/>
                    <%
                        } else {
                    %>
                        <div class="small">No image selected</div>
                    <%
                        }
                    %>
                </div>

                <div class="btns">
                    <button type="submit"><%= (student_id==null || student_id.isEmpty()) ? "Add New" : "Update" %></button>

                    <%
                        if(student_id != null && !student_id.isEmpty()){
                    %>
                        <a href="student.jsp?action=delete&student_id=<%=student_id%>"
                           onclick="return confirm('Delete this student?');">
                           <button type="button" style="background:#ffdddd;">Delete</button>
                        </a>
                    <%
                        }
                    %>

                    <a href="student.jsp"><button type="button">Clear</button></a>
                </div>
            </form>
        </div>

        <!-- RIGHT: Table List -->
        <div>
            <h3>Students List</h3>

            <table>
                <tr>
                    <th>ID</th>
                    <th>Code</th>
                    <th>Name</th>
                    <th>Semester?</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Actions</th>
                </tr>

                <%
                    try {
                        PreparedStatement psList = con.prepareStatement(
                            "SELECT student_id, student_code, name, email, phone FROM students ORDER BY student_id DESC"
                        );
                        ResultSet rsList = psList.executeQuery();
                        while(rsList.next()){
                %>
                    <tr>
                        <td><%=rsList.getInt("student_id")%></td>
                        <td><%=rsList.getString("student_code")%></td>
                        <td><%=rsList.getString("name")%></td>
                        <td class="small">--</td>
                        <td><%=rsList.getString("email")==null?"":rsList.getString("email")%></td>
                        <td><%=rsList.getString("phone")==null?"":rsList.getString("phone")%></td>
                        <td>
                            <a href="student.jsp?action=search&q=<%=rsList.getString("student_code")%>">Edit</a>
                        </td>
                    </tr>
                <%
                        }
                        rsList.close();
                        psList.close();
                    } catch(Exception e2){
                        out.println("<tr><td colspan='7'>Error loading list: " + e2.getMessage() + "</td></tr>");
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
