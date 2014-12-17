<%@ page language="java" %>
<%@ include file = "include/htmltop.jsp" %>
<%@ page import="java.sql.*" %>

<style>
	.multipleSelectBoxControl span{	/* Labels above select boxes*/
		font-family:arial;
		font-size:11px;
		font-weight:bold;
	}
	.multipleSelectBoxControl div select{	/* Select box layout */
		font-family:arial;
		height:100%;
	}
	.multipleSelectBoxControl input{	/* Small butons */
		width:25px;	
	}
	
	.multipleSelectBoxControl div{
		float:left;
	}
</style>

<script type="text/javascript">
$(document).ready(function() {
	$('#message').fadeOut(1).fadeIn(1500).delay(5000).fadeOut(1000);
	$('#addAlert').fadeOut(1);

	$("#addBtn").click(function () {
		var input = $('input[fn=lines]').val();
		input = input.replace(/\s+/g, '');
		var regex = /^(\d+-\d+)(;\d+-\d+)*$/;
		var match = false;
		 if (input.match(regex)) 
			match = true;
		 else if (input == '')
			match = true;
		 else if (input.match(/^(\d+-\d+)(;\d+-\d+)*;$/))
			match = true;
		 if (match == false) {
			$('#addAlert').fadeIn(500);
			$('input[fn=lines]').focus();
		 } else {
			var question = document.getElementById("question").value;
			var count = document.getElementById("questionClassCount").value;
			var sel = document.getElementById("addConceptList");
			var concept = sel.options[sel.selectedIndex].value;
	        var array = new Array();
	        array.push(sel);
	        for (var i = 0; i < count; i++) {
        	   var selected = document.getElementById(i+"AddRowSelected");
        	   var lines = document.getElementById(i+"AddRowLines");
        	   var className = document.getElementById(i+"AddConceptClass");
        	   if (selected.checked) {
        		   array.push(selected);
        		   array.push(lines);
        		   array.push(className);
				}
        	}
			$.post("AddConcept?question="+question+"&count="+count+"&type=example",array, function() {})
			    .success(function() {
			    	var domain = $( "#scope option:selected" ).attr('domain');
			    	var exampleID = $('select[name="example"]').val();
			    	var exampleTitle = $('select[name="example"] option:selected').text();
			    	$.post("ExampleConceptUmUpdate?exampleID="+exampleID+"&domain="+domain+"&exampleTitle="+exampleTitle, function() {}).always(function() {
				    	window.location.href = window.location.href.split("?")[0]+"?sc=<%=request.getParameter("sc")%>&ex=<%=request.getParameter("ex")%>&mtype=alert-success&message=Concept added successfully!";
			    	});
			    })
			    .error(function() {
			    	window.location.href = window.location.href.split("?")[0]+"?sc=<%=request.getParameter("sc")%>&ex=<%=request.getParameter("ex")%>&mtype=alert-danger&message=Concept was not added";
			    })
			    .complete(function() {});	
		 }
	});
	
	$('input[fn=lines]').on('keyup keypress blur change keydown', function(event) {
		if ((event.keyCode || event.which) == 13) {
			event.preventDefault();
		}
		$('#addAlert').fadeOut(500);
	});
	
	$("#saveBtn").click(function () {
		var question = document.getElementById("question").value;
		var count = document.getElementById("conceptCount").value;
        var array = new Array();
        for (var i = 0; i < count; i++)
        	{
        	   var selected = document.getElementById(i+"Selected");
        	   var concept = document.getElementById(i+"Concept");
        	   var weight = document.getElementById(i+"Weight");
        	   var direction = document.getElementById(i+"Direction");
        	   if (selected.checked)
        	   {
        		   array.push(selected);
        		   array.push(concept);
        		   array.push(weight);
        		   array.push(direction);    		   
        	   }
        	   else
        		   array.push(concept);
        	}
		$.post("SaveIndexing.jsp?question="+question+"&count="+count+"&type=example",array, function() {})
		    .success(function() {
		    	var domain = $( "#scope option:selected" ).attr('domain');
		    	var exampleID = $('select[name="example"]').val();
		    	var exampleTitle = $('select[name="example"] option:selected').text();
		    	$.post("ExampleConceptUmUpdate?exampleID="+exampleID+"&domain="+domain+"&exampleTitle="+exampleTitle, function() {}).always(function() {
			    	window.location.href = "<%=request.getContextPath()%>/authoring.jsp?type=example&alert=success&message=Indexing saved successfully!";
		    	});
		    })
		    .error(function() {
		    	window.location.href = "<%=request.getContextPath()%>/authoring.jsp?type=example&alert=danger&message=Indexing was not saved because of an internal error";
		    })
		    .complete(function() {});	
	});	
	
	$("img").click(function () {
		var fn =  $(this).attr("fn");
		if (fn == 'delete')
		{
			if ( $(this).attr("disabled") != "disabled") {
				var concept = $(this).attr("concept");
				var question = $(this).attr("question");
				$('#myModalLabel2').html('Are you sure you want to delete \"'+concept+'\" concept?');
				$('#myModal2 .modal-body').addClass('hidden');
				$('#myModal2 .modal-footer').html('<button type="button" class="btn btn-default" onclick="deleteConcept(\''+question+'\', \''+concept+'\');">Ok</button><button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>');
				$('#myModal2').modal('show');		
			}
		}
		else if (fn == 'edit')
		{
			if ( $(this).attr("disabled") != "disabled") {
				var concept = $(this).attr("concept");
				var question = $(this).attr("question");
				
				$('#myModalLabel2').html('Editing \"'+concept+'\" concept');
				$('#myModal2 .modal-body').removeClass('hidden');
				$('#myModal2').modal('show');
				
				$('#myModal2 .modal-footer').html('<button onclick="apply();" class="btn btn-default" name="applyBtn" id ="applyBtn">Apply</button><button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>');
				
				$.post("UpdateConcept.jsp?question="+question+"&concept="+concept+"&type=example", function( data ) {
					$('#myModal2 .modal-body').html(data);
					$('#addAlert2').fadeOut(1);
					
					$('input[fn=lines2]').on('keyup', function() {
						$('#addAlert2').fadeOut(500);
					});
				});
				
			}
		}		
	});
	
});

	function deleteConcept(question, concept) {
		$.post("DeleteConcept?question="+question+"&concept="+concept+"&type=example",function() {})
		    .success(function() {
		    	var domain = $( "#scope option:selected" ).attr('domain');
		    	var exampleID = $('select[name="example"]').val();
		    	var exampleTitle = $('select[name="example"] option:selected').html();
		    	
		    	$.post("ExampleConceptUmUpdate?exampleID="+exampleID+"&domain="+domain+"&exampleTitle="+exampleTitle, function() {}).always(function() {
			    	window.location.href = window.location.href.split("?")[0]+"?sc=<%=request.getParameter("sc")%>&ex=<%=request.getParameter("ex")%>&mtype=alert-success&message="+concept+" concept has been successfully removed!";
		    	});		    	
		    })
		    .error(function() {
		    	window.location.href = window.location.href.split("?")[0]+"?sc=<%=request.getParameter("sc")%>&ex=<%=request.getParameter("ex")%>&mtype=alert-danger&message="+concept+" concept was not removed because of an internal error";
		    })
		    .complete(function() {});
	}
	
	function editSuccess(concept) {
		window.location.href = window.location.href.split("?")[0]+"?sc=<%=request.getParameter("sc")%>&ex=<%=request.getParameter("ex")%>&mtype=alert-success&message="+concept+" concept has been successfully updated!";
	}
	
	function editFailed(concept) {
		window.location.href = window.location.href.split("?")[0]+"?sc=<%=request.getParameter("sc")%>&ex=<%=request.getParameter("ex")%>&mtype=alert-danger&message="+concept+" concept was not updated because of an internal error";
	}
	
	function checkAll() {
		for (var i=0;i<document.indexForm.elements.length;i++) {
		    var e=document.indexForm.elements[i];
			if ((e.name != 'selectAll') && (e.type=='checkbox')) {
				e.checked=document.indexForm.selectAll.checked;
				e.onclick();
			}			
		}	
	}
	
	function disableEnableFormElements(concept,question, lines,count)
	{
		if (document.getElementById(count+"Selected").checked == false)
		{
			document.getElementById(count+"Weight").disabled = true;
			document.getElementById(count+"Direction").disabled = true;
			document.getElementById(count+"Row").style.color = "gray";
			document.getElementById(count+"hRef").innerHTML = concept +"&nbsp;&nbsp;";
			document.getElementById(count+"deleteImg").style.opacity = '0.3';
			document.getElementById(count+"editImg").style.opacity = '0.3';
			//for firefox,chrome
			document.getElementById(count+"deleteImg").setAttribute("disabled", "disabled");			
			document.getElementById(count+"editImg").setAttribute("disabled", "disabled");		
		 
			//for ie
			document.getElementById(count+"deleteImg").disabled = true;		
			document.getElementById(count+"editImg").disabled = true;
			
			document.getElementById(count+"deleteImg").style.cursor = 'not-allowed';
			document.getElementById(count+"editImg").style.cursor = 'not-allowed';
		}
		else
	    {
			document.getElementById(count+"Weight").disabled = false;
			document.getElementById(count+"Direction").disabled = false;
			document.getElementById(count+"Row").style.color = "black";
			document.getElementById(count+"hRef").innerHTML =  "<a href='javascript:showClassTab(\""+question+"\",\""+lines+"\")'>"+concept+"</a>&nbsp;&nbsp;";
			
			document.getElementById(count+"deleteImg").style.opacity = '1.0';
			document.getElementById(count+"editImg").style.opacity = '1.0';
			document.getElementById(count+"deleteImg").disabled = false;
			document.getElementById(count+"editImg").disabled = false;
			
			document.getElementById(count+"deleteImg").removeAttribute("disabled");			
			document.getElementById(count+"editImg").removeAttribute("disabled");
			
			document.getElementById(count+"deleteImg").style.cursor = 'pointer';
			document.getElementById(count+"editImg").style.cursor = 'pointer';
		}
	}
	
	function showConceptClass(id,href){
		document.getElementById(id).style.display="table-row";
		document.getElementById(href).innerHTML =  "-";
		document.getElementById(href).href = "javascript:hideConceptClass(\""+id+"\",\""+href+"\")";
    }
	
	function hideConceptClass(id,href)
	{
		document.getElementById(id).style.display="none";
		document.getElementById(href).innerHTML =  "+";
		document.getElementById(href).href  = "javascript:showConceptClass(\""+id+"\",\""+href+"\")";
	}
	
	function showClassTab(question,lines){ 
		for(var i = 0; i < lineCount; i++) {
			document.getElementById(question+i).style.backgroundColor = "";
		}					

        var lineArray = lines.split(';');
        var temp;
        var isFirstLine = true;
		for (var i = 0; i < lineArray.length; i++) {
			var seLine = lineArray[i].split('-');
	    	var start = parseInt(seLine[0],10);
	    	var end = parseInt(seLine[1],10);
	    	
		    for (var j=start; j<=end; j++)
		    {
		       if (isFirstLine == true)
		       {
		    	   temp = seLine[0];
		    	   isFirstLine = false;
		       }
			   document.getElementById(question+j).style.backgroundColor = "yellow";  
		    }		    
		}
		$('html, body').animate({scrollTop: $('#'+question+temp).offset().top -100 }, 'slow');
    }
	
	function showTab(tabIndex){ 
        tabPane.setSelectedIndex(tabIndex);        	 
    }
	
	function showAddConcept(id) {
		document.getElementById(id).style.display="table";
	}
	
	function enableAddRow(classCount) {
		var select = document.getElementById('addConceptList');
		var newConcept = select.options[select.selectedIndex].value;
		if (newConcept != '-1') {
			for (var j = 0; j < classCount; j++) {
			    var row =  document.getElementById(j+'AddRow');
			    row.style.color = "black";
			    var select = document.getElementById(j+'AddRowSelected');
			    select.disabled = false;
			    var linesText = document.getElementById(j+'AddRowLines');
			    linesText.disabled = false;
			    var btn = document.getElementById('addBtn');
			    btn.disabled = false;
			}
		} else {
			 for (var j = 0; j < classCount; j++) {
			    var row =  document.getElementById(j+'AddRow');
			    row.style.color = "gray";
			    var select = document.getElementById(j+'AddRowSelected');
			    select.disabled = true;
			    var linesText = document.getElementById(j+'AddRowLines');
			    linesText.disabled = true;
			    var btn = document.getElementById('addBtn');
			    btn.disabled = true;
			  }
		}
	}
	
	function disableEnableAddRowLine(line)
	{
        var select = document.getElementById(line+"AddRowSelected");
  	    var lineText = document.getElementById(line+"AddRowLines");
	    var row =  document.getElementById(line+'AddRow');

        if (select.checked == false)
        	{
    		  lineText.disabled = true;
    		  row.style.color = "gray";
        	}
        else
        {
  		  lineText.disabled = false;
  		  row.style.color = "black";
      	}
		
	}	

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

function changeTitle() {
	var scopeid = document.getElementById("scope").value;
	var selectExample = document.myForm.example;
	var ex=selectExample.options[selectExample.selectedIndex].value;;

	document.location.href="concept_indexing1.jsp?sc="+scopeid+"&ex="+ex;
}    

function changeScope() {
	var scopeid = document.getElementById("scope").value;
	if (scopeid == '-1') {
		document.location.href="concept_indexing1.jsp";
	} else {
		document.location.href="concept_indexing1.jsp?sc="+scopeid+"&ex=-1";
	}
} 

function showModal() {
	$('#myModal').modal('show');
}
function closeModal() {
	$('#myModal').modal('hide');
}
</script>

<%    
    Connection conn  = getConnectionToWebex21();
    ResultSet result = null;
    Statement stmts = null;
    ResultSetMetaData rsmds = null;  
    Statement stmt = null;
    ResultSet rs2 = null;   	
    Statement stmt2 = null;
    ResultSet rs3 = null;   	
    Statement stmt3 = null;
    ResultSet rs4 = null;   	
    Statement stmt4 = null;
    ResultSet rs5 = null;   	
    Statement stmt5 = null;
    ResultSet rs6 = null;   	
    Statement stmt6 = null;
    ResultSetMetaData rsmd6 = null;                      
    ResultSet rs7 = null;   	
    Statement stmt7 = null;
    String sc="";       	
    String uid= Integer.toString(userBean.getId());
    ResultSet rs = null;  
    String tempDomain = null;
%>

<h3>Please select the example you'd like to index:</h3>
<hr>
<form class="form-horizontal" role="form" name="myForm">

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
						if (request.getParameter("sc").equals(result.getString(1))) {
							tempDomain = result.getString(5);
						}
					} 
%>
	    	</select>
	    </div>
	</div>
	<div class="form-group">
    	<label for="scope" class="col-sm-3 control-label">Example:</label>
	    <div class="col-sm-9">
			<select class="form-control" name="example" onChange="Javascript:changeTitle();">
<%	             
				stmt = null;
				result = null;
				try {                
					stmt = conn.createStatement();
					result = stmt.executeQuery("SELECT e.DissectionID,e.Name,e.description FROM ent_dissection e, rel_scope_dissection r, rel_dissection_privacy dp where e.DissectionID=r.DissectionID and r.ScopeID ="+ request.getParameter("sc")+" and e.dissectionid = dp.dissectionid and (dp.privacy = 1 or dp.uid = "+uid+") order by e.Name" );                                                        
					int columns=0;
					ResultSetMetaData rsmd = result.getMetaData();       
					columns = rsmd.getColumnCount();        
					
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
%>
</form>
<%

if (request.getParameter("ex") != null && request.getParameter("ex").trim().length() > 0) {

	int classLine = 0;
	List<String> ontoConcepts = getOntologyConcepts(tempDomain);
	List<String> allClass = new ArrayList<String>();
	String question = "";
	String dissectionId = request.getParameter("ex");
	if (dissectionId.equals("-1") == false) {
		InputStream in = null;
		int length ;
		int bufferSize = 1024;
		byte[] buffer = new byte[bufferSize];        
		int position=0;
		int P = 0;
		String codepart="";
		int QuesType=0; 
		int flag=0;
		ArrayList<String> fileName = new ArrayList<String>();
		ResultSet rs1 = null;
		rs2 = null;
		Statement statement = null;
		try {
			 conn = getConnectionToWebex21();
			 if (isConnectedToDB(conn)) {
				String query = "SELECT rdfID FROM ent_dissection where dissectionID = "+dissectionId;
				statement = conn.createStatement();
				ResultSet temp = statement.executeQuery(query);
				while(temp.next()) {
					question = temp.getString(1);
				    allClass.add(0, question);
				}	    
			}    
		}catch (SQLException e) {
			System.out.println("Error occurred " + e);
			if (!response.isCommitted()) {
				response.sendRedirect("servletResponse.jsp");
				return;
			}
		} finally {
			try {
				if (rs1 != null)
					rs1.close();
				if (rs2 != null)
					rs2.close();
				if (statement != null)
					statement.close();
			} catch (Exception e) {
				e.printStackTrace();
		    }
		}

%>

<hr/>
<div class="row">
	<div class="col-xs-12 col-md-6">
		<div style="overflow-x:scroll;">
			<div class="tab-pane" id="tabpane" style="width:470px;overflow:auto;">
				<pre style="white-space:pre-wrap; font-size: 11px">
<%   
		int linecount = 0;
		try {
			stmt3 = conn.createStatement();
			String query = "SELECT l.Code,l.Comment FROM ent_line l where l.DissectionID="+request.getParameter("ex")+" order by l.LineIndex ";
			rs3 = stmt3.executeQuery(query);
			String line = "";
			while(rs3.next()) {
				line = rs3.getString(1);
			    out.print("<div id='"+question+""+linecount+"' >"+linecount+"   "+line+"</div>"); //print each line of the program question
			    linecount++;
			}
			classLine = linecount;
			stmt3.close();        
		} catch (Exception e) {
			System.out.println("Error occurred " + e);
			if (!response.isCommitted()) {
				response.sendRedirect("servletResponse.jsp");
				return;
			}
		} finally {
			try {
				if (stmt3 != null)
					stmt3.close();
			} catch (SQLException e) {}     
		}       				
%> 
				</pre>
			</div>
		</div>  
	</div>

	<div class="col-xs-12  col-md-6">	
<%
		if (request.getParameter("message") != null && request.getParameter("message").trim().length() > 0 && request.getParameter("mtype") != null && request.getParameter("mtype").trim().length() > 0) {
%>
		<div id="message" class="alert <%=request.getParameter("mtype")%>" role="alert"><%=request.getParameter("message")%></div>
<%
		}
%>
		<form name="indexForm" >

<%
		ArrayList<String> concepts = new ArrayList<String>();
		ResultSet classRs = null;
		ResultSet conceptRs = null;
		ResultSet weightDirectionRs = null;
		try
		{
		    conn = getConnectionToWebex21();
		    if (isConnectedToDB(conn))
		    {
				
				statement = conn.createStatement();
				String title = question;
				String query = "select distinct concept from ent_jexample_concept where title = '"+ title + "' order by concept ASC";
				conceptRs = statement.executeQuery(query);
				while (conceptRs.next()) {
					concepts.add(conceptRs.getString(1));					
				}
%>

			<label class="checkbox-inline" style="margin-bottom: 10px;">
				<input type="checkbox" checked="checked" value="on" id="selectAll" name="selectAll" onclick="checkAll();" align="left" style="margin-right: 10px;">Select All <%=concepts.size() %> concepts
			</label>
			<div style="overflow-x:scroll; /* width:550px; */">
				<table class="table table-condensed">
<%
				int count = 0;
				for (String c : concepts)
				{
					String lines = "";
					String classLinksHtml = "";
					query = "select distinct class from ent_jexample_concept where title = '"+ title + "' and concept = '"+c+"'" ;
					classRs = statement.executeQuery(query);
					String curClass;
					while (classRs.next())
					{	  
						lines = "";
						curClass = classRs.getString(1);
					    query = "select sline, eline from ent_jexample_concept where title = '"+ title + "' and class = '"+curClass+"' and concept = '"+c+"' and sline != -1 and eline !=-1";
					    stmt = conn.createStatement();
					    ResultSet seLineRs = stmt.executeQuery(query);
						while (seLineRs.next())
						{
							lines += seLineRs.getInt(1)+"-"+seLineRs.getInt(2);
							if (seLineRs.isLast() == false)
								lines += ";";
						}
						if (seLineRs != null) {
							seLineRs.close();							
						}
						if (stmt != null) {
							stmt.close();							
						}
						/* if (lines.equals("") == false)
							classLinksHtml += "<a style=\"float:left;\" href='javascript:showClassTab(\""+curClass+"\",\""+lines+"\")"+"'>"+" "+curClass+" "+"</a>"; */  
					}
%>
						<tr id='<%=count+"Row"%>'>
							<td class = 'formfieldlight'><%=count+1%> </td>
							<td><input type=checkbox onclick='disableEnableFormElements("<%=c%>","<%=question%>","<%=lines%>",<%=count%>);' checked='checked' id='<%=count+"Selected"%>' name='<%=count+"Selected"%>' align="left"></td>
							<td class = 'formfieldlight' id ='<%=count+"hRef"%>'><a href='javascript:showClassTab("<%=question%>","<%=lines%>")'><%=c%></a>&nbsp;&nbsp;</td>
<%
					query = "select weight,direction from ent_jexample_concept where title ='"+title+"'"+" and concept = '"+c+"'"; 
					weightDirectionRs = statement.executeQuery(query);
					String direction = "";
					String weight = "";
					while(weightDirectionRs.next()) {
						weight = weightDirectionRs.getString(1);
						direction = weightDirectionRs.getString(2);	
					}
%>		
							<td class="hidden">
		 						<select id='<%=count+"Weight"%>' name = '<%=count+"Weight"%>'>
<% 
					String selected = "";  
					if (weight != null) {
						selected = weight;							
					} else {
						selected = Const.RELATED_WEIGHT;
					}
					
					for (String s : Const.WEIGHTS) {
						String tempPrint = selected.equals(s) ? "selected" : "";
						out.println("<option value=\""+s+"\""+tempPrint+">"+s+"</option>");
					}
%>
		 						</select>&nbsp;&nbsp;&nbsp;
		 					</td>
							<td>
								<select id='<%=count+"Direction"%>' name='<%=count+"Direction"%>'>
<%
					if (direction.equals("prerequisite")) {
%>
						    		<option value='0' selected>Prerequisite</option>
						    		<option value='1'>Outcome</option>
						    		<option value='2'>Unknown</option>
<%
					} else if (direction.equals("outcome")) {
%>
					      	 		<option value='0'>Prerequisite</option>	      
					         		<option value='1' selected>Outcome</option>
					         		<option value='2'>Unknown</option>
<%
					} else {
%>
					      	 		<option value='0'>Prerequisite</option>	      
					         		<option value='1'>Outcome</option>
					         		<option value='2' selected>Unknown</option>
<%
					}
%>
					      		</select>
					      	</td>		      
					      	<td>
					      		<img src="images/edit.png" id = '<%=count %>editImg' concept = '<%=c%>' question='<%=question%>' fn = 'edit' style="cursor: pointer;">
					      	</td>	      
					      	<td>
					      		<img src="images/delete.png" id = '<%=count %>deleteImg' concept = '<%=c%>' question='<%=question%>' fn = 'delete'  style="cursor: pointer;">
					      	</td>
					     </tr>
<% 
					count++;
				}	
%>
	</table>
	</div>
<%
				for (int i = 0; i < concepts.size(); i++) {
%>
						<input type="hidden" name='<%=i+"Concept"%>' id='<%=i+"Concept"%>' value='<%=concepts.get(i)%>'>	      
<%
				}
%>
					    <input type="hidden" name="conceptCount" id = "conceptCount" value="<%=concepts.size()%>">	
					    <a class="btn btn-default" onclick="showModal();" >Add More Concepts</a>
    
<!-- Modal Add Concept -->
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
        <h4 class="modal-title" id="myModalLabel">Add Concept</h4>
      </div>
      <div class="modal-body">
		<div class="form-horizontal">
			<div class="form-group">
				<label class="col-sm-3 control-label">Concept</label>
	    		<div class="col-sm-9">
    				<select id = 'addConceptList' name = "addConceptList" onchange="enableAddRow(<%=allClass.size()%>)" class="form-control">
<% 
			    List<String> totalConcepts = getOntologyConcepts(tempDomain);
			    for (String c : concepts) {
			    	totalConcepts.remove(c);    	
			    }
			    Collections.sort(totalConcepts);
				out.println("<option value='-1'>Please select the concept</option>");
			    for (String c: totalConcepts) {
%>
						<option value='<%=c%>'><%=c%></option>
<%
				}
%>
    				</select>
    			</div>
    		</div>
<%
				String tableHtml = "";

				for (int j = 0; j < allClass.size(); j++) {
					tableHtml += "<div class=\"form-group\">"+
					"<label class=\"col-sm-3 control-label\" style=\"color: grey;\" id = \""+j+"AddRow\" name = \""+j+"AddRow\">Start-end lines:</label><div class=\"col-sm-9\">"+
					"<input type=checkbox checked disabled id='"+j+"AddRowSelected' name='"+j+"AddRowSelected' onchange = \"disableEnableAddRowLine("+j+");\" class=\"hidden\">"+
					"<input type=\"text\" id = '"+j+"AddRowLines' name = '"+j+"AddRowLines' disabled fn = 'lines'\" class=\"form-control\"><span class=\"help-block\">start-end lines example: 1-3;5-5</span></div></div>";
				}
%>
    <%=tableHtml %>
<%
    			for (int i = 0; i < allClass.size(); i++) {
%>
	    	<input type="hidden" name="<%=i+"AddConceptClass"%>" id="<%=i+"AddConceptClass"%>" value="<%=allClass.get(i)%>">	      
<%
				}
%>
	  		<input type="hidden" id='questionClassCount' value='<%=allClass.size()%>'>	      
	    	<input type="hidden" id='question' value='<%=question%>'>
		</div>
		<div id="addAlert" class="alert alert-danger" role="alert">Input should be list of hyphenated digits separated by ;</div>
      </div>
      <div class="modal-footer">
        <input type="button"  name ="addBtn" id ="addBtn" value="Add" disabled="disabled" class="btn btn-default">
        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>    
    
    
			<input type="button" name = "saveBtn" id = "saveBtn" value="Save" class="btn btn-default pull-right">
		</form>	
	
	</div>
</div>

	
<script>
	var lineCount=<%=classLine%>;
</script>

<%
	
			}
		}catch (Exception e) {
			e.printStackTrace();
			if (!response.isCommitted()) {
				response.sendRedirect("servletResponse.jsp");
				return;
			}
		} finally {
			try {		
				if (classRs != null)
					classRs.close();
				if (conceptRs != null)
					conceptRs.close();
				if (weightDirectionRs != null)
					weightDirectionRs.close();
				if (statement != null)
					statement.close();
				disconnectFromDB(conn); //here connection is closed
			} catch (Exception e) {
				disconnectFromDB(conn); //here connection is closed
				e.printStackTrace();
			}
		} 		
			
	}	
}
%>

<!-- Modal -->
<div class="modal fade" id="myModal2" tabindex="-1" role="dialog" aria-labelledby="myModalLabel2" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
        <h4 class="modal-title" id="myModalLabel2"></h4>
      </div>
      <div class="modal-body">
      </div>
      <div class="modal-footer">
      </div>
    </div>
  </div>
</div>    

<%!
	public Connection getConnectionToWebex21() {
		Connection conn = null;
		try {
			Class.forName(this.getServletContext().getInitParameter("db.driver"));
			conn = DriverManager.getConnection(this.getServletContext().getInitParameter("db.webexURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
		}catch (Exception e) {
			e.printStackTrace();
		}
		return conn;
	}
 
	 public List<String> getOntologyConcepts(String tempDomain) {
		 List<String> ontoConcepts = new ArrayList<String>();
		 Connection conn = null;
		 PreparedStatement pstmt = null;
		 ResultSet rs = null;
		try {
			Class.forName(this.getServletContext().getInitParameter("db.driver"));
			conn = DriverManager.getConnection(this.getServletContext().getInitParameter("db.um2"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
			
			String sqlCommand = null;
			if (tempDomain.equals("java")) {
				sqlCommand = " SELECT e.Title FROM ent_concept e, rel_domain_concept r, ent_domain d" +
	  					 " WHERE r.ConceptID = e.ConceptID AND d.DomainID = r.DomainID AND d.id=\""+tempDomain+"\";";
			} else {
				sqlCommand = " SELECT e.Title FROM ent_concept e, rel_domain_concept r, ent_domain d" +
			   					 " WHERE e.ConceptID IN" +
								 " (SELECT ChildConceptID FROM rel_concept_concept WHERE ChildConceptID NOT IN (SELECT distinct ParentConceptID FROM rel_concept_concept)) AND r.ConceptID = e.ConceptID AND d.DomainID = r.DomainID AND d.id=\""+tempDomain+"\";";
			   /*String sqlCommand = " SELECT Title FROM ent_concept" +
	  					 " WHERE ConceptID IN" +
					 " (SELECT ChildConceptID FROM rel_concept_concept WHERE ChildConceptID NOT IN (SELECT distinct ParentConceptID FROM rel_concept_concept))"; */
			}


			pstmt = conn.prepareStatement(sqlCommand);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				ontoConcepts.add(rs.getString(1));
			}			 
		}catch (Exception e) {
			e.printStackTrace();
		}			
		return ontoConcepts;
	}
 
 	public boolean isConnectedToDB(Connection conn) {		
		try {
			if (conn != null && (conn.isClosed() == false)) 
				return true;								
					
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return false;		
	} 
 
	public void disconnectFromDB(Connection conn) {
		try {
			if (conn != null && (conn.isClosed() == false)) {
				conn.close();
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}		
	}
 %>

<%@ include file = "include/htmlbottom.jsp" %>  