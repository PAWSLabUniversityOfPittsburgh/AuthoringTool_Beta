<%@ page 
	contentType="text/html; charset=utf8"
	language="java"
	import="java.io.*, java.util.*, edu.pitt.sis.paws.authoring.beans.*, edu.pitt.sis.paws.authoring.data.Const"
	pageEncoding="utf8"
%>

<%
	request.setCharacterEncoding("UTF-8");

	boolean displaySysManage = false;
	UserBean userBean = (UserBean) session.getAttribute("userBean");
	String userBeanName = "";
	if (userBean != null) {
		userBeanName = userBean.getName();
		GroupBean gbean = userBean.getGroupBean();
		if (gbean != null) {
			/* if (userBean.getGroupBean().getName().equals("admins") || userBean.getGroupBean().getName().equals("teachers")) {    
				displaySysManage = true;
			} */
			if (userBean.getGroupBean().getName().equals("admins")) {    
				displaySysManage = true;
			}
		}
		else {
			response.sendRedirect("index.html?action="+"EXPIRED");
			return;
		}
	}
	else {
		response.sendRedirect("index.html?action="+"EXPIRED");
		return;
	}
%>

<!DOCTYPE html>
<html>
<head>
<title>Authoring Tool</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<link href="<%=request.getContextPath()%>/stylesheets/bootstrap.min.css" rel="stylesheet" type="text/css" />
<script src="js/jquery-1.9.1.js"></script>
<script src="js/bootstrap.min.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/stylesheets/treetable.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/stylesheets/EditInPlace.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/stylesheets/starrating.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/stylesheets/boxover.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/stylesheets/getQuiz.js"></script>
<script type="text/javascript">
	function toggleMe(a){
		var e=document.getElementById(a);
		if(!e) return true;
		if(e.style.display=="none") {
			e.style.display="block";
		} else{
			e.style.display="none";
		}
		return true;
	}
</script>
<style>

/* Start by setting display:none to make this hidden.
   Then we position it in relation to the viewport window
   with position:fixed. Width, height, top and left speak
   speak for themselves. Background we set to 80% white with
   our animation centered, and no-repeating */


/* When the body has the loading class, we turn
   the scrollbar off with overflow:hidden */
body.loading {
    overflow: hidden;   
}

/* Anytime the body has the loading class, our
   modal element will be visible */
body.loading .modal {
    display: block;
}


body { padding-top: 70px; }
.navbar-inverse {
  background-color: rgb(66, 139, 202);
  border-color: rgb(66, 139, 202);
}
.navbar-inverse .navbar-brand {
  color: #fff;
}
.navbar-inverse .navbar-brand:hover,
.navbar-inverse .navbar-brand:focus {
  color: yellow;
  background-color: transparent;
}
.navbar-inverse .navbar-text {
  color: #fff;
}
.navbar-inverse .navbar-nav > li > a {
  color: #fff;
}
.navbar-inverse .navbar-nav > li > a:hover {
  color: yellow;
  background-color: transparent;
}
.navbar-inverse .navbar-nav > .active > a,
.navbar-inverse .navbar-nav > .active > a:hover,
.navbar-inverse .navbar-nav > .active > a:focus {
  color: #fff;
  background-color: rgb(24, 93, 153);
}
.navbar-inverse .navbar-nav > .disabled > a,
.navbar-inverse .navbar-nav > .disabled > a:hover,
.navbar-inverse .navbar-nav > .disabled > a:focus {
  color: #444;
  background-color: transparent;
}
.navbar-inverse .navbar-toggle {
  border-color: #fff;
}
.navbar-inverse .navbar-toggle:hover,
.navbar-inverse .navbar-toggle:focus {
  background-color: rgb(24, 93, 153);
}
.navbar-inverse .navbar-toggle .icon-bar {
  background-color: #fff;
}
.navbar-inverse .navbar-collapse,
.navbar-inverse .navbar-form {
  border-color: rgb(24, 93, 153);
}
.navbar-inverse .navbar-nav > .open > a,
.navbar-inverse .navbar-nav > .open > a:hover,
.navbar-inverse .navbar-nav > .open > a:focus {
  color: yellow;
  background-color: rgb(24, 93, 153);
}
@media (max-width: 767px) {
  .navbar-inverse .navbar-nav .open .dropdown-menu > .dropdown-header {
    border-color: #080808;
  }
  .navbar-inverse .navbar-nav .open .dropdown-menu .divider {
    background-color: #080808;
  }
  .navbar-inverse .navbar-nav .open .dropdown-menu > li > a {
    color: #fff;
  }
  .navbar-inverse .navbar-nav .open .dropdown-menu > li > a:hover,
  .navbar-inverse .navbar-nav .open .dropdown-menu > li > a:focus {
    color: yellow;
    background-color: transparent;
  }
  .navbar-inverse .navbar-nav .open .dropdown-menu > .active > a,
  .navbar-inverse .navbar-nav .open .dropdown-menu > .active > a:hover,
  .navbar-inverse .navbar-nav .open .dropdown-menu > .active > a:focus {
    color: #fff;
    background-color: #080808;
  }
  .navbar-inverse .navbar-nav .open .dropdown-menu > .disabled > a,
  .navbar-inverse .navbar-nav .open .dropdown-menu > .disabled > a:hover,
  .navbar-inverse .navbar-nav .open .dropdown-menu > .disabled > a:focus {
    color: #444;
    background-color: transparent;
  }
}
.navbar-inverse .navbar-link {
  color: #999;
}
.navbar-inverse .navbar-link:hover {
  color: #fff;
}
.beta { font-size: 0.7em; vertical-align: super; }
</style>

</head>

<body>

	<div class="navbar navbar-fixed-top navbar-inverse" role="navigation">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="authoring.jsp">Authoring Tool <span class="beta" id="beta" data-toggle="tooltip" data-placement="bottom" title="This is a beta version of the system which means it can still contain some bugs and inconsistent user experience. Feedback is greatly appreciated."> [beta]</span></a>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li class="dropdown">
	          <a href="#" class="dropdown-toggle" data-toggle="dropdown">Authoring <span class="caret"></span></a>
	          <ul class="dropdown-menu" role="menu">
				<li><a href="authoring.jsp?type=topic">Topic Authoring</a></li>
				<!-- <li><a href="authoring.jsp?type=quiz">Quizjet Authoring</a></li> -->
				<li><a href="authoring.jsp?type=example">Example Authoring</a></li>
	          </ul>
	        </li>
            <%
				if(displaySysManage) {
			%>
					<!-- <li><a href="sysmanage.jsp">System Management</a></li> --> <!-- Full version of system management (not fully finished yet) -->
					<li><a href="sysmanage_temp.jsp">System Management</a></li>
			<%
				}
			%>
          </ul>
          <ul class="nav navbar-nav navbar-right">
	        <li><a href="myaccount.jsp"><%= userBeanName  %></a></li>
	        <li><a href="SecurityServlet?action=LOGOUT">Logout</a></li>
	      </ul>
        </div><!-- /.nav-collapse -->
      </div><!-- /.container -->
    </div><!-- /.navbar -->

	<div class="container">

    	