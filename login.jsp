<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@page import="java.sql.*"%>
<%
    // لو المستخدم مسجل دخول، ودّيه للداشبورد
    if (session.getAttribute("username") != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    String msg = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String u = request.getParameter("username");
        String p = request.getParameter("password");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/studentms", "root", "Aseel#2424"
            );

            PreparedStatement ps = con.prepareStatement(
                "SELECT username, role FROM users WHERE username=? AND password=?"
            );
            ps.setString(1, u);
            ps.setString(2, p);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                session.setAttribute("username", rs.getString("username"));
                session.setAttribute("role", rs.getString("role"));
                response.sendRedirect("dashboard.jsp");
                con.close();
                return;
            } else {
                msg = "Invalid username or password!";
            }
            con.close();
        } catch (Exception e) {
            msg = "Error: " + e.getMessage();
        }
    }
%>

<html>
<head>
    <title>Login - StudentMS</title>
    <style>
        body{font-family:Arial; background:#f4f4f4;}
        .box{width:350px; margin:80px auto; background:#fff; padding:20px; border-radius:8px;}
        input{width:100%; padding:10px; margin:8px 0;}
        button{padding:10px; width:100%;}
        .err{color:red;}
    </style>
</head>
<body>
<div class="box">
    <h2>Login</h2>
    <p class="err"><%=msg%></p>

    <form method="post" action="login.jsp">
        <input type="text" name="username" placeholder="Username" required />
        <input type="password" name="password" placeholder="Password" required />
        <button type="submit">Login</button>
    </form>

    <p style="font-size:12px;color:#666;">
        Demo: admin / admin123
    </p>
</div>
</body>
</html>
