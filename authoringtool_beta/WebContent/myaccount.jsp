<%@ page language="java" %>
<%@ include file = "include/htmltop.jsp" %>
   
   <div class="panel-group" id="accordion">
	  <div class="panel panel-default">
	    <div class="panel-heading">
	      <h4 class="panel-title">
	        <a data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
	          My Account
	        </a>
	      </h4>
	    </div>
	    <div id="collapseOne" class="panel-collapse collapse in">
	      <div class="panel-body">
<%
			Vector groupList = (Vector)session.getAttribute("groupList");
			if (groupList == null)
				return;
			if(groupList.size() > 1) {
%>
				<b>Switch Group :</b>
				<br/>
				| 
<%
				ListIterator i = groupList.listIterator();
				while(i.hasNext()) {
					GroupBean gBean = (GroupBean) i.next();
%>
				<a href="SecurityServlet?action=SWITCHGROUP&index=<%=i.previousIndex()%>">
<%
					if(gBean.getId() == userBean.getGroupBean().getId()) {
%>
				<b><%=gBean.getName()%></b>
<%
					} else {
%>
				<%=gBean.getName()%>
<%
					}
%>
				</a> |                 
<%
				}
			}
%>
	      	<ul>
		        <li><a href="passwordChange.jsp">Modify Personal Data</a></li> 
		        <li><a href="SecurityServlet?action=LOGOUT">Logout</a></li>
		    </ul> 
	      </div>
	    </div>
	  </div>
	  <div class="panel panel-default">
	    <div class="panel-heading">
	      <h4 class="panel-title">
	        <a data-toggle="collapse" data-parent="#accordion" href="#collapseTwo">
	          My Authoring
	        </a>
	      </h4>
	    </div>
	    <div id="collapseTwo" class="panel-collapse collapse">
	      <div class="panel-body">
	      	<ul>
				<li><a href="myQuizzes.jsp?type=myquizzes">My Topics</a></li>	
				<li><a href="myQuestions.jsp">My Questions</a></li>					
				<li><a href="mine.jsp">My Examples</a></li>					
			</ul>
	      </div>
	    </div>
	  </div>
	</div>
	
	
<%@ include file = "include/htmlbottom.jsp" %>