<%@ page language="java" %>
<%@ include file = "include/htmltop.jsp" %>

<% 				
	if (!userBean.isAdmin() && !userBean.getGroupBean().getName().equals("teachers")) {
		response.sendRedirect("authoring.jsp");
		return;
	}
%>

<script language="JavaScript" type="text/javascript">
	function validateForm() {
		var reNotName = new RegExp(/\W+/);
		if (document.formGroup.nameInput.value.length < 1) {
			alertMessage("Group Name can not be empty");
	        return false;
		}
	    if(reNotName.test(document.formGroup.nameInput.value)) {
	    	alertMessage("Group Name can have only alphanumerical symbols and underscores");
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

<h3>Create New Group</h3>
	<hr>
	
	<form class="form-horizontal" role="form" name="formGroup" id="formGroup" method="post" action="SecurityServlet?action=CREATEGROUP" onSubmit="return validateForm();">
		<div id="alertMessage"></div>
		<div class="form-group">
		    <label for="name" class="col-sm-3 control-label">Group Name:</label>
		    <div class="col-sm-9">
				<input type="text" name="name" class="form-control" id="nameInput"/>
		    </div>
		</div>
		<div class="form-group">
		    <div class="col-sm-offset-3 col-sm-9">
		    	<input name="submit" type="submit" value="Submit" class="btn btn-default" />
		    </div>
		</div>
	</form>

<%@ include file = "include/htmlbottom.jsp" %>