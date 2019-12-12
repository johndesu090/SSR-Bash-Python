#! /usr/bin/env python
# -*- coding: utf-8 -*-
import json
import cgi
import urllib2

#Obtain the IP of the local network
myip = urllib2.urlopen('http://members.3322.org/dyndns/getip').read()
myip=myip.strip()
#Load SSR JSON file
f = file("/usr/local/shadowsocksr/mudb.json");
json = json.load(f);

# Accept submission data
form = cgi.FieldStorage() 

# Parsing submitted data
getport = form['port'].value
getpasswd = form['passwd'].value
#Determine if the port is found
portexist=0
passwdcorrect=0
#Cycle through ports
for x in json:
	#Considered to be found when the input port is the same as the json port
	if(str(x[u"port"]) == str(getport)):
		portexist=1
		if(str(x[u"passwd"]) == str(getpasswd)):
			passwdcorrect=1
			jsonmethod=str(x[u"method"])
			jsonobfs=str(x[u"obfs"])
			jsonprotocol=str(x[u"protocol"])
		break

if(portexist==0):
	getport = "This port was not found, please check for a typo!"
	myip = ""
	getpasswd = ""
	jsonmethod = ""
	jsonprotocol = ""
	jsonobfs = ""

if(portexist!=0 and passwdcorrect==0):
	getport = "Connection password entered incorrectly, please try again"
	myip = ""
	getpasswd = ""
	jsonmethod = ""
	jsonprotocol = ""
	jsonobfs = ""


header = '''
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta content="IE=edge" http-equiv="X-UA-Compatible">
	<meta content="initial-scale=1.0, width=device-width" name="viewport">
	<title>Connection information</title>
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
                <h1 class="heading">&nbsp;&nbsp;Connection information</h1>
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


#Print what is returned
print header

formhtml = '''

<div class="card-wrap">
					<div class="row">
						
						
						<div class="col-lg-4 col-sm-6">
							<div class="card card-green">
								<a class="card-side" href="/"><span class="card-heading">Connection information</span></a>
								<div class="card-main">
									<div class="card-inner">
									<p>
										<strong>Server address：</strong> %s </br></br>
										<strong>Connection port：</strong> %s </br></br>
										<strong>Connection password：</strong> %s </br></br>
										<strong>Encryption： </strong> %s </br></br>
										<strong>Agreement method： </strong> </br>%s </br></br>
										<strong>Obfuscation：</strong> </br>%s 
										</p>
									</div>
									<div class="card-action">
										<ul class="nav nav-list pull-left">
											<li>
												<a href="../index.html"><span class="icon icon-check"></span>&nbsp;Return</a>
											</li>
										</ul>
									</div>
								</div>
							</div>
						</div>
						
						
						
					</div>
				</div>




'''

print formhtml % (myip,getport,getpasswd,jsonmethod,jsonprotocol,jsonobfs)
print footer
f.close();

