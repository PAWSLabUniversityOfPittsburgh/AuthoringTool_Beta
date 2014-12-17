package edu.pitt.sis.paws.authoring.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashSet;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import edu.pitt.sis.paws.authoring.beans.UserBean;

public class ExampleConceptUmUpdate extends AbstractServlet {
	private static final long serialVersionUID = 1L;
       
	public void init(ServletConfig config) throws ServletException {
        super.init(config);
    }
	
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		this.session = request.getSession();

		Connection connection = null;
		Statement statement = null;
		Connection connection2 = null;
		Statement statement2 = null;
		ResultSet resultd = null;
		ResultSet tmpRs = null;
		try {
			UserBean uBean = (UserBean) this.session.getAttribute("userBean"); 
			String tempDomain = request.getParameter("domain");
			String dissectionID = request.getParameter("exampleID");
			String dissectionTitle = request.getParameter("exampleTitle");
			
			if (uBean == null || dissectionID == null || dissectionID.length()<1 || tempDomain == null || !tempDomain.equals("java") || dissectionTitle == null || dissectionTitle.length()<1) {
			} else {
				Class.forName(this.getServletContext().getInitParameter("db.driver"));
				connection = DriverManager.getConnection(this.getServletContext().getInitParameter("db.webexURL"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));				
				statement = connection.createStatement();
				ResultSet rs = null;
				rs = statement.executeQuery("SELECT rdfID FROM ent_dissection WHERE DissectionID = "+dissectionID+";");
				if (rs.next()) {
					dissectionTitle = rs.getString("rdfID");

					int webEx21DissectionID = Integer.parseInt(dissectionID);
					
					connection2 = DriverManager.getConnection(this.getServletContext().getInitParameter("db.um2"),this.getServletContext().getInitParameter("db.user"),this.getServletContext().getInitParameter("db.passwd"));
					statement2 = connection2.createStatement();
					
					rs = statement2.executeQuery("SELECT ActivityID FROM ent_activity WHERE Activity = '"+dissectionTitle+"';");
					Integer um2ActivityID = null;
					if (rs.next()) {
						um2ActivityID = rs.getInt("ActivityID");
					
						HashSet<Integer> conceptsIDs = new HashSet<Integer>();
						rs = statement.executeQuery("SELECT concept FROM ent_jexample_concept WHERE dissectionID = "+webEx21DissectionID+";");
						while(rs.next()) {
							tmpRs = statement2.executeQuery("SELECT ConceptID FROM ent_concept WHERE Title = '"+rs.getString(1)+"' AND ConceptID IN (SELECT r.ConceptID FROM rel_domain_concept r, ent_domain e WHERE r.DomainID = e.DomainID AND e.id = '"+tempDomain+"');");
							while(tmpRs.next()) {
								conceptsIDs.add(tmpRs.getInt(1));					
							}
						}
						
						if (conceptsIDs.size()>0) {
							statement2.executeUpdate("DELETE FROM rel_concept_activity WHERE ActivityID = '"+um2ActivityID+"';");
							for (Integer z: conceptsIDs) {
								if (z != null) {
									statement2.executeUpdate("INSERT INTO rel_concept_activity VALUES ("+z+", "+um2ActivityID+", 1, 1,  NOW());");							
								}
							}
						}		
					}					
			    }
			}
		} catch (Exception e) {
            e.printStackTrace();
        } finally {    	
        	try {
        		if (resultd != null) {       			
        			resultd.close();
        		}
        		if (tmpRs != null) {       			
        			tmpRs.close();
        		}
        		if (statement != null) {       			
        			statement.close();
        		}
        		if (connection != null) {
        			connection.close();        			
        		}
        		if (statement2 != null) {       			
        			statement2.close();
        		}
        		if (connection2 != null) {       			
        			connection2.close();
        		}
			} catch (SQLException e) {
				e.printStackTrace();
			}
        }
	}
}
