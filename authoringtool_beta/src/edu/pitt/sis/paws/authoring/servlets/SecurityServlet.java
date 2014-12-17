/*
 * Date  : May, 15, 2006
 * Author(s): Sergey Sosnovsky, Girish Chavan
 * Email : sas15@pitt.edu
 */
package edu.pitt.sis.paws.authoring.servlets;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import edu.pitt.sis.paws.authoring.beans.*;
import edu.pitt.sis.paws.authoring.data.Const;
import edu.pitt.sis.paws.authoring.data.PasswordHash;
import edu.pitt.sis.paws.authoring.mail.MailServices;
import edu.pitt.sis.paws.utils.SqlUtil;

import java.security.SecureRandom;
import java.sql.*;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.ListIterator;
import java.util.Random;
import java.util.Set;
import java.util.Vector;




/**
 * 
 * Checks login. Loads userBean with details about user. 
 * 
 * Valid Requests 
 * --------------
 * LOGIN
 * LOGOUT
 * MODIFYUSERINFO
 * SWITCHGROUP
 * 
 * GETADDUSERLIST
 * GETDELETEUSERLIST
 * CREATEGROUP 
 * MODIFYGROUP
 * DELETEGROUP
 * ADDUSERTOGROUP
 * REMOVEUSERFROMGROUP
 * MODIFYUSERRIGHTS
 * 
 * CREATEUSER
 * MODIFYUSER
 * DELETEUSER
 * --------------
 */

@SuppressWarnings("serial")
public class SecurityServlet extends AbstractServlet {
    
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
    }

	public void service(HttpServletRequest req, HttpServletResponse res) {
		
        this.action = req.getParameter(Const.REQ_PARAM_ACT);
        this.session = req.getSession();
        try {
            String dbdrv = this.context.getInitParameter(Const.CON_PARAM_DB_DRIVER);
            String dburl = this.context.getInitParameter(Const.CON_PARAM_WEBEX21_URL);            
            String dbuser = this.context.getInitParameter(Const.CON_PARAM_DB_USER);
            String dbpass = this.context.getInitParameter(Const.CON_PARAM_DB_PASSWORD);
            if (dbdrv == null || dburl == null || dbuser == null || dbpass == null) {
                throw new Exception("db initialization failed: loadData(" +                        
                           "driver = " + dbdrv + ", url = " + dburl +
                           ", user = " + dbuser + ", dbpass = " + dbpass);
            }
            this.dbConn = SqlUtil.getConnection(dbdrv, dburl, dbuser, dbpass);
            // Inherited method to initialize connection to database
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }

		try {
            /********************************************************************/
            /************************ USER's ACTIONS ****************************/    
            /********************************************************************/ 
			if (this.action.equalsIgnoreCase("LOGIN")) {
                if (checkLogin(req))
                	res.sendRedirect(res.encodeRedirectURL(req.getContextPath()+"/authoring.jsp"));
//                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath()+"/home.jsp"));
                else 
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath()+"/index.html?" +
                            Const.REQ_PARAM_ACT + "=LOGINFAILED"));               
			} 
            else if (this.action.equalsIgnoreCase("LOGOUT")) {
				req.getSession().invalidate();
				res.sendRedirect(res.encodeRedirectURL(req.getContextPath()+"/index.html?" +
                            Const.REQ_PARAM_ACT + "=LOGGEDOUT"));                
            } 
            else if (this.action.equalsIgnoreCase("MODIFYUSERINFO")) {
            	//argument changed by @roya
                if (modifyUserInfo(req,res))
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() + "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=MODIFYUSERINFOOK"));                 
                else {
                	if (!res.isCommitted()) {
        				res.sendRedirect(res.encodeRedirectURL(req.getContextPath() + "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=MODIFYUSERINFOFAILED"));            
        				return;
        			}
                }
            }
            else if (this.action.equalsIgnoreCase("MODIFYUSERINFO_ADMIN")) {
            	modifyUserInfoTemp(req,res);
            }
            else if (this.action.equalsIgnoreCase("RECOVER_PASSWORD")) {
                recoverPassword(req,res);
            }
            else if (this.action.equalsIgnoreCase("RESET_PASSWORD")) {
                resetPassword(req,res);
            } 
            else if (this.action.equalsIgnoreCase("SWITCHGROUP")) {
                switchGroup();
//Sharon 2007
/*		if (this.session.getAttribute("userBean", uBean) == "example_test")
		res.sendRedirect(res.encodeRedirectURL(req.getContextPath() + "/example_home.jsp"));
		else
		*/
                res.sendRedirect(res.encodeRedirectURL(req.getContextPath() + "/home.jsp"));
            }
            /********************************************************************/
            /************************ SUPERUSER's ACTIONS ***********************/    
            /********************************************************************/        
                
            else if (this.action.equalsIgnoreCase("CREATEGROUP")) {
                if (createGroup(req))
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                             "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=CREATEGROUPOK"));
                else {
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                                     "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=CREATEGROUPFAILED"));
                }
            } 
            else if (this.action.equalsIgnoreCase("MODIFYGROUP")) {
                if (modifyGroup())
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                             "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=MODIFYGROUPOK"));
                else {
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                                     "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=MODIFYGROUPFAILED"));
                }
            }
            else if (this.action.equalsIgnoreCase("DELETEGROUP")) {
                if (deleteGroup())
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                             "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=DELETEGROUPOK"));
                else {
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                                     "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=DELETEGROUPFAILED"));
                }
            }
            
			else if (this.action.equalsIgnoreCase("GETADDUSERLIST")) {
				if (getUserList())
				    res.sendRedirect(res.encodeRedirectURL(req.getContextPath()	+ "/addUser.jsp"));
                else
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                            "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=GETADDUSERLISTFAILED"));
			} 
            else if (this.action.equalsIgnoreCase("GETDELETEUSERLIST")) {
				if (getUserList())
					res.sendRedirect(res.encodeRedirectURL(req.getContextPath() + "/deleteuserlist.jsp"));
//				    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() + "/deleteUser.jsp"));
                else
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                            "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=GETDELETEUSERLISTFAILED"));                
			} 
            else if (this.action.equalsIgnoreCase("MODIFYUSERRIGHTS")) {
                if (modifyUsersRights())
                       res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                                "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=MODIFYUSERRIGHTSOK"));
                else {
                   res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                                    "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=MODIFYUSERRIGHTSF"));
                }
            }
            
            else if (this.action.equalsIgnoreCase("ADDUSERSTOGROUP")) {
                if (addUSersToGroup())
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() + 
                            "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=ADDUSERSTOGROUPOK"));
                else
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                            "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=ADDUSERSTOGROUPFAILED"));
            }
            
            else if (this.action.equalsIgnoreCase("REMOVEUSERSFROMGROUP")) {
                if (removeUsersFromGroup())
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() + 
                            "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=REMOVEUSERSFROMGROUPOK"));
                else
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                            "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=REMOVEUSERSFROMGROUPFAILED"));
            }
            /********************************************************************/
            /************************ ADMIN's ACTIONS ***************************/    
            /********************************************************************/              
            else if (this.action.equalsIgnoreCase("CREATEUSER")) {
				if (createUser(req))
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() + 
                            "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=CREATEUSEROK"));
				else 
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                             "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=CREATEUSERFAILED"));
			}
            else if (this.action.equalsIgnoreCase("CREATEUSER_TEMP")) {
				if (createUserTemp(req))
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() + 
                            "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=CREATEUSEROK"));
				else 
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                             "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=CREATEUSERFAILED"));
			}
            else if (this.action.equalsIgnoreCase("CHECKLOG")) {
				checkLog(req, res);
			}
            else if (this.action.equalsIgnoreCase("DELETEUSER")) {
                if (deleteUser())
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() + 
                                     "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=DELETEUSEROK"));
                else
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                            "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=DELETEUSERFAILED"));                
			} else if (this.action.equalsIgnoreCase("MODIFYUSER")) {
				if (modifyUser())
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                             "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=MODIFYUSEROK"));
				else 
                    res.sendRedirect(res.encodeRedirectURL(req.getContextPath() +
                             "/servletResponse.jsp?" + Const.REQ_PARAM_ACT + "=MODIFYUSERFAILED"));
                
			}            
            else
                res.sendError(HttpServletResponse.SC_BAD_REQUEST,
                        "This Security Action is not defined");
		} catch (Exception e) {
			System.out.println("[Authoring] service(): Exception while trying to redirect");
			e.printStackTrace();
		}
    }
/********************************************************************/
/************************ USER's ACTIONS ****************************/    
/********************************************************************/    
    /**
     * checkLogin(HttpServletRequest): checks if the user with the given login and password exists in the DB
     * retreives his data and stores in the userBean attribute in the session
     * It also retrieves the list of all groups from the DB, where user participates and
     *  assignes current group to a user and puts the entire list to the groupList attribute of the session
     * For every group it retreive all its users and their rights and puts it toi the users member of GroupBean     
     * @param req - containes two parameters "login" and "password"   
     * @return true if the user was successfuly retrieved from the DB, false if an error occured
     */ 
    boolean checkLogin(HttpServletRequest req) {

        UserBean uBean = new UserBean();
        Vector<GroupBean> groupList = new Vector<GroupBean>();
        GroupBean teacherGBean = new GroupBean();

        String login = req.getParameter("login");
        String password = req.getParameter("password");
        
        
//      if no user name has been received
        if(login == null || password == null)
            return false;
        if(login.length()<1 || password.length()<1)
            return false;
       
        try {
//          retrieve user information
        	String querGetUserPass = "SELECT * FROM ent_user" +
                    " WHERE login = '" + login + "'";      
			ResultSet rsUser = SqlUtil.executeStatement(this.dbConn, querGetUserPass);
			rsUser.last();
			int size = rsUser.getRow();
			if (size != 1)
				return false;
			rsUser.first();
			if (PasswordHash.validatePassword(password, rsUser.getString("ent_user.password"))) {
				uBean.setId(rsUser.getInt("ent_user.id"));
				uBean.setLogin(rsUser.getString("ent_user.login"));
				uBean.setName(rsUser.getString("ent_user.name"));
				uBean.setPassword(rsUser.getString("ent_user.password"));
				uBean.setRole(rsUser.getString("ent_user.role"));
				uBean.setEmail(rsUser.getString("ent_user.email"));
			} else {
				//if there is no user with such name and password in the DB
				System.out.println("[Authoring] checkLogin(): Login failed for the user: " +
				                  login + " with passowrd: " + password);
				return false;
			}
        	
//            String querGetUserPass = "SELECT * FROM ent_user" +
//                                     " WHERE login = '" + login + "'" +                                    
//                                     " AND password = '" + password+"'";      
//            ResultSet rsUser = SqlUtil.executeStatement(this.dbConn, querGetUserPass);
//            if (rsUser.next()) {
//                uBean.setId(rsUser.getInt("ent_user.id"));
//                uBean.setLogin(rsUser.getString("ent_user.login"));
//                uBean.setName(rsUser.getString("ent_user.name"));
//                uBean.setPassword(rsUser.getString("ent_user.password"));
//                uBean.setRole(rsUser.getString("ent_user.role"));
//            } else {
////              if there is no user with such name and password in the DB
//                System.out.println("[Authoring] checkLogin(): Login failed for the user: " +
//                                   login + " with passowrd: " + password);
//                return false;
//            }
            
            String querGetUserGroups = "SELECT * FROM rel_group_user, ent_group " +
                                       "WHERE rel_group_user.groupid = ent_group.id " +
                                       "AND rel_group_user.userid = " + uBean.getId();
            
            ResultSet rsGroup = SqlUtil.executeStatement(this.dbConn, querGetUserGroups);
            while(rsGroup.next()) {
//              populate group bean
                GroupBean gBean = new GroupBean();
                gBean.setId(rsGroup.getInt("ent_group.id"));
                gBean.setOwnerId(rsGroup.getInt("ent_group.ownerId"));
                gBean.setName(rsGroup.getString("ent_group.name"));
                groupList.add((GroupBean) gBean.clone());
                
                String querGetGroupUsers = "SELECT * " +
                                           "FROM rel_group_user " +
                                           "WHERE rel_group_user.groupid = " + gBean.getId();
                ResultSet rsGroupUsers = SqlUtil.executeStatement(this.dbConn, querGetGroupUsers);
                while (rsGroupUsers.next())
                    gBean.addUser(rsGroupUsers.getInt("rel_group_user.userid"), 
                                  rsGroupUsers.getInt("rel_group_user.rights"));             
                
                if (gBean.getOwnerId() == uBean.getId()) { 
                    uBean.setGroupBean(gBean);
                    uBean.setRights(rsGroup.getInt("rel_group_user.rights"));
                }
            }
            
            
            /*
             * add teacherGroup for teachers' use
             * @author : roya
             */
			String querTeachersGroup = "SELECT * FROM rel_group_user, ent_group "
					+ "WHERE rel_group_user.groupid = ent_group.id "
					+ "AND ent_group.name = 'teachers' ";

			rsGroup = SqlUtil.executeStatement(this.dbConn,querTeachersGroup);
			while (rsGroup.next()) {
				// populate group bean
				GroupBean gBean = new GroupBean();
				gBean.setId(rsGroup.getInt("ent_group.id"));
				gBean.setOwnerId(rsGroup.getInt("ent_group.ownerId"));
				gBean.setName(rsGroup.getString("ent_group.name"));
				teacherGBean = (GroupBean) gBean.clone();				
			}

            if (uBean.getGroupBean() == null) 
            {
            	if (groupList.isEmpty() == false)
            	{
                    uBean.setGroupBean(groupList.firstElement());
                    rsGroup.first();
                    uBean.setRights(rsGroup.getInt("rel_group_user.rights"));
            	}
            	else 
            		uBean.setGroupBean(teacherGBean);
            }
            
            ListIterator i = groupList.listIterator();
            boolean isAdmin = false;
            GroupBean adminGBean = null;
			while(i.hasNext()) {
				GroupBean gBean = (GroupBean) i.next();
				if (gBean.getName().equals("admin"))
				{
					adminGBean = gBean;
					isAdmin = true;
					break;
				}
			}
			
			if (isAdmin)
				this.session.setAttribute("groupBean", adminGBean);
			else
				this.session.setAttribute("groupBean", teacherGBean );
//            if(groupList.size() == 0) {
//                System.out.println("[Authoring] checkLogin(): No group is found for " +
//                        "the user " + login);
//                return false;
//            }    
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
        
        this.session.setAttribute("userBean", uBean);
        this.session.setAttribute("groupList", groupList);
        

        return true;
    }
  
/**
 * switchGroup(): changes groupBean member of userBean to newGroupBean 
 * modifys userBean in the session, removes newGroupBean from the session
 * @return nothing
 */ 
    private void switchGroup() {        
        UserBean uBean = (UserBean) this.session.getAttribute("userBean");
        GroupBean newGroupBean = (GroupBean) this.session.getAttribute("newGroupBean");
        uBean.setGroupBean(newGroupBean);
        uBean.setRights(newGroupBean.getUsers().get(uBean.getId()));
        this.session.setAttribute("userBean", uBean);
        this.session.removeAttribute("newGroupBean");
    }    
    
/**
 * Changes userBean's 
 * password and name and stores new info in the DB
 * Updates userBean in the session
 * @param res 
 * @param req 
 * @return true if the password has been changed successfully, false if an error occurred
 */ 
	private boolean modifyUserInfo(HttpServletRequest req, HttpServletResponse res) {
		UserBean uBean = (UserBean) this.session.getAttribute("userBean");
		
		String tempName = req.getParameter("name");
		String tempLogin = req.getParameter("login");
		String tempEmail = req.getParameter("email");
		String tempOldPassword = req.getParameter("oldPassword");
		String tempPassword = req.getParameter("password");
		String tempCheckPassword = req.getParameter("checkpassword");
		
		if(tempName == null || tempLogin == null || tempEmail == null || tempOldPassword == null || tempPassword == null || tempCheckPassword == null)
            return false;
		
		if(tempName.length()<1 || tempLogin.length()<1 || tempEmail.length()<1 || tempOldPassword.length()<1 || tempPassword.length()<1 || tempCheckPassword.length()<1)
            return false;
		
		if (!tempPassword.equals(tempCheckPassword))
			return false;
       
        try {
        	String querGetUserPass = "SELECT * FROM ent_user" +
                    " WHERE login = '" + tempLogin + "'";      
			ResultSet rsUser = SqlUtil.executeStatement(this.dbConn, querGetUserPass);
			rsUser.last();
			int size = rsUser.getRow();
			if (size != 1)
				return false;
			rsUser.first();
			if (!PasswordHash.validatePassword(tempOldPassword, rsUser.getString("ent_user.password"))) {
				res.sendRedirect(res.encodeRedirectURL(req.getContextPath() + "/passwordChange.jsp?alert=1"));
				return false;
			}
			String finalPass = PasswordHash.createHash(tempPassword);
				
			String querUpdateUserInfo =	"Update ent_user " +
					"SET password = \"" + finalPass +					"\", name = \"" + tempName +
					"\", email = \"" + tempEmail +
					"\" WHERE id = " + uBean.getId();					SqlUtil.executeUpdate(this.dbConn, querUpdateUserInfo);

			uBean.setLogin(tempLogin);
			uBean.setPassword(finalPass);
			uBean.setName(tempName);
			uBean.setEmail(tempEmail);
		} catch (Exception e) {
            e.printStackTrace();
            return false;
        }
        this.session.setAttribute("userBean", uBean);
		return true;
	}
	
	
	private void modifyUserInfoTemp(HttpServletRequest req, HttpServletResponse res) {
		try {
			PrintWriter out = res.getWriter();

			UserBean uBean = (UserBean) this.session.getAttribute("userBean"); 
			String tempName = req.getParameter("name");
			String tempId = req.getParameter("id");
			String tempEmail = req.getParameter("email");
			
			if (uBean == null || !uBean.getRole().equals("admin") || tempName == null || tempName.length()<1 || tempId == null || tempId.length()<1 || tempEmail == null || tempEmail.length()<1 ) {
				out.println("false");
			} else {
				String querUpdateUserInfo =	"Update ent_user " +
						"SET name = \"" + tempName +
						"\", email = \"" + tempEmail +
						"\" WHERE id = " + tempId;		
				SqlUtil.executeUpdate(this.dbConn, querUpdateUserInfo);
				out.println("true");
			}
		} catch (Exception e) {
            e.printStackTrace();
            try {
            	PrintWriter out = res.getWriter();
            	out.println("false");
            } catch (Exception e2) {}
        }
	}
	
	
	private void recoverPassword(HttpServletRequest req, HttpServletResponse res) {
		try {
        	String tempEmail = req.getParameter("email");
        	PrintWriter out = res.getWriter();
        	
        	if (tempEmail != null) {
        		tempEmail = tempEmail.trim();
        		if (tempEmail.length()>0) {
        			String querGetLog = "SELECT * FROM ent_user" +
                            " WHERE email = '" + tempEmail + "'";
        			ResultSet rsUser = SqlUtil.executeStatement(this.dbConn, querGetLog);
        			rsUser.last();
        			int size = rsUser.getRow();
        			if (size != 1) {
        				out.println("false");
        			} else {
        				String id = rsUser.getString("id");
        				String name = rsUser.getString("name");
        				String login = rsUser.getString("login");
        				String randLink = "";
        				
        				Random rand = new SecureRandom();
        				String letters = "abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789+@";
						for (int i=0; i<10; i++) {
							int index = (int)(rand.nextDouble()*letters.length());
							randLink += letters.substring(index, index+1);
						}
						randLink = PasswordHash.createHash(randLink);
						
						String querInsertPR = "INSERT INTO ent_user_pr (user_id, rand, time) VALUES ("+id+", \""+randLink+"\", NOW())";
			            SqlUtil.executeUpdate(this.dbConn, querInsertPR);
			            
			            String subject = "PAWS.AuthoringTool - Password Reset (NoReply)";
        				String content = "Hello, "+name+"\n\nYou have received this email according to the recent password recovery request from PAWS Authoringtool.\n"+
        						"To reset password for "+login+" (login) follow this link:\n\nhttp://adapt2.sis.pitt.edu/authoringtool_beta/pr.jsp?id="+randLink+"\n\nFor security purpose this link will be active for the next 24 hours only.\n\nIf you didn't request "+
        						"password recovery, your account might have been hijacked. Please, login into your account and change your password.\n\nThank you for using our system,\n\t- PAWS team.";
        				String[] recipient = {tempEmail};
        				MailServices.sendMessage(recipient, content, subject);
        				
        				out.println("true");
        			}
        		} else {
        			out.println("false"); 
        		}
        	} else {
        		out.println("false");        		
        	}
		} catch (Exception e) {
            e.printStackTrace();
            try {
            	PrintWriter out = res.getWriter();
            	out.println("false");
            } catch (Exception e2) {}
        }
	}
	
	
	private void resetPassword(HttpServletRequest req, HttpServletResponse res) {
		try {
        	String tempPR = req.getParameter("pr");
        	String tempPass = req.getParameter("np");
        	PrintWriter out = res.getWriter();
        	
        	if (tempPR != null && tempPass != null) {
        		tempPR = tempPR.trim();
        		if (tempPR.length()>0 && tempPass.length()>0) {
        			String querGetId = "SELECT user_id FROM ent_user_pr WHERE rand = \""+tempPR+"\" ORDER BY time ASC LIMIT 1;";
        			ResultSet rs = SqlUtil.executeStatement(this.dbConn, querGetId);
                    rs.last();
        			
        			String querUpdatePass = "UPDATE ent_user " +
        					"SET password = \""+PasswordHash.createHash(tempPass)+"\" WHERE id ="+rs.getInt("user_id")+";";
        			SqlUtil.executeUpdate(this.dbConn, querUpdatePass);
        			SqlUtil.executeUpdate(this.dbConn, "DELETE FROM ent_user_pr WHERE rand = \""+tempPR+"\";");
        			out.println("true");
        		} else {
        			out.println("false"); 
        		}
        	} else {
        		out.println("false");        		
        	}
		} catch (Exception e) {
            e.printStackTrace();
            try {
            	PrintWriter out = res.getWriter();
            	out.println("false");
            } catch (Exception e2) {}
        }
	}

    
/********************************************************************/
/************************ SUPERUSER's ACTIONS ***********************/    
/********************************************************************/   
  
/**
 * getUserList(): retrieves the list of all users form the DB and put them as a Vector of UserBeans
 * to the userList attribute of the session   
 * @return true if the user lust was retreived from the DB, false if an error occured
 */     
	private boolean getUserList() {
        String querUserList = "SELECT * FROM ent_user";
        Vector<UserBean> userList = new Vector<UserBean>();        
        try {
            ResultSet rs = SqlUtil.executeStatement(this.dbConn, querUserList);
            while (rs.next()) {
                UserBean uBean = new UserBean();
                uBean.setId(rs.getInt("id"));
                uBean.setName(rs.getString("name"));
                uBean.setLogin(rs.getString("login"));
                uBean.setRole(rs.getString("role"));
                userList.add(uBean);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
        this.session.setAttribute("userList", userList);
        System.out.println("[Authoring] getUserList(): " + userList.size() + "users");
        return true;
    }
    
    /**
     * modifyUsersRights(): retrieves new rights of users for the current gtoup of the current user 
     * as a session attribute modifyUsersRights and modifys users member of the groupBean memeber 
     * of the current userBean
     * save new users' right to the usergroupmap table of the DB
     * modifys userBean and groupList atributes of the session
     * remove newUsersRights attribute form the session  
     * @return true if the user lust was retreived from the DB, false if an error occured
     */ 
    private boolean modifyUsersRights() {
//      modify user rights for the current group of userBean             
        UserBean uBean = (UserBean) this.session.getAttribute("userBean");
        Hashtable<Integer, Integer> newUsersRights = (Hashtable<Integer, Integer>) this.session.getAttribute("newUsersRights");
        this.session.removeAttribute("newUserRights");
        uBean.getGroupBean().setUsers(newUsersRights);
//      modify user rights for the group from the groupList            
        Vector<GroupBean> groupList = (Vector<GroupBean>) this.session.getAttribute("groupList");
        ListIterator i = groupList.listIterator();
        while (i.hasNext())
            if (((GroupBean) i.next()).getId() == uBean.getGroupBean().getId()) {
                ((GroupBean) i.previous()).setUsers(newUsersRights);
                i.next();
            }
        
        Set ids = newUsersRights.keySet();
        try {           
            Iterator j = ids.iterator();
            while (j.hasNext()) {
                int curId = ((Integer) j.next()).intValue();
                String querUpdateGroup = "MODIFY usergroupmap";
                querUpdateGroup = querUpdateGroup.concat(" SET rights = " + 
                                                  ((Integer) newUsersRights.get(curId)).intValue());
                querUpdateGroup = querUpdateGroup.concat(" WHERE userid = " + curId);
                querUpdateGroup = querUpdateGroup.concat(" AND groupid = " + uBean.getGroupBean().getId());
                SqlUtil.executeUpdate(dbConn, querUpdateGroup);
            }
        } catch (Exception e) {          
            e.printStackTrace();
            return false;
        }
        this.session.setAttribute("userBean", uBean);
        this.session.setAttribute("groupList", groupList);
        return true;
    }

    private boolean createGroup(HttpServletRequest req) {
    	UserBean userBean = (UserBean) session.getAttribute("userBean");
		if (userBean == null)
			return false;
		GroupBean gbean = userBean.getGroupBean();
		if (gbean == null)
			return false;
		if (!(userBean.getRole().equals("admin") || userBean.getRole().equals("superuser")))
			return false;
		
		String tempGroupName = req.getParameter("name");
		
		if (tempGroupName == null || tempGroupName.length()<1)
			return false;
		
		String tempOwner = (userBean.getRole().equals("admin")) ? "0" : ""+userBean.getId();
		try {
            String querInsertGroup = "INSERT INTO ent_group (name, ownerId) VALUES ('"+tempGroupName+"', "+tempOwner+")";
            SqlUtil.executeUpdate(this.dbConn, querInsertGroup);
            System.out.println("[Authoring] group " + tempGroupName + " has been created");
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Exception while saving group to database");
            return false;
        }
        return true;
//        UserBean uBean = (UserBean) this.session.getAttribute("userBean");
//        GroupBean gBean = (GroupBean) this.session.getAttribute("newGroupBean");
//        this.session.removeAttribute("newGroupBean");
//        Vector<GroupBean> groupList = (Vector<GroupBean>) this.session.getAttribute("groupList");
//               
//        try {
//            String querInsertGroup = "INSERT INTO group (name, ownerId) VALUES (";
//            querInsertGroup = querInsertGroup.concat(gBean.getName() + ", ");
//            querInsertGroup = querInsertGroup.concat(uBean.getId() + ", ");
//            SqlUtil.executeUpdate(this.dbConn, querInsertGroup);
//            System.out.println("[Authoring] group " + gBean.getName() + "has been created");
//            String querSelectGroupId = "SELECT max(id) FROM group";
//            ResultSet rs = SqlUtil.executeStatement(this.dbConn, querSelectGroupId);
//            if (rs.next())
//                gBean.setId(rs.getInt(1));
//        } catch (Exception e) {
//            e.printStackTrace();
//            System.out.println("Exception while saving group to database");
//            this.session.removeAttribute("newGroupBean");
//            return false;
//        }
//        groupList.add(gBean); 
//        this.session.setAttribute("groupList", groupList);
//        return true;
    }
    
    public boolean modifyGroup() {
        UserBean uBean = (UserBean) this.session.getAttribute("userBean");
        GroupBean gBean = (GroupBean) this.session.getAttribute("modifyGroupBean");
        this.session.removeAttribute("modifyGroupBean");
        Vector<GroupBean> groupList = (Vector<GroupBean>) this.session.getAttribute("groupList");
//      modify groupList        
        ListIterator i = groupList.listIterator();
        while (i.hasNext())
            if (((GroupBean) i.next()).getId() == gBean.getId()) {
                groupList.setElementAt(gBean, groupList.indexOf((GroupBean) i.previous()));
                break;
            }
//      modify DB        
        try {              
            String querUpdateGroup = "MODIFY group ";
            querUpdateGroup = querUpdateGroup.concat("SET name = " + gBean.getName());
            querUpdateGroup = querUpdateGroup.concat(", ownerId = " + gBean.getOwnerId()); 
            querUpdateGroup = querUpdateGroup.concat(" WHERE id = " + gBean.getId());            
            SqlUtil.executeUpdate(this.dbConn, querUpdateGroup);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Exception while saving group to database");
            this.session.removeAttribute("modifyGroupBean");
            return false;
        }
        this.session.setAttribute("groupList", groupList);
        return true;
        
    }
    
    private boolean deleteGroup() {
        UserBean uBean = (UserBean) this.session.getAttribute("userBean");
        int deleteGroupId = (Integer) this.session.getAttribute("deleteGroupId");
        this.session.removeAttribute("deleteGroupId");
        Vector<GroupBean> groupList = (Vector<GroupBean>) this.session.getAttribute("groupList");

        String querDeleteUserGroupMap = "DELETE FROM usergroupmap WHERE groupid = " + deleteGroupId;
        String querDeleteGroup = "DELETE FROM group WHERE id = " + deleteGroupId;

        try {
            SqlUtil.executeUpdate(this.dbConn, querDeleteUserGroupMap);
            SqlUtil.executeUpdate(this.dbConn, querDeleteGroup);
            
            ListIterator i = groupList.listIterator();
            while (i.hasNext())
                if (((GroupBean) i.next()).getId() == deleteGroupId) {
                    groupList.remove((GroupBean) i.previous());
                    break;
                }            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
        this.session.setAttribute("groupList", groupList);
        return true;
    }

    private boolean removeUsersFromGroup() {
//      modify users for the current group of userBean             
        UserBean uBean = (UserBean) this.session.getAttribute("userBean");
        Vector<Integer> removeUsersId = (Vector<Integer>) this.session.getAttribute("removeUsersId");
        this.session.removeAttribute("removeUsersId");
        ListIterator i = removeUsersId.listIterator();
        while (i.hasNext())
            if (uBean.getGroupBean().getUsers().contains((Integer) i.next())) {
                uBean.getGroupBean().removeUser(((Integer) i.previous()).intValue());
                i.next();
            }
//      modify users for the group from the groupList            
        Vector<GroupBean> groupList = (Vector<GroupBean>) this.session.getAttribute("groupList");
        i = groupList.listIterator();
        while (i.hasNext())
            if (((GroupBean) i.next()).getId() == uBean.getGroupBean().getId()) {
                ((GroupBean) i.previous()).setUsers(uBean.getGroupBean().getUsers());
                i.next();
            }
        
        try {           
            i = removeUsersId.listIterator();
            while (i.hasNext()) {
                String querDeleteUserFromGroup = "DELETE FROM usergroupmap" +
                                                 " WHERE userid = " + ((Integer) i.next()).intValue();                
                SqlUtil.executeUpdate(dbConn, querDeleteUserFromGroup);
            }
        } catch (Exception e) {          
            e.printStackTrace();
            return false;
        }
        this.session.setAttribute("userBean", uBean);
        this.session.setAttribute("groupList", groupList);
        return true;
    }
    
    private boolean addUSersToGroup() {

//      modify users for the current group of userBean             
        Hashtable<Integer, Integer> newUsersRights = (Hashtable) this.session.getAttribute("newUsersRights");
        this.session.removeAttribute("newUsersRights");        
        UserBean uBean = (UserBean) this.session.getAttribute("userBean");        
        uBean.getGroupBean().setUsers(newUsersRights);
        
//      modify users for the group from the groupList            
        Vector<GroupBean> groupList = (Vector<GroupBean>) this.session.getAttribute("groupList");
        ListIterator i = groupList.listIterator();
        while (i.hasNext())
            if (((GroupBean) i.next()).getId() == uBean.getGroupBean().getId()) {
                ((GroupBean) i.previous()).setUsers(uBean.getGroupBean().getUsers());
                i.next();
            }
        
        Set ids = newUsersRights.keySet();
        try {           
            Iterator j = ids.iterator();
            while (j.hasNext()) {
                int curId = ((Integer) j.next()).intValue();
                String querAddUserToGroup = "INSERT INTO usergroupmap " +
                                            "(userid, groupid, rights) " +
                                            "VALUES (";
                querAddUserToGroup = querAddUserToGroup.concat(curId + ", ");
                querAddUserToGroup = querAddUserToGroup.concat(uBean.getGroupBean().getId() + ", ");
                querAddUserToGroup = querAddUserToGroup.concat(newUsersRights.get(curId) + ")");
                SqlUtil.executeUpdate(dbConn, querAddUserToGroup);
            }
            this.session.setAttribute("userBean", uBean);
            this.session.setAttribute("groupList", groupList);
            return true;
        } catch (Exception e) {          
            e.printStackTrace();
            return false;
        }
    }
    
/********************************************************************/
/************************ ADMIN's ACTIONS ***************************/    
/********************************************************************/ 
/**
 * createUser(): retrieves newUserBean attribute from the session and saves it to the DB
 * removes newUserBean from the session
 * @return true if the user was successfuly saved in the DB, false if an error occured
 * 
 */ 
	private boolean createUser(HttpServletRequest req) {
		UserBean userBean = (UserBean) session.getAttribute("userBean");
		if (userBean == null)
			return false;
		GroupBean gbean = userBean.getGroupBean();
		if (gbean == null)
			return false;
		if (!(userBean.getRole().equals("admin") || userBean.getRole().equals("superuser")))
			return false;
		
		String tempRole = req.getParameter("role");
		String tempGroupAdmin = req.getParameter("groupAdmin");
		String tempGroupTeacher = req.getParameter("groupTeacher");
		String tempGroupNew = req.getParameter("newGroup");
		String tempName = req.getParameter("name");
		String tempLogin = req.getParameter("login");
		String tempPassword = req.getParameter("password");
		String tempCheckPassword = req.getParameter("checkpassword");	
		String tempGroup = "";
		
		if (tempName == null  || tempLogin == null || tempPassword == null || tempCheckPassword == null || tempRole == null || tempRole == null)
			return false;
		if (tempRole.length() < 1 || tempName.length() < 1  || tempLogin.length() < 1 || tempPassword.length() < 1 || tempCheckPassword.length() < 1 || tempRole.length() < 1 || !tempPassword.equals(tempCheckPassword))
			return false;
		
		boolean createGroup = false;
		if (tempRole.equals("admin")) {
			tempGroup  = "1";
		} else if (tempRole.equals("superuser")) {
			tempGroup  = "2";
		} else if (tempRole.equals("user")) {
			if (userBean.getRole().equals("admin")) {
				if (tempGroupAdmin == null || tempGroupAdmin.length()<1)
					return false;
				if (tempGroupAdmin.equals("-1")) {
					createGroup = true;
				} else {
					tempGroup = tempGroupAdmin;
				}
			} else {
				if (tempGroupTeacher == null || tempGroupTeacher.length()<1)
					return false;
				if (tempGroupTeacher.equals("-1")) {
					createGroup = true;
				} else {
					tempGroup = tempGroupTeacher;
				}
			}
		} else {
			return false;
		}
		
		String tempOwner = "0";
		if (userBean.getRole().equals("superuser")) {
			tempOwner = userBean.getId()+"";
		}

		if (createGroup) {
			if (tempGroupNew == null || tempGroupNew.length()<1)
				return false;
			
			try {
	            String querInsertGroup = "INSERT INTO ent_group (name, ownerId) VALUES (\""+tempGroupNew+"\", "+tempOwner+")";
	            SqlUtil.executeUpdate(this.dbConn, querInsertGroup);

	            String querSelectGroupId = "SELECT max(id) FROM ent_group";
	            ResultSet rs = SqlUtil.executeStatement(this.dbConn, querSelectGroupId);
	            if (rs.next())
	            	tempGroup = ""+rs.getInt(1);
	        } catch (Exception e) {
	            e.printStackTrace();
	            System.out.println("Exception while saving group to database");
	            return false;
	        }
		}
		//tempRole	tempGroup	tempOwner	tempName	tempLogin		tempPassword
		
		try {
			String querGetUserList = "SELECT login FROM ent_user";
			ResultSet rs = SqlUtil.executeStatement(this.dbConn, querGetUserList);
//          check if a user with such name is already in DB

			while (rs.next()) {
				if(rs.getString("login").equals(tempLogin)) {
					System.out.println("[Authoring] saveUser(): user with login " +
							tempLogin + "already exists in the DB");                            
					return false;
				}
			}
//          insert a user in DB
			String tempPass = PasswordHash.createHash(tempPassword);
			String querInsertUser = "INSERT INTO ent_user " +
                                    "(login, name, password, role, ownerId) " +
                                    " VALUES(\""+tempLogin+"\", \""+tempName+"\", \""+tempPass+"\", \""+tempRole+"\", \""+tempOwner+"\")";			
            SqlUtil.executeUpdate(this.dbConn, querInsertUser);
            System.out.println("[Authoring] createUser(): user " + tempLogin + 
                               "has been added to the DB");
            
            String userID = "";
            String querGetUserID = "SELECT id FROM ent_user WHERE login = \""+tempLogin+"\"";
			rs = SqlUtil.executeStatement(this.dbConn, querGetUserID);
			while (rs.next()) {
				userID = rs.getString("id");
			}
			
			String tempRight = "0";
			if (tempRole.equals("admin"))
				tempRight = "1";
			String querAddGroupUserRel = "INSERT INTO rel_group_user " +
                                    "(UserID, GroupID, Rights) VALUES ("+userID+", "+tempGroup+", "+tempRight+");";
			SqlUtil.executeUpdate(this.dbConn, querAddGroupUserRel);
			
		}catch(Exception e) {
			System.out.println("[Authoring] createUser(): Error");	
			e.printStackTrace();
			return false;
	 	 }
		 return true;
	}
    
	
	
	
	private boolean createUserTemp(HttpServletRequest req) {
		UserBean userBean = (UserBean) session.getAttribute("userBean");
		if (userBean == null)
			return false;
		GroupBean gbean = userBean.getGroupBean();
		if (gbean == null)
			return false;
		if (!userBean.getRole().equals("admin"))
			return false;
		
		String tempRole = req.getParameter("role");
		String tempName = req.getParameter("name");
		String tempLogin = req.getParameter("login");
		String tempEmail = req.getParameter("email");
		String tempPassword = req.getParameter("password");
		String tempCheckPassword = req.getParameter("checkpassword");	
		String tempGroup = "";
		
		if (tempName == null  || tempLogin == null || tempPassword == null || tempCheckPassword == null || tempRole == null || tempRole == null || tempEmail == null)
			return false;
		if (tempRole.length() < 1 || tempName.length() < 1  || tempLogin.length() < 1 || tempEmail.length() < 1 || tempPassword.length() < 1 || tempCheckPassword.length() < 1 || tempRole.length() < 1 || !tempPassword.equals(tempCheckPassword))
			return false;
		
		if (tempRole.equals("admin")) {
			tempGroup  = "1";
		} else if (tempRole.equals("superuser")) {
			tempGroup  = "2";
		} else {
			return false;
		}

		try {
			String querGetUserList = "SELECT login FROM ent_user";
			ResultSet rs = SqlUtil.executeStatement(this.dbConn, querGetUserList);
//          check if a user with such name is already in DB

			while (rs.next()) {
				if(rs.getString("login").equals(tempLogin)) {
					System.out.println("[Authoring] saveUser(): user with login " +
							tempLogin + "already exists in the DB");                            
					return false;
				}
			}
//          insert a user in DB
			String tempPass = PasswordHash.createHash(tempPassword);
			String querInsertUser = "INSERT INTO ent_user " +
                                    "(login, name, password, role, email) " +
                                    " VALUES(\""+tempLogin+"\", \""+tempName+"\", \""+tempPass+"\", \""+tempRole+"\", \""+tempEmail+"\")";			
            SqlUtil.executeUpdate(this.dbConn, querInsertUser);
            System.out.println("[Authoring] createUser(): user " + tempLogin + 
                               "has been added to the DB");
            
            String userID = "";
            String querGetUserID = "SELECT id FROM ent_user WHERE login = \""+tempLogin+"\"";
			rs = SqlUtil.executeStatement(this.dbConn, querGetUserID);
			while (rs.next()) {
				userID = rs.getString("id");
			}
			
			String tempRight = "0";
			if (tempRole.equals("admin"))
				tempRight = "1";
			String querAddGroupUserRel = "INSERT INTO rel_group_user " +
                                    "(UserID, GroupID, Rights) VALUES ("+userID+", "+tempGroup+", "+tempRight+");";
			SqlUtil.executeUpdate(this.dbConn, querAddGroupUserRel);
			
		}catch(Exception e) {
			System.out.println("[Authoring] createUser(): Error");	
			e.printStackTrace();
			return false;
	 	 }
		 return true;
	}
	
	/**
	 * Check if login exists
	 */ 
		private void checkLog(HttpServletRequest req, HttpServletResponse res) {
	        try {
	        	UserBean uBean = (UserBean) this.session.getAttribute("userBean");
	        	if (!uBean.isAdmin() && !uBean.getGroupBean().getName().equals("teachers")) {
	        		res.sendRedirect("authoring.jsp");
	        		return;
	        	}
	        	
	        	String tempLog = req.getParameter("log");
	        	if(tempLog == null || tempLog.length()<1) {
	        		res.sendRedirect("authoring.jsp");
	        		return;
	        	}
	        	
	        	PrintWriter out = res.getWriter();
	        	String querGetLog = "SELECT * FROM ent_user" +
	                    " WHERE login = '" + tempLog + "'";      
				ResultSet rsUser = SqlUtil.executeStatement(this.dbConn, querGetLog);
				rsUser.last();
				int size = rsUser.getRow();
				if (size > 0) {
					out.println("false");
				} else {
					out.println("true");
				}
			} catch (Exception e) {
	            e.printStackTrace();
	            try {
	            	res.sendRedirect("authoring.jsp");	            	
	            } catch (Exception e2) {}
        		return;
	        }
		}
	
	
	
	
    /**
     * modifyUser(): retrieves newUserBean attribute from the session , and modify it in the DB
     * removes newUserBean from the session
     * @return true if the user was successfuly saved in the DB, false if an error occured     * 
     */   
    private boolean modifyUser() {
        UserBean uBean = (UserBean) session.getAttribute("newUserBean");
        this.session.removeAttribute("newUserBean");
        try {
        	String tempPass = PasswordHash.createHash(uBean.getPassword());
        	uBean.setPassword(tempPass);
			
            String querUpdateUser = "MODIFY ent_user SET";
            querUpdateUser = querUpdateUser.concat(" login = " + uBean.getLogin());
            querUpdateUser = querUpdateUser.concat(" name = " + uBean.getName());
            querUpdateUser = querUpdateUser.concat(", password = " + uBean.getPassword());
            querUpdateUser = querUpdateUser.concat(", role = " + uBean.getRole());
            querUpdateUser = querUpdateUser.concat(" WHERE id = " + uBean.getId());
            SqlUtil.executeUpdate(this.dbConn, querUpdateUser);                
            System.out.println("[Authoring] modifyUser(): user " + uBean.getId() + 
                               "has been modified");
        } catch(Exception e) {
            System.out.println("[Authoring] modifyUser(): Error");  
            e.printStackTrace();
            return false;
        }
        return true;        
    }

    /**
     * deleteUser(): get the deleteUserId from the session delete user from the session and 
     * deletes corresponding tuples in ther DB from the user and usergroupmap tables
     * modifys corrsponding tuples in quiz, question and concept tables (authorid = 1 "deleted user")
     * removes deleteUserId attribute from the session 
     * @return true if the user has been deleted successfully, false if an error occured
     */
    
    private boolean deleteUser() {        
        Integer deleteUserId = null;
        String tmp = (String) this.session.getAttribute("deleteUserId");
        this.session.removeAttribute("deleteUserId");
        try {
            deleteUserId = new Integer (tmp);
        } catch (NumberFormatException e){
            System.out.println("[Authoring] deleteUser(): Incorrect user id");
            return false;
        }
        
//      modify and save groupList        
        Vector<GroupBean> groupList = (Vector<GroupBean>) this.session.getAttribute("grouplList");
        ListIterator i = groupList.listIterator();
        while (i.hasNext())
            if (((GroupBean) i.next()).getUsers().containsKey(deleteUserId)) {
                ((GroupBean) i.previous()).removeUser(deleteUserId.intValue());
                i.next();
            }
        
//      modify Database        
        String querDeleteUserGRoup = "DELETE FROM usergroupmap WHERE userid = " + deleteUserId.intValue();
        String querDeleteUser = "DELETE FROM user WHERE id = " + deleteUserId.intValue();
        String querModifyQuiz = "MODIFY quiz SET authorid = 1 WHERE authorid = " + deleteUserId.intValue();
        String querModifyQuestion = "MODIFY question SET authorid = 1 WHERE authorid = " + deleteUserId.intValue();
        String querModifyConcept = "MODIFY concept SET authorid = 1 WHERE authorid = " + deleteUserId.intValue();
        System.out.println("[Authoring] deleteUser(): " + deleteUserId.intValue()); 
        try {
            SqlUtil.executeUpdate(this.dbConn, querDeleteUserGRoup);
            SqlUtil.executeUpdate(this.dbConn, querModifyQuiz);
            SqlUtil.executeUpdate(this.dbConn, querModifyQuestion);
            SqlUtil.executeUpdate(this.dbConn, querModifyConcept);
            SqlUtil.executeUpdate(this.dbConn, querDeleteUser);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
        this.session.setAttribute("groupList", groupList); 
        return true;
    }
    
 }
