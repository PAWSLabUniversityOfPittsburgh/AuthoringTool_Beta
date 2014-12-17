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
	
	function alertMessage (text) {
		$("#alertMessage").hide().html('<div class="alert alert-danger alert-dismissible" role="alert">'+
				'<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>'+
				text+'</div>').fadeIn('slow');
		$("html, body").animate({ scrollTop: 0 }, "slow");
	}
</script>

<% 				
	String action = request.getParameter("action");
	String welcome = null;
	UserBean modifyUserBean = null;
	int index = 0;
 	if (action != null) {		
		if (action.equalsIgnoreCase("MODIFYUSER")) {
			if (userBean.isAdmin()) {
				Vector userList = (Vector) session.getAttribute("userList");
				session.removeAttribute("userList");
				try {
					index = (new Integer ((String) request.getParameter("index"))).intValue();
				} catch (NumberFormatException e) {
					System.out.println("[userinfo.jsp]: incorrect index");
					e.printStackTrace();            
				}
				modifyUserBean = (UserBean) userList.elementAt(index);				
				welcome = "Modify User <i>" + modifyUserBean.getLogin() + "</i>:";
			} 
		} else if (action.equalsIgnoreCase("CREATEUSER")) {
			if (userBean.isAdmin())
				welcome = "Create New User:";
		} else if (action.equalsIgnoreCase("MODIFYUSERINFO")) {
			welcome = "Modify Personal Data:";			
		}
		
		if (welcome == null) {
			welcome = "You do not have sufficient rights to perform this operation. " +
					 "Only <a href=\"mailto:roh38@pitt.edu\">System Administrator</a> " +
					 "can create new users.<br/> Return to <a href=\"authoring.jsp\">Home</a>";
%>
		<h4><%=welcome%></h4>
<%			
		} else {
%>
		<h3><%=welcome%></h3>
		<hr>
		<div id="alertMessage"></div>
	
		<form class="form-horizontal" role="form" name="formUser" id="formUser" method="post" action="SecurityServlet?action=<%=action%>" onSubmit="return validateForm();">
			<input type="hidden" name="id" value="<%=(action.equalsIgnoreCase("MODIFYUSER")) ? modifyUserBean.getId() : (action.equalsIgnoreCase("MODIFYUSERINFO")) ? userBean.getId() : -1%>" />
			<div class="form-group">
			    <label for="name" class="col-sm-3 control-label">Name:</label>
			    <div class="col-sm-9">
			    	<input type="text" name="name" value="<%=""+((action.equalsIgnoreCase("MODIFYUSER"))?""+modifyUserBean.getName().trim():""+((action.equalsIgnoreCase("MODIFYUSERINFO"))?""+userBeanName:""))%>" class="form-control" />
			    </div>
			</div>
			<div class="form-group">
			    <label for="login" class="col-sm-3 control-label">Login:</label>
			    <div class="col-sm-9">
			    	<input type="text" name="login" <%=(!userBean.isAdmin()) ? "readonly" : ""%> value="<%=(action.equalsIgnoreCase("MODIFYUSER"))?modifyUserBean.getLogin().trim():(action.equalsIgnoreCase("MODIFYUSERINFO"))?userBean.getLogin().trim():""%>" class="form-control" />
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
<!-- 			<div class="form-group">
				<label for="role" class="col-sm-3 control-label">Role:</label>
				<div class="col-sm-9"> -->

<%
					/* if (userBean.getRole().equals("admin")) {
						String role = (action.equalsIgnoreCase("MODIFYUSER")) ? modifyUserBean.getRole() : (action.equalsIgnoreCase("MODIFYUSERINFO")) ? userBean.getRole() : ""; */
%>
<%-- 			    	<select name="role" <%=(!userBean.isAdmin()) ? "readonly" : ""%> size="1" class="form-control">
						<option <%=(role.equalsIgnoreCase("admin")) ? "selected" : ""%> value="admin">System Administrator</option>
						<option <%=(role.equalsIgnoreCase("superuser")) ? "selected" : ""%> value="superuser">Super User</option>
						<option <%=(role.equalsIgnoreCase("user")) ? "selected" : ""%> value="user">User</option>
		    		</select> --%>
<%
/* 					} else {
						out.println(userBean.getRole());
					} */
%>
<!-- 				</div>
			</div> -->
			<div class="form-group">
			    <div class="col-sm-offset-3 col-sm-9">
			    	<input name="submit" type="submit" value="Submit" class="btn btn-default">
			    </div>
			</div>
		</form>
<%	
		}
	}
%>

<%@ include file = "include/htmlbottom.jsp" %>