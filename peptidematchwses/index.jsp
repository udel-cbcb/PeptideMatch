<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Peptide Search Asynchronous RESTful Web Services</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        h1 { color: navy; }
        pre { background-color: #f8f9fa; padding: 15px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container" style="max-width: 960px; margin-top: 40px;">
        <h1>Peptide Search Asynchronous RESTful API</h1>
        <br>

        <h3>Client sends POST query</h3>
        <p>POST a query to <code>https://peptidesearch.uniprot.org/asyncrest/</code></p>
        <pre>POST https://peptidesearch.uniprot.org/asyncrest/ HTTP/1.1
Content-type: application/x-www-form-urlencoded

peps=AAVEEGIVLGGGCALLR,STKKSVQY
taxIds=9606,10090
lEQi=on</pre>
        <p>The query consists of a comma-separated list of peptides, a comma-separated list of NCBI taxIds, and the option flag
        <code>lEQi</code> which indicates whether to treat Leucine (L) and Isoleucine
        (I) as equivalent or not.</p>
        <p><b>Note:</b> Peptide Search service supports query peptides with
        three or more amino acids. Shorter peptides take more time to search.</p>

        <h3>Server responds 202 (Accepted)</h3>
        <p>Once the server receives the query, it creates a background job and returns a location to a job status resource.</p>
        <pre>HTTP/1.1 202 Accepted
Location: https://peptidesearch.uniprot.org/asyncrest/jobs/PM201602291d5444276668425dbb05a2044c4c15c4</pre>

        <h3>Client requests the job status</h3>
        <pre>GET https://peptidesearch.uniprot.org/asyncrest/jobs/PM201602291d5444276668425dbb05a2044c4c15c4 HTTP/1.1</pre>

        <h3>Server responds 303 (See Other) - Job still running</h3>
        <pre>HTTP/1.1 303 See Other
Retry-After: 30</pre>

        <h3>Server responds 200 (OK) - Job finished</h3>
        <pre>HTTP/1.1 200 OK

A0A024R3X4,B3GQS7,B3KNN9,B4DX43,B7Z4F6,B7Z597,B7Z5E7,P10809,P63038,Q13740</pre>
    </div>
</body>
</html>
