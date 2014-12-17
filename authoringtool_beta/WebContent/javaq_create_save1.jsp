<%@page import="javax.servlet.jsp.tagext.TryCatchFinally"%>
<%@ page language="java" %>
<%@ include file = "include/htmltop.jsp" %>
<%@ page import = "java.text.*" %>
<%@ page import = "java.lang.String" %>

<%@ page import="java.sql.*" %>

<%
	Connection connection = null;
	Class.forName(this.getServletContext().getInitParameter("db.driver"));
	connection = DriverManager.getConnection(this.getServletContext().getInitParameter("db.webexURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
	Statement statement = connection.createStatement();
	
	Connection connection2 = null;
	Statement statement2 = null;
            
	try{            
		String title1 = request.getParameter("title1");             
		String description1 = request.getParameter("description1");      
		String privacy1 = request.getParameter("privacy1");      
		String domain = request.getParameter("domain"); 
		
		if (title1 == null || title1.length()<1 || privacy1 == null || privacy1.length()<1 || domain == null || domain.length()<1 || domain.equals("-1")) {
			if (!response.isCommitted()) {
				response.sendRedirect("servletResponse.jsp");
				return;
			}
		}
		
		String title1_1 = title1.replace("'","\\'");
		title1_1 = title1_1.trim();
		title1_1 = title1_1.replaceAll(" ", "_");
		String description1_1 = description1.replace("'","\\'"); 
		
		String uid="";
		ResultSet rs = null;  
		rs = statement.executeQuery("SELECT id FROM ent_user where name = '"+userBeanName+"' ");
		while(rs.next()) {
			uid=rs.getString(1);  	
		}
	
		String gid="";
		ResultSet rs1 = null;  
		rs1 = statement.executeQuery("SELECT id FROM ent_group where name = '"+userBean.getGroupBean().getName()+"' ");
		while(rs1.next()) {
			gid=rs1.getString(1);  	
		}			
		
		rs1 = statement.executeQuery("SELECT * FROM ent_jquestion WHERE Title = '"+title1_1+"' ");
		if (rs1.next()) {
			if (!response.isCommitted()) {
				response.sendRedirect("servletResponse.jsp");
				return;
			}
		} else {
			if (privacy1.equals("private")) {
				String command = "insert into ent_jquestion (AuthorID,GroupID,Title,Description,Privacy, domain)"
				+" values ('"+uid+"','"+gid+"','"+(title1_1)+"','"+(description1_1)+"','0', \""+domain+"\") ";
				statement.executeUpdate(command);	 	
				response.sendRedirect("authoring.jsp?type=topic&message=Topic created successfully!&alert=success");
			} else {
				String command = "insert into ent_jquestion (AuthorID,GroupID,Title,Description,Privacy, domain)"
				+" values ('"+uid+"','"+gid+"','"+(title1_1)+"','"+(description1_1)+"','1', \""+domain+"\") ";
				statement.executeUpdate(command);	
				response.sendRedirect("authoring.jsp?type=topic&message=Topic created successfully!&alert=success");
			}
			
			if (domain.equals("java")) {
				connection2 = DriverManager.getConnection(this.getServletContext().getInitParameter("db.um2"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
				statement2 = connection2.createStatement();
				statement2.executeUpdate("INSERT INTO ent_activity (AppID, URI, Activity, Description, DateNTime) VALUES (25,'no uri', '"+title1_1+"', 'QuizJet quiz-Automatic Addition', NOW());");
			}
		}
	} catch (Exception e) {
		if (connection != null)
			connection.close();
		if (statement != null)
			statement.close();	
		System.out.println("Error occurred " + e);
		if (!response.isCommitted()) {
			response.sendRedirect("servletResponse.jsp");
			return;
		}
	} finally {
		try {
			if (statement != null) {
			statement.close();
			}
			if (connection != null) {
			connection.close();
			}
			if (statement2 != null) {       			
				statement2.close();
			}
			if (connection2 != null) {       			
				connection2.close();
			}
		} catch (Exception e) {
		}
	}
%>