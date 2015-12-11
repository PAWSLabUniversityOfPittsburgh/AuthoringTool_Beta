<%@ page language="java" %>
<%@ page import="java.sql.*" %>

<%
	String randLink = request.getParameter("id");
	if (randLink == null || randLink.trim().length() == 0) {
		response.sendRedirect("home.jsp");
		return;
	}
	
	Connection conn  = null;
	ResultSet results = null;
	Statement stmts = null;
	Integer id = null;
	String name = null;
	String login = null;
	try{     
		conn  = getConnectionToWebex21();
		stmts = conn.createStatement();       
		stmts.executeUpdate("DELETE FROM ent_user_pr WHERE time < (NOW() - INTERVAL 1 DAY)");
		results = stmts.executeQuery("SELECT * FROM ent_user_pr WHERE rand = \""+randLink+"\";");
		results.last();
		int size = results.getRow();
		if (size != 1) {
			if (!response.isCommitted()) {
				response.sendRedirect("home.jsp");
				return;
			}
		} else {
			id = results.getInt("user_id");
			results = stmts.executeQuery("SELECT name, login FROM ent_user WHERE id = "+id+";");
			results.last();
			name = results.getString("name");
			login = results.getString("login");
		}
	} catch (Exception e) {
		if (stmts != null)
			stmts.close();
		if (results != null)
			results.close();
		System.out.println(e);
		if (!response.isCommitted()) {
			response.sendRedirect("home.jsp");
			return;
		}
	} finally {
		if(isConnectedToDB(conn))
			disconnectFromDB(conn);
	}
%>

<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Authoring Tool</title>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<meta name="viewport" content="width=device-width, initial-scale=1" />
		<link href="stylesheets/bootstrap.min.css" rel="stylesheet" type="text/css" />
		<style>
			.form-group a {
				float: right;
			}
			.form-group.bottom {
				margin-bottom: 0px;
			}
		</style>
		<script language="JavaScript">
			function submit() {
				var reNotLogPass = new RegExp(/[a-zA-Z0-9_]+[a-zA-Z0-9_;:,-\.]*/); 
				tempPass = document.getElementById("password").value;
				if(!reNotLogPass.test(tempPass)) {
					alertMessage("User password can have only alphanumerical symbols and underscores");
			    }
			    else if (tempPass != document.getElementById("checkpassword").value) {
					alertMessage("Passwords do not match");
				}
				else {
			    	$.post("SecurityServlet?action=RESET_PASSWORD", {np: tempPass, pr: "<%= randLink %>"}, function() {})
				    .done(function(data) {
				    	if ($.trim(data) == "true") {
				    		window.location.href="index.html?action=PR";
				    	} else {
				    		alertMessage("Something went wrong while we were processing your request, please try to submit again");
				    	}
				    })
				    .fail(function() {
				    	alertMessage("Something went wrong while we were processing your request, please try to submit again");
				    });
			
				}
			}
			
			function alertMessage (text) {
				$("#alertMessage").hide().html('<div class="alert alert-danger alert-dismissible" role="alert">'+
						'<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>'+
						text+'</div>').fadeIn('slow');
				$("html, body").animate({ scrollTop: 0 }, "slow");
			}
		</script>
	</head>
<body>
	<div id="alertMessage"></div>
	<br/>
	<div class="row">
		<div class="col-xs-10 col-xs-offset-1 col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3 col-lg-4 col-lg-offset-4">
			<div class="panel panel-primary">
				<div class="panel-heading">
			    <h2 class="panel-title text-center">Authoring Tool - Password Reset</h2>
				</div>
			  	<div class="panel-body">
					<p>Hello, <%= name %><br/>Please, enter new password for your account with login: <%= login %></p>
					  
					<div class="form-horizontal">
						<div class="form-group">
						    <label for="password" class="col-sm-3 control-label">New Password:</label>
						    <div class="col-sm-9">
						    	<input type="password" name="password" id="password" value="" maxlength="45" class="form-control" />
						    </div>
						</div>
						<div class="form-group">
						    <label for="checkpassword" class="col-sm-3 control-label">Repeat Password:</label>
						    <div class="col-sm-9">
						    	<input type="password" name="checkpassword" id="checkpassword" value="" maxlength="45" class="form-control" />
						    </div>
						</div>
						<div class="form-group">
						  <div class="col-sm-offset-3 col-sm-9">
						    <button class="btn btn-default" id="submitBtn" onclick="submit();">Submit</button>
						  </div>
						</div>
						<div class="form-group bottom">
						  <div class="col-sm-offset-3 col-sm-9">
						    <a href="index.html">main page</a>
						  </div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	
	<script src="js/jquery-1.9.1.js"></script>
	<script src="js/bootstrap.min.js"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('#email').focus();
		});
	</script>
</body>
</html>

<%!
	public Connection getConnectionToWebex21() {
		Connection tempConn = null;
		try
		{
			Class.forName(this.getServletContext().getInitParameter("db.driver"));
			tempConn = DriverManager.getConnection(this.getServletContext().getInitParameter("db.webexURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
		}catch (Exception e) {
			e.printStackTrace();
		}
		return tempConn;
	}
	
	public boolean isConnectedToDB(Connection conn) {		
		try {
			if (conn != null && (conn.isClosed() == false)) 
				return true;								
					
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return false;		
	} 
	 
	public void disconnectFromDB(Connection conn) {
		try {
			if (conn != null && (conn.isClosed() == false)) {
				conn.close();
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}		
	}
 %>