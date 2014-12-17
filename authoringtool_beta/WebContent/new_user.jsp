<%@ page language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ include file = "include/htmltop.jsp" %>

<% 				
	if (!userBean.isAdmin() && !userBean.getGroupBean().getName().equals("teachers")) {
		response.sendRedirect("authoring.jsp");
		return;
	}
%>
<script language="JavaScript" type="text/javascript">
	function validateForm() {
	    var reName = new RegExp(/\w+/);
		var reNotLogPass = new RegExp(/[a-zA-Z0-9_]+[a-zA-Z0-9_;:,-\.]*/); /*\W+*/

	    if(!reName.test(document.formUser.name.value)) {
	    	alertMessage("User name cannot be empty");
	    }
	    else if(!reNotLogPass.test(document.formUser.login.value)) {
	    	alertMessage("User login can have only alphanumerical symbols and underscores");
	    }
		else if(!reNotLogPass.test(document.formUser.password.value)) {
			alertMessage("User password can have only alphanumerical symbols and underscores");
	    }
	    else if (document.formUser.password.value != document.formUser.checkpassword.value) {
			alertMessage("Passwords do not match");
		}
	    else if (checkNewGroupInput()) {
	    	alertMessage("New Group name cannot be empty, or select existing group");
	    }
	    else {
	    	var tempLog = document.formUser.login.value;
	    	$.post("SecurityServlet?action=CHECKLOG", {log: tempLog}, function() {})
		    .done(function(data) {
		    	if ($.trim(data) == "true") {
					$('form').attr('action', 'SecurityServlet?action=CREATEUSER');
					$('form').attr('onsubmit', 'return true;');
					$('form').submit();
		    	} else {
		    		alertMessage("Login ("+tempLog+") already exist");
		    	}
		    })
		    .fail(function() {
		    	alertMessage("Something went wrong while we were processing your request, please try to submit again");
		    });

		}
	}
	
	function checkNewGroupInput () {
		if ($('#addGroupTeacherField').length) {
			if (!$('#addGroupTeacherField').hasClass('hidden')) {
				tempVal = $('#addGroupTeacherField').val();	
				if (tempVal.length < 1) {
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		} else if ($('#addGroupAdminField').length) {
			if (!$('#addGroupAdminField').hasClass('hidden')) {
				tempVal = $('#addGroupAdminField').val();	
				if (tempVal.length < 1) {
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}
		return true;
	}
	
	function newGroupTeacher() {
		$('#addGroupTeacherButton').addClass('hidden');
		$('#groupTeacher').addClass('hidden');
		$('#addGroupTeacherField').removeClass('hidden');
		$('#userInfo').removeClass('hidden');
		$('#groupTeacher select option').each(function() {
			if ($( this ).val() == '-1') {
				$( this ).attr('selected', true);
			} else {
				$( this ).attr('selected', false);
			}
		});
	}
	
	function closeNewGroupTeacher() {
		$('#addGroupTeacherButton').attr('class', 'form-group');
		$('#groupTeacher').attr('class', 'form-group');
		$('#addGroupTeacherField').attr('class', 'form-group hidden');
		$('#userInfo').attr('class', 'hidden');
	}
	
	function groupTeacherSelect() {
		if ($( "#groupTeacher select" ).val() == "-1") {
			$('#userInfo').attr('class', 'hidden');
		} else {
			$('#userInfo').attr('class', '');
		}
	}
	
	function roleSelect() {
		testVar = $( "#roleSelect select" ).val();
		if (testVar == "-1") {
			$('#userInfo').attr('class', 'hidden');
			$('#groupAdmin').attr('class', 'form-group hidden');
			$('#addGroupAdminButton').attr('class', 'form-group hidden');
			$('#addGroupAdminField').attr('class', 'form-group hidden');
			
		} else if (testVar == "admin" || testVar == "superuser") {
			$('#userInfo').attr('class', '');
			$('#groupAdmin').attr('class', 'form-group hidden');
			$('#addGroupAdminButton').attr('class', 'form-group hidden');
			$('#addGroupAdminField').attr('class', 'form-group hidden');
			
		} else {
			$('#userInfo').attr('class', 'hidden');
			$('#groupAdmin').attr('class', 'form-group');
			$('#addGroupAdminButton').attr('class', 'form-group');
			$('#addGroupAdminField').attr('class', 'form-group hidden');
		}
		$('#groupAdmin select option').each(function() {
			if ($( this ).val() == '-1') {
				$( this ).attr('selected', true);
			} else {
				$( this ).attr('selected', false);
			}
		});
	}
	
	function groupAdminSelect() {
		if ($( "#groupAdmin select" ).val() == "-1") {
			$('#userInfo').attr('class', 'hidden');
		} else {
			$('#userInfo').attr('class', '');
		}
	}
	
	function newGroupAdmin() {
		$('#addGroupAdminButton').addClass('hidden');
		$('#groupAdmin').addClass('hidden');
		$('#addGroupAdminField').removeClass('hidden');
		$('#userInfo').removeClass('hidden');
		$('#groupAdmin select option').each(function() {
			if ($( this ).val() == '-1') {
				$( this ).attr('selected', true);
			} else {
				$( this ).attr('selected', false);
			}
		});
	}
	
	function closeNewGroupAdmin() {
		$('#addGroupAdminButton').attr('class', 'form-group');
		$('#groupAdmin').attr('class', 'form-group');
		$('#addGroupAdminField').attr('class', 'form-group hidden');
		$('#userInfo').attr('class', 'hidden');
	}
	
	function alertMessage (text) {
		$("#alertMessage").hide().html('<div class="alert alert-danger alert-dismissible" role="alert">'+
				'<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>'+
				text+'</div>').fadeIn('slow');
		$("html, body").animate({ scrollTop: 0 }, "slow");
	}
</script>

		<h3>Create New User:</h3>
		<hr>
		<div id="alertMessage"></div>
	
		<form class="form-horizontal" role="form" name="formUser" id="formUser" method="post" action="" onSubmit="return false">
<%
					int size = 0;
					if (userBean.getRole().equals("admin")) {
%>
			<div class="form-group" id="roleSelect">
				<label for="role" class="col-sm-3 control-label">Role:</label>
				<div class="col-sm-9">
					<select name="role" size="1" class="form-control" onchange="roleSelect();">
						<option value="-1" selected >Please select Role</option>
						<option value="admin">System Administrator</option>
						<option value="superuser">Super User</option>
						<option value="user">User</option>
		    		</select>
				</div>
			</div>
			<div id="adminBox">
			
			</div>
<%
					
						Connection conn  = null;
						ResultSet results = null;
						Statement stmts = null;
						try {
							Class.forName(this.getServletContext().getInitParameter("db.driver"));
							conn = DriverManager.getConnection(this.getServletContext().getInitParameter("db.webexURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
							stmts = conn.createStatement();       
							results = stmts.executeQuery("SELECT * FROM ent_group WHERE id != 1 AND id != 2");
							
							results.last();
							size = results.getRow();
							if (size > 0) {
%>
			<div class="form-group hidden" id="groupAdmin">
				<label class="col-sm-3 control-label">Group:</label>
				<div class="col-sm-9">
					<select name="groupAdmin" size="1" class="form-control" onchange="groupAdminSelect();">
						<option value="-1" selected>Please select a group</option>
<%
								results.first();
								out.println("<option value='"+results.getString(1)+"' >"+results.getString(2)+"</option>"); 
								while(results.next()) {
									out.println("<option value='"+results.getString(1)+"' >"+results.getString(2)+"</option>"); 	
								}					
%>
					</select>
				</div>
			</div>
<%
							}
%>
			<div class="form-group hidden" id="addGroupAdminButton">
				<label class="col-sm-3 control-label"></label>
				<div class="col-sm-9">
					<button class="btn btn-default" onclick="newGroupAdmin();">Create new Group</button>
				</div>
			</div>
			<div class="form-group <%= (size == 0) ? "" : "hidden" %>" id="addGroupAdminField">
				<label class="col-sm-3 control-label">New Group name:</label>
				<div class="col-sm-9">
<%
							if (size == 0) {
%>
					<input type="text" name="newGroup" value="" class="form-control" />
<%
							} else {
%>
					<div class="input-group">
						<input type="text" name="newGroup" value="" class="form-control" />
						<span class="input-group-btn">
							<button class="btn btn-default" type="button" onclick="closeNewGroupAdmin();" >Select existing group</button>
						</span>
					</div>
<%
							}
%>
				</div>
			</div>
<%				
						}catch (Exception e) {
							System.out.println(e);
							response.sendRedirect("servletResponse.jsp");
							return;
						} finally {
							if (conn != null)
								conn.close();
							if (results != null)
								results.close();
							if (stmts != null)
								stmts.close();
						}

					} else {
%>
						<input type="hidden" name="role" value="user" />
<%
						Connection conn  = null;
						ResultSet results = null;
						Statement stmts = null;
						try {
							Class.forName(this.getServletContext().getInitParameter("db.driver"));
							conn = DriverManager.getConnection(this.getServletContext().getInitParameter("db.webexURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
							stmts = conn.createStatement();       
							results = stmts.executeQuery("SELECT * FROM ent_group WHERE ownerid = "+userBean.getId());
							
							results.last();
							size = results.getRow();
							if (size > 0) {
%>
			<div class="form-group" id="groupTeacher">
				<label class="col-sm-3 control-label">Group:</label>
				<div class="col-sm-9">
					<select name="groupTeacher" size="1" class="form-control" onchange="groupTeacherSelect();">
						<option value="-1" selected>Please select a group</option>
<%
								results.first();
								out.println("<option value='"+results.getString(1)+"' >"+results.getString(2)+"</option>"); 
								while(results.next()) {
									out.println("<option value='"+results.getString(1)+"' >"+results.getString(2)+"</option>"); 	
								}					
%>
		    		</select>
				</div>
			</div>
<%
							}
%>
			<div class="form-group <%= (size > 0) ? "" : "hidden" %>" id="addGroupTeacherButton">
			<label class="col-sm-3 control-label"></label>
			    <div class="col-sm-9">
			    	<button class="btn btn-default" onclick="newGroupTeacher();">Create new Group</button>
			    </div>
			</div>
			<div class="form-group <%= (size == 0) ? "" : "hidden" %>" id="addGroupTeacherField">
			    <label class="col-sm-3 control-label">New Group name:</label>
			    <div class="col-sm-9">
<%
							if (size == 0) {
%>
					<input type="text" name="newGroup" value="" class="form-control" />
<%
							} else {
%>
					<div class="input-group">
				    	<input type="text" name="newGroup" value="" class="form-control" />
		              	<span class="input-group-btn">
		                	<button class="btn btn-default" type="button" onclick="closeNewGroupTeacher();" >Select existing group</button>
						</span>
					</div>
<%
							}
%>
			    </div>
			</div>
<%				
						}catch (Exception e) {
							System.out.println(e);
							response.sendRedirect("servletResponse.jsp");
							return;
						} finally {
							if (conn != null)
								conn.close();
							if (results != null)
								results.close();
							if (stmts != null)
								stmts.close();
						}
					}

%>		
			<div id="userInfo" class="<%= (userBean.getRole().equals("admin")) ? "hidden" : (size == 0) ? "" : "hidden" %>">
				<div class="form-group">
				    <label for="name" class="col-sm-3 control-label">Name:</label>
				    <div class="col-sm-9">
				    	<input type="text" name="name" value="" class="form-control" />
				    </div>
				</div>
				<div class="form-group">
				    <label for="login" class="col-sm-3 control-label">Login:</label>
				    <div class="col-sm-9">
				    	<input type="text" name="login" value="" class="form-control" />
				    </div>
				</div>
				<div class="form-group">
				    <label for="password" class="col-sm-3 control-label">Password:</label>
				    <div class="col-sm-9">
				    	<input type="password" name="password" value="" maxlength="45" class="form-control" />
				    </div>
				</div>
				<div class="form-group">
				    <label for="checkpassword" class="col-sm-3 control-label">Repeat Password:</label>
				    <div class="col-sm-9">
				    	<input type="password" name="checkpassword" value="" maxlength="45" class="form-control" />
				    </div>
				</div>
				<div class="form-group">
				    <div class="col-sm-offset-3 col-sm-9">
				    	<button class="btn btn-default" onclick="validateForm();">Submit</button>
				    </div>
				</div>
			</div>
		</form>

<%@ include file = "include/htmlbottom.jsp" %>