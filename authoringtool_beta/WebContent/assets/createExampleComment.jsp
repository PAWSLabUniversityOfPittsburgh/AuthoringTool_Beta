<%@ page language="java" %>
<%@ include file = "../include/htmltop.jsp" %> //!!!!!
<%@ page import = "java.text.*" %>
<%@ page import = "java.lang.*" %>
<%@ page import="java.sql.*" %>

<script type="text/javascript">
	function rtrim(StringToTrim){
		return StringToTrim.replace(/\s+$/,"");
	}
	
	function textCounter (field,cntfield,maxlimit) {
		if (field.value.length > maxlimit) {// if too long...trim it!
			field.value = field.value.substring(0, maxlimit);
		} else {
			cntfield.value = maxlimit - field.value.length;			// otherwise, update 'characters left' counter
		}
	}
</script>

<h3>Please write down the comments for each line of the code and then click the save button</h3>
<form role="form" name="myForm" method="post" action="savecomment.jsp">
	<ul class="list-group">
	        	
<%
	ResultSet resultd = null;
	Connection connection = null;

	try {
		Class.forName(this.getServletContext().getInitParameter("db.driver"));
		connection = DriverManager.getConnection(this.getServletContext().getInitParameter("db.webexURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
		
		Statement statement = connection.createStatement();
		
		String text1 = request.getParameter("title");  	
		text1 = text1.replace("'","\\'");	
	
		String topic = request.getParameter("topic");
		String text2 = request.getParameter("chapter");	
		String text5 = request.getParameter("rdfID"); 
	
		int text3_0 = 12;
		
		String text4="";
		int text2index = text2.lastIndexOf("text2");
		if (text2index>=255) {
			text4 = text2.substring(0,254);		
			text4=text4.replace("'","\\'");	 
		}else{
			 text4=text2;
			 text4=text4.replace("'","\\'");	 
		}
		
		String command3 = "INSERT INTO ent_dissection (rdfID,Name, Description) VALUES ('"+text5+"','"+text1+"','"+text2+"')";
		statement.executeUpdate(command3); 
		
		String MaxID ="";
		resultd = statement.executeQuery("SELECT MAX(DissectionID) AS LastID FROM ent_dissection WHERE rdfID='"+text5+"';");        
		while(resultd.next()) {
			MaxID = resultd.getString(1);		
		}	
		int Max = Integer.parseInt(MaxID);
				
		String command2 = "INSERT INTO rel_scope_dissection (ScopeID,DissectionID) VALUES ( '"+(text3_0)+"','" +(Max)+ "')";         
		statement.executeUpdate(command2);  
	
		String uid="";
		ResultSet rs = null;  
		rs = statement.executeQuery("SELECT id FROM ent_user where name = '"+userBeanName+"' ");
		while(rs.next()) {
			uid=rs.getString(1);  	
		}  
		
		String privacy = request.getParameter("privacy");	
		if (privacy.equals("Private")){
			String command4 = "insert into rel_dissection_privacy (DissectionID, Uid, Privacy) values ('"+(Max)+"','"+uid+"','0') ";			
			statement.executeUpdate(command4);                        	    	      		
		}else {
	 		String command4 = "insert into rel_dissection_privacy (DissectionID, Uid, Privacy) values ('"+(Max)+"','"+uid+"','1') ";			
			statement.executeUpdate(command4);                        	    	      		
		}
	
		String command5 = "insert into rel_topic_dissection (topicID,DissectionID) values ('"+topic+"','"+Max+"') ";			
		statement.executeUpdate(command5);
		
		/*
		* Adding record to Agregate DB
		*/
		ResultSet tmpRs = null;
		tmpRs = statement.executeQuery("SELECT login FROM ent_user where name = '"+userBeanName+"' ");
		String login = "";
		while(tmpRs.next()) {
		 login=tmpRs.getString(1);  	
		}
		Connection connection2 = null;
		Statement statement2 = null;
		
		try {
			connection2 = DriverManager.getConnection(this.getServletContext().getInitParameter("db.aggregateURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
			statement2 = connection2.createStatement();
			String pri = privacy.equals("Private")?"private":"public";
			String c2 ="insert into ent_content (content_name,content_type,display_name,`desc`,url,domain,provider_id,visible,creation_date,creator_id,privacy,comment) values "+
			        "('"+text5+"','example','"+text1+"','"+text2+"','http://adapt2.sis.pitt.edu/webex/Dissection2?act="+text5+"&svc=progvis','java','webex','1', NOW(),'"+login+"','"+pri+"','')";
			statement2.executeUpdate(c2);
		} catch (Exception e1) {
			e1.printStackTrace();
			throw new Exception("Exception: Couldn't add record to agregate DB");
		} finally {
			if (statement2 != null)
				statement2.close();
			
			if (connection2 != null)
				connection2.close();
		}
	
		String text = request.getParameter("textarea1");  
		String Message = "";        
		int msgLength = text.length();
		int Position = 0;
		int count = 0;
	    
		int cnt=0;
		String mobileView = "";
		String hiddenClass = "";
		text=text+"\n";
		while (true) {
			cnt++;
			mobileView = (cnt > 1) ? " hidden-md hidden-lg": "";
			
			int index = text.indexOf('\n', Position);
			if (index == -1) {
				break;
			}
			
			if (index > Position) {
				Message = text.substring(Position, index);  
				Message = Message.replace("'","\\'");	    	    	
			}
			   
			String command = "INSERT INTO ent_line (Code, LineIndex,DissectionID,Comment) VALUES ( '" +Message+ "' , '"+(count+1)+"','" +(Max)+ "','')";
			statement.executeUpdate(command);                        	    	      
	
			Position = index + 1;
			count = count + 1;
			hiddenClass = (Message != null && Message.trim().length() > 0) ? "" : " hidden";
%>
		<li class="list-group-item<%= hiddenClass %>">
	  		<div class="form-inline">
	  			<div class="form-group">
	  				<p class="help-block<%= mobileView %>">Line:</p>
					<textarea class="form-control" rows="2" cols="60" readonly><%= Message %></textarea>
            	</div>
	            <div class="form-group">
	            	<p class="help-block<%= mobileView %>">Comment:</p>
					<textarea class="form-control" name="C<%=count%>" wrap="physical" cols="60" rows="2" onKeyDown="textCounter(this.form.C<%=count%>,this.form.remLen<%=count%>,2048);" onKeyUp="textCounter(this.form.C<%=count%>,this.form.remLen<%=count%>,2048);" ></textarea>
	            </div>
	            <div class="form-group">
	            	<p class="help-block<%= mobileView %>">Characters left:</p>
					<textarea class="form-control" readonly rows="2"  name="remLen<%=count%>" >2048</textarea>
				</div>
			</div>
		</li>
<%      
		}
%>
 
	</ul>
	<div class="form-group">
	    	<input type="Submit" value="Save" class="btn btn-default">
	        <input type = "hidden" name = "sc" value = "<%=text3_0%>">
	        <input type = "hidden" name = "ex" value = "<%=Max%>">
	</div>
</form>

<%
	} catch (Exception e) {
		e.printStackTrace();
		response.sendRedirect("servletResponse.jsp");
	} finally {
		if (resultd != null)
			resultd.close();
		
		if (connection != null)
			connection.close();
	}
%>        

<%@ include file = "../include/htmlbottom.jsp" %>   