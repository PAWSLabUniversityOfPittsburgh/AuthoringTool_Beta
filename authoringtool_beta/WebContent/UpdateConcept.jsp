<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>	
<%@ page import="java.util.Collections" %>

<script type="text/javascript" language="javascript">
	function apply() {
		var input = $('input[fn=lines2]').val();
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
			$('#addAlert2').fadeIn(500);
			$('input[fn=lines2]').focus();
		 } else {
    		var count = document.getElementById("questionClassCount2").value;
            var array = new Array();
            array.push(document.getElementById("questionClassCount2"));
            for (var i = 0; i < count; i++) {
				var selected = document.getElementById(i+"RowSelected2");
				var lines = document.getElementById(i+"RowLines2");
				var className = document.getElementById(i+"ConceptClass2");
           	   
				if (selected.checked) {
					array.push(selected);
					array.push(lines);
					array.push(className);
				} else 
					array.push(className);
			}
            
            $.post("UpdateConcept?question=<%=request.getParameter("question")%>&concept=<%=request.getParameter("concept")%>&type=<%=request.getParameter("type")%>" ,array,function() {})
            .success(function() {
            	var domain = $( "#scope option:selected" ).attr('domain');
		    	var exampleID = $('select[name="example"]').val();
		    	var exampleTitle = $('select[name="example"] option:selected').text();
		    	$.post("ExampleConceptUmUpdate?exampleID="+exampleID+"&domain="+domain+"&exampleTitle="+exampleTitle, function() {}).always(function() {
	            	editSuccess("<%=request.getParameter("concept")%>");
		    	});
            }).error(function() {
            	editFailed("<%=request.getParameter("concept")%>");
		    }).complete(function() {});				 
		 }
	}	
    
    function disableEnableRowLine(line) {
        var select = document.getElementById(line+"RowSelected2");
  	    var lineText = document.getElementById(line+"RowLines2");
	    var row =  document.getElementById(line+'Row2');

        if (select.checked == false) {
			lineText.disabled = true;
			row.style.color = "gray";
		} else {
			lineText.disabled = false;
			row.style.color = "black";
      	}
	}	 
</script>

 <% 
    String question = request.getParameter("question");
    String concept = request.getParameter("concept");
    String type = request.getParameter("type");
    boolean isExample = false;
    if (type != null) {
    	if (type.equals("example"))
    		isExample = true;    		
    }
    ArrayList<String> classList = new ArrayList<String>();
    
    Connection conn = null;
    String query = "";    
    int quizId = -1;
    Statement statement = null;
    try {    	   	 
		Class.forName(this.getServletContext().getInitParameter("db.driver"));
		conn = DriverManager.getConnection(this.getServletContext().getInitParameter("db.webexURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
        statement = conn.createStatement();  

    	if(isExample)
    		classList.add(question);
    		
		else {
            //if the concept is null, it means the check box of the concept
    		//	is not selected by user and this concept should be removed since it 
    		//	has been previously stored in db by ParserServlet

        	query = "select QuizID from ent_jquiz where  Title = '"+question+"'";      
            ResultSet quizRs = statement.executeQuery(query);
              
            while (quizRs.next()) {
                quizId = quizRs.getInt(1);
            }
                    
            query = "select c.ClassName from ent_class c, rel_quiz_class r where c.ClassID = r.ClassID and r.QuizID= '"+quizId+"' ";      
            ResultSet  classRs = statement.executeQuery(query);  
            String className =  "";

            while (classRs.next()) {  
            	className = classRs.getString(1);
            	if (className.substring(0,1).equals("0") |
            		className.substring(0,1).equals("1"))
            		className = className.substring(2,className.length()); 
            	classList.add(className);
            }      
            classList.add("Tester.java"); // this class always exists and is not in the query result
		}
		
        Collections.sort(classList);
    
 %>
 <div style = "border-style:solid;border-width:1px; border-color:rgb(238, 238, 238);padding: 10px">
    <table width="100%" id ="editTable">    
    <tr><td style = "padding-bottom:10px;" colspan="3">
  <b><%=question%>: <%=concept %> </b>
    
    </td></tr>   
    <tr><td></td><td></td><td style="font-style:italic;color: gray;padding-left: 10px">start-end lines example: 1-3;5-5</td></tr>
    
      <% 
		String lines = "";
		boolean exists = false;
		ResultSet rs;
		String className;
		String table = "ent_jquiz_concept";
		if (isExample)
			table = "ent_jexample_concept";
		for (int j = 0; j < classList.size(); j++) {
			className = classList.get(j);
			lines = "";
			exists = false;
			if (isExample == false)
				query = "select class from "+table+" where title = '"+ question + "' and class = '"+className+"' and concept = '"+concept+"'";
			else
				query = "select class from "+table+" where title = '"+ question + "' and concept = '"+concept+"'";
			rs = statement.executeQuery(query);
			if (rs.next())
				exists = true;
	
			if (exists) {
				if (isExample = false)
					query = "select sline,eline from "+table+" where title = '"+ question + "' and class = '"+className+"' and concept = '"+concept+"' and sline != -1 and eline !=-1";
				else
					query = "select sline,eline from "+table+" where title = '"+ question + "' and concept = '"+concept+"' and sline != -1 and eline !=-1";
				rs = statement.executeQuery(query);
				while (rs.next()) {
					lines += rs.getInt(1)+"-"+rs.getInt(2);
					if (rs.isLast() == false)
						lines += ";";
				}
			}
	  %>	  
      <tr id = '<%=j%>Row2'  <%=(exists?"":"style=\"color:gray\"")%>>
      <td><input type=checkbox id='<%=j %>RowSelected2' name='<%=j %>RowSelected2' align="left" onchange = "disableEnableRowLine(<%=j %>);" <%=(exists?"checked":"")%>></td>
      <td > <%=className %></td>
      <td style = "padding-left:10px" >start-end lines: <input type="text" id = '<%=j%>RowLines2' name = '<%=j%>RowLines2' <%=(exists?"":"disabled")%> value='<%=lines%>' fn = 'lines2'></td>
      </tr>
<%
		}
%>    
    </table>
    <input type="hidden" id='questionClassCount2' name='questionClassCount2' value='<%=classList.size()%>'>	      
<%
		for (int i = 0; i < classList.size(); i++) {
%>
			    <input type="hidden" name='<%=i+"ConceptClass2"%>' id='<%=i+"ConceptClass2"%>' value='<%=classList.get(i)%>'>	      
<%
		}
	}catch(SQLException e) {
	   e.printStackTrace();    	
	} finally {
		try {   						
			if (statement != null)
				statement.close();
			try {
				if (conn != null && (conn.isClosed() == false)) {
					conn.close();
				}
			} catch (SQLException e) {
				e.printStackTrace();
			}
			
		} catch (Exception e) {
			if (conn != null && (conn.isClosed() == false)) {
				conn.close();
			}
			e.printStackTrace();
		}
	}
%>
    </div>
<div id="addAlert2" class="alert alert-danger" role="alert">Input should be list of hyphenated digits separated by ;</div>