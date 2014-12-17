<%@ page language="java" %>
<%@ include file = "include/htmltop.jsp" %>
<%@ page import="java.sql.*" %>
<%@ include file = "include/connectDB.jsp" %>


<script src="<%=request.getContextPath()%>/js/jquery1.4.2.js"></script>

<script type="text/javascript">
	$(document).ready(function(){
		$("img").click(function () {
			var fn = $(this).attr('fn');
			if (fn == 'select')
			{
				var qname = $(this).Attr("qname");
				$("#myForm").attr("action", "ModifyQuestion.jsp?qname="+qname);
				$("#myForm").submit();
			}
		});
	});

	function submitFunction(obj,i) {
		if (i==1) obj.action = "jquiz_modify_retrieve.jsp?msg=0";
		if (i==2) {
			var sel = document.getElementById('question');
			var  quizval= sel.options[sel.selectedIndex].value;
			var title2 = document.myForm.title2.value;
			var quizcode = document.myForm.quizcode.value;
			var minvar = document.myForm.minvar.value;	
			var maxvar = document.myForm.maxvar.value;	
				
			if (quizval== "-1") {
				alertMessage("Topic is missing!");
			}
			if (title2 == "") {
				alertMessage("Title is missing!");
			} else if (quizcode == "") {
				alertMessage("Code is missing!");
			} else if (minvar == "") {
				alertMessage("Minimum Variable is missing!");
			} else if (isNaN(minvar)) {
				alertMessage("Minimum Variable should be number!");			
			} else if (maxvar == "") {
				alertMessage("Maximum Variable is missing!");
			} else if (isNaN(maxvar)) {
				alertMessage("Maximum Variable should be number!");
			} else if (!document.myForm.privacy2[0].checked && !document.myForm.privacy2[1].checked) {
				alertMessage("Please select Privacy!");
			} else {
				obj.action="jquiz_modify_save.jsp";
			}    
		}
		obj.submit();
	}
	
	function alertMessage (text) {
		$("#alertMessage").hide().html('<div class="alert alert-danger alert-dismissible" role="alert">'+
				'<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>'+
				text+'</div>').fadeIn('slow');
		$("html, body").animate({ scrollTop: 0 }, "slow");
	}

	function changeTopic() {
		var sel = document.getElementById('topic');
		var  topic= sel.options[sel.selectedIndex].value;
		if (topic == -1)
			document.location = "jquestion_modify.jsp";
		else
			document.location = "jquestion_modify.jsp?QuestionID="+topic;
	}

	function changeQuestion() {
		var sel = document.getElementById('topic');
		var  topic= sel.options[sel.selectedIndex].value;
		if (topic == -1)
			document.location = "jquestion_modify.jsp";
		var sel = document.getElementById('qid');
		var  qid= sel.options[sel.selectedIndex].value;
		if (qid == -1)
			document.location = "jquestion_modify.jsp?QuestionID="+topic;
		else
			document.location = "jquestion_modify.jsp?QuestionID="+topic+"&qid="+qid;
	}
</script>

<%
	ResultSet results = null;
	Statement statement  = null;
	Statement stmts = null;
	ResultSetMetaData rsmds = null;   	
	String uid="";
	ResultSet rs = null;
	try {
		stmts = conn.createStatement();
		rs = stmts.executeQuery("SELECT id FROM ent_user where name = '"+userBeanName+"' ");
		while (rs.next()) {
			uid=rs.getString(1);  	
		}
	} catch (SQLException e) {
		System.out.println("Error occurred " + e);
	} 
	
	String questionID = request.getParameter("QuestionID");
	String qid = request.getParameter("qid");
	String disabled = "";
	if (questionID == null)
		disabled = "disabled";
%>

<h3>Please select the topic and question that you'd like to modify:</h3>
<hr>
<form class="form-horizontal" role="form" name="myForm" method="post" action = "ModifyQuestion.jsp">

<%
	try{
	 
	    statement = conn.createStatement();
		ResultSet rs1 = null;  
		rs1 = statement.executeQuery("SELECT q.QuestionID,q.AuthorID,q.Privacy,q.Title,q.Description FROM ent_jquestion q, ent_user u where (q.Privacy = '1' or u.name='"+userBeanName+"') and q.AuthorID=u.id order by q.Title ");			
		String topicSelected = "";
%>
	<div class="form-group">
    	<label for="topic" class="col-sm-3 control-label">Topic:</label>
	    <div class="col-sm-9">
	    	<select id="topic" name="topic" onchange="changeTopic();" class="form-control">
	    		<option value = '-1' selected>Please select the topic</option>
<%
				while(rs1.next())	 {
					if (rs1.getString(1).equals(questionID))
						 topicSelected = "selected";
					else
						 topicSelected = "";
				
					if(rs1.getString(3).equals("0")) {
%>
				 		<option class = 'private' name="QuestionID" value="<%=rs1.getString(1)%>" title = 'This topic is private' <%=topicSelected %>><%=rs1.getString(4)%></option>
<%						  		
				 	} else {
%>
				 		<option name="QuestionID" value="<%=rs1.getString(1)%>" <%=topicSelected %>><%=rs1.getString(4)%></option>
<%
				 	}  		
				}			
%>	
	    	</select>
	    </div>
	</div>
	<div class="form-group">
    	<label for="qid" class="col-sm-3 control-label">Question:</label>
	    <div class="col-sm-9">
	    	<select id="qid" name="qid" onchange="changeQuestion();" <%=disabled %> class="form-control">
	    		<option value = '-1' selected>Please select the question</option>
<%		  
		 String questionSelected = "";
		 String query = "SELECT q.QuizID,q.title,q.Description,q.AuthorID,q.Privacy FROM ent_jquiz q, rel_question_quiz qq where qq.QuizID=q.QuizID and qq.QuestionID = "+questionID+" and (q.privacy = 1 or q.authorid = "+uid+") order by q.title";
		 rs1 = statement.executeQuery(query);
				while(rs1.next()) {
					if (rs1.getString(1).equals(qid))
						questionSelected = "selected";
					else
						questionSelected = "";
					if(rs1.getString(3).equals("0")){
%>
				<option class = 'private' name="quizID" value="<%=rs1.getString(1)%>" title = 'This question is private' <%=questionSelected %>><%=rs1.getString(4)%></option>
<%						  		
					}else{
%>
				<option name="quizID" value="<%=rs1.getString(1)%>" <%=questionSelected %>><%=rs1.getString(2)%></option>
<%
					}  		
				}
%>
			</select>
	    </div>
	</div>
<%
		if (questionID != null && qid != null) {
%>

	<hr>
	<div class="form-group">
    	<label for="question" class="col-sm-3 control-label">Topic:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<select name="question" id = "question" class="form-control">
<%
			ResultSet rs2 = null;  
			rs2 = statement.executeQuery("SELECT q.QuestionID,q.Title,q.Privacy FROM ent_jquestion q, ent_user u where (q.Privacy = '1' or u.name='"+userBeanName+"') and q.AuthorID=u.id ");
			while(rs2.next()) {			  			  				  
			 	if(rs2.getString(3).equals("1")){
			 		if(rs2.getString(1).equals(request.getParameter("QuestionID"))){ 		
						out.write("<option value='"+rs2.getString(1)+"' selected>"+rs2.getString(2)+"</option>");			  	        			  		
			 		}else{
						out.write("<option value='"+rs2.getString(1)+"'>"+rs2.getString(2)+"</option>");			  	        			  		
			 		}
			 	}else{			  		
			 		if(rs2.getString(1).equals(request.getParameter("QuestionID"))){ 		
						out.write("<option value='"+rs2.getString(1)+"'  selected>"+rs2.getString(2)+"</option>");			  	        			  	      
			 	    }else{
						out.write("<option value='"+rs2.getString(1)+"' >"+rs2.getString(2)+"</option>");			  	        			  	      
			 	    }
			 	}
			}
%>	
	    	</select>
	    </div>
	</div>
<%
			 ResultSet rs4 = null;  
			 rs4 = statement.executeQuery("SELECT distinct * FROM ent_jquiz q where q.QuizID='"+qid+"' and (q.authorid = "+uid+" or q.privacy = 1) ");
			 while(rs4.next())	 {
%>
	<div class="form-group">
	    <label for="title2" class="col-sm-3 control-label">Title:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<input type="text" name="title2" size="45" maxlength="45" value="<%=rs4.getString(4)%>" class="form-control" />
	    </div>
	</div>
	<div class="form-group">
	    <label for="rdfID" class="col-sm-3 control-label">rdfID:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<input type="text" name="rdfID" size="45" maxlength="45" value="<%=rs4.getString(11)%>" class="form-control" />
			<input type="hidden" name="rdfID" value="<%=rs4.getString(11)%>">
	    </div>
	</div>
	<div class="form-group">
	    <label for="description2" class="col-sm-3 control-label">Description:</label>
	    <div class="col-sm-9">
			<textarea rows="3" name="description2" cols="80" class="form-control"><%=rs4.getString(5)%></textarea>
	    </div>
	</div>
	<div class="form-group">
    	<label for="questiontype" class="col-sm-3 control-label">Assessment Type:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<select name="questiontype" class="form-control">
<%
			String Qtype[] = new String[2];			
			Qtype[0]="final value";
			Qtype[1]="output";					
			for (int a=0;a<Qtype.length;a++){	
				if (rs4.getInt("QuesType") == a){
%>
				<option value=<%=a%> selected><%=Qtype[a]%></option>
<%
				}
				else{
%>
				<option value=<%=a%>><%=Qtype[a]%></option>
<%
				}		
			}
%>	
	    	</select>
	    </div>
	</div>
<%
			InputStream is =rs4.getBinaryStream(6);
	 		BufferedReader inpStream = new BufferedReader (new InputStreamReader (is));
	 		String streamcode = inpStream.readLine();
	   		String code = "";
			while(streamcode != null) {		
			    code += streamcode + "\n";		
			    streamcode = inpStream.readLine();		
			}		
%>
	<div class="form-group">
	    <label for="quizcode" class="col-sm-3 control-label">Code:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
			<textarea cols="80" rows="8" name="quizcode" value="<%=code%>" class="form-control"><%out.print(code);%></textarea>
	    </div>
	</div>
	<div class="form-group">
	    <label for="minvar" class="col-sm-3 control-label">Minimum:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<input type="text" name="minvar" size="4" maxlength="4" value="<%=rs4.getString(7)%>" class="form-control" />
	    </div>
	</div>
	<div class="form-group">
	    <label for="maxvar" class="col-sm-3 control-label">Maximum:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<input type="text" name="maxvar" size="4" maxlength="4" value="<%=rs4.getString(8)%>" class="form-control" />
	    </div>
	</div>
		<div class="form-group">
    	<label for="anstype" class="col-sm-3 control-label">Answer Type:</label>
	    <div class="col-sm-9">
	    	<select name="anstype" class="form-control">
<%
			String type[] = new String[5];			
			type[0]="";
			type[1]="int";
			type[2]="float";
			type[3]="String";
			type[4]="double";
			for (int a=0;a<type.length;a++){						
				if (rs4.getInt("AnsType") == a) {
%>
				<option value=<%=a%> selected><%=type[a]%></option>
<%
				} else {
%>
				<option value=<%=a%>><%=type[a]%></option>
<%
				}
			}
%>	
	    	</select>
	    </div>
	</div>
	<div class="form-group">
    	<label for="privacy2" class="col-sm-3 control-label">Privacy:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
<% 
			if(rs4.getString(10).equals("0")) {
%>
			<label class="radio-inline">
				<input type="radio" name="privacy2" value="0" checked>Private
			</label>
			<label class="radio-inline">
				<input type="radio" name="privacy2" value="1">Public
			</label>
<%
			} else {
%>
			<label class="radio-inline">
				<input type="radio" name="privacy2" value="0">Private
			</label>
			<label class="radio-inline">
				<input type="radio" name="privacy2" value="1" checked>Public
			</label>
<%			
			}
%>
	    </div>
	</div>
	<div class="form-group">
	    <div class="col-sm-offset-3 col-sm-9">
	    	<input type="button" value="Save" onclick="submitFunction(this.form,2);" class="btn btn-default" />
			<input type="hidden" name = "quiz" value="<%=request.getParameter("qid")%>" />
	    </div>
	</div>
<%
		}
%>
	<!--  	
	<td>
		<select multiple name="fromBox" id="fromBox">
		<%
		ResultSet rs5 = null;  
		//rs5 = statement.executeQuery("SELECT distinct c.ClassID,c.ClassName FROM rel_quiz_class q, ent_class c where q.ClassID=c.ClassID  ");		
		rs5 = statement.executeQuery("SELECT distinct c.ClassName, c.ClassID FROM rel_quiz_class q, ent_class c where q.ClassID=c.ClassID and c.ClassName not in (SELECT c.ClassName FROM rel_quiz_class q, ent_class c where q.ClassID=c.ClassID and q.QuizID='"+request.getParameter("qid")+"') ");
		while(rs5.next())	
		{		
		%>
			<option value ="<%=rs5.getInt("ClassID")%>"><%=rs5.getString("ClassName")%></option>
		<%
		}
		%>	
		</select>
		
		<select name="toBox" id="toBox">
		<%
		ResultSet rs6 = null;  		
		rs6 = statement.executeQuery("SELECT distinct * FROM rel_quiz_class q,ent_class c where q.ClassID=c.ClassID and q.QuizID='"+request.getParameter("qid")+"' ");		  
		while(rs6.next())	
		{		
		%>
			<option value ="<%=rs6.getInt("ClassID")%>"><%=rs6.getString("ClassName")%></option>
		<%
		}
		
		%>
		</select>

		<script type="text/javascript">
		createMovableOptions("fromBox","toBox",400,200,'all classes','imported classes');
		</script>

	</td>
-->
<%
	}
}
catch(Exception e) {
	e.printStackTrace();
	response.sendRedirect("servletResponse.jsp");
} finally {
	try {
		if (stmts != null)
		stmts.close();
	}	catch (SQLException e) {}
}
%>

</form>

<%@ include file = "include/htmlbottom.jsp" %>