<%@ page language="java" %>
<%@ include file = "../include/htmltop.jsp" %>
<%@ include file = "../include/connectDB.jsp" %>
<%@ page import="java.sql.*" %>

<script src="<%=request.getContextPath()%>/js/jquery1.4.2.js"></script>

<script type="text/javascript">
$(document).ready(function(){
	$("img").click(function () {
		var fn = $(this).attr('fn');
/* 		if (fn == 'clone')
		{
			var disID = $(this).attr('disID');
		    $.post("CloneExampleServlet?dis="+disID+"&uid="+uid+"&sc="+sc,function(data) {
		    	var newdis = data.dis;
				alert("Example cloned successfully!");window.location = "displayA1.jsp?sc="+sc+"&uid="+uid+"&dis="+newdis; }, "json");	  
		}
		else if (fn == 'delete')
		{
			var disID = $(this).attr('disID');
			if (confirm('Are you sure you want to delete this example?')==true)
			{
				$.post("DeleteExampleServlet?disID="+disID,function() {
					alert("Example deleted successfully!");
					window.location = "mine.jsp";
				});	 
			}			
		}
		else  */
		if (fn == 'addline') {
			var dis = $(this).attr('disID');
			var lno = $(this).attr('lno');
			var max = $(this).attr('max');
			$("body").addClass("loading");
			$('.modal').fadeIn(1);
			$.post("AddExampleLineServlet?dis="+dis+"&lno="+lno+"&max="+max,function() {
				$("body").removeClass("loading");
				$('.modal').fadeOut(1);
				alert("Line added successfully!");
				window.location.reload(true); 
			});	 
		} else if (fn == 'deleteline') {
			if (confirm('Are you sure you want to delete this line?')==true) {
				$("body").addClass("loading");
				$('.modal').fadeIn(1);
				var dis = $(this).attr('disID');
				var lno = $(this).attr('lno');
				var max = $(this).attr('max');
				$.post("DeleteExampleLineServlet?dis="+dis+"&lno="+lno+"&max="+max,function() {
					$("body").removeClass("loading");
					$('.modal').fadeOut(1);
					alert("Line deleted successfully!");
					window.location.reload(true); 
				});	 
			}
		}
	});	
	
	$("input").click(function () {
		var fn =  $(this).attr("fn");
		if (fn == 'save') {
			var title =  $("#Name").val();
			var rdfID = $("#rdfID").val();
			var scope = $('#sel').val();
			var topic = document.getElementById("topic").value;
			title = title.replace(/\s+/g, '');
			rdfID = rdfID.replace(/\s+/g, '');
			if (topic== "-1") {
				alertMessage('Please select topic for the example.');
				return false;
			}
			if (title == '')
			{
				alertMessage("Title cannot be empty!");
				return false;
			}
			if (rdfID == '')
		    {
				alertMessage("RDF ID cannot be empty!");
	    		return false;
			}
			if (scope == '-1')
			{
				alertMessage("Please select the scope!");
	    		return false;	
			}
			else
			{
				var invalid = false;
				rdfID = $("#rdfID").val();
				var curVal = $("#rdfID").attr("curVal");
				for (var index in rdfs)
				{
					if (rdfs[index] ==rdfID)
					{		
					  if (rdfID != curVal)
						  invalid = true;
					}
				}
				if (invalid)
				{
					alertMessage("RDF ID already exists. Please enter another value.");
					return false;
				}
				else
    			{   				 
    				var min = $("#min").val();
					var max = $("#max").val();
					var code = "";
					for (var i = min; i <= max; i++)
    			    {
						code+= $("#code"+i).val();
						if (i < max)
							code += "\n";
    		     	}
					//$.post("CompileCodeServlet",{code: code},function(data) {
    				 //   	 var err = data.message;

    				  //  	 if (err != '')
    				  // 	 {
    				   // 		alert("Code cannot be compiled due to following errors:\n"+err);   
    				   // 		return false;
    				   // 	 }
    				  //  	 else
    				  //  	 { 	
    				    		$("#eform").submit();
    				    		return true;
    				     //    }
    				//    }, "json");    				    	 	   
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
	
	function changeScope() {
		var sel = document.getElementById('scope');
		var  scope= sel.options[sel.selectedIndex].value;
		if (scope == -1)
			document.location = "displayA1.jsp";
		else
			document.location = "displayA1.jsp?sc="+scope;
	}
	
	function changeExample() {
		var sel = document.getElementById('example');
		var  dis= sel.options[sel.selectedIndex].value;
		var sel2 = document.getElementById('scope');
		var  scope= sel2.options[sel2.selectedIndex].value;
		if (scope == -1)
			document.location = "displayA1.jsp";
		else
			document.location = "displayA1.jsp?sc="+scope+"&dis="+dis;
	}
	
	function cOn(td) {
		if(document.getElementById||(document.all && !(document.getElementById))){
			td.style.backgroundColor="#ffffe1";
		}
	}
	
	function cOut(td) {
		if(document.getElementById||(document.all && !(document.getElementById))){
			td.style.backgroundColor="#FFCC00";
		}
	}
	
	function changelist() {
		var sel = document.getElementById("exampleList");
		var example = sel.options[sel.selectedIndex].value;
		if (example == '-1')
			return;
		document.location = "displayA1.jsp?sc="+sc+"&uid="+uid+"&dis="+example;
	} 
		   
	function textCounter(field,cntfield,maxlimit) {
		if (field.value.length > maxlimit) {
			field.value = field.value.substring(0, maxlimit);
		} else {
			cntfield.value = maxlimit - field.value.length;
		}
	}
</script>
<%
	ResultSet results = null;
	Statement statement  = null;
	Statement stmts = null;
	ResultSetMetaData rsmds = null;   	
	String uid="";
	ResultSet rs = null;  
	String scope = request.getParameter("sc");
	String dis=request.getParameter("dis");
	String authorID = "";
	String disabled = "";
	String readonly = "";
	String command = "select rdfID from ent_dissection;";
	ArrayList<String> rdfList = new ArrayList<String>();
	try {
		stmts = conn.createStatement();
	    rs = stmts.executeQuery("SELECT id FROM ent_user where name = '"+userBeanName+"' ");
		while(rs.next()) {
			uid=rs.getString(1);  	
		}
		
		stmt = conn.createStatement();
		rs = stmt.executeQuery(command);
		while (rs.next()) {
			rdfList.add(rs.getString(1));
		}

		stmt = conn.createStatement();
        result = stmt.executeQuery("SELECT d.DissectionID,d.Name,d.Description,dp.Uid FROM ent_dissection d,rel_scope_dissection r, rel_dissection_privacy dp where r.ScopeID = '"+request.getParameter("sc")+"' and d.DissectionID=r.DissectionID and dp.DissectionID=d.DissectionID order by d.name");
     
		columns=0;
		rsmd = result.getMetaData();       
		columns = rsmd.getColumnCount();       
	} catch (Exception e) {
		if (conn != null)
			conn.close();
		
		System.out.println("Error occurred " + e);
		if (!response.isCommitted()) {
			response.sendRedirect("authoring.jsp?type=example&message=Unknown error has occurred&alert=danger");
		}
	} finally {
		if (stmts != null)
			stmts.close();
		
		if (stmt != null)
			stmt.close();
		
		if (rs != null)
			rs.close();
		
		if (result != null)
			result.close();
	}

%>

<script type="text/javascript">
	var sc = "<%=scope%>";
	var uid = "<%=uid%>";
	var rdfs = new Array();
	<%for (String rdf : rdfList){%>
	     rdfs.push("<%=rdf%>");
	<%}%>
</script>

	<h3>Please select the scope and example that you'd like to modify</h3>
	<hr>
	<form class="form-horizontal" role="form" id="1" name="1" method="post" action="">
		<div class="form-group">
	    	<label for="scope" class="col-sm-3 control-label">Scope:</label>
		    <div class="col-sm-9">
		    	<select class="form-control" onchange="changeScope();" name="scope" id="scope">
<%
				ResultSet rs1 = null;
				try{  	  
					statement = conn.createStatement();
					rs1 = statement.executeQuery(" select distinct s.scopeID,s.Name,sp.privacy from ent_scope s,rel_scope_privacy sp where sp.scopeID = s.scopeID and"+
							                      " (sp.privacy = 1 or sp.uid = "+ uid+") order by s.Name");
					 
					out.write("<option value = '-1' selected>Please select the scope</option>");
					String scopeSelected = "";
				
					while(rs1.next()) {
						if (rs1.getString(1).equals(scope)) {
							scopeSelected = "selected";
						} else {
							scopeSelected = "";
						}
				
						if (rs1.getString(3).equals("0")) {
							out.write("<option class = 'private' bgcolor='#FCF4BD' title = 'This scope is private' value = '"+rs1.getString(1)+"' "+scopeSelected+">"+rs1.getString(2)+"</option>");
						} else {
							out.write("<option value = '"+rs1.getString(1)+"' "+scopeSelected+">"+rs1.getString(2)+"</option>");	  	
						}	   		
					} 
				} catch(Exception e) {
					if (conn != null)
						conn.close();
					
					if (rs1 != null)
						rs1.close();
					
					e.printStackTrace();
					if (!response.isCommitted()) {
						response.sendRedirect("authoring.jsp?type=example&message=Unknown error has occurred&alert=danger");
					}
				} finally {
					if (stmts != null)
						stmts.close();
				}
				
				String disabledMenu = "";
				if (scope == null)
					disabledMenu = "disabled";
%>	
		    	</select>
		    </div>
		</div>
		<div class="form-group">
	    	<label for="example" class="col-sm-3 control-label">Example:</label>
		    <div class="col-sm-9">
		    	<select class="form-control" onchange="changeExample();" name="example" id="example" <%=disabledMenu %>>
<%
				try{  	  
					statement = conn.createStatement();
					//	 String query = "select distinct d.dissectionID,d.name,dp.privacy from ent_dissection d,rel_dissection_privacy dp, rel_scope_dissection sd, ent_scope s where s.scopeID = "+scope 
					//            +"  and sd.scopeID = s.scopeID and d.dissectionID = sd.dissectionID and dp.dissectionID = d.dissectionID and (dp.privacy = 1 or d.author = "+uid+")  order by d.name";
					String query = "select distinct d.dissectionID,d.name,d.description from ent_dissection d,rel_scope_dissection sd, ent_scope s, rel_dissection_privacy dp where s.scopeID = "+scope 
					            +"  and sd.scopeID = s.scopeID and d.dissectionID = sd.dissectionID and dp.dissectionid = d.dissectionid and (dp.uid = "+uid+" or dp.privacy = 1)  order by d.name";
					
					rs1 = statement.executeQuery(query);
					out.write("<option value = '-1' selected>Please select the example</option>");
					String exampleSelected = "";
					
					while(rs1.next()) {
						if (rs1.getString(1).equals(dis)) {
							exampleSelected = "selected";
						} else {
							exampleSelected = "";
						}
						//TODO should be added when query consideres privacy
						//if(rs1.getString(3).equals("0")){
						//	out.write("<option class = 'private' bgcolor='#FCF4BD' title = 'This example is private' value = '"+rs1.getString(1)+"' "+exampleSelected+">"+rs1.getString(2)+"</option>");
						//}else{
						out.write("<option value = '"+rs1.getString(1)+"' "+exampleSelected+">"+rs1.getString(2)+"</option>");
						//}	   		
					}
				} catch (Exception e) {
					if (conn != null)
						conn.close();
					
					if (rs1 != null)
						rs1.close();
					
					if (statement != null)
						statement.close();
					
					e.printStackTrace();
					if (!response.isCommitted()) {
						response.sendRedirect("authoring.jsp?type=example&message=Unknown error has occurred&alert=danger");
					}
				} finally {
					if (stmts != null)
						stmts.close();
				}
%>	
		    	</select>
		    </div>
		</div>
	</form>
<% 

	if (dis != null  && !dis.equals("-1")) {
		String Name = null;
		String Des = null;
		String rdfID= null;
		int privacy = -1;
		
		String ex;
		Connection connd = null;
		ResultSet resultd = null;
		ResultSet rs2 = null; 
		Statement stmtd = null;
		ResultSetMetaData rsmdd = null;
		result1 = null;
		stmt1 = null;
		int M = 0;
		int min = 0;
		
		try {
%>
	<form class="form" role="form" name="eform" id ="eform" method="post" action="save.jsp?sc=<%=scope %>&dis=<%=dis%>">
	<hr/>
	<div class="form-horizontal">
		<div id="alertMessage"></div>
	  		<div class="form-group">
		  		<label for="topic" class="col-sm-3 control-label">Topic:<span style="color: red;"> *</span></label>
				<div class="col-sm-9">
<%    
			rs = statement.executeQuery("Select distinct e.Name,e.Description,e.rdfID,dp.privacy,dp.Uid from ent_dissection e, rel_dissection_privacy dp where e.DissectionID = '"+dis+"' and dp.DissectionID = e.DissectionID ");
			while (rs.next()) {
				Name = rs.getString(1);
				Des = (rs.getString(2)==null?"":rs.getString(2));
				rdfID = rs.getString(3);
				privacy  = rs.getInt(4);
				authorID = rs.getString(5);
			}
			int topicid = -1;
			rs = statement.executeQuery("select topicid from webex21.rel_topic_dissection where dissectionid ='"+dis+"'");
			while (rs.next()) {
				topicid = rs.getInt(1);
			}
		    
		   // if (privacy == 1)
		   // {
		    //	if (uid.equals(authorID))
		    //	{    		
		    		//out.write("<td><img src='images/trash.jpg'  title = 'Delete example' fn = 'delete' disID='"+dis+"'></td>");
		    //	}
		    //	else
		    //	{
		    		//disabled = "disabled";
		    		//readonly = "readonly";
		    		//out.write("<td><img src='images/clone.png' title = 'Clone example' fn = 'clone' disID='"+dis+"'></td>");
		    //	}
		   // }
		  //  else
		  //  {
				//out.write("<td><img src='images/trash.jpg' title = 'Delete example' fn = 'delete' disID='"+dis+"'></td>");
		  //  }    	
%>
					<select name="topic" id = "topic" class="form-control">
<% 
			rs2 = statement.executeQuery("SELECT q.QuestionID,q.Title,q.Privacy FROM ent_jquestion q, ent_user u where (q.Privacy = '1' or u.name='"+userBeanName+"') and q.AuthorID=u.id ");
			out.write("<option value='-1' selected>Please select the topic</option>");			  	        			  		
			
			while(rs2.next()) {			  			  				  
				if (rs2.getInt(1)==topicid) { 		
					out.write("<option value='"+rs2.getString(1)+"' selected>"+rs2.getString(2)+"</option>");			  	        			  		
				}else{
					out.write("<option value='"+rs2.getString(1)+"'>"+rs2.getString(2)+"</option>");			  	        			  		
				}
			}				
%>
					</select>
				</div>
			</div>
			<div class="form-group">
				<label for="Name" class="col-sm-3 control-label">Title:</label>
				<div class="col-sm-9">
					<textarea class="form-control" rows="2" cols="25"  id="Name" name="Name" value="<%=Name%>" <%=readonly%>><%=Name%></textarea>
				</div>
			</div>
			<div class="form-group">
				<label for="rdfID" class="col-sm-3 control-label">RDF ID:</label>
				<div class="col-sm-9">
					<textarea class="form-control" rows="2" cols="25" curVal="<%=rdfID%>"  name="rdfID" id="rdfID" value="<%=rdfID%>" <%=readonly%>><%=rdfID%></textarea>
				</div>
			</div>
			<div class="form-group">
				<label for="Des" class="col-sm-3 control-label">Description:</label>
				<div class="col-sm-9">
					<textarea class="form-control" rows="2" cols="25" name="Des" value="<%=Des%>" <%=readonly%>><%=Des%></textarea>
				</div>
			</div>
			<div class="form-group">
				<label for="privacy" class="col-sm-3 control-label">Privacy:</label>
				<div class="col-sm-9">
<%
	   // command = "select * from ent_scope s, rel_scope_privacy sp where sp.ScopeID = s.ScopeID and (sp.privacy = 1 or sp.Uid = "+uid+")";
	   // ResultSet scrs = statement.executeQuery(command);
		//if (readonly.equals("readonly"))
		//	out.write("<option value = '-1' selected disabled = 'disabled' disabled>Please select the scope</option>");	
		//else
		//	out.write("<option value = '-1' selected>Please select the scope</option>");	
	
		//while(scrs.next()){	
	//		if (scrs.getString(1).equals(scope))
	//			 out.write("<option value = '"+scrs.getString(1)+"' selected>"+scrs.getString(3)+"</option>");	
	//		else 
		//		if (readonly.equals("readonly"))
	//				out.write("<option value = '"+scrs.getString(1)+"' disabled = 'disabled' disabled>"+scrs.getString(3)+"</option>");	
	//			else
		//			out.write("<option value = '"+scrs.getString(1)+"'>"+scrs.getString(3)+"</option>");	
	//	}
			rs1=null;
			rs1 = statement.executeQuery("Select Privacy from rel_dissection_privacy where DissectionID = '"+dis+"' ");
			while (rs1.next()) {
				if (rs1.getString(1).equals("1")) {
%>
				<label class="radio-inline">
					<input type="radio" name="privacy" value="Private" disabled />Private
				</label>
				<label class="radio-inline">
					<input type="radio" name="privacy" value="Public" checked />Public
				</label>
<%
					//out.write("<input type=radio name=privacy value=Private "+disabled+">Private<input type=radio name=privacy value=Public checked>Public</td>" );	
				}else{
%>
				<label class="radio-inline">
					<input type="radio" name="privacy" value="Private" checked />Private
				</label>
				<label class="radio-inline">
					<input type="radio" name="privacy" value="Public" disabled />Public
				</label>
<%
					//out.write("<input type=radio name=privacy value=Private checked>Private<input type=radio name=privacy value=Public "+disabled+">Public</td> ");	
				}
			}  
%>
				</div>
			</div>
		</div>
			<hr/>
			
			<ul class="list-group">
<%
	    
			stmtd = conn.createStatement();
	        resultd = stmtd.executeQuery("SELECT LineIndex, Code, Comment,DissectionID FROM ent_line where DissectionID = '" + dis + "' order by LineIndex");	
			String count = "";
		
		
			stmt1 = conn.createStatement();
			result1 = stmt1.executeQuery("SELECT Min(LineIndex),Max(LineIndex) FROM ent_line where DissectionID = '" + dis + "'");	
			while (result1.next()) {
				min = result1.getInt(1);
				M=result1.getInt(2);
			}
			
			int cnt=0;
			String mobileView = "";
	        while (resultd.next())  {	
	        	StringBuffer text = new StringBuffer(resultd.getString(2));
	        	int loc = (new String(text)).indexOf('\n');
	        	while (loc >= 0){       
		            text.replace(loc, loc+1,"");
		            loc = (new String(text)).indexOf('\r');
				}
		    	StringBuffer text1 = new StringBuffer(resultd.getString(3)==null?"":resultd.getString(3));
		    	
	        	int loc1 = (new String(text1)).indexOf('\n');        	
		        while (loc1 >= 0) {       
					text1.replace(loc1, loc1+1,"");
		            loc1 = (new String(text1)).indexOf('\r');
		       }
		       
		       count = resultd.getString(1);
		       int LineNo = Integer.parseInt(count); 
		       
		       cnt++;
		       mobileView = (cnt > 1) ? " hidden-md hidden-lg": "";
%>
		       <li class="list-group-item">
			  		<div class="form-inline">
			  			<div class="form-group">
			  				<img src='images/trash.jpg' id = 'deleteImg<%=LineNo %>' title = 'Delete this line' fn = 'deleteline' disID='<%=dis%>' lno='<%=resultd.getString(1)%>' max = '<%=M%>' />
							<img src='images/add-icon.png' id = 'AddImg<%=LineNo %>' title = 'Add line above this line' fn = 'addline' disID='<%=dis%>' lno='<%=resultd.getString(1)%>' max = '<%=M%>' />
		            	</div>
		     
		      <script type="text/javascript">
		       var rd = "<%=readonly%>";
		       if (rd == 'readonly')
		       {
					document.getElementById("deleteImg<%=LineNo %>").style.opacity = '0.3';
					document.getElementById("AddImg<%=LineNo %>").style.opacity = '0.3';
		    		//for firefox,chrome
					document.getElementById("deleteImg<%=LineNo %>").setAttribute("disabled", "disabled");			
					document.getElementById("AddImg<%=LineNo %>").setAttribute("disabled", "disabled");		
				 
					//for ie
					document.getElementById("deleteImg<%=LineNo %>").disabled = true;		
					document.getElementById("AddImg<%=LineNo %>").disabled = true;
	
		       }
		      </script>	
		      
						<div class="form-group">
			  				<p class="help-block<%= mobileView %>">Code:</p>
							<textarea class="form-control" rows="2" cols="60" id="code<%=resultd.getString(1)%>" name="code<%=resultd.getString(1)%>" <%=readonly%>><%=text%></textarea>
		            	</div>
			            <div class="form-group">
			            	<p class="help-block<%= mobileView %>">Comment:</p>
							<textarea class="form-control" rows="2" cols="60" name="comment<%=resultd.getString(1)%>" wrap="physical" onKeyDown="textCounter(this.form.comment<%=resultd.getString(1)%>,this.form.remLen<%=resultd.getString(1)%>,2048)" onKeyUp="textCounter(this.form.comment<%=resultd.getString(1)%>,this.form.remLen<%=resultd.getString(1)%>,2048)" <%=readonly%>><%=text1%></textarea>
						</div>
			            <div class="form-group">
			            	<p class="help-block<%= mobileView %>">Characters left:</p>
							<input readonly class="form-control" type="text" name=remLen<%=resultd.getString(1)%> size="4" value="2048" />    
							<input  type="hidden" value=<%=resultd.getString(1)%> name="count<%=resultd.getString(1)%>" />
						</div>
					</div>
				</li>     	     
<% 	       
	        }                                       	             
%>
			</ul>
			<div class="form-group">
				<input type="button" name="save" fn = 'save' class="btn btn-default" value = "Save" <%=disabled %>>
				<input type="hidden" name="sel" value = "<%=scope %>">
				<input type="hidden" name="sc" value=<%=request.getParameter("sc")%>>
	        	<input  TYPE="hidden" VALUE=<%=M%> NAME="max" id = "max">
		    	<input  TYPE="hidden" VALUE=<%=min%> NAME="min" id = "min"> 
			</div>
		</form>

<%
		} catch (SQLException e) {
			System.out.println("Error occurred " + e);
			if (!response.isCommitted()) {
				response.sendRedirect("authoring.jsp?type=example&message=Unknown error has occurred&alert=danger");
			}
		} finally {
			if (stmt != null)
				stmt.close();
			
	        if (conn != null)
				conn.close();
	   }     

}
%>	

<%@ include file = "../include/htmlbottom.jsp" %>