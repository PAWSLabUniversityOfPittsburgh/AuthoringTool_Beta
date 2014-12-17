<%@ page language="java" %>
<%@ include file = "../include/htmltop.jsp" %>
<%@ page import = "java.text.*" %>
<%@ page import="java.sql.*" %>

<%
	ResultSet resultd = null;
	ResultSet resultd1 = null;
	Statement statement = null;
    Connection connection = null;
	
	try{	    
	    Class.forName(this.getServletContext().getInitParameter("db.driver"));
		connection = DriverManager.getConnection(this.getServletContext().getInitParameter("db.webexURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
		statement = connection.createStatement();
		
/* 		String MaxID ="";
	    resultd = statement.executeQuery("select max(DissectionID) from rel_scope_dissection");      
		while(resultd.next()) { 	
			MaxID = resultd.getString(1);		
		}
	    int Max = Integer.parseInt(MaxID);	 */
	    int Max = Integer.parseInt(request.getParameter("ex"));
		
	    String MaxLine="";
	    resultd1 = statement.executeQuery("select max(LineIndex) from ent_line where DissectionID = '"+Max+"' ");        
		while(resultd1.next()) {
	    	MaxLine=resultd1.getString(1);
	    }
	    int Line = Integer.parseInt(MaxLine);	
		
	    while(Line>0) {
		    String comment = request.getParameter("C"+Line+"");
		    comment = comment.replace("'","\\'");
		    String command = "update ent_line set Comment = '"+comment+"' where DissectionID = '"+Max+"' and LineIndex = '"+Line+"' ";	    	   
	        statement.executeUpdate(command);              
	        Line--;
	    }
		
	    response.sendRedirect("ParserServlet?sc="+request.getParameter("sc")+"&question="+request.getParameter("ex")+"&type=example&load=javaExampleSaved.jsp");
	} catch (Exception e) {
		e.printStackTrace();
		if (!response.isCommitted()) {
			response.sendRedirect("servletResponse.jsp");
		}
	} finally {
		if (resultd != null)
			resultd.close();
		
		if (resultd1 != null)
			resultd1.close();
		
		if (statement != null)
			statement.close();
		
		if (connection != null)
			connection.close(); 
	}            	    	
%>

<%@ include file = "../include/htmlbottom.jsp" %>