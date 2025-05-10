<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%
	session.invalidate();
        Properties properties = new Properties();
	InputStream inputStream = null; 
	String version = "";
	try {
		inputStream = this.getClass().getClassLoader().getResourceAsStream("config/index.properties");
                properties.load(inputStream);
                version = properties.getProperty("version");
                
	}
	catch(IOException ioe) {
		ioe.printStackTrace();
	}
%>
<html><head>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="save" content="history">
	<title>Peptide Match - Command Line Tool [PIR - Protein Information Resource]</title><!-- ##### page dependent-->
  	<link href="./imagefiles/styles.css" type="text/css" rel="stylesheet">
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-39280281-1']);
  _gaq.push(['_trackPageview']);
  _gaq.push(['_trackPageLoadTime']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
 <style type="text/css">
     a:active {  color:#336699; text-decoration:underline}
    a:link {  color:#336699; text-decoration:underline}
    a:visited { color:#996666; text-decoration:underline }
    a:hover {  color: #FFAA00; text-decoration: underline}
    a.nounderline{text-decoration:none}
    </style>
    <style>
 
    
.radio1 {
	font-size:4px;
	background-color:transparent;
	border:1px;
	border-color:transparent;
	border:transparent;
}
.searchBannerBox {
font-family: Verdana, Tahoma, Arial, Helvetica, sans-serif; 
font-size: 11px; 
WIDTH: 180px;  
HEIGHT:18px
}
td.searchLable {
	color:#ffffff;
	font-family:Verdana,Arial, Helvetica, sans-serif;
	font-size:10px;
	font-weight:bold
}

.hide2 { position:absolute; visibility:hidden; }
.show2 { position:absolute; visibility:visible; }
#organismlink{
display:none;
}
#organismlist{
font-size:11px;
}
#organism_name{
display:none;
}
#organism{
display:none;
}
#organism_name_div{
display:none;
}
#result_display{
display:none;
}
#result_newline{
display:none;
}
#show_selected_count{
display:none;
}
th#th_link{
color:#036;
background-color: #369;
}
</style>
</head>
 
 <body onload="goBackInitilization();" bgcolor="#cccccc" background="./imagefiles/bg02.gif" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0"><span id="progress" class="hide2"><form name="dialog"><table width="220" height="70" border="4" cellpadding="0" cellspacing="0" align="center" bgcolor="#FFFFFF"><tbody><tr><td align="center"> Processing ... <br><input type="text" name="bar" size="25" bar.style="color:navy;"><br></td></tr></tbody></table></form></span>

<table border="0" cellspacing="0" cellpadding="0" width="100%"><tbody><tr><td>
<map name="PIRBanner_Map">
<area shape="rect" alt="home" coords="16,16,110,60" href="http://pir.georgetown.edu/pirwww/index.shtml" target="_top">
<area shape="rect" alt="uniprot" coords="140,36,178,50" href="http://www.uniprot.org/" target="_blank">
</map>
<table cellspacing="0" cellpadding="0" width="100%" border="0" height="80">
<tr> 
<td><img alt="" src="./imagefiles/PIRBanner.png" border="0" usemap="#PIRBanner_Map"></td> 
<td width="99%" nowrap="" height="1" background="./imagefiles/blueSpacer.png">
<img alt="" src="./imagefiles/spacer.gif" width="1" height="1" border="0">
</td>
<td align="right" valign="top" height="80" width="400" background="./imagefiles/gradientHome6.png">
<table border="0" cellpadding="0" cellspacing="0" width="400" height="80">
 <form action="http://pir.georgetown.edu/cgi-bin/textsearch.pl" id="textSearch" method="get" name="textSearchForm" style="MARGIN: 0px">
   <tr>
              <td width="400" colspan="10"><img alt="" src="./imagefiles/spacer.gif" width="400" height="30"></td>
            </tr>  
            <tr>
              <td><img alt="" src="./imagefiles/spacer.gif" width="60" height="1"></td>
	            <td><input type="radio" name="sitesearch" checked=""></td>
	            <td align="right" nowrap="" class="searchLable">Protein Search</td>
	            <td><input type="radio" name="sitesearch" value="sitesearch"></td>
	            <td align="right" nowrap="" class="searchLable">Site Search</td>
	            <td><img alt="" src="./imagefiles/spacer.gif" width="8" height="1"></td>
              <td align="right"><input alt="submit" type="image" src="./imagefiles/but06.png" border="0" width="18" height="16" name="submit"></td>
              <td><img alt="" src="./imagefiles/spacer.gif" width="2" height="1"></td>
              <td align="right"><input alt="query" name="query0" type="text" class="searchBannerBox" style="background:#CED9E7;" value=""></td>
              <td><img alt="" src="./imagefiles/spacer.gif" width="6" height="1"></td>
            </tr>
<input type="hidden" name="field0" value="ALL">
<input type="hidden" name="search" value="1">
</form>
 </table>
</td>
</tr>
</table>


<noscript>
    &lt;td&gt;
			&lt;table bgcolor="#4a4a4a" width="100%" height="21" border="0" cellspacing="0" cellpadding="0"&gt;
				&lt;tr&gt;
					&lt;td class="nrm02" nowrap&gt;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;
						&lt;a href="http://pir.georgetown.edu/pirwww/index.shtml" class="m"&gt;&lt;font face=verdana size="2pt" color="white"&gt;Home&lt;/font&gt;&lt;/a&gt; &amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp; 
						&lt;a href="http://pir.georgetown.edu/pirwww/about/" class="m"&gt;&lt;font face=verdana size="2pt" color="white"&gt;About PIR&lt;/font&gt;&lt;/a&gt;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp; 
						&lt;a href="http://pir.georgetown.edu/pirwww/dbinfo/" class="m"&gt;&lt;font face=verdana size="2pt" color="white"&gt;Databases&lt;/font&gt;&lt;/a&gt; &amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp; 
						&lt;a href="http://pir.georgetown.edu/pirwww/search/" class="m"&gt;&lt;font face=verdana size="2pt" color="white"&gt;Search/Retrieval&lt;/font&gt;&lt;/a&gt; &amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp; 
						&lt;a href="http://pir.georgetown.edu/pirwww/download/" class="m"&gt;&lt;font face=verdana size="2pt" color="white"&gt;Download&lt;/font&gt;&lt;/a&gt; &amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp; 
						&lt;a href="http://pir.georgetown.edu/pirwww/support/" class="m"&gt;&lt;font face=verdana size="2pt" color="white"&gt;Support&lt;/font&gt;&lt;/a&gt;
					&lt;/td&gt;
				&lt;/tr&gt;
			&lt;/table&gt;
		&lt;/td&gt;
</noscript>

<table cellspacing="0" cellpadding="0" width="100%" bgcolor="#333333" border="0"> <tbody><tr>
<td><img src="./imagefiles/leftSearch.png"></td><!-- ############### group dependent-->
<td class="sml01" width="99%" background="./imagefiles/bgcolor.png">&nbsp;</td>
</tr></tbody></table>
<table cellspacing="0" cellpadding="0" width="100%" bgcolor="#ffffff" border="0" style="margin-bottom:3%">
    <tbody><tr valign="top"> 
      <td background="./imagefiles/bg02.gif"><img src="./imagefiles/spacer.gif" width="94" height="1" alt=""></td>
      <td><img width="8" height="400" src="./imagefiles/spacer.gif" border="0" alt=""></td>
      <td id="inputtd" align="left" nowrap="" bgcolor="#ffffff" width="50%">
<!-- The closing half of the body frame is in half_frame_close.inc-->

<table border="0" cellspacing="0" cellpadding="0" class="docTitle"><tbody><tr>
	  <td width="10" rowspan="2"><img height="20" src="./imagefiles/spacer.gif" width="10" alt=""></td>
<td>
   <table border="0" cellpadding="0" cellspacing="0" width="8" height="20">
      <tbody><tr>
         <td bgcolor="#336699"><img height="20" src="./imagefiles/spacer.gif" width="8" alt=""></td>
      </tr>
   </tbody></table>
</td>
<td width="10"><img height="20" src="./imagefiles/spacer.gif" width="10" alt=""></td>

		<td>
                <a href="http://pir.georgetown.edu/pirwww/" class="titleLink"><b>HOME</b></a>
								   / <a href="http://pir.georgetown.edu/pirwww/search/" class="titleLink"><b>Search</b></a>
                    / <b><i>Peptide Match - Command Line Tool</i></b><!-- ############### page dependent-->
    </td></tr>
</tbody></table>
	<br/><br/>
   <table cellspacing="0" cellpadding="9" border="0" width="100%" bgcolor="#ffffff" class="nrm02">
      <tbody>
      <tr><td align="right">
<span style="font-size: 10px;"><a href="docs/userguide.htm#restful" target="_blank"><b>API 1.0</b></a> | <a href="api/v2/" target="_blank"><b>API 2.0</b></a></span><br/><br/>
<a href="./index.jsp"><b>Single Peptide Match</b></a> | <a href="./batchpeptidematch.jsp" ><b>Multiple Peptide Match</b></a> 

 </td></tr>
      <tr>
       <td><table width="100%" bgcolor="#ffffff" cellpadding="8" cellspacing="0" class="boxTable">
                  <tbody><tr>
									<!-- ########### page dependent block. modify it -->
                    <th class="right" id="th_formtitle" colspan="1" width=97% align="left">Command Line Tool</th>  
<!--
<th class="right" id="th_link" width=3% colspan="1" align="right"><a  href="docs/userguide.htm#single" target="_blank"><img src="./imagefiles/question11.gif" border=0"></a></th>
-->
									<!-- ########### end of page dependent block. -->
                  </tr>

                  <tr>
                    <td class="nrm02">
                    <!-- ######### MAIN content -->
<form class=inputform action=peptidewithorganisms.jsp method=post name="searchform" onSubmit="return PeptideInputCheck(this)">
<table class="nrm02" border="0" width=100%>
<tbody>
<!--
<tr><td colspan=4 align="right"><span style="color: navy; font-weight: bold;"><%=version%></span> </td></tr>
-->
<tr><td>
	<p>A command line tool allows users to query the peptide sequences against their own customized protein sequence database. </p>
	<p>The tool provides two major functionalities: <br>
		<ol>
			<li>Given a protein sequence database in FASTA format, create the Lucene index for it.</li>
			<li>Query the peptide sequences against the above index. The query can be:
				<ul>
					<li>A peptide sequence or a comma-separated list of peptide sequences or </li>
					<li>A file in either FASTA format or a list of peptide sequences, one sequence per line.</li>
				</ul>  
			</li>
		</ol>
	</p> 
<h3>From Native OS</h3>
	<p>The runnable jar can be downloaded at <a href="downloads/PeptideMatchCMD_1.0.jar">here</a>. The source code is also availabe at <a href="downloads/PeptideMatchCMD_src_1.0.zip">here</a>.

	<p><b>Run from executable jar</b><br/>
<pre>
$ java -jar PeptideMatchCMD_1.0.jar -h
Command line options: -h 
usage: java -jar PeptideMatchCMD_1.0.jar [options]
            Available options:
            ------------------
 -a,--action <arg>       The action to perform ("index" or "query").
 -d,--dataFile <arg>     The path to a FASTA file to be indexed.
 -e,--LeqI               Treat Leucine (L) and Isoleucine (I) as
                         equivalent (default: no).
 -f,--force              Overwrite the indexDir (default: no).
 -h,--help               Print this message.
 -i,--indexDir <arg>     The directory where the index is stored.
 -l,--list               The query peptide sequence file is a list of
                         peptide sequences, one sequence per line
                         (default: no).
 -o,--outputFile <arg>   The path to the query result file.
 -Q,--queryFile <arg>    The path to the query peptide sequence file in
                         either FASTA format or a list of peptide
                         sequences, one sequence per line.
 -q,--query <arg>        One peptide sequence or a comma-separated list of
                         peptide sequences.
</pre>
</p>
<p><b>Compile from source</b>
<pre>
$ unzip PeptideMatchCMD_src_1.0.zip
$ cd PeptideMatchCMD_src_1.0
$ ant
$ java -jar PeptideMatchCMD_1.0.jar -h
</pre>
</p>
	<p><b>Tutorial</b>
		<ul>
			<li>Creating Lucene index using a protein sequence database in FASTA format:
<pre>
$ java -jar PeptideMatchCMD_1.0.jar -a index -d uniprot_sprot.fasta -i sprot_index 
Command line: -a index -d uniprot_sprot.fasta -i sprot_index 
Indexing to directory "sprot_index" ...
Indexing "uniprot_sprot.fasta" ...
Indexing "uniprot_sprot.fasta" finished
Time used: 00 hours, 06 mins, 31.215 seconds
</pre>
			</li>
			<li>Query a peptide sequence:
<pre>
$ java -jar PeptideMatchCMD_1.0.jar -a query -i sprot_index -q AAFGGSGGR -o out.txt 
Command line: -a query -i sprot_index -q AAFGGSGGR -o out.txt 
Quering...

AAFGGSGGR	has 1 match

Query is finished.
The result is saved in "out.txt".
Time used: 00 hours, 00 mins, 00.457 seconds

$ cat out.txt 
#Command line: -a query -i sprot_index -q AAFGGSGGR -o out.txt 
##Query	Subject	SubjectLength	MatchStart	MatchEnd
AAFGGSGGR	sp|P35908|K22E_HUMAN	639	516	524
</pre>
			</li>
			<li>Query a list of peptide sequences:
<pre>
$ java -jar PeptideMatchCMD_1.0.jar -a query -i sprot_index -q AAFGGSGGR,GVPDIR -o out.txt 
Command line: -a query -i sprot_index -q AAFGGSGGR,GVPDIR -o out.txt 
Quering...

AAFGGSGGR	has 1 match
GVPDIR	has 4 matches

Query is finished.
The result is saved in "out.txt".
Time used: 00 hours, 00 mins, 00.493 seconds

$ cat out.txt 
#Command line: -a query -i sprot_index -q AAFGGSGGR,GVPDIR -o out.txt 
##Query	Subject	SubjectLength	MatchStart	MatchEnd
AAFGGSGGR	sp|P35908|K22E_HUMAN	639	516	524	
GVPDIR	sp|Q9CK59|Y1775_PASMU	92	45	50	
GVPDIR	sp|B1Y8E7|PYRB_LEPCP	320	194	199	
GVPDIR	sp|B4SHE6|MURD_PELPB	464	252	257	
GVPDIR	sp|Q6FX42|ATR_CANGA	2379	1135	1140
</pre>
			</li>
			<li>Query a list of peptide sequences and treat Leucine (L) and Isoleucine (I) as equivalent:
<pre>
$ java -jar PeptideMatchCMD_1.0.jar -a query -i sprot_index -q AAFGGSGGR,GVPDIR -e -o out.txt 
Command line: -a query -i sprot_index -q AAFGGSGGR,GVPDIR -e -o out.txt 
Quering...

AAFGGSGGR	has 1 match
GVPDIR	has 13 matches

Query is finished.
The result is saved in "out.txt".
Time used: 00 hours, 00 mins, 00.513 seconds

$ cat out.txt 
#Command line: -a query -i sprot_index -q AAFGGSGGR,GVPDIR -e -o out.txt 
##Query	Subject	SubjectLength	MatchStart	MatchEnd	MatchedLEqIPositions
AAFGGSGGR	sp|P35908|K22E_HUMAN	639	516	524	
GVPDIR	sp|Q9CK59|Y1775_PASMU	92	45	50	
GVPDIR	sp|A0R5Z2|GLFT1_MYCS2	302	182	187	186
GVPDIR	sp|Q7D4V6|GLFT1_MYCTU	304	179	184	183
GVPDIR	sp|B1Y8E7|PYRB_LEPCP	320	194	199	
GVPDIR	sp|A5GDX3|RECF_GEOUR	364	126	131	130
GVPDIR	sp|P96919|EX5A_MYCTU	575	138	143	142
GVPDIR	sp|Q17QV2|MON1A_BOVIN	555	441	446	445
GVPDIR	sp|Q2QZ37|OBGM_ORYSJ	528	500	505	504
GVPDIR	sp|B4SHE6|MURD_PELPB	464	252	257	
GVPDIR	sp|Q9M1G3|LRK16_ARATH	669	595	600	599
GVPDIR	sp|Q5U3H2|SV421_DANRE	808	575	580	579
GVPDIR	sp|A6H5Y3|METH_MOUSE	1253	1147	1152	1151
GVPDIR	sp|Q6FX42|ATR_CANGA	2379	1135	1140
</pre>
			</li>
			<li>Query peptides in a <a href="downloads/query.fasta">FASTA</a> file:
<pre>
$ java -jar PeptideMatchCMD_1.0.jar -a query -i sprot_index -Q query.fasta -e -o out_fasta.txt 
Command line: -a query -i sprot_index -Q query.fasta -e -o out_fasta.txt 
Quering...

example_1	has 1 match
example_2	has 1 match
example_3	has 1 match
example_4	has 1 match
example_5	has 1 match
example_6	has 1 match
example_7	has 1 match
example_8	has 1 match
example_9	has 1 match
example_10	has 1 match

Query is finished.
The result is saved in "out_fasta.txt".
Time used: 00 hours, 00 mins, 00.724 seconds
</pre>
			</li> 
			<li>Query peptides in a <a href="downloads/query.list">list</a> file, one peptide per line:
<pre>
$ java -jar PeptideMatchCMD_1.0.jar -a query -i sprot_index -Q query.list -l -e -o out_list.txt 
Command line: -a query -i sprot_index -Q query.list -l -e -o out_list.txt 
Quering...

AAFGGSGGR	has 1 match
ELEVQSEDGTFAK	has 1 match
FEDPAEGEDTLVEK	has 1 match
FSDGLITPDFLAK	has 1 match
GAPEFWAAR	has 1 match
GVIEANGGKVEK	has 1 match
HIPVYVSEEMVGHKFGEFSPTR	has 1 match
HNDVNFGTQDHNR	has 1 match
IGFYLTTCPR	has 1 match
ILVGQGNDGVAFVK	has 1 match

Query is finished.
The result is saved in "out_list.txt".
Time used: 00 hours, 00 mins, 00.752 seconds
</pre>
			</li> 
		</ul>
	</p>	
<h3>From Docker Container</h3> 
<ul>
	<li>Set up local working directory to hold input and output files. It will be mounted into Docker container.
<pre>
$ mkdir /your/localworkdir/

$ cd /your/localworkdir/

$ ls 
uniprot_sprot.fasta query.list query.fasta
</li>
<li>Creating Lucene index using a protein sequence database in FASTA format:
<pre>
$ docker run -v /your/localworkdir/:/workdir chenc/peptidematch \
	-a index -d /workdir/uniprot_sprot.fasta -i /workdir/uniprot_sprot_index -f
Unable to find image 'chenc/peptidematch:latest' locally
latest: Pulling from chenc/peptidematch
7448db3b31eb: Pull complete 
c36604fa7939: Pull complete 
29e8ef0e3340: Pull complete 
a0c934d2565d: Pull complete 
a360a17c9cab: Pull complete 
cfcc996af805: Pull complete 
2cf014724202: Pull complete 
4bc402a00dfe: Pull complete 
1da5b1324a69: Pull complete 
Digest: sha256:923a488fad501b35de6629309a02f6aa786d42edb7aa0666691aa861bbfd831f
Status: Downloaded newer image for chenc/peptidematch:latest
Command line options: -a index -d /workdir/uniprot_sprot.fasta -i /workdir/uniprot_sprot_index -f 
Indexing to directory "/workdir/uniprot_sprot_index" ...
Indexing "/workdir/uniprot_sprot.fasta" ...
Indexing "/workdir/uniprot_sprot.fasta" finished
Time used: 00 hours, 03 mins, 31.116 seconds
</pre>
</li>
<li>Query a peptide sequence:
<pre>
$ docker run -v /your/localworkdir/:/workdir chenc/peptidematch \
	-a query -q NEKKQQMGKEYREKIEAEL -i /workdir/uniprot_sprot_index -o /workdir/single_query_out.txt
Command line options: -a query -q NEKKQQMGKEYREKIEAEL -i /workdir/uniprot_sprot_index -o /workdir/single_query_out.txt 
Quering...

NEKKQQMGKEYREKIEAEL	has 6 matches

Query is finished.
The result is saved in "/workdir/single_query_out.txt".
Time used: 00 hours, 00 mins, 00.935 seconds
</pre>
</li>

<li>Query a list of peptide sequences:
<pre>
$ docker run -v /your/localworkdir/:/workdir chenc/peptidematch \
	-a query -q NEKKQQMGKEYREKIEAEL,EAFEISKKE -i /workdir/uniprot_sprot_index -o /workdir/multi_query_out.txt
Command line options: -a query -q NEKKQQMGKEYREKIEAEL,EAFEISKKE -i /workdir/uniprot_sprot_index -o /workdir/multi_query_out.txt 
Quering...

NEKKQQMGKEYREKIEAEL	has 6 matches
EAFEISKKE	has 15 matches

Query is finished.
The result is saved in "/workdir/multi_query_out.txt".
Time used: 00 hours, 00 mins, 00.685 seconds
</pre>
</li>
<li>Query peptides in a <a href="downloads/query.fasta">FASTA</a> file:
<pre>
$ docker run -v /your/localworkdir/:/workdir chenc/peptidematch \
	-a query -Q /workdir/query.fasta -i /workdir/uniprot_sprot_index -o /workdir/fasta_query_out.txt
Command line options: -a query -Q /workdir/query.fasta -i /workdir/uniprot_sprot_index -o /workdir/fasta_query_out.txt 
Quering...

example_1	has 1 match
example_2	has 1 match
example_3	has 1 match
example_4	has 1 match
example_5	has 1 match
example_6	has 1 match
example_7	has 1 match
example_8	has 1 match
example_9	has 1 match
example_10	has 1 match

Query is finished.
The result is saved in "/workdir/fasta_query_out.txt".
Time used: 00 hours, 00 mins, 01.733 seconds
</pre>
</li>
<li>Query peptides in a <a href="downloads/query.list">list</a> file, one peptide per line:
<pre>
$ docker run -v /your/localworkdir/:/workdir chenc/peptidematch \
	-a query -Q /workdir/query.list -l -i /workdir/uniprot_sprot_index -o /workdir/list_query_out.txt
Command line options: -a query -Q /workdir/query.list -l -i /workdir/uniprot_sprot_index -o /workdir/list_query_out.txt 
Quering...

AAFGGSGGR	has 1 match
ELEVQSEDGTFAK	has 1 match
FEDPAEGEDTLVEK	has 1 match
FSDGLITPDFLAK	has 1 match
GAPEFWAAR	has 1 match
GVIEANGGKVEK	has 1 match
HIPVYVSEEMVGHKFGEFSPTR	has 1 match
HNDVNFGTQDHNR	has 1 match
IGFYLTTCPR	has 1 match
ILVGQGNDGVAFVK	has 1 match

Query is finished.
The result is saved in "/workdir/list_query_out.txt".
Time used: 00 hours, 00 mins, 01.432 seconds
</pre>
</li>
 <ul>

</td></tr>
</tbody></table>
</form>
				            <!-- ######### end of MAIN content -->
						        </td>
                  </tr>
				
                </tbody></table>
            </td>
           </tr>
        </tbody></table>
<!-- ############## end of page dependent block-->
<!-- ############## end of page dependent block-->


   <!-- This is a second half of body frame. The first half is in half_frame_close.inc"-->
      </td>
      <td width="100%" background="./imagefiles/bg02.gif" align="right" bgcolor="#ffffff"><img src="./imagefiles/spacer.gif" width="1" height="1" alt=""></td>
    </tr>
</tbody></table>

<!-- FOOTER -->
<table cellspacing="0" cellpadding="0" width="100%" bgcolor="#eeeeee" border="0" class="nrm02">
  <tbody>
    <tr> 
			<td align="center" valign="middle" nowrap="" bgcolor="#71a1cf">
				<img src="./imagefiles/pirlogo2.png" alt="PIR">
			</td>
      <td align="left" valign="top"> 
        <table background="./imagefiles/spacer.gif" width="686" border="0" cellpadding="3" cellspacing="0" class="nrm02">
          <tbody>
            <tr> 
              <td align="left" valign="bottom" nowrap="">
                  &nbsp;<a href="http://pir.georgetown.edu/pirwww/" target="_blank" class="footerMenu">Home</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/about/" target="_blank" class="footerMenu">About PIR</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/dbinfo" target="_blank" class="footerMenu">Databases</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/search/" target="_blank" class="footerMenu">Search/Analysis</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/download/" target="_blank" class="footerMenu">Download</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/support/" target="_blank" class="footerMenu">Support</a>
              </td>
              <td align="right" valign="bottom" nowrap="" class="nrm01">
                  &nbsp;<a href="http://pir.georgetown.edu/pirwww/support/sitemap.shtml" target="_blank" class="footer">SITE MAP</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/about/linkpir.shtml" target="_blank" class="footer">TERMS OF USE</a>
              </td>
            </tr>
            <tr> 
              <td colspan="2" align="center" nowrap="" class="footer3"><span class="nrm10"><font color="#999999"> &copy; 2018</font>
                                    <img src="./imagefiles/spacer.gif" alt="" width="20" height="1">
                                    <b><a href="http://pir.georgetown.edu/pirwww/index.shtml" target="_blank">Protein Information Resource</a></b>
                                    <img src="./imagefiles/spacer.gif" alt="" width="105" height="1"></span></td>
            </tr>

            <tr><td colspan="2" nowrap=""><table border="0" cellpadding="2" cellspacing="0" class="nrm02" width="100%">
                         <tbody><tr><td><img src="./imagefiles/spacer.gif" alt="" width="50" height="1"></td>
                             <td nowrap="" align="center" class="footer"><a href="http://bioinformatics.udel.edu/"><font color="#999999">University of Delaware</font></a>
                                          <br><font color="#999999">15 Innovation Way, Suite 205
                                          <br>Newark, DE 19711, USA</font></td>
                             <td><img src="./imagefiles/spacer.gif" alt="" width="20" height="1"></td>

                            <td nowrap="" align="center" class="footer"><a href="http://gumc.georgetown.edu/"><font color="#999999">Georgetown University Medical Center</font></a>
                                  <br><font color="#999999">3300 Whitehaven Street, NW, Suite 1200
                                  <br>Washington, DC 20007, USA</font></td>
                          </tr></tbody></table></td>

            </tr>
          </tbody>
        </table></td>
			<td width="99%">&nbsp;
			</td>       
    </tr>
</tbody>
</table>

</td></tr></tbody></table>
 
</body>

<!-- Menu Related -->
<script language="javascript" src="./imagefiles/milonic_src.js"
	type="text/javascript"></script>
<script language="javascript">
  if(ns4) _d.write("<scr"+"ipt language=JavaScript src=./imagefiles/mmenuns4.js><\/scr"+"ipt>");		
    else _d.write("<scr"+"ipt language=JavaScript src=./imagefiles/mmenudom.js><\/scr"+"ipt>"); 
</script>
<script language="JavaScript" src="./imagefiles/mmenudom.js"></script>
<script>function getflta(ap){return _f}</script>
<script language="javascript" src="./imagefiles/menu_data.js"
	type="text/javascript"></script>
<!-- Menu Related ends -->

<!-- Input process starts -->
<!--
<script language="JavaScript" src="./imagefiles/peptidesearch.js"> </script>
-->
<script language="JavaScript" src="js/peptidesearch.js"> </script>
<!-- Input process ends -->
</html>
