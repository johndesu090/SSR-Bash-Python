#! /usr/bin/env python
# -*- coding: utf-8 -*-
import json
import cgi

f = file("/usr/local/shadowsocksr/mudb.json");
json = json.load(f);

# Accept submission data
form = cgi.FieldStorage() 

# Parsing submitted data
getport = form['port'].value

# Determine if the port is found
portexist=0

# Cycle through ports
for x in json:
	#Considered to be found when the input port is the same as the json port
	if(str(x[u"port"]) == str(getport)):
		portexist=1
		transfer_enable_int = int(x[u"transfer_enable"])/1024/1024;
		d_int = int(x[u"d"])/1024/1024;
		transfer_unit = "MB"
		d_unit = "MB"

		#Flow unit conversion
		if(transfer_enable_int > 1024):
			transfer_enable_int = transfer_enable_int/1024
			transfer_unit = "GB"
		if(transfer_enable_int > 1024):
			d_int = d_int/1024
			d_unit = "GB"
		break

if(portexist==0):
	getport = "This port was not found, please check for a typo!"
	d_int = ""
	d_unit = ""
	transfer_enable_int = ""
	transfer_unit = ""







header = '''
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta content="IE=edge" http-equiv="X-UA-Compatible">
	<meta content="initial-scale=1.0, width=device-width" name="viewport">
	<title>Traffic query</title>
	<!-- css -->
	<link href="../css/base.min.css" rel="stylesheet">

	<!-- favicon -->
	<!-- ... -->

	<!-- ie -->
    <!--[if lt IE 9]>
        <script src="../js/html5shiv.js" type="text/javascript"></script>
        <script src="../js/respond.js" type="text/javascript"></script>
    <![endif]-->
    
</head>
<body>
    <div class="content">
        <div class="content-heading">
            <div class="container">
                <h1 class="heading">&nbsp;&nbsp;Traffic query</h1>
            </div>
        </div>
        <div class="content-inner">
            <div class="container">
'''


footer = '''
</div>
        </div>
    </div>
	<footer class="footer">
		<div class="container">
			<p>JohndesuSSR</p>
		</div>
	</footer>

	<script src="../js/base.min.js" type="text/javascript"></script>
</body>
</html>
'''


# Print what is returned
print header
formhtml = '''

<div class="card-wrap">
					<div class="row">
						<div class="col-lg-3 col-md-4 col-sm-6">
							<div class="card card-alt card-alt-bg">
								<div class="card-main">
									<div class="card-inner">
										<p class="card-heading">端口：%s</p>
										<p>
											Used traffic：%s %s <br>
											Total flow limit：%s %s </br></br>
											<a href="../index.html"><button class="btn" type="button">Return</button></a>
										</p>
									</div>
								</div>
							</div>
						</div>
						
					</div>
				</div>



'''
print formhtml % (getport,d_int,d_unit,transfer_enable_int,transfer_unit)

print footer
f.close();

