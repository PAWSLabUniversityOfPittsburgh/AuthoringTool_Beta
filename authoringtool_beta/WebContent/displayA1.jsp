<%@ page language="java" %>
<%@ include file = "include/htmltop.jsp" %>
<%@ include file = "include/connectDB.jsp" %>
<%@ page import="java.sql.*" %>

<script type="text/javascript">
	function save() {
		var privacyTemp = document.querySelector('input[name="privacy"]:checked');
		if (privacyTemp != null) {
			privacyTemp = privacyTemp.value;
			if (oldPrivacy == privacyTemp) {
				privacyTemp = null;
			}
		} else {
			privacyTemp = null;
		}
		var exampleTitle = $('#titleField').val();
		var exampleDescription = $('#descriptionField').val();
		if (oldDescription == exampleDescription) {
			exampleDescription = null;
		}
		var linesTemp = $('.comment-line');
		var lines = [];
		for (var i=0; i<linesTemp.length; i++) {
			tempLineNumber = $(linesTemp[i]).attr('linenumber');
			tempComment = $(linesTemp[i]).val();
			lines[i] = {"lineNumber" : ""+tempLineNumber+"", "comment" : ""+tempComment+""};
		}
		var allLines = JSON.stringify(lines);
		
		$.post("CreateExampleServlet", {commentUpdate : 'true', rdfID : oldRdfID, privacy : (privacyTemp != null ? privacyTemp : 'null'), title : exampleTitle, description : (exampleDescription != null ? exampleDescription : 'null'), lines : allLines, dissectionID : disID}, function() {})
	    .done(function(data) {
	    	if ($.trim(data) == "true") {
				window.location.href = "authoring.jsp?type=example&message=Example updated successfully!&alert=success";
	    	} else {
	    		alertMessage("Something went wrong while we were processing your request, please try to submit again");
	    	}
	    })
	    .fail(function() {
	    	alertMessage("Something went wrong while we were processing your request, please try to submit again");
	    });
	}
	
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
		   
/* 	function textCounter(field,cntfield,maxlimit) {
		if (field.value.length > maxlimit) {
			field.value = field.value.substring(0, maxlimit);
		} else {
			cntfield.value = maxlimit - field.value.length;
		}
	} */
	
	function textCounter(field) {
		maxlimit = 2048;
		fieldLength = $(field).val().length;
		if (fieldLength > maxlimit) {
			$(field).val($(field).val().substring(0, maxlimit));
		} else {
			$(field).parents('li').eq(0).find('input').eq(0).val(maxlimit - fieldLength);
		}
	}
</script>
<%
	ResultSet results = null;
	Statement statement  = null;
	Statement stmts = null;
	ResultSetMetaData rsmds = null;   	
	String uid= Integer.toString(userBean.getId());
	ResultSet rs = null;  
	String scope = request.getParameter("sc");
	String dis=request.getParameter("dis");
	String authorID = "";
	String disabled = "";
	String readonly = "";
	String oldPrivacy = null;
	String oldDescription = null;
	try {
		stmt = conn.createStatement();
        result = stmt.executeQuery("SELECT d.DissectionID,d.Name,d.Description,dp.Uid FROM ent_dissection d,rel_scope_dissection r, rel_dissection_privacy dp WHERE r.ScopeID = '"+request.getParameter("sc")+"' AND d.DissectionID=r.DissectionID AND dp.DissectionID=d.DissectionID ORDER BY d.name");
     
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
		if (stmt != null)
			stmt.close();
		if (result != null)
			result.close();
	}

%>

<script type="text/javascript">
	var sc = "<%=scope%>";
	var uid = "<%=uid%>";
	var disID = "<%=dis%>";
</script>

	<h3>Please select the scope and example that you'd like to modify</h3>
	<hr>
	<div class="form-horizontal" id="1" name="1">
		<div class="form-group">
	    	<label for="scope" class="col-sm-3 control-label">Scope:</label>
		    <div class="col-sm-9">
		    	<select class="form-control" onchange="changeScope();" name="scope" id="scope">
<%
				ResultSet rs1 = null;
				try{  	  
					statement = conn.createStatement();
					rs1 = statement.executeQuery("SELECT DISTINCT s.scopeID,s.Name,sp.privacy FROM ent_scope s,rel_scope_privacy sp WHERE sp.scopeID = s.scopeID AND"+
							                      " (sp.privacy = 1 OR sp.uid = "+ uid+") ORDER BY s.Name");
					 
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
					String query = "SELECT DISTINCT d.dissectionID,d.name,d.description FROM ent_dissection d,rel_scope_dissection sd, ent_scope s, rel_dissection_privacy dp WHERE s.scopeID = "+scope 
					            +" AND sd.scopeID = s.scopeID AND d.dissectionID = sd.dissectionID AND dp.dissectionid = d.dissectionid AND (dp.uid = "+uid+" OR dp.privacy = 1)  ORDER BY d.name";
					
					rs1 = statement.executeQuery(query);
					out.write("<option value = '-1' selected>Please select the example</option>");
					String exampleSelected = "";
					
					while(rs1.next()) {
						if (rs1.getString(1).equals(dis)) {
							exampleSelected = "selected";
						} else {
							exampleSelected = "";
						}
						out.write("<option value = '"+rs1.getString(1)+"' "+exampleSelected+">"+rs1.getString(2)+"</option>");   		
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
	</div>
<% 

		String rdfID= null;
	if (dis != null  && !dis.equals("-1")) {
		String Name = null;
		String Des = null;
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
	<div class="form" name="eform" id ="eform">
	<hr/>
	<div class="form-horizontal">
		<div id="alertMessage"></div>
	  		<div class="form-group">
		  		<label class="col-sm-3 control-label">Topic:</label>
				<div class="col-sm-9">
<%    
			rs = statement.executeQuery("Select distinct e.Name,e.Description,e.rdfID,dp.privacy,dp.Uid from ent_dissection e, rel_dissection_privacy dp where e.DissectionID = '"+dis+"' and dp.DissectionID = e.DissectionID ");
			while (rs.next()) {
				Name = rs.getString(1);
				Des = (rs.getString(2)==null?"":rs.getString(2));
				oldDescription = Des;
				rdfID = rs.getString(3);
				privacy  = rs.getInt(4);
				authorID = rs.getString(5);
			}
			String topic = "";
			rs = statement.executeQuery("SELECT t.Title FROM rel_topic_dissection r, ent_jquestion t WHERE t.QuestionID = r.topicID AND r.dissectionID = '"+dis+"';");
			while (rs.next()) {
				topic = rs.getString(1);
			}	       	
%>
					<input readonly class="form-control" type="text" size="4" value="<%=topic%>" />
				</div>
			</div>
			<div class="form-group">
				<label class="col-sm-3 control-label">Title:</label>
				<div class="col-sm-9">
					<input id="titleField" class="form-control" type="text" size="4" value="<%=Name%>" />
				</div>
			</div>
			<div class="form-group">
				<label class="col-sm-3 control-label">RDF ID:</label>
				<div class="col-sm-9">
					<input readonly class="form-control" type="text" size="4" value="<%=rdfID%>" />
				</div>
			</div>
			<div class="form-group">
				<label for="Des" class="col-sm-3 control-label">Description:</label>
				<div class="col-sm-9">
					<textarea class="form-control" rows="2" cols="25" id="descriptionField" name="Des" value="<%=Des%>"><%=Des%></textarea>
				</div>
			</div>
			<div class="form-group">
				<label for="privacy" class="col-sm-3 control-label">Privacy:</label>
				<div class="col-sm-9">
<%
			rs1=null;
			rs1 = statement.executeQuery("Select Privacy, Uid from rel_dissection_privacy where DissectionID = '"+dis+"' ");
			while (rs1.next()) {
				oldPrivacy = rs1.getString(1);
				if (rs1.getString(1).equals("1")) {
%>
				<label class="radio-inline">
					<input type="radio" name="privacy" value="0" disabled />Private
				</label>
				<label class="radio-inline">
					<input type="radio" name="privacy" value="1" checked />Public
				</label>
<%	
				}else{
%>
				<label class="radio-inline">
					<input type="radio" name="privacy" value="0" checked />Private
				</label>
				<label class="radio-inline">
					<input type="radio" name="privacy" value="1" <%=rs1.getInt(2) == userBean.getId() ? "": "disabled"%> />Public
				</label>
<%
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
			  				<p class="help-block<%= mobileView %>">Code:</p>
							<textarea readonly class="form-control" rows="2" cols="60"><%=text%></textarea>
		            	</div>
			            <div class="form-group">
			            	<p class="help-block<%= mobileView %>">Comment:</p>
							<textarea <%= ((text1.toString().trim().length() < 1) ? " readonly " : "") %> class="form-control <%= ((text1.toString().trim().length() < 1) ? "" : " comment-line") %>" rows="2" cols="60" linenumber="<%=resultd.getString(1)%>" wrap="physical" onKeyDown="textCounter(this);"><%=text1%></textarea>
						</div>
			            <div class="form-group">
			            	<p class="help-block<%= mobileView %>">Characters left:</p>
							<input readonly class="form-control" type="text" size="4" value="<%= (2048-text1.toString().trim().length()) %>" />    
						</div>
					</div>
				</li>     	     
<% 	       
	        }                                       	             
%>
			</ul>
			<div class="form-group">
				<button class="btn btn-default" onclick="save();">Save</button>
				<a href="authoring.jsp?type=example" class="btn btn-default pull-right">Cancel</a>
			</div>
		</div>

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

<script type="text/javascript">
	var oldPrivacy = "<%=oldPrivacy%>";
	var oldDescription = "<%=oldDescription%>";
	var oldRdfID = "<%=rdfID%>";
</script>

<%@ include file = "include/htmlbottom.jsp" %>