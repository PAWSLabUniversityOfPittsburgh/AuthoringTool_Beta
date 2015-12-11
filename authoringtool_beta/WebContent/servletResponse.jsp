<%@ page language="java" %>
<%@ include file = "include/htmltop.jsp" %>

<script src="<%=request.getContextPath()%>/js/jquery1.4.2.js"></script>
<script language="JavaScript">
	function handleRequest() {
		var query = window.location.search;
		if (query.length == 0) {
			$('#message').addClass('alert-warning');
			return("Something went wrong");
		}
		else	{
			var action = query.substring(query.indexOf("=") + 1,query.length);
			if (action == "MODIFYUSERINFOOK") {
				$('#message').addClass('alert-success');
				return("You have successfully modified your personal data.");
			}
			else if (action =="MODIFYUSERINFOFAILED" ) {
				$('#message').addClass('alert-danger');
				return("Error occured while saving user info to the database. " + 
					   "Please contact <a href=\"mailto:roh38@pitt.edu\" class=\"alert-link\">System Administrator</a>");
			}
			else if (action == "CREATEGROUPOK") {
				$('#message').addClass('alert-success');
				return("The group has been successfully created.");
			}
			else if (action == "CREATEGROUPFAILED") {
				$('#message').addClass('alert-danger');
				return("Error occured while saving group info to the database. " + 
					   "Please contact <a href=\"mailto:roh38@pitt.edu\" class=\"alert-link\">System Administrator</a>");				   
			}
			else if (action == "MODIFYGROUPOK") {
				$('#message').addClass('alert-success');
				return("The group has been successfully modified.");
			}
			else if (action == "MODIFYGROUPFAILED") {
				$('#message').addClass('alert-danger');
				return("Error occured while saving group info to the database. " + 
					   "Please contact <a href=\"mailto:roh38@pitt.edu\" class=\"alert-link\">System Administrator</a>");
			}
			else if (action == "DELETEGROUPOK") {
				$('#message').addClass('alert-success');
				return("The group has been successfully deleted.");
			}		
			else if (action == "DELETEGROUPFAILED") {
				$('#message').addClass('alert-danger');
				return("Error occured while deleting a group from the database. " + 
					   "Please contact <a href=\"mailto:roh38@pitt.edu\" class=\"alert-link\">System Administrator</a>");
			}
			else if (action == "MODIFYUSERRIGHTSOK") {
				$('#message').addClass('alert-success');
				return("The users' rights for the current group have been successfully modified.");
			}
			else if (action == "MODIFYUSERRIGHTSFAILED") 	{
				$('#message').addClass('alert-danger');
				return("Error occured while saving users' rights to the database. " + 
					   "Please contact <a href=\"mailto:roh38@pitt.edu\" class=\"alert-link\">System Administrator</a>");
			}
			else if (action == "ADDUSERSTOGROUPOK") {
				$('#message').addClass('alert-success');
				return("The users have been successfully added to the current group.");
			}
			else if (action == "ADDUSERSTOGROUPFAILED") {
				$('#message').addClass('alert-danger');
				return("Error occured while adding users to the current group. " + 
					   "Please contact <a href=\"mailto:roh38@pitt.edu\" class=\"alert-link\">System Administrator</a>");
			}
			else if (action == "DELETEUSERSFROMGROUPOK") {
				$('#message').addClass('alert-success');
				return("The users have been successfully deleted from the current group.");
			}
			else if (action == "DELETEUSERSFROMGROUPFAILED") {
				$('#message').addClass('alert-danger');
				return("Error occured while deleteing users from the current group. " + 
					   "Please contact <a href=\"mailto:roh38@pitt.edu\" class=\"alert-link\">System Administrator</a>");
			}
			else if (action == "GETGROUPUSERLISTFAILED") {
				$('#message').addClass('alert-danger');
				return("Error occured while retrieving users of the current group. " + 
					   "Please contact <a href=\"mailto:roh38@pitt.edu\" class=\"alert-link\">System Administrator</a>");
			}
			else if (action == "GETADDUSERLISTFAILED") {
				$('#message').addClass('alert-danger');
				return("Error occured while retrieving users for adding to the current group. " + 
					   "Please contact <a href=\"mailto:roh38@pitt.edu\" class=\"alert-link\">System Administrator</a>");
			}		
			else if (action == "CREATEUSEROK") {
				$('#message').addClass('alert-success');
				return("The user has been successfully added to the database.");
			}
			else if (action == "CREATEUSERFAILED") {
				$('#message').addClass('alert-danger');
				return("Error occured while adding a user to the database. " + 
					   "Please contact <a href=\"mailto:roh38@pitt.edu\" class=\"alert-link\">System Administrator</a>. You do not have access to this functionality");
			}
			else if (action == "MODIFYUSEROK") {
				$('#message').addClass('alert-success');
				return("The user has been successfully modified in the database.");
			}
			else if (action == "MODIFYUSERFAILED") {
				$('#message').addClass('alert-danger');
				return("Error occured while modifying a user in the database. " + 
					   "Please contact <a href=\"mailto:roh38@pitt.edu\" class=\"alert-link\">System Administrator</a>. You do not have access to this functionality");
			}
			else if (action == "DELETEUSEROK") {
				$('#message').addClass('alert-success');
				return("The user has been successfully deleted from the database.");
			}
			else if (action == "DELETEUSERFAILED") {
				$('#message').addClass('alert-danger');
				return("Error occured while deleting a user from the database. " + 
					   "Please contact <a href=\"mailto:roh38@pitt.edu\" class=\"alert-link\">System Administrator</a>. You do not have access to this functionality");
			}
			else if (action == "GETMODIFYUSERLISTFAILED") {
				$('#message').addClass('alert-danger');
				return("Error occured while retrieving users to modify from the database. " + 
					   "Please contact <a href=\"mailto:roh38@pitt.edu\" class=\"alert-link\">System Administrator</a>. You do not have access to this functionality");
			}
			else if (action == "GETDELETEUSERLISTFAILED") {
				$('#message').addClass('alert-danger');
				return("Error occured while retrieving users to delete from the database. " +
					   "Please contact <a href=\"mailto:roh38@pitt.edu\" class=\"alert-link\">System Administrator</a>. You do not have access to this functionality");
			}		
		}
	}
</script>

<div id="message" class="alert" role="alert">
<script type="text/javascript">document.write(handleRequest())</script>
</div>

<br/>
<a href="home.jsp" class="btn btn-default">Return to Home</a>
<%@ include file = "include/htmlbottom.jsp" %>