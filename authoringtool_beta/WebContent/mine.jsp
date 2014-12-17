<%@ page language="java" %>
<%@ include file = "include/htmltop.jsp" %>
<%@ include file = "include/connectDB.jsp" %>

<h3>My Examples:</h3>
<hr>
<div class="row hidden-xs hidden-sm">
  <div class="col-md-1">Preview</div>
  <div class="col-md-3">Title</div>
  <div class="col-md-2">RDF ID</div>
  <div class="col-md-3">Description</div>
  <div class="col-md-3">Privacy</div>
  <hr>
</div>

 <%
     String uid = "";
     ResultSet rs = null;  
     Statement statement = conn.createStatement();
     rs = statement.executeQuery("SELECT id FROM ent_user where name = '"+userBeanName+"' ");
     while(rs.next())
	 {
    	 uid = rs.getString(1);
	 }
     String des = "";
	 rs = statement.executeQuery("SELECT distinct d.DissectionID,d.Name,d.Description,dp.Uid,dp.Privacy,s.Name,s.ScopeID,sp.Privacy,d.rdfID FROM rel_dissection_privacy dp, ent_dissection d, ent_user u,ent_scope s,rel_scope_dissection sd, rel_scope_privacy sp where dp.DissectionID=d.DissectionID and u.name = '"+userBeanName+"' and u.id = dp.Uid and sd.DissectionID=d.DissectionID and s.ScopeID=sd.ScopeID and sp.ScopeID=s.ScopeID order by d.name");
	 while(rs.next())
	  {
	  	/* out.write("<div class=\"row\" style=\"margin-bottom: 5px;\"><a href=\""+request.getContextPath()+"/displayA1.jsp?sc="+rs.getString(7)+"&dis="+rs.getString(1)+"&uid="+uid+"\">"); */
	  	out.write("<div class=\"row\" style=\"margin-bottom: 5px;\">");
	  	out.write("<div class=\"col-xs-2 col-md-1\" style=\"margin-bottom: 5px;\"><a href='http://adapt2.sis.pitt.edu/webex/Dissection2?act="+rs.getString(9)+"' target='_blank'><img src='images/preview.jpg' width='20' height='20' border='0' /></a></div>");	
	  	des = rs.getString(3);
	  	if (des == null)
	  		des = "";
	  	%>
	  	<div class="col-xs-10 col-md-3" style="margin-bottom: 5px;"><a href="<%=request.getContextPath()%>/displayA1.jsp?sc=<%=rs.getString(7)%>&dis=<%=rs.getString(1)%>&uid=<%=uid%>"><%=rs.getString(2)%></a></div>				
	  	<%
	  	out.write("<div class=\"col-xs-12 col-md-2\" style=\"margin-bottom: 5px;\">"+rs.getString(9)+"</div>");
	  	out.write("<div class=\"col-xs-12 col-md-3\" style=\"margin-bottom: 5px;\">"+des+"</div>");
		
		if (rs.getString(5).equals("1")){
	  		out.write("<div class=\"col-xs-12 col-md-3\" style=\"margin-bottom: 5px;\"><input type=radio name=privacy"+rs.getString(1)+" value=Private disabled>&nbsp;&nbsp;Private&nbsp;&nbsp;<input type=radio name=privacy"+rs.getString(1)+" value=Public checked >&nbsp;&nbsp;Public&nbsp;&nbsp;</div>");				
	  	}else{
	  		out.write("<div class=\"col-xs-12 col-md-3\" style=\"margin-bottom: 5px;\"><input type=radio name=privacy"+rs.getString(1)+" value=Private checked>&nbsp;&nbsp;Private&nbsp;&nbsp;<input type=radio name=privacy"+rs.getString(1)+" value=Public disabled>&nbsp;&nbsp;Public&nbsp;&nbsp;</div>");							
	  	}
		out.write("</div><hr class=\"hidden-md hidden-lg\">");
	  }
            
%>                  

</body> 
</html>

<%@ include file = "include/htmlbottom.jsp" %>