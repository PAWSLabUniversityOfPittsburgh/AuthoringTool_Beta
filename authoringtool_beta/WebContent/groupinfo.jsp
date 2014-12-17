<%@ page language="java" %>
<%@ include file = "include/htmltop.jsp" %>

<script language="JavaScript" type="text/javascript">
	function validateForm() {
		var reNotName = new RegExp(/\W+/);
	    if(reNotName.test(document.formGroup.nameInput.value)) {
	    	alertMessage("Group Name can have only alphanumerical symbols and underscores");
	        return false;
	    }
		return true;
	}
	
	function validateFormDelete() {
		if (validateForm()) {
			return confirm('Are you sure you want to delete this group?');
		}
	    return false;
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
	int index = 0;
	Vector userList = null;
 	if (action != null) {		
		if ((action.equalsIgnoreCase("MODIFYGROUP") || action.equalsIgnoreCase("DELETEGROUP")) && userBean.getGroupBean() != null) {
			userList = (Vector) session.getAttribute("userList");
			if (userList == null) {
				if (action.equalsIgnoreCase("MODIFYGROUP")) {
%>
				<jsp:forward page="SecurityServlet?action=GETMODIFYGROUPUSERLIST&sender=groupinfo" />
<%			
				} else if (action.equalsIgnoreCase("DELETEGROUP")) {
%>
				<jsp:forward page="SecurityServlet?action=GETDELETEGROUPUSERLIST&sender=groupinfo" />
<%					
				}
			}
		}
		if (action.equalsIgnoreCase("CREATEGROUP")) {
			welcome = "Create New Group:";
		} else if (action.equalsIgnoreCase("MODIFYGROUP")) {
			welcome = "Modify Group <i>" + userBean.getGroupBean().getName() + "</i> :";
		} else if (action.equalsIgnoreCase("DELETEGROUP")) {
			welcome = "Delete Group <i>" + userBean.getGroupBean().getName() + "</i> :";
		} 	
		session.removeAttribute("userList");
%>
	<h3><%= welcome %></h3>
	<hr>
	
	<form class="form-horizontal" role="form" name="formGroup" id="formGroup" method="post" action="SecurityServlet?action=<%=action%>" onSubmit="return <%=(action.equalsIgnoreCase("DELETEGROUP")) ? "validateFormDelete();" : "validateForm();" %>">
		<input type="hidden" name="groupId" value="<%= (action.equalsIgnoreCase("MODIFYGROUP") || action.equalsIgnoreCase("DELETEGROUP")) ? userBean.getGroupBean().getId() : -1 %>" />
		<div id="alertMessage"></div>
			<div class="form-group">
			    <label for="name" class="col-sm-3 control-label">Group Name:</label>
			    <div class="col-sm-9">
					<input type="text" <%=(action.equalsIgnoreCase("DELETEGROUP")) ? "disabled" :""%> name="name" value="
					<%=(action.equalsIgnoreCase("MODIFYGROUP") || action.equalsIgnoreCase("DELETEGROUP")) ? userBean.getGroupBean().getName() : ""%>
					" class="form-control" id="nameInput"/>
			    </div>
			</div>
			<div class="form-group">
			    <label for="num" class="col-sm-3 control-label">Number of Users:</label>
			    <div class="col-sm-9" id="num">
					<b><i><%=(action.equalsIgnoreCase("MODIFYGROUP") || action.equalsIgnoreCase("DELETEGROUP")) ? userList.size() : 0%></i></b>
			    </div>
			</div>
			<div class="form-group">
		    	<label for="ownerId" class="col-sm-3 control-label">Group Owner:</label>
			    <div class="col-sm-9">
			    	<select <%=(action.equalsIgnoreCase("DELETEGROUP")) ? "disabled" :""%> name="ownerId" <%=(!userBean.isAdmin()) ? "readonly" : ""%> size="1" class="form-control">
<%
						if (userList != null) { 						
							Iterator i = userList.iterator();
							System.out.println(userList.size());
							while (i.hasNext()) {
								UserBean uBean = (UserBean) i.next();
								System.out.println("user" + uBean.getLogin() + ((uBean.isAdmin()) ? " admin " : ((uBean.isSuperUser() ? " superuser " : ""))));
								if (uBean.isAdmin() || uBean.isSuperUser()) {
%>
						<option <%=(uBean.getId() == userBean.getGroupBean().getOwnerId()) ? "selected" : ""%> value="<%=uBean.getId()%>"><%=uBean.getLogin()%></option>
<%
								}
							}
						} else {
%>						
						<option selected value="<%=userBean.getId()%>"><%=userBean.getLogin()%></option>
<%
						}
%>
			    	</select>
			    </div>
			</div>
			<div class="form-group">
			    <div class="col-sm-offset-3 col-sm-9">
			    	<input name="submit" type="submit" value="Submit" class="btn btn-default" />
			    </div>
			</div>
		</form>
<%	
	} else {
		response.sendRedirect("home.jsp");
	}
%>

<%@ include file = "include/htmlbottom.jsp" %>