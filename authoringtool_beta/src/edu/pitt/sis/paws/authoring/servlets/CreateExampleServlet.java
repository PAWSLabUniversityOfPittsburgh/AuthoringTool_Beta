package edu.pitt.sis.paws.authoring.servlets;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.net.URL;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashSet;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;

import edu.pitt.sis.paws.authoring.beans.UserBean;

/**
 * Servlet implementation class CreateExample
 */
public class CreateExampleServlet extends AbstractServlet {
	private static final long serialVersionUID = 1L;
       
	public void init(ServletConfig config) throws ServletException {
        super.init(config);
    }
	
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		this.session = request.getSession();
		UserBean uBean = (UserBean) this.session.getAttribute("userBean");
		String domain = request.getParameter("domain");
		
		if (uBean == null || domain == null || domain.length()<1) {
			return;
		}
		
		PrintWriter out = response.getWriter();
		ResultSet rs = null;
		Connection connection = null;
		Statement stmt = null;
		try {
			connection = DriverManager.getConnection(this.getServletContext().getInitParameter("db.webexURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
			stmt = connection.createStatement();
			
			String output = "";
			output += "<div class=\"form-group\" id=\"topicSelector\">"+
								"<label for=\"topic\" class=\"col-sm-3 control-label\">Topic:<span style=\"color: red;\"> *</span></label>"+
								"<div class=\"col-sm-9\">"+
									"<select name=\"topic\" id=\"topic\" class=\"form-control\">"+
										"<option value=\"-1\" selected>Please select the topic</option>";
			
			rs = stmt.executeQuery("SELECT q.QuestionID,q.Title,q.Privacy,q.authorid FROM ent_jquestion q WHERE (q.Privacy = '1' OR q.authorid = "+uBean.getId()+") AND q.domain = \""+domain+"\" order by q.title");
			String imgHtml;
			rs.last();
			int count = rs.getRow();
			if (count < 1) {
				try {
					if (rs != null) {
						rs.close();
					}
					if (stmt != null) {
						stmt.close();
					}
					if (connection != null) {
						connection.close();
					}
				} catch (SQLException e) {
					e.printStackTrace();
				}
				return;
			}
			rs.beforeFirst();
			while(rs.next()) {
				imgHtml = (rs.getString(4).equals(uBean.getId())) ? "style=\"background-color:#A9A9D5\" title = \"You are the owner of this quiz\"": "";
				output += "<option value='"+rs.getString(1)+"'"+imgHtml+">"+rs.getString(2)+"</option>";
			}				
			output += "</select>"+
						"</div>"+
					"</div>";
			out.println(output);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (rs != null) {
					rs.close();
				}
				if (stmt != null) {
					stmt.close();
				}
				if (connection != null) {
					connection.close();
				}
			} catch (SQLException e) {
				e.printStackTrace();
			} 
		}
	}
	
	
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		this.session = request.getSession();
		
		String commentUpdate = request.getParameter("commentUpdate");
		if (commentUpdate != null && commentUpdate.equals("true")) {
			updateComments(request, response);
			return;
		}
		
		Connection connection = null;
		Statement statement = null;
		Connection connection2 = null;
		Statement statement2 = null;
		Connection connection3 = null;
		Statement statement3 = null;
		PreparedStatement statement4 = null;
		ResultSet resultd = null;
		try {
			PrintWriter out = response.getWriter();

			UserBean uBean = (UserBean) this.session.getAttribute("userBean"); 
			String tempScope = request.getParameter("scope");
			String tempDomain = request.getParameter("domain");
			String tempTopic = request.getParameter("topic");
			String tempTitle = request.getParameter("title");
			String tempRdfID = request.getParameter("rdfID");
			tempRdfID = tempRdfID.replaceAll("\\s+","");
			String tempPrivacy = request.getParameter("privacy");
			String tempDescription = request.getParameter("description");
			tempDescription = (tempDescription == null) ? "" : tempDescription;
			String tempLines = request.getParameter("lines");
			
			if (uBean == null || tempScope == null || tempScope.length()<1 || tempTopic == null || tempTopic.length()<1 || tempTitle == null || tempTitle.length()<1 
					|| tempRdfID == null || tempRdfID.length()<1 || tempPrivacy == null || tempPrivacy.length()<1 || tempLines == null || tempLines.length()<1 || tempDomain == null || tempDomain.length()<1) {
				out.println("false");
			} else {

				Class.forName(this.getServletContext().getInitParameter("db.driver"));
				connection = DriverManager.getConnection(this.getServletContext().getInitParameter("db.webexURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
				
				statement = connection.createStatement();
				tempTitle = tempTitle.replace("'","\\'");	
				tempDescription = (tempDescription.length()>=255) ? tempDescription.substring(0,254) : tempDescription;
				
				String command3 = "INSERT INTO ent_dissection (rdfID,Name, Description, domain) VALUES ('"+tempRdfID+"','"+tempTitle+"','"+tempDescription+"', '"+tempDomain+"')";
				statement.executeUpdate(command3); 
				
				String MaxID ="";
				resultd = statement.executeQuery("SELECT MAX(DissectionID) AS LastID FROM ent_dissection WHERE rdfID='"+tempRdfID+"';");        
				while(resultd.next()) {
					MaxID = resultd.getString(1);		
				}	
				int Max = Integer.parseInt(MaxID);
						
				String command2 = "INSERT INTO rel_scope_dissection (ScopeID,DissectionID) VALUES ( '"+tempScope+"','" +(Max)+ "')";         
				statement.executeUpdate(command2);  
			
				String uid="";
				ResultSet rs = null;  
				rs = statement.executeQuery("SELECT id FROM ent_user where name = '"+uBean.getName()+"' ");
				while(rs.next()) {
					uid=rs.getString(1);  	
				}  
					
				if (tempPrivacy.equals("Private")){
					String command4 = "INSERT INTO rel_dissection_privacy (DissectionID, Uid, Privacy) VALUES ('"+(Max)+"','"+uid+"','0') ";			
					statement.executeUpdate(command4);                        	    	      		
				}else {
			 		String command4 = "INSERT INTO rel_dissection_privacy (DissectionID, Uid, Privacy) VALUES ('"+(Max)+"','"+uid+"','1') ";			
					statement.executeUpdate(command4);                        	    	      		
				}
			
				String command5 = "INSERT INTO rel_topic_dissection (topicID,DissectionID) VALUES ('"+tempTopic+"','"+Max+"') ";			
				statement.executeUpdate(command5);
				
				
				connection3 = DriverManager.getConnection(this.getServletContext().getInitParameter("db.um2"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
				statement3 = connection3.createStatement();
				statement3.executeUpdate("INSERT INTO ent_activity (AppID, URI, Activity, Description, DateNTime) VALUES (3, 'http://adapt2.sis.pitt.edu/webex/webex.rdf#"+tempRdfID+"', '"+tempRdfID+"', 'Automatic Addition', NOW());", Statement.RETURN_GENERATED_KEYS);
				Integer exampleID = null;
				rs = statement3.getGeneratedKeys();
				if (rs.next()) {
			    	exampleID = rs.getInt(1);
			    }
			    
				statement3.executeUpdate("INSERT INTO ent_activity (AppID, URI, Activity, Description, DateNTime) VALUES (3,'no uri', 0, 'Automatic Addition', NOW());", Statement.RETURN_GENERATED_KEYS);
				Integer lineZeroID = null;
				rs = statement3.getGeneratedKeys();
				if (rs.next()) {
					lineZeroID = rs.getInt(1);
			    }
				
				statement3.executeUpdate("INSERT INTO rel_activity_activity (ParentActivityID, ChildActivityID, AppID, DateNTime) VALUES ("+exampleID+", "+lineZeroID+", 3, NOW());");
						
				ArrayList<Integer> childrenLinesIDs = new ArrayList<Integer>();
				
				JSONArray jsonArray = new JSONArray(tempLines); 
				for(int i=0 ; i< jsonArray.length(); i++){
					JSONObject jsonObject = jsonArray.getJSONObject(i);
					String lineNum = jsonObject.getString("lineNumber");
					String code = jsonObject.getString("code");
					String comment = jsonObject.getString("comment");
					
					statement4 = connection.prepareStatement("INSERT INTO ent_line (Code, LineIndex,DissectionID,Comment) VALUES (?, ?, ?, ?);");
					statement4.setString(1, code);
					statement4.setString(2, lineNum);
					statement4.setInt(3, Max);
					statement4.setString(4, comment);
					statement4.executeUpdate();
					
					if (comment.trim().length()>0) {
						statement3.executeUpdate("INSERT INTO ent_activity (AppID, URI, Activity, Description, DateNTime) VALUES (3,'no uri', "+lineNum+", 'Automatic Addition', NOW());", Statement.RETURN_GENERATED_KEYS);
						Integer currentLineID = null;
						rs = statement3.getGeneratedKeys();
						if (rs.next()) {
							currentLineID = rs.getInt(1);
					    }
						childrenLinesIDs.add(currentLineID);
					}
				}
				
				if (childrenLinesIDs.size()>0) {
					for (Integer z: childrenLinesIDs) {
						statement3.executeUpdate("INSERT INTO rel_activity_activity (ParentActivityID, ChildActivityID, AppID, DateNTime) VALUES ("+exampleID+", "+z+", 3, NOW());");
					}
				}
				
				/*
				* Adding record to Aggregate DB
				*/
				ResultSet tmpRs = null;
				tmpRs = statement.executeQuery("SELECT login FROM ent_user where name = '"+uBean.getName()+"' ");
				String login = "";
				while(tmpRs.next()) {
				 login=tmpRs.getString(1);  	
				}
				
				connection2 = DriverManager.getConnection(this.getServletContext().getInitParameter("db.aggregateURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
				statement2 = connection2.createStatement();
				String pri = tempPrivacy.equals("Private")?"private":"public";
				String c2 ="INSERT INTO ent_content (content_name,content_type,display_name,`desc`,url,domain,provider_id,visible,creation_date,creator_id,privacy,comment) VALUES "+
				        "('"+tempRdfID+"','example','"+tempTitle+"','"+tempDescription+"','http://adapt2.sis.pitt.edu/webex/Dissection2?act="+tempRdfID+"&svc=progvis','"+tempDomain+"','webex','1', NOW(),'"+login+"','"+pri+"','')";
				statement2.executeUpdate(c2);
				
				String domain = null; 
				rs = statement.executeQuery("SELECT domain FROM ent_scope WHERE ScopeID = '"+tempScope+"' ");
				while(rs.next()) {
					domain=rs.getString(1);
				}
				
				
				if (domain != null && domain.equalsIgnoreCase("java")) {
					StringBuffer url = request.getRequestURL();
					String uri = request.getRequestURI();
					String ctx = request.getContextPath();
					String base = url.substring(0, url.length() - uri.length() + ctx.length()) + "/";
					
					URL url2 = new URL(base+"ParserServlet?sc="+tempScope+"&question="+Max+"&type=example&load=javaExampleSaved.jsp");
					InputStream is = url2.openStream();
					try {	
					} finally {
					  is.close();
					}
					
					HashSet<Integer> conceptsIDs = new HashSet<Integer>();
					rs = statement.executeQuery("SELECT concept FROM ent_jexample_concept WHERE dissectionID = "+Max+";");
					while(rs.next()) {
						tmpRs = statement3.executeQuery("SELECT ConceptID FROM ent_concept WHERE Title = '"+rs.getString(1)+"' AND Description = 'java ontology v2';");
						while(tmpRs.next()) {
							conceptsIDs.add(tmpRs.getInt(1));					
						}
					}
					
					if (conceptsIDs.size()>0) {
						for (Integer z: conceptsIDs) {
							statement3.executeUpdate("INSERT INTO rel_concept_activity VALUES ("+z+", "+exampleID+", 1, 1,  NOW());");
						}
					}			
				}
				
				out.println("true");
			}
		} catch (Exception e) {
            e.printStackTrace();
            try {
            	PrintWriter out = response.getWriter();
            	out.println("false");
            } catch (Exception e2) {}
        } finally {    	
        	try {
        		if (connection != null) {
        			connection.close();        			
        		}
        		if (statement != null) {       			
        			statement.close();
        		}
        		if (connection2 != null) {       			
        			connection2.close();
        		}
        		if (statement2 != null) {       			
        			statement2.close();
        		}
        		if (connection3 != null) {       			
        			connection3.close();
        		}
        		if (statement3 != null) {       			
        			statement3.close();
        		}
        		if (statement4 != null) {       			
        			statement4.close();
        		}
        		if (resultd != null) {       			
        			resultd.close();
        		}
			} catch (SQLException e) {
				e.printStackTrace();
			}
        }
	}

	private void updateComments(HttpServletRequest request, HttpServletResponse response) {
		Connection connection = null;
		Statement statement = null;
		Connection connection2 = null;
		Statement statement2 = null;
		PreparedStatement sprSatement = null;
		try {
			PrintWriter out = response.getWriter();

			UserBean uBean = (UserBean) this.session.getAttribute("userBean"); 
			String tempDissectionID = request.getParameter("dissectionID");
			String tempDescription = request.getParameter("description");
			String tempTitle =  request.getParameter("title");
			String tempPrivacy = request.getParameter("privacy");
			String tempLines = request.getParameter("lines");
			String rdfID = request.getParameter("rdfID");
			
			if (uBean == null || tempDissectionID == null || tempDissectionID.length()<1 || tempLines == null || tempLines.length()<1) {
				out.println("false");
			} else {
				Class.forName(this.getServletContext().getInitParameter("db.driver"));
				connection = DriverManager.getConnection(this.getServletContext().getInitParameter("db.webexURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));			
				statement = connection.createStatement();
				
				if (tempDescription != null && !tempDescription.equals("null")) {
					tempDescription = (tempDescription.length()>=255) ? tempDescription.substring(0,254) : tempDescription;
					
					String command = "UPDATE ent_dissection SET Description = '"+tempDescription+"' WHERE DissectionID = "+tempDissectionID+";";
					statement.executeUpdate(command); 					
				}
				
				if (tempTitle.length() > 0) {
					tempTitle = (tempTitle.length()>=255) ? tempTitle.substring(0,254) : tempTitle;
					
					String command = "UPDATE ent_dissection SET Name = '"+tempTitle+"' WHERE DissectionID = "+tempDissectionID+";";
					statement.executeUpdate(command); 					
				}
				
				if (tempPrivacy != null && !tempPrivacy.equals("null") && rdfID != null && rdfID.length() > 0 && (tempPrivacy.equals("0") || tempPrivacy.equals("1"))) {
					String command = "UPDATE rel_dissection_privacy SET Privacy = "+tempPrivacy+" WHERE DissectionID = "+tempDissectionID+";";
					statement.executeUpdate(command);
					
					/*
					 * Update record in Aggregate DB
					 */
					connection2 = DriverManager.getConnection(this.getServletContext().getInitParameter("db.aggregateURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
					statement2 = connection2.createStatement();
					String pri = tempPrivacy.equals("0")?"private":"public";
					String c2 = "UPDATE ent_content SET privacy = '"+pri+"' WHERE content_name = '"+rdfID+"';";
					statement2.executeUpdate(c2);			
				}

				JSONArray jsonArray = new JSONArray(tempLines); 
				for(int i=0 ; i< jsonArray.length(); i++){
					JSONObject jsonObject = jsonArray.getJSONObject(i);
					String lineNum = jsonObject.getString("lineNumber");
					String comment = jsonObject.getString("comment");
					System.out.println(lineNum);
					System.out.println(comment);
					
					sprSatement = connection.prepareStatement("UPDATE ent_line SET Comment = ? WHERE DissectionID = ? AND LineIndex = ? ;");
					sprSatement.setString(1, comment);
					sprSatement.setString(2, tempDissectionID);
					sprSatement.setString(3, lineNum);
					sprSatement.executeUpdate();				
				}
						
				out.println("true");
			}
		} catch (Exception e) {
            e.printStackTrace();
            try {
            	PrintWriter out = response.getWriter();
            	out.println("false");
            } catch (Exception e2) {}
        } finally {    	
        	try {
        		if (connection != null) {
        			connection.close();        			
        		}
        		if (statement != null) {       			
        			statement.close();
        		}
        		if (connection2 != null) {       			
        			connection2.close();
        		}
        		if (statement2 != null) {       			
        			statement2.close();
        		}
        		if (sprSatement != null) {       			
        			sprSatement.close();
        		}
			} catch (SQLException e) {
				e.printStackTrace();
			}
        }
	}

}
