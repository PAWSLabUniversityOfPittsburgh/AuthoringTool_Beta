<%@ page language="java" %>
<%@ include file = "include/htmltop.jsp" %>
<%@ include file = "include/connectDB.jsp" %>

<%@ page import="java.sql.*" %>
<%@page import="java.io.*"%>
<%@page import="java.net.URL"%>

<%
    Connection conn2 = null;
   
    ResultSet rs1 = null;
    Statement stmts = null;
    ResultSetMetaData rsmds = null;   	
   
    String sc="";       	
    Class.forName(this.getServletContext().getInitParameter("db.driver"));
    conn2 = DriverManager.getConnection(this.getServletContext().getInitParameter("db.webexURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
    
     try {
        stmts = conn2.createStatement();
        rs1 = stmts.executeQuery("SELECT * FROM ent_class");        
     }
     catch (SQLException e) {
         System.out.println("Error occurred " + e);
     }

%>

<script language="javascript">
	function send_iswriting(e){
	     var key = -1 ;
	     var shift ;
	     key = e.keyCode ;
	     shift = e.shiftKey ;
		if ( !shift && ( key == 13 ) ) {
	          document.form.reset() ;
	     }
	}
</script>
<link rel="stylesheet" href="<%=request.getContextPath()%>/js/themes/base/jquery-ui.css" />
<script src="<%=request.getContextPath()%>/js/jquery-1.9.1.js"></script>
<script src="<%=request.getContextPath()%>/js/ui/jquery-ui.js"></script>
<script src="<%=request.getContextPath()%>/js/ajaxfileupload.js"></script>

<script type="text/javascript">
function ajaxFileUpload() {      
    /*
        prepareing ajax file upload
        url: the url of script file handling the uploaded files
                    fileElementId: the file type of input element id and it will be the index of  $_FILES Array()
        dataType: it support json, xml
        secureuri:use secure protocol
        success: call back function when the ajax complete
        error: callback function when the ajax failed
        
    */
    $.ajaxFileUpload
    (
        {
            url:'single_upload_page2.jsp', 
            secureuri:false,
            fileElementId:'fileToUpload',
            dataType: 'json',
            success: function (data, status)
            {
                if(typeof(data.error) != 'undefined')
                {
                    if(data.error != '')
                    {
                        alert(data.error);
                    }else
                    {
                        alert(data.filename);
                        addItemToList(data.filename,data.fileid);
                    }
                }
                alert("e");
            },
            error: function (data, status, e)
            {
                alert(e);
            }
        }
    );
    return false;
} 

function addItemToList(filename,fileid){
	var content = $( "#class-file-list" ).html();
	var added = "<input type=\"checkbox\" class=\"import-classes-list-item\" name=\"import-classes\" value=\""+fileid+"\">" +
				"<input type=\"hidden\" id=\""+fileid+"\" name=\""+fileid+"\" value=\""+filename+"\">" +
				"<a class=\"import-classes-list-item\" href='http://adapt2.sis.pitt.edu/quizjet/class/"+filename+"' target='_blank'>"+filename+"</a><br />";	  		  	

	$( "#class-file-list" ).html(added+content);
	return false;
}

$(document).ready(function(){

	$("input").click(function () {
		var fn = $(this).attr('fn');
		if (fn == 'createQuiz') {
			var title1 = document.fr1.title1.value;	
			if(title1 == "") {
				alertMessage("Title cannot be empty!");
				return false;
			} else if (!document.fr1.privacy1[0].checked && !document.fr1.privacy1[1].checked) {
				alertMessage("Please select the privacy.");
				return false;
			} else if (title1!="" && (document.fr1.privacy1[0].checked || document.fr1.privacy1[1].checked) && i==1) {
				$("#fr1").submit();
				return true;
			}
		} else if (fn == 'createQuestion') {
		    var quizval = document.getElementById("quiz").value;
		    var title2 = document.fr2.title2.value;	
   		    title2 = title2.replace(/\s+/g, '');

			var quizcode = document.fr2.quizcode.value;	
			var tmpCode =quizcode;	
			tmpCode = tmpCode.replace(/\s+/g, '');

			var minvar = document.fr2.minvar.value;	
			var maxvar = document.fr2.maxvar.value;	
			var rdf = document.fr2.rdfID.value;
			var tmpRdf = rdf;
			tmpRdf = tmpRdf.replace(/\s+/g, '');
			if (quizval== "-1") {
				alertMessage("Please select topic for the question.");
				return false;
			} else if (title2 == "") {
				alertMessage("Title cannot be empty!");
				return false;
			} else if (tmpRdf == "") {
				alertMessage("RDF ID cannot be empty!");
				return false;
			} else if (tmpCode == "") {
				alertMessage("Code cannot be empty!");
				return false;
			} else if(minvar == "") {
				alertMessage("Minimum Variable cannot be empty!");
				return false;
			} else if(maxvar == "" || (maxvar.match(/^\d+$/)==false)) {
				if (maxvar == "") {
					alertMessage("Maximum Variable cannot be empty!");
					return false;
				}
			} else if (!document.fr2.privacy2[0].checked && !document.fr2.privacy2[1].checked) {
				alertMessage("Please select the privacy.");
				return false;
			} else if (isNaN(minvar)) {
				alertMessage("Minimum Variable should be an integer.");
				return false;
			} else if (isNaN(maxvar)) {
				alertMessage("Maximum Variable should be an integerr.");
				return false;
			} else {
				 var invalid = false;
    			 for (var index in rdfs) {
    				 if (rdfs[index] ==rdf) {
    					 invalid = true;    					 
    				 }
    			 }
    			 if (invalid) {
    				 alertMessage("RDF ID already exists. Please enter another value.");
    				 return false;    				 
    			 } else {   				 	
    				 var mydata = { code:quizcode, 'importclasses' : $("#imported-classes-label").html(), minvar:minvar};
    				 $.post("CompileCodeServlet",mydata,function(data) {
   				    	 var err = data.message;

   				    	 if (err != '') {
   				    		 alertMessage("Code cannot be compiled due to following errors:\n"+err);   
   				    		return false;
   				    	 } else {  
   				    		$("#fr2").submit();//submit those in a form
   				    		return true;
   				         }
					}, "json");    				    	 	   
	    		}
			}
		}
	});
});	
	    				 

	function selectedClasses() {
		var classesstr = "";
		var classesvals = "";
		var classlabel = "";
		$('input[name="import-classes"]:checked').each(function() {
			classesstr += " " + $('#'+this.value).val();
			classesvals += " " + this.value;
			classlabel += "<li>"+$('#'+this.value).val()+"</li>";
		});
/* 	          $("#imported-classes-label").html(classesstr); */
		$("#imported-classes-label").html("<ul style=\"margin-top:5px;\">"+classlabel+"</ul>");
		$("#import-classes-vals").val(classesvals);
		$("#import-classes-names").val(classesstr);
	}
	
	$("#add-file-button").click(function (){
		var content = $( "#class-file-list" ).html();
		var added = "new class<br />";
		$( "#class-file-list" ).html(added+content);
		return false;
	});
	

/* 	$("#import-classes-button").click(function () {
		$( "#import-classes-dialog" ).dialog("open");
	}); */
	
	function function3(obj,i) { 	
		if (i==1) {
			window.open('classcombo.jsp','_blank');
		}
	}
</script>

<%
	stmt = conn.createStatement();
	String command = "select rdfID from ent_jquiz;";
	ResultSet rs = stmt.executeQuery(command);
	ArrayList<String> rdfList = new ArrayList<String>();
	while (rs.next()) {
		rdfList.add(rs.getString(1));
	}
%>

<script>
	var rdfs = new Array();
	<%for (String rdf : rdfList){%>
	     rdfs.push("<%=rdf%>");
	<%}%>
	
	function clearForm() {
		$("html, body").animate({ scrollTop: 0 }, "slow");
		document.form.message.focus();
	}
	
	function alertMessage (text) {
		$("#alertMessage").hide().html('<div class="alert alert-danger alert-dismissible" role="alert">'+
				'<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>'+
				text+'</div>').fadeIn('slow');
		$("html, body").animate({ scrollTop: 0 }, "slow");
	}
	
	function showModal() {
		$('#myModal').modal('show');
	}
	function closeModal() {
		$('#myModal').modal('hide');
	}
	function okModal() {
		selectedClasses();
		$('#myModal').modal('hide');
	}
</script>

<%
     String uid = "";
     Statement statement = conn.createStatement();
     rs = statement.executeQuery("SELECT id FROM ent_user where name = '"+userBeanName+"' ");
     while(rs.next()) {
    	 uid = rs.getString(1);
	 }
 %>
 
<h3>Create Java Question:</h3>
<hr>
 
<form class="form-horizontal" role="form" name="fr2" id  ="fr2"  method="post" action = "javaq_create_save2.jsp">
	<div id="alertMessage"></div>
	<input type="hidden" name="import-classes-vals" id="import-classes-vals" value="" />
	<input type="hidden" name="import-classes-names" id="import-classes-names" value="" />
 	<div class="form-group">
    	<label for="quiz" class="col-sm-3 control-label">Topic:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<select name="quiz" id = "quiz" class="form-control">
<%
				statement = conn.createStatement();
				out.write("<option value='-1' selected>Please select the topic</option>");
				
				rs = statement.executeQuery("SELECT q.QuestionID,q.Title,q.Privacy,q.authorid FROM ent_jquestion q where (q.Privacy = '1' or q.authorid = "+uid+") order by q.title");
				String imgHtml;
				while(rs.next()) {
					if (rs.getString(4).equals(uid))
						imgHtml = "style=\"background-color:#A9A9D5\" title = \"You are the owner of this quiz\"";
					else
						imgHtml = "";
					out.write("<option value='"+rs.getString(1)+"'"+imgHtml+">"+rs.getString(2)+"</option>");
				}							
%>	
	    	</select>
	    </div>
	</div>
	<div class="form-group">
	    <label for="title2" class="col-sm-3 control-label">Title:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<input type="text" name="title2" size="45" maxlength="45" class="form-control"/>
	    </div>
	</div>
	<div class="form-group">
	    <label for="rdfID" class="col-sm-3 control-label">RDF ID:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<input type="text" name="rdfID" size="45" maxlength="45" class="form-control"/>
	    </div>
	</div>
	<div class="form-group">
	    <label for="description2" class="col-sm-3 control-label">Description:</label>
	    <div class="col-sm-9">
			<textarea  name="description2" cols="80" rows="3" class="form-control"></textarea>
	    </div>
	</div>
	<div class="form-group">
    	<label for="questiontype" class="col-sm-3 control-label">Assessment Type:</label>
	    <div class="col-sm-9">
	    	<select name="questiontype" onChange="Javascript:type_change();" class="form-control">
				<option value="1">final value</option>
				<option value="2">output</option>
	    	</select>
	    </div>
	</div>
	<div class="form-group">
	    <div class="col-sm-offset-3 col-sm-9">
	    	<a class="btn btn-default" onclick="showModal();" >Import Classes</a>
		    <div id="imported-classes-label" class=""></div>
	    </div>
	</div>
	<div class="form-group">
	    <label for="quizcode" class="col-sm-3 control-label">Code:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
			<textarea cols="80" rows="10" name="quizcode" class="form-control"></textarea>
	    </div>
	</div>
	<div class="form-group">
	    <label for="minvar" class="col-sm-3 control-label">Minimum:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<input type="text" name="minvar" size="4" maxlength="4" class="form-control" />
	    </div>
	</div>
	<div class="form-group">
	    <label for="maxvar" class="col-sm-3 control-label">Maximum:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<input type="text" name="maxvar" size="4" maxlength="4" class="form-control" />
	    </div>
	</div>
	<div class="form-group">
    	<label for="anstype" class="col-sm-3 control-label">Answer Type:</label>
	    <div class="col-sm-9">
	    	<select name="anstype" class="form-control">
				<option value="0"></option>
				<option value="3">int</option>
				<option value="5">float</option>
				<option value="7">String</option>
				<option value="8">double</option>
	    	</select>
	    </div>
	</div>
	<div class="form-group">
    	<label for="privacy2" class="col-sm-3 control-label">Privacy:<span style="color: red;"> *</span></label>
	    <div class="col-sm-9">
	    	<label class="radio-inline">
				<input type="radio" name="privacy2" value="private">Private
			</label>
			<label class="radio-inline">
				<input type="radio" name="privacy2" value="public" checked>Public
			</label>
	    </div>
	</div>
	<div class="form-group">
	    <div class="col-sm-offset-3 col-sm-9">
	    	<input type="button" value="Create" fn = 'createQuestion' class="btn btn-default"/>
	    	<input type="reset" value="Clear" onclick="clearForm();" class="btn btn-default"/>
	    	<a href="authoring.jsp?type=quiz" class="btn btn-default pull-right">Cancel</a>
	    </div>
	</div>
</form>


<!-- Modal -->
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
        <h4 class="modal-title" id="myModalLabel">Import Classes</h4>
      </div>
      <div class="modal-body">
      	<div class="row">
	      	<div class="col-sm-12 col-md-6">
				<h4>Select classes:</h4>
				<div id="class-file-list">
<%
					int colcount=0;
					int totalcount=0;
					while(rs1.next()) {
						//hy:
						String className = rs1.getString("ClassName");
					    String realClassName = className.replaceAll("\\s+", "");
					    //TODO: check in detail: make sure the classname is legal by java, and standard by our definition
					    if (realClassName.length() == 0 || realClassName.equals("") || realClassName.equals("\"\"") || realClassName.equals("''"))
					    	continue;
						colcount++;
						if (false) {
							if (colcount==4){
								//input-classes-cell is the new style defined in stylesheets/authoring.css
								out.write("<div class=\"input-classes-cell\"><input type=\"checkbox\" name=\"import-classes\" value=\""+rs1.getString("ClassID")+"\">");
								out.write("<input type=\"hidden\" id=\""+rs1.getString("ClassID")+"\" name=\""+rs1.getString("ClassID")+"\" value=\""+rs1.getString("ClassName")+"\">");
								out.write("<a href='http://adapt2.sis.pitt.edu/quizjet/class/"+rs1.getString("ClassName")+"' target='_blank'>"+rs1.getString("ClassName")+"</a>&nbsp;&nbsp;");	  	
								out.write("<a href='http://adapt2.sis.pitt.edu/quizjet/class/"+rs1.getString("ClassTester")+"' target='_blank'></a></div>");
								colcount=0;
							}else{
								out.write("<div class=\"input-classes-cell\"><input type=\"checkbox\" name=\"import-classes\" value=\""+rs1.getString("ClassID")+"\">");
								out.write("<input type=\"hidden\" id=\""+rs1.getString("ClassID")+"\" name=\""+rs1.getString("ClassID")+"\" value=\""+rs1.getString("ClassName")+"\">");
								out.write("<a href='http://adapt2.sis.pitt.edu/quizjet/class/"+rs1.getString("ClassName")+"' target='_blank'>"+rs1.getString("ClassName")+"</a>&nbsp;&nbsp;");	  		  	
								out.write("<a href='http://adapt2.sis.pitt.edu/quizjet/class/"+rs1.getString("ClassTester")+"' target='_blank'></a></div>");
							}
						}
						out.write("<div><input type=\"checkbox\" class=\"import-classes-list-item\" name=\"import-classes\" value=\""+rs1.getString("ClassID")+"\">&nbsp;&nbsp;&nbsp;");
						out.write("<input type=\"hidden\" id=\""+rs1.getString("ClassID")+"\" name=\""+rs1.getString("ClassID")+"\" value=\""+rs1.getString("ClassName")+"\">");
						out.write("<a class=\"import-classes-list-item\" href='http://adapt2.sis.pitt.edu/quizjet/class/"+rs1.getString("ClassName")+"' target='_blank'>"+rs1.getString("ClassName")+"</a></div>");	  		  	
						
						totalcount++;
					}				  
%>
				</div>
			</div>
			<div class="col-sm-12 col-md-6">
				<h4>Upload classes:</h4>
				<input id="fileToUpload" type="file" size="45" name="fileToUpload" class="input" /><br />
				<button class="btn btn-default" onclick="ajaxFileUpload();">Upload</button>
			</div>
		</div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" onclick="okModal();">OK</button>
        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>

<%@ include file = "include/htmlbottom.jsp" %>