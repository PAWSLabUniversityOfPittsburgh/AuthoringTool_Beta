<%@ page language="java" %>
<%@ include file = "include/htmltop.jsp" %>

<script language="JavaScript" type="text/javascript">
	function validateForm() {
	    var reName = new RegExp(/\w+/);
	    if(!reName.test(document.formUser.name.value)) {
	    	alertMessage("User name cannot be empty");
	        return false;
	    }
		var reNotLogPass = new RegExp(/[a-zA-Z0-9_]+[a-zA-Z0-9_;:,-\.]*/); /*\W+*/
	    if(!reNotLogPass.test(document.formUser.login.value)) {
	    	alertMessage("User login can have only alphanumerical symbols and underscores");
	        return false;
	    }
	    var reEmail = new RegExp(/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);
	    if (!reEmail.test(document.formUser.email.value)) {
	    	alertMessage("Invalid email");
	    	return false;
	    }
	    if(!reName.test(document.formUser.oldPassword.value)) {
	    	alertMessage("Old Password cannot be empty");
	        return false;
	    }
		if(!reNotLogPass.test(document.formUser.password.value)) {
			alertMessage("User password can have only alphanumerical symbols and underscores");
	        return false;
	    }
		if (document.formUser.password.value != document.formUser.checkpassword.value) {
			alertMessage("Passwords do not match");
	        return false;
		}
		return true;
	}
<%
		boolean alertMes = false;
		String alert = request.getParameter("alert");
		if (alert != null && alert.equals("1")) {
			alertMes = true;
		}
%>
	
	function alertMessage (text) {
		$("#alertMessage").hide().html('<div class="alert alert-danger alert-dismissible" role="alert">'+
				'<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>'+
				text+'</div>').fadeIn('slow');
		$("html, body").animate({ scrollTop: 0 }, "slow");
	}
</script>

		<h3>Modify Personal Data:</h3>
		<hr>
		<div id="alertMessage"><%= (alertMes) ? "<div class=\"alert alert-danger alert-dismissible\" role=\"alert\">"+
				"<button type=\"button\" class=\"close\" data-dismiss=\"alert\"><span aria-hidden=\"true\">&times;</span><span class=\"sr-only\">Close</span></button>"+
				"Incorrect old password</div>" : ""%></div>
	
		<form class="form-horizontal" role="form" name="formUser" id="formUser" method="post" action="SecurityServlet?action=MODIFYUSERINFO" onSubmit="return validateForm();">
			<input type="hidden" name="id" value="<%= userBean.getId() %>" />
			<div class="form-group">
			    <label for="name" class="col-sm-3 control-label">Name:</label>
			    <div class="col-sm-9">
			    	<input type="text" name="name" value="<%= userBeanName %>" class="form-control" />
			    </div>
			</div>
			<div class="form-group">
			    <label for="login" class="col-sm-3 control-label">Login:</label>
			    <div class="col-sm-9">
			    	<input type="text" name="login" readonly value="<%= userBean.getLogin().trim() %>" class="form-control" />
			    </div>
			</div>
			<div class="form-group">
			    <label for="email" class="col-sm-3 control-label">Email:</label>
			    <div class="col-sm-9">
			    	<input type="email" name="email" value="<%= userBean.getEmail().trim() %>" class="form-control" />
			    </div>
			</div>
			<div class="form-group">
			    <label for="password" class="col-sm-3 control-label">Old Password:</label>
			    <div class="col-sm-9">
			    	<input type="password" name="oldPassword" value="" maxlength="45" class="form-control" />
			    </div>
			</div>
			<div class="form-group">
			    <label for="password" class="col-sm-3 control-label">New Password:</label>
			    <div class="col-sm-9">
			    	<input type="password" name="password" value="" maxlength="45" class="form-control" />
			    </div>
			</div>
			<div class="form-group">
			    <label for="checkpassword" class="col-sm-3 control-label">Repeat New Password:</label>
			    <div class="col-sm-9">
			    	<input type="password" name="checkpassword" value="" maxlength="45" class="form-control" />
			    </div>
			</div>
			<div class="form-group">
			    <div class="col-sm-offset-3 col-sm-9">
			    	<input name="submit" type="submit" value="Submit" class="btn btn-default">
			    </div>
			</div>
		</form>

<%@ include file = "include/htmlbottom.jsp" %>