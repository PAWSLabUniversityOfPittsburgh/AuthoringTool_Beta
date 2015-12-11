<%@ page language="java" %>
<%@ include file = "include/htmltop.jsp" %>

<% 				
	if (!userBean.isAdmin()) {
		response.sendRedirect("authoring.jsp");
		return;
	}
%>
	
		<div class="panel panel-default">
		    <div class="panel-heading">
		      <h4 class="panel-title">
		        <a data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
		          User Management
		        </a>
		      </h4>
		    </div>
		    <div id="collapseOne" class="panel-collapse collapse in">
		      <div class="panel-body">
		      	<ul>
					<!-- <li><a href="userinfo.jsp?action=CREATEUSER">Create New User</a></li> -->
					<li><a href="create_user_temp.jsp">Create New User</a></li>
					<li><a href="modify_user_temp.jsp">Modify Existing User</a></li>
				</ul> 
		      </div>
		    </div>
		  </div>
    	
<%@ include file = "include/htmlbottom.jsp" %>