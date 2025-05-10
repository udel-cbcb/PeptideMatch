<html>
<head>
<title>Peptide Match Asynchronous RESTful Web Services</title>
<!-- Latest compiled and minified CSS -->
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"
	integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7"
	crossorigin="anonymous">

<!-- Optional theme -->
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css"
	integrity="sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r"
	crossorigin="anonymous">

<!-- Latest compiled and minified JavaScript -->
<script
	src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"
	integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS"
	crossorigin="anonymous"></script>
<!-- </head>
<body>
	
    <h2>Jersey RESTful Web Application!</h2>
    <p><a href="webapi/myresource">Jersey resource</a>
    <p>Visit <a href="http://jersey.java.net">Project Jersey website</a>
    for more information on Jersey!
</body>
</html> -->
<style type="text/css">
/*  body {
            background-color: #CCC;
        } */
#SiteBody {
	width: 1280px;
	margin: 0 auto;
	background-color: white;
}

h1 {
	color: navy;
}
</style>
</head>
<body>
	<div id="SiteBody">
		<div class="container">
			<div class="row">
				<div class="span12">
					<h1>Peptide Match Asynchronous RESTful API</h1>
					<br /> <br />
					<h3>Client sends POST query</h3>
					<p>POST a query to
						https://research.bioinformatics.udel.edu/peptidematchws/asyncrest/
					<pre>
POST https://research.bioinformatics.udel.edu/peptidematchws/asyncrest/ HTTP/1.1
Content-type: application/x-www-form-urlencoded ; version=1.1

peps:AAVEEGIVLGGGCALLR,STKKSVQY
taxIds:9606,10090
lEQi:on
spOnly:on                    		
</pre>
					The query consists of a list of a comma separated list of peptides, a comma separated list of NCBI taxIds and option flag
					"lEQi" which indicates whether to treat Leucine (L) and Isoleucine
					(I) as equivalent or not. It is most likely to be a checkbox value.
					</p>
					<p>
						<b>Note: Peptide Match service supports query peptide with
							three and more amino acids. However, shorter peptide takes more
							time to search and generate match report.</b>
					<p>
					<h3>Server responds 202 (Accepted)</h3>
					Once the server received the query, it creates a background job to
					run the peptide match and return a message tells the client that
					the server has accepted the request, but has not processed (or
					still is busy processing) the request. Instead of the URI of the
					actual match result resource, it would send a location to a job
					status resource.
					<pre>
HTTP/1.1 202 Accepted
Location: https://research.bioinformatics.udel.edu/peptidematchws/asyncrest/jobs/PM201602291d5444276668425dbb05a2044c4c15c4
</pre>
					</p>
					<p>
					<h3>Client gets the job status</h3>
					<pre>
GET https://research.bioinformatics.udel.edu/peptidematchws/asyncrest/jobs/PM201602291d5444276668425dbb05a2044c4c15c4 HTTP/1.1
</pre>
					</p>
					
					<p>
					<h3>Server responds 303 (See Other) and Retry-After (30 seconds) - If the job is still running</h3>
					<pre>
HTTP/1.1 303 See Other
Retry-After: 30</pre>
<!-- 
Location: http://research.bioinformatics.udel.edu/peptidematchws/asyncrest/jobs/PM201602291d5444276668425dbb05a2044c4c15c4</pre>
	 -->
	 				</p>
					<p>
					<h3>Server responds 200 (OK) and matched protein accessions - If the job is finished</h3>
					<pre>
HTTP/1.1 200 OK			

A0A024R3X4,B3GQS7,B3KNN9,B4DX43,B7Z4F6,B7Z597,B7Z5E7,E9Q3Q6,E9Q4G8,F5GXJ9,P10809,P63038,P63038-2,Q13740,Q13740-2,Q13740-3,Q54AJ5,Q5MPX5,Q61490
</pre>
					
					</p>
					
					<p>
					<h3>Client gets the job parameters</h3>
					<pre>
GET https://research.bioinformatics.udel.edu/peptidematchws/asyncrest/jobs/PM202203143cfba27c0ded4cb488377eaee526fbb5/parameters HTTP/1.1
</pre>
					</p>
					
					<p>
					<h3>Server responds 200 (OK) and job parameters</h3>
					<pre>
HTTP/1.1 200 OK			

QueryPetides:AAVEEGIVLGGGCALLR,STKKSVQY
TaxonIds:9606,10090
lEqi:Y
swissProtOnly:Y
</pre>
					
					</p>
				</div>
			</div>
		</div>
	</div>
</body>
</html>