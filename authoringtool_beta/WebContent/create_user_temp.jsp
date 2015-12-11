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
		var reNotLogPass = new RegExp(/[a-zA-Z0-9_]+[a-zA-Z0-9_;:,-\.]*/); /*\W+*/
		var reEmail = new RegExp(/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);
	
	    if(!reName.test(document.formUser.name.value)) {
	    	alertMessage("User name cannot be empty");
	    }
	    else if(!reNotLogPass.test(document.formUser.login.value)) {
	    	alertMessage("User login can have only alphanumerical symbols and underscores");
	    }
	    else if (!reEmail.test(document.formUser.email.value)) {
	    	alertMessage("Invalid email");
	    	return false;
	    }
		else if(!reNotLogPass.test(document.formUser.password.value)) {
			alertMessage("User password can have only alphanumerical symbols and underscores");
	    }
	    else if (document.formUser.password.value != document.formUser.checkpassword.value) {
			alertMessage("Passwords do not match");
		}
	    else {
	    	tempLog = document.formUser.login.value;
	    	$.post("SecurityServlet?action=CHECKLOG", {log: tempLog}, function() {})
		    .done(function(data) {
		    	if ($.trim(data) == "true") {
					$('form').attr('action', 'SecurityServlet?action=CREATEUSER_TEMP');
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
			<div class="form-group" id="roleSelect">
				<label for="role" class="col-sm-3 control-label">Role:</label>
				<div class="col-sm-9">
					<select name="role" size="1" class="form-control" >
						<option value="admin">System Administrator</option>
						<option value="superuser">Super User</option>
		    		</select>
				</div>
			</div>
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
			    <label for="email" class="col-sm-3 control-label">Email:</label>
			    <div class="col-sm-9">
			    	<input type="email" name="email" value="" class="form-control" />
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
		</form>

<%@ include file = "include/htmlbottom.jsp" %>