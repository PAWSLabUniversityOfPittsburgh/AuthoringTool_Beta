<%@ page language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ include file = "include/htmltop.jsp" %>

<% 				
	if (!userBean.isAdmin()) {
		response.sendRedirect("authoring.jsp");
		return;
	}
%>
<script language="JavaScript" type="text/javascript">
	function validateForm() {
	    var reName = new RegExp(/\w+/);
	    var reEmail = new RegExp(/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);
	    if(!reName.test($('#myModal input[name="name"]').val())) {
	    	alertMessageUser("User name cannot be empty");
	    }
	    else if (!reEmail.test($('#myModal input[name="email"]').val())) {
	    	alertMessageUser("Invalid email");
	    }
	    else {
	    	$.post("SecurityServlet?action=MODIFYUSERINFO_ADMIN", 
	    			{id: ''+$('#myModal input[name="id"]').val()+'', name: ''+$('#myModal input[name="name"]').val()+'', email: ''+$('#myModal input[name="email"]').val()+''}, function() {})
		    .done(function(data) {
		    	if ($.trim(data) == "true") {
		    		closeModal();
		    		alertMessageTrue("User info has been successfully changed");
		    	} else {
		    		closeModal();
		    		alertMessage("Something went wrong while we were processing your request, please try to submit again");
		    	}
		    })
		    .fail(function() {
		    	closeModal();
		    	alertMessage("Something went wrong while we were processing your request, please try to submit again");
		    });
	    }
	}
	
	function showModal(id, name, login, email) {
		$('#myModal input[name="id"]').val(id);
		$('#myModal input[name="name"]').val(name);
		$('#myModal input[name="email"]').val(email);
		$('#userTitle').html(name+' ('+login+')');
		$('#myModal').modal('show');
	}
	
	function closeModal() {
		$('#myModal').modal('hide');
	}

	function alertMessage (text) {
		$("#alertMessage").hide().html('<div class="alert alert-danger alert-dismissible" role="alert">'+
				'<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>'+
				text+'</div>').fadeIn('slow');
		$("html, body").animate({ scrollTop: 0 }, "slow");
	}
	
	function alertMessageTrue (text) {
		$("#alertMessage").hide().html('<div class="alert alert-success alert-dismissible" role="alert">'+
				'<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>'+
				text+'</div>').fadeIn('slow');
		$("html, body").animate({ scrollTop: 0 }, "slow");
	}
	
	function alertMessageUser (text) {
		$("#alertMessageUser").hide().html('<div class="alert alert-danger alert-dismissible" role="alert">'+
				'<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>'+
				text+'</div>').fadeIn('slow');
	}
</script>
<style>
	#userTitle {
		font-weight: bold;
	}
</style>

		<h3>Modify Existing User:</h3>
		<p>Select any user to modify his(her) account information</p>
		<hr>
		<div id="alertMessage"></div>
		<div class="list-group">
		
<%
	Connection conn  = null;
	ResultSet results = null;
	Statement stmts = null;
	try{     
		conn  = getConnectionToWebex21();
		stmts = conn.createStatement();       
		results = stmts.executeQuery("SELECT * FROM ent_user ORDER BY name ASC;");
		while (results.next()) {
			String id = results.getString("id");
			String name = results.getString("name");
			String login = results.getString("login");
			String role = results.getString("role");
			String email = results.getString("email");
%>
			<a href="javascript:void(0);" class="list-group-item" onclick="<%= "showModal('"+id+"', '"+name+"', '"+login+"', '"+email+"')" %>"><%= name+" ("+login+") | email: "+email+" | role: "+role+" | id: "+id %></a>
<%
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

		</div>
		
		<!-- Modal Add Concept -->
		<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		  <div class="modal-dialog">
		    <div class="modal-content">
		      <div class="modal-header">
		        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
		        <h4 class="modal-title" id="myModalLabel">Modify user - <span id="userTitle"></span></h4>
		      </div>
		      <div class="modal-body">
		      	<div id="alertMessageUser"></div>
		      
				<div class="form-horizontal" id="formUser">
					<input type="hidden" name="id" value="" />
					<div class="form-group">
					    <label for="name" class="col-sm-3 control-label">Name:</label>
					    <div class="col-sm-9">
					    	<input type="text" name="name" value="" class="form-control" />
					    </div>
					</div>
					<div class="form-group">
					    <label for="email" class="col-sm-3 control-label">Email:</label>
					    <div class="col-sm-9">
					    	<input type="email" name="email" value="" class="form-control" />
					    </div>
					</div>
					<div class="form-group">
					    <div class="col-sm-offset-3 col-sm-9">
					    	<button type="button" class="btn btn-default" onclick="validateForm();">Submit</button>
		        			<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
					    </div>
					</div>
				</div>
		      
		      </div>
		    </div>
		  </div>
		</div> 

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
 
<%@ include file = "include/htmlbottom.jsp" %>