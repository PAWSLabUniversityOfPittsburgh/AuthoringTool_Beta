<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>Authoring Tool</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	<link href="stylesheets/bootstrap.min.css" rel="stylesheet" type="text/css" />
	<style>
		.form-group a {
			float: right;
		}
		.form-group.bottom {
			margin-bottom: 0px;
		}
		.green {
			color: green;
			font-weight: bold;
		}
	</style>
	
	<script language="JavaScript">
		function submit() {
			var reEmail = new RegExp(/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);
			tempEmail = document.getElementById('email').value;
		    if (!reEmail.test(tempEmail)) {
		    	alertMessage("Invalid email");
		    	return false;
		    }
			else {
				$('#submitBtn').attr('disabled', 'disabled');
		    	$.post("SecurityServlet?action=RECOVER_PASSWORD", {email: ""+tempEmail+""}, function() {})
			    .done(function(data) {
			    	if ($.trim(data) == "true") {
						$('#change').html('We have sent an email to <span class="green">'+tempEmail+'</span> with a link to recover your password. It can take several minutes before you receive it.');
			    	} else {
			    		alertMessage("Something went wrong while we were processing your request, please try to submit again");
			    	}
			    })
			    .fail(function() {
			    	alertMessage("Something went wrong while we were processing your request, please try to submit again");
			    	$('#submitBtn').attr('disabled', '');
			    });
		
			}
		}
		
		function alertMessage (text) {
			$("#alertMessage").hide().html('<div class="alert alert-danger alert-dismissible" role="alert">'+
					'<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>'+
					text+'</div>').fadeIn('slow');
			$("html, body").animate({ scrollTop: 0 }, "slow");
		}
	</script>

</head>
<body>
	<div id="alertMessage"></div>
	<br/>
	<div class="row">
		<div class="col-xs-10 col-xs-offset-1 col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3 col-lg-4 col-lg-offset-4">
			<div class="panel panel-primary">
			  <div class="panel-heading">
			    <h2 class="panel-title text-center">Password Recovery</h2>
			  </div>
			  <div class="panel-body">
				  <p>To recover your password type in an email associated with your account and click Submit button. We will send you an email with a link to the recovery page.</p>
				  
				  <div class="form-horizontal">
				  	<div id="change">
						<div class="form-group">
						  <label for="Login" class="col-sm-3 control-label">Email</label>
						  <div class="col-sm-9">
						    <input type="email" class="form-control" id="email" name="email" />
						  </div>
						</div>
						<div class="form-group">
						  <div class="col-sm-offset-3 col-sm-9">
						    <button class="btn btn-default" id="submitBtn" onclick="submit();">Submit</button>
						  </div>
						</div>
					</div>
					<div class="form-group bottom">
					  <div class="col-sm-offset-3 col-sm-9">
					    <a href="index.html">back to login</a>
					  </div>
					</div>
				</div>
			  	
			</div>
			</div>
		</div>
	</div>
	
	<script src="js/jquery-1.9.1.js"></script>
	<script src="js/bootstrap.min.js"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('#email').focus();
		});
	</script>
</body>
</html>