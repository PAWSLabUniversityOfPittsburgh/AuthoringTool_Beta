<%@ page language="java" %>
<%@ include file = "include/htmltop.jsp" %>
<%@ include file = "include/connectDB.jsp" %>

<script language="javascript">
function send_iswriting(e){
     var key = -1 ;
     var shift ;

     key = e.keyCode ;
     shift = e.shiftKey ;

     if ( !shift && ( key == 13 ) )
     {
          document.form.reset() ;
     }
}
</script>
<script src="<%=request.getContextPath()%>/js/jquery1.4.2.js"></script>

<script type="text/javascript">
$(document).ready(function(){
	$("input").click(function () {
		var fn = $(this).attr('fn');
		if (fn == 'createQuiz')
		{
			var title1 = document.fr1.title1.value;	
			var domain = document.fr1.domain.value;
			if(domain == "-1") {
				alertMessage("Please select the domain");
				return false;
			}
			else if(title1 == "") {
				alertMessage("Title cannot be empty!");
				return false;
			}	
			else if (!document.fr1.privacy1[0].checked && !document.fr1.privacy1[1].checked) {
				alertMessage("Please select the privacy.");
				return false;
			}	
			else {   		
				if (title1!="" && (document.fr1.privacy1[0].checked || document.fr1.privacy1[1].checked) && i==1) {
					$("#fr1").submit();
					return true;
				}
		    }
		}
	});	
});

function alertMessage (text) {
	$("#alertMessage").hide().html('<div class="alert alert-danger alert-dismissible" role="alert">'+
			'<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>'+
			text+'</div>').fadeIn('slow');
	$("html, body").animate({ scrollTop: 0 }, "slow");
}
</script>

<script type="text/javascript">
<!-- 
function function3(obj,i){ 	
   if (i==1) 
   {window.open('classcombo.jsp','_blank');}
   }
//-->
</script>

 <h3>Create Topic:</h3>
 <hr>
<form class="form-horizontal" role="form" name="fr1" id  ="fr1"  method="post" action = "javaq_create_save1.jsp">
	<div id="alertMessage"></div>
	
	
	<div class="form-group">
		<label class="col-sm-3 control-label">Domain:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<select class="form-control" name="domain" id="domain">
	    		<option value = "-1" selected>Please select the domain</option>
<%
					Statement statement = null;
					try {
						statement = conn.createStatement();
						result1 = statement.executeQuery("SELECT domain, name FROM ent_domain");
						
						while(result1.next()) {
								out.write("<option value = '"+result1.getString(1)+"' >"+result1.getString(2)+"</option>");
						} 
					} catch (Exception e) {
						if (conn != null)
							conn.close();
						if (statement != null)
							statement.close();	
						System.out.println("Error occurred " + e);
						if (!response.isCommitted()) {
							response.sendRedirect("servletResponse.jsp");
							return;
						}
					} finally {
						if (conn != null)
							conn.close();
						if (statement != null)
							statement.close();						
					}
%>
	    	</select>
	    </div>
	</div>
	
	
	<div class="form-group">
    	<label for="title1" class="col-sm-3 control-label">Title:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<input type="text" class="form-control" name="title1" size="45" maxlength="45">
	    </div>
	</div>
	<div class="form-group">
	    <label for="description1" class="col-sm-3 control-label">Description:</label>
	    <div class="col-sm-9">
			<textarea class="form-control" rows="3" name="description1"  cols="70"></textarea>
	    </div>
	</div>
	<div class="form-group">
    	<label for="privacy1" class="col-sm-3 control-label">Privacy:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<label class="radio-inline">
				<input type="radio" name="privacy1" value="private">Private
			</label>
			<label class="radio-inline">
				<input type="radio" name="privacy1" value="public">Public
			</label>
	    </div>
	</div>
	<div class="form-group">
	    <div class="col-sm-offset-3 col-sm-9">
	      <input type="submit" value="Create" fn = 'createQuiz' class="btn btn-default">
	      <input type="reset" value="Clear" OnClick="document.form.message.focus()" class="btn btn-default">
	      <a href="authoring.jsp" class="btn btn-default pull-right">Cancel</a>
	    </div>
	</div>
</form>

<%@ include file = "include/htmlbottom.jsp" %>