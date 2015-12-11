<%@ page language="java" %>
<%@ include file = "include/htmltop.jsp" %>

	<div class="panel-group" id="accordion">
<%
	String toggle = " in";
    if(userBean.isAdmin() || userBean.isSuperUser()) {
    	toggle = "";
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
					<li><a href="new_user.jsp">Create New User</a></li>
					<li><a href="SecurityServlet?action=GETMODIFYUSERLIST">Modify Existing User</a></li>
					<li><a href="SecurityServlet?action=GETDELETEUSERLIST">Delete User</a></li>
				</ul> 
		      </div>
		    </div>
		  </div>
<%  
	}
	if (userBean.isAdmin() || userBean.isSuperUser()) {		
%>
		<div class="panel panel-default">
		    <div class="panel-heading">
		      <h4 class="panel-title">
		        <a data-toggle="collapse" data-parent="#accordion" href="#collapseTwo">
		          Group Management
		        </a>
		      </h4>
		    </div>
		    <div id="collapseTwo" class="panel-collapse collapse<%= toggle %>">
		      <div class="panel-body">
		      	<ul>
					<li><a href="new_group.jsp">Create New Group</a></li>
<%
			if (userBean.isAdmin() || (userBean.getGroupBean() != null && userBean.isGroupOwner(userBean.getGroupBean()))) {
%>			
					<li><a href="groupinfo.jsp?action=MODIFYGROUP">Modify Info of Group <b><%=userBean.getGroupBean().getName()%></b></a></li>
					<li><a href="groupusers.jsp">Modify Users of Group <b><%=userBean.getGroupBean().getName()%></b></a></li>
					<li><a href="groupinfo.jsp?action=DELETEGROUP">Delete Group <b><%=userBean.getGroupBean().getName()%></b></a></li>
<%
			} else if (userBean.getGroupBean() != null) {
%>
					<li>You cannot modify group <b><%=userBean.getGroupBean().getName()%></b>. Create a new group using the link above or switch to a group owned by you <a href="myaccount.jsp">here</a></li>
<%				
			}
%>
				</ul>
		      </div>
		    </div>
		  </div>
		</div>
<%
	}
%>	
    	
<%@ include file = "include/htmlbottom.jsp" %>