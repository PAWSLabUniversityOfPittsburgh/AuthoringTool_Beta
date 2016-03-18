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
<script type="text/javascript">
		function create () {
			var scopeTemp = document.getElementById("scope").value;
			var topicTemp = $('#topic').attr('topicid');
			var titleTemp = document.getElementById("title").value;
			var domainTemp = $('#scope option:selected').attr('domain');
			titleTemp = titleTemp.replace(/\s+/g, '');
			var rdfIDTemp = document.getElementById("rdfID").value;
			rdfIDTemp = rdfIDTemp.replace(/\s+/g, '');
			var privacyTemp = document.querySelector('input[name="privacy"]:checked');
			if (privacyTemp != null) {
				privacyTemp = privacyTemp.value;
			} else {
				privacyTemp = "";
			}
			var selected = false;
			var descriptionTemp =  document.getElementById("description").value;
			if (descriptionTemp == "undefind") {
				descriptionTemp = "";
			}
			if(privacyTemp == "Private" || privacyTemp == "Public") {
				selected = true;					
			}
			
			if (scopeTemp== "-1") {
				alertMessage('Please select scope for the example.');
			}
			else if (topicTemp == "-1" || !$('#topicSelector').length) {
				alertMessage('Please select topic for the example.');
			}
			else if (titleTemp == "") {
				alertMessage('Title cannot be empty!');
			} else if (rdfIDTemp == "") {
				alertMessage("RDF ID cannot be empty!");
			} else if (selected == false) {
				alertMessage("Please select the privacy.");
			} else {
				var invalid = false;
				for (var index in rdfs) {
					if (rdfs[index] == rdfIDTemp)
						invalid = true;
				}
    			if (invalid) {
    				alertMessage("RDF ID already exists. Please enter another value.");
    			} else {			
    				if ($('#code').length) {
    					if (confirm('Are you sure you want to save this example without line comments?')) {
    						createCommentsHtml();
    					} else {
    					    return;
    					}
    				}
    				
					var allLines = getLines();
					if (allLines == null) {
						alertMessage("Something went wrong while we were processing your request, please try to submit again");
					} else {
						$.post("CreateExampleServlet", {scope: scopeTemp, topic : topicTemp, title : titleTemp, rdfID : rdfIDTemp, privacy : privacyTemp, description : descriptionTemp, lines : allLines, domain : domainTemp}, function() {})
					    .done(function(data) {
					    	if ($.trim(data) == "true") {
								window.location.href = "authoring.jsp?type=example&message=Example saved successfully!&alert=success";
					    	} else {
					    		alertMessage("Something went wrong while we were processing your request, please try to submit again");
					    	}
					    })
					    .fail(function() {
					    	alertMessage("Something went wrong while we were processing your request, please try to submit again");
					    });
					}
				}
    		}
		}

		
		function getLines() {  
			var linesTemp = $('#codeCommentLines li');
			var lines = [];
			for (i=0; i<linesTemp.length; i++) {
				tempCode = $(linesTemp[i]).find('textarea').eq(0).val();
				tempComment = $(linesTemp[i]).find('textarea').eq(1).val();
				lines[i] = {"lineNumber" : ""+(i+1)+"", "code" : ""+tempCode+"", "comment" : ""+tempComment+""};
			}
			return JSON.stringify(lines);
		}
		
		
		function changeScope() {
			var scopeid = document.getElementById("scope").value;
			if (scopeid == '-1') {
				document.location.href="create_example_version.jsp";
			} else {
				document.location.href="create_example_version.jsp?sc="+scopeid+"&ex=-1";
			}
		}
		
		function changeTitle() {
			var scopeid = document.getElementById("scope").value;
			var exampleid = document.getElementById("example").value;

			document.location.href="create_example_version.jsp?sc="+scopeid+"&ex="+exampleid;
		} 
	
		function alertMessage (text) {
			$("#alertMessage").hide().html('<div class="alert alert-danger alert-dismissible" role="alert">'+
					'<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>'+
					text+'</div>').fadeIn('slow');
			$("html, body").animate({ scrollTop: 0 }, "slow");
		}
		
		function deleteLine(line) {
			$(line).parents("li").eq(0).hide('slow', function() {
				$(line).parents("li").eq(0).remove();
			});
		}
		
		function addLine(line) {
			$('<li class="list-group-item">'+
			  		'<div class="form-inline">'+
					'<div class="form-group">'+
		  				'<p class="help-block hidden-md hidden-lg">Code:</p>'+
						'<textarea class="form-control" rows="2" cols="65" ></textarea>'+
	            	'</div>'+
		            '<div class="form-group">'+
		            	'<p class="help-block hidden-md hidden-lg">Comment:</p>'+
						'<textarea class="form-control" rows="2" cols="65" onKeyDown="textCounter(this);"></textarea>'+
					'</div>'+
		            '<div class="form-group">'+
		            	'<p class="help-block hidden-md hidden-lg">Characters left:</p>'+
						'<input readonly class="form-control" type="text" size="4" value="2048" />'+
					'</div>'+
		  			'<div class="form-group">'+ 
		  			'<img src="images/trash.jpg" onclick="deleteLine(this);" title="Delete this line" style="margin-right: 10px;"/>'+
						'<img src="images/add-icon.png" onclick="addLine(this);" title="Add line bellow this line" />'+
	            	'</div>'+	
				'</div>'+
			'</li>').hide().insertAfter($(line).parents("li").eq(0)).show('slow');
		}
		
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
<style>
.form-inline div {
	margin-right: 10px;
}
</style>
<%
	stmt = conn.createStatement();
	String commandx = "SELECT rdfID FROM ent_dissection;";
	ResultSet rs = stmt.executeQuery(commandx);
	ArrayList<String> rdfList = new ArrayList<String>();
	while (rs.next()) {
		rdfList.add(rs.getString(1));
	}
%>

<script>
    var uname = "<%=userBeanName%>";
	var rdfs = new Array();
	<%for (String rdf : rdfList){%>
	     rdfs.push("<%=rdf%>");
	<%}%>
</script>

<%
	String uid = "";
	rs = stmt.executeQuery("SELECT id FROM ent_user where name = '"+userBeanName+"' ");
	while(rs.next()) {
		 uid = rs.getString(1);
	}
%>

<h3>Create new version of the existing example:</h3>
<hr>
<div class="form-horizontal" role="form" id = "eform" name = "create_example">

<%
	if (request.getParameter("sc") == null || request.getParameter("sc").trim().length() == 0) {
%>
		<div class="form-group" id="scopeSelector">
		<label for="scope" class="col-sm-3 control-label">Scope:</label>
	    <div class="col-sm-9">
	    	<select class="form-control" onchange="changeScope();" name="scope" id="scope">
	    		<option value = "-1" selected>Please select the scope</option>
<%

					stmt = conn.createStatement();
					String command = "SELECT * FROM ent_scope s, rel_scope_privacy sp WHERE sp.ScopeID = s.ScopeID AND (sp.privacy = 1 or sp.Uid = "+uid+")";
					result = stmt.executeQuery(command);
					
					while(result.next()) {
						if (result.getString(3).equals("0")) {
							out.write("<option class = 'private' bgcolor='#FCF4BD' title = 'This scope is private' value = '"+result.getString(1)+"' domain='"+result.getString(5)+"'>"+result.getString(3)+"</option>");
						} else {
							out.write("<option value = '"+result.getString(1)+"' domain='"+result.getString(5)+"' >"+result.getString(3)+"</option>");	  	
						}	   		
					} 
%>
	    	</select>
	    </div>
	</div>
<%
	} else {
%>
	<div class="form-group" id="scopeSelector">
		<label for="scope" class="col-sm-3 control-label">Scope:</label>
	    <div class="col-sm-9">
	    	<select class="form-control" onchange="changeScope();" name="scope" id="scope">
	    		<option value = "-1">Please select the scope</option>
<%

					stmt = conn.createStatement();
					String command = "SELECT * FROM ent_scope s, rel_scope_privacy sp WHERE sp.ScopeID = s.ScopeID AND (sp.privacy = 1 or sp.Uid = "+uid+")";
					result = stmt.executeQuery(command);
					
					while(result.next()) {
						if (result.getString(3).equals("0")) {
							out.write("<option class = 'private' bgcolor='#FCF4BD' title = 'This scope is private' value = '"+result.getString(1)+"' domain='"+result.getString(5)+"' "+((request.getParameter("sc").equals(result.getString(1))) ? "selected" : "")+">"+result.getString(3)+"</option>");
						} else {
							out.write("<option value = '"+result.getString(1)+"' domain='"+result.getString(5)+"' "+((request.getParameter("sc").equals(result.getString(1))) ? "selected" : "")+">"+result.getString(3)+"</option>");	  	
						}	   		
					} 
%>
	    	</select>
	    </div>
	</div>
	<div class="form-group">
    	<label for="scope" class="col-sm-3 control-label">Example:</label>
	    <div class="col-sm-9">
			<select class="form-control" name="example" id="example" onChange="Javascript:changeTitle();">
<%	             
				stmt = null;
				result = null;
				try {                
					stmt = conn.createStatement();
					result = stmt.executeQuery("SELECT e.DissectionID,e.Name,e.description FROM ent_dissection e, rel_scope_dissection r, rel_dissection_privacy dp where e.DissectionID=r.DissectionID and r.ScopeID ="+ request.getParameter("sc")+" and e.dissectionid = dp.dissectionid and (dp.privacy = 1 or dp.uid = "+uid+") order by e.Name" );                                                        
										
					String exParam = request.getParameter("ex");
					if (exParam == null || exParam.trim().length() == 0) {
						exParam = "-1";
					}
					if (exParam.equals("-1")) {
						out.println("<option value='-1' selected>Please select the example</option>");
					} else {
						out.println("<option value='-1' >Please select the example</option>");
					}
					
					for (int i=1; i<=columns; i++) {    
						while (result.next()) {  
							if (result.getString(1).equals(exParam)){
								out.write("<option value="+result.getString(1)+" selected>" + result.getString(2) + "</option>");		    		    
							}else{
								out.write("<option value="+result.getString(1)+">" + result.getString(2) + "</option>");		    		    
							}
						}	                       
					}                     
					stmt.close();        
				} catch (Exception e) {
					if (result != null)
						result.close();
					
					System.out.println("Error occurred " + e);
					if (!response.isCommitted()) {
						response.sendRedirect("servletResponse.jsp");
						return;
					}
				} finally {
					try {
						if (stmt != null)
							stmt.close();
					} catch (SQLException e) {}     
				}
%>
			</select>
		</div>
	</div>
<%
	}

if (request.getParameter("ex") != null && request.getParameter("ex").trim().length() > 0 && !request.getParameter("ex").trim().equals("-1")) {
%>

<hr/>
<div id="alertMessage"></div>

<%
			stmt = conn.createStatement();
			rs = stmt.executeQuery("SELECT topicID FROM rel_topic_dissection WHERE dissectionID = '"+request.getParameter("ex").trim()+"';");
			rs.last();
			int count = rs.getRow();
			if (count != 1) {
%>
	<p style="color: red;">Sorry, you can not create new version of this example, because of some possible inconsistencies in existing study courses</p>
	<%@ include file = "include/htmlbottom.jsp" %>
<%
				try {
					if (rs != null) {
						rs.close();
					}
					if (stmt != null) {
						stmt.close();
					}
					if (conn != null) {
						conn.close();
					}
				} catch (SQLException e) {
					e.printStackTrace();
				}
				return;
			}
			rs.beforeFirst();
			Integer topicID = null;
			while(rs.next()) {
				topicID = rs.getInt(1);
			}
			
			rs = stmt.executeQuery("SELECT Title FROM ent_jquestion WHERE QuestionID = '"+topicID+"';");
			rs.last();
			count = rs.getRow();
			if (count != 1) {
				try {
					if (rs != null) {
						rs.close();
					}
					if (stmt != null) {
						stmt.close();
					}
					if (conn != null) {
						conn.close();
					}
				} catch (SQLException e) {
					e.printStackTrace();
				}
				return;
			}
			rs.beforeFirst();
			String topicTitle = null;
			while(rs.next()) {
				topicTitle = rs.getString(1);
			}
			
			rs = stmt.executeQuery("SELECT * FROM ent_dissection WHERE DissectionID = '"+request.getParameter("ex").trim()+"';");
			rs.last();
			count = rs.getRow();
			if (count != 1) {
				try {
					if (rs != null) {
						rs.close();
					}
					if (stmt != null) {
						stmt.close();
					}
					if (conn != null) {
						conn.close();
					}
				} catch (SQLException e) {
					e.printStackTrace();
				}
				return;
			}
			rs.beforeFirst();

			while(rs.next()) {
				
				String title = rs.getString("Name");
				title = (title != null) ? (title.contains("_version_") ? title+".01" : title+"_version_1") : "";
				String rdfId = rs.getString("rdfID");
				rdfId = (rdfId != null) ? (rdfId.contains("_version_") ? rdfId+".01" : rdfId+"_version_1") : "";
%>
	<div class="form-group" id="topicSelector">
		<label for="topic" class="col-sm-3 control-label">Topic:</label>
		<div class="col-sm-9">
			<input type="text"  class="form-control" disabled name="topic" id="topic" topicid="<%= topicID %>" value="<%= topicTitle %>"/>
		</div>
	</div>
	<div class="form-group">
	    <label for="title" class="col-sm-3 control-label">Title:</label>
	    <div class="col-sm-9">
	    	<input type="text" name="title" maxlength="45" class="form-control" id="title" value="<%= title %>"/>
	    </div>
	</div>
	<div class="form-group">
	    <label for="rdfID" class="col-sm-3 control-label">RDF ID:</label>
	    <div class="col-sm-9">
	    	<input type="text" name="rdfID" id="rdfID" class="form-control" value="<%= rdfId %>">
	    </div>
	</div>
	<div class="form-group">
	    <label for="chapter" class="col-sm-3 control-label">Description:</label>
	    <div class="col-sm-9">
			<textarea  name="chapter" id="description" cols="70" rows="3" class="form-control" value="<%= rs.getString("Description") != null ? rs.getString("Description") : "" %>"><%= rs.getString("Description") != null ? rs.getString("Description") : "" %></textarea>
	    </div>
	</div>
	<div class="form-group" id="privacyFormGroup">
    	<label for="privacy" class="col-sm-3 control-label">Privacy:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<label class="radio-inline">
				<input type="radio" name="privacy" value="Private">Private
			</label>
			<label class="radio-inline">
				<input type="radio" name="privacy" value="Public">Public
			</label>
	    </div>
	</div>
</div>
<%
			}
%>
<div id="center">
	<ul class="list-group" id="codeCommentLines">
<%
String mobileView = "";
int i = 0;
boolean notFirstButton = false;	

rs = stmt.executeQuery("SELECT * FROM ent_line WHERE DissectionID = '"+request.getParameter("ex").trim()+"' order by lineindex asc;");

while(rs.next()) {
	
	mobileView = (i > 0) ? " hidden-md hidden-lg": "";

%>
		<li class="list-group-item">
	  		<div class="form-inline">
				<div class="form-group">
	  				<p class="help-block <%= mobileView %>">Code:</p>
					<textarea class="form-control" rows="2" cols="65" ><%= rs.getString("Code") != null ? rs.getString("Code") : "" %></textarea>
            	</div>
	            <div class="form-group">
	            	<p class="help-block <%= mobileView %>">Comment:</p>
					<textarea class="form-control" rows="2" cols="65" onKeyDown="textCounter(this);"><%= rs.getString("Comment") != null ? rs.getString("Comment") : "" %></textarea>
				</div>
	            <div class="form-group">
	            	<p class="help-block <%= mobileView %>">Characters left:</p>
					<input readonly class="form-control" type="text" size="4" value="<%= rs.getString("Comment") != null ? 2048 - rs.getString("Comment").length() : "2048" %>" />
				</div>
	  			<div class="form-group">
	  			<%= (notFirstButton ? "<img src=\"images/trash.jpg\" onclick=\"deleteLine(this);\" title=\"Delete this line\" style=\"margin-right: 10px;\"/>" : "") %>
					<img src="images/add-icon.png" onclick="addLine(this);" title="Add line bellow this line" />
            	</div>
			</div>
		</li>
<%
		i++;
		notFirstButton = true;
}
%>
	</ul>
</div>
<div class="form-horizontal" id="bottom">
	<button class="btn btn-default" onclick="create();">Create</button>
	<a href="authoring.jsp?type=example" class="btn btn-default pull-right">Cancel</a>
</div>

<%
}
%>

<%@ include file = "include/htmlbottom.jsp" %>