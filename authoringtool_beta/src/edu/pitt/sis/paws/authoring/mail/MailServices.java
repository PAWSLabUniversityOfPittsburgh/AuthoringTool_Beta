package edu.pitt.sis.paws.authoring.mail;

import javax.mail.Address;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import java.net.InetAddress;
import java.util.Properties;

public class MailServices {
	final String localhost;
    final String mailhost;
    final String mailuser;
    final String[] email_notify;
    protected Session session= null;
	                    
    public MailServices(String _localhost, String _mailhost, String _mailuser, String[] _email_notify) {
    	localhost= _localhost;
	    mailhost= _mailhost;
	    mailuser= _mailuser;
        email_notify= _email_notify;
    }
	                        
    public void send(String subject, String text)  throws Exception {
    	send(email_notify, subject, text);
    }
    public void send(String[] _to, String subject, String text) throws Exception{
		if(_to != null){
			if (session== null) {
				Properties p = new Properties();
				p.put("mail.transport.protocol", "smtp");
				p.put("mail.smtp.host", mailhost);
				p.put("mail.user",mailuser);
				p.put("mail.smtp.port","465");
				p.put("mail.smtp.socketFactory.port","465");
				p.put("mail.smtp.auth", "true");
				p.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
		        p.put("mail.smtp.socketFactory.fallback", "false");
				
				Authenticator auth = new Authenticator("authoringtool.paws@gmail.com","@paws@authoringtool@");
				session = Session.getDefaultInstance(p, auth);
				
				// Try to fake out SMTPTransport.java and get working EHLO:
				Properties properties = session.getProperties();
				String key= "mail.smtp.localhost";
				String prop= properties.getProperty(key);
				if (prop== null){
					properties.put(key, localhost);
				}else{
					System.out.println(key+ ": "+ prop);
				}
			}
			if(_to != null){
				for(int i=0;i < (_to.length-1)/100 + 1;i++){
					int k = 100*(i+1);
					if(k > _to.length){
						k = _to.length - 100*i;
					}
					MimeMessage msg = new MimeMessage(session);
					msg.setText(text);
					msg.setSubject(subject);
					Address fromAddr = new InternetAddress(mailuser);
					msg.setFrom(fromAddr);
					for(int j=0;j<k;j++){
						if(j==0){
							Address toAddr = new InternetAddress(_to[j + i*100].trim());
							msg.addRecipient(Message.RecipientType.TO, toAddr);       
						}else{
							Address toAddr = new InternetAddress(_to[j + i*100].trim());
							msg.addRecipient(Message.RecipientType.CC, toAddr);       
						}
					}
					Transport.send(msg);
					
				}
			}
		}
		// Note: will use results of getLocalHost() to fill in EHLO domain
    }
    
	/**
	 * Get the name of the local host, for use in the EHLO and HELO commands.
	 * The property mail.smtp.localhost overrides what InetAddress would tell
	 * us.
	 * Adapted from SMTPTransport.java
	 */
	public String getLocalHost() {
		String localHostName= null;
		String name = "smtp";  // Name of this protocol
		try {
			// get our hostname and cache it for future use
			if (localHostName == null || localHostName.length() <= 0)
				localHostName =  session.getProperty("mail." + name + ".localhost");      
			if (localHostName == null || localHostName.length() <= 0)
				localHostName = InetAddress.getLocalHost().getHostName();
		} catch (Exception uhex) {}
		return localHostName;
	}

	public static void sendMessage(String[] recipient, String content, String subject){
		String localhost= "adapt2.sis.pitt.edu";
		String mailhost= "smtp.gmail.com";
		String mailuser= "noReply";

		MailServices mn= new MailServices(localhost, mailhost, mailuser, recipient);
		try {
			mn.send(subject, content);
		} catch (Exception e) {
			System.out.println("Sending Error: " + e.getLocalizedMessage());
		}  
	}
	
	
	private class Authenticator extends javax.mail.Authenticator {
		private String username;
		private String password; 
		public Authenticator(String username, String password) {
			this.username = username;
			this.password = password;
		}
		protected PasswordAuthentication getPasswordAuthentication(){
			return new PasswordAuthentication(username,password);
		}
	}
}