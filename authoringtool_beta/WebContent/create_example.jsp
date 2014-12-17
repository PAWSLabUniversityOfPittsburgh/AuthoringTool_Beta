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
			var topicTemp = document.getElementById("topic").value;
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
			var scopeTemp = document.getElementById("scope").value;
			var domain = $('#scope option:selected').attr('domain');
			$("#alertMessage").html('');
			$('#topicSelector').remove();
			if (scopeTemp != "-1") {
				$.get("CreateExampleServlet?domain="+domain, function() {})
			    .done(function(data) {
			    	var foundSomething = false;
			        for(var i=0; i<data.length; ++i) {
			            if(data[i] !== null) foundSomething = true;
			            break;
			        }
			        if(foundSomething) {
			        	$('#scopeSelector').after(data);
			        }else{
			        	alertMessage("Sorry, you cannot create example for this scope, because there are no topicts associated with the domain it belongs to.<br/>Would you like to create <a href=\"jquiz_create.jsp\">new topic<a/>?");
			        }
			    })
			    .fail(function() {
			    	alertMessage("Something went wrong while we were accessing topics list");
			    });
			}
		}
	
		function alertMessage (text) {
			$("#alertMessage").hide().html('<div class="alert alert-danger alert-dismissible" role="alert">'+
					'<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>'+
					text+'</div>').fadeIn('slow');
			$("html, body").animate({ scrollTop: 0 }, "slow");
		}
		
		
		function createCommentsHtml () {
			var text = $("#code").val();   
			var linesTemp = text.split(/\r|\r\n|\n/);
			var foundSomething = false;
	        for(var i=0; i<linesTemp.length; ++i) {
	            if(linesTemp[i] !== null && linesTemp[i].length > 0)
	            	foundSomething = true;
	            break;
	        }
	        if(foundSomething) {
	        	$('#codeLabel').html('Code / Comments:<span style="color: red;"> *</span>');
				$('#codeComments').html('');
				mobileView = "";
				notFirstButton = false;	
				htmlString = '<ul class="list-group" id="codeCommentLines">';
				
				for (i=0; i<linesTemp.length; i++) {
					mobileView = (i > 0) ? " hidden-md hidden-lg": "";
				      htmlString += '<li class="list-group-item">'+
					  		'<div class="form-inline">'+
								'<div class="form-group">'+
					  				'<p class="help-block'+mobileView+'">Code:</p>'+
									'<textarea class="form-control" rows="2" cols="65" >'+linesTemp[i]+'</textarea>'+
				            	'</div>'+
					            '<div class="form-group">'+
					            	'<p class="help-block'+mobileView+'">Comment:</p>'+
									'<textarea class="form-control" rows="2" cols="65" onKeyDown="textCounter(this);"></textarea>'+
								'</div>'+
					            '<div class="form-group">'+
					            	'<p class="help-block'+mobileView+'">Characters left:</p>'+
									'<input readonly class="form-control" type="text" size="4" value="2048" />'+
								'</div>'+
					  			'<div class="form-group">'+ 
					  			((notFirstButton) ? '<img src="images/trash.jpg" onclick="deleteLine(this);" title="Delete this line" style="margin-right: 10px;"/>' : '')+
 									'<img src="images/add-icon.png" onclick="addLine(this);" title="Add line bellow this line" />'+
				            	'</div>'+	
							'</div>'+
						'</li>';	     
				      notFirstButton = true;
				}

				htmlString += '</ul>';
				$('#codeFormGroup').remove();
				$('#center').html(htmlString);
				$('#bottom').html('<button class="btn btn-default" onclick="create();">Create</button>'+
				    	'<a href="authoring.jsp?type=example" class="btn btn-default pull-right">Cancel</a>');
	        }else{
	        	alertMessage("Cannot add comments, because code field is empty");
	        }
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
	String command = "SELECT rdfID FROM ent_dissection;";
	ResultSet rs = stmt.executeQuery(command);
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

<h3>Create example:</h3>
<hr>
<div class="form-horizontal" role="form" id = "eform" name = "create_example">
	<div id="alertMessage"></div>
	<div class="form-group" id="scopeSelector">
		<label for="scope" class="col-sm-3 control-label">Scope:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<select class="form-control" onchange="changeScope();" name="scope" id="scope">
	    		<option value = "-1" selected>Please select the scope</option>
<%

					command = "SELECT * FROM ent_scope s, rel_scope_privacy sp WHERE sp.ScopeID = s.ScopeID AND (sp.privacy = 1 or sp.Uid = "+uid+")";
					result1 = stmt.executeQuery(command);
					
					while(result1.next()) {
						if (result1.getString(3).equals("0")) {
							out.write("<option class = 'private' bgcolor='#FCF4BD' title = 'This scope is private' value = '"+result1.getString(1)+"' domain='"+result1.getString(5)+"'>"+result1.getString(3)+"</option>");
						} else {
							out.write("<option value = '"+result1.getString(1)+"' domain='"+result1.getString(5)+"' >"+result1.getString(3)+"</option>");	  	
						}	   		
					} 
%>
	    	</select>
	    </div>
	</div>
	<div class="form-group">
	    <label for="title" class="col-sm-3 control-label">Title:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<input type="text" name="title" maxlength="45" class="form-control" id="title" />
	    </div>
	</div>
	<div class="form-group">
	    <label for="rdfID" class="col-sm-3 control-label">RDF ID:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<input type="text" name="rdfID" id="rdfID" class="form-control">
	    </div>
	</div>
	<div class="form-group">
	    <label for="chapter" class="col-sm-3 control-label">Description:</label>
	    <div class="col-sm-9">
			<textarea  name="chapter" id="description" cols="70" rows="3" class="form-control"></textarea>
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
	<div class="form-group" id="codeFormGroup">
	    <label for="textarea1" class="col-sm-3 control-label" id="codeLabel">Code:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9" id="codeComments">
			<textarea name="textarea1"  id="code" cols="75" rows="15" class="form-control lined"></textarea>
			<br/><button class="btn btn-default" onclick="createCommentsHtml();">Add comments</button>
	    </div>
	</div>
</div>
<div id="center"></div>
<div class="form-horizontal" id="bottom">
	<hr/>
	<div class="form-group">
	    <div class="col-sm-offset-3 col-sm-9">
	    	<button class="btn btn-default" onclick="create();">Create</button>
	    	<a href="authoring.jsp?type=example" class="btn btn-default pull-right">Cancel</a>
	    </div>
	</div>
</div>

<script src="js/jquery-linedtextarea.js"></script>
<link href="stylesheets/jquery-linedtextarea.css" type="text/css" rel="stylesheet" />
<script>
	$(function() {
		$(".lined").linedtextarea();
	});
</script>

<%@ include file = "include/htmlbottom.jsp" %>