<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%
	session.invalidate();
        Properties properties = new Properties();
	InputStream inputStream = null; 
	String version = "";
	String totalSeq = "";
	try {
		inputStream = this.getClass().getClassLoader().getResourceAsStream("config/index.properties");
                properties.load(inputStream);
                version = properties.getProperty("version");
                totalSeq = properties.getProperty("total_sequence");
                
	}
	catch(IOException ioe) {
		ioe.printStackTrace();
	}
%>
<html><head>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="save" content="history">
	<title>Peptide Match [PIR - Protein Information Resource]</title><!-- ##### page dependent-->
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
                    / <b><i>Peptide Match</i></b><!-- ############### page dependent-->
    </td></tr>
</tbody></table>
	<br/><br/>
   <table cellspacing="0" cellpadding="9" border="0" width="100%" bgcolor="#ffffff" class="nrm02">
      <tbody>
	<tr><td valign="top" align="right"><span style="font-size: 10px;"><a href="docs/userguide.htm#restful" target="_blank"><b>API 1.0</b></a> | <a href="api/v2/" target="_blank"><b>API 2.0</b></a> | <a href="commandlinetool.jsp"><b>Command Line Tool</b></a></span><br/><br/>
      <a href="./batchpeptidematch.jsp" ><b>Multiple Peptide Match</b></a> </td></tr>
      <tr>
       <td><table width="100%" bgcolor="#ffffff" cellpadding="8" cellspacing="0" class="boxTable">
                  <tbody><tr>
									<!-- ########### page dependent block. modify it -->
                    <th class="right" id="th_formtitle" colspan="1" width=97% align="left">Single Peptide Match</th>  <th class="right" id="th_link" width=3% colspan="1" align="right"><a  href="docs/userguide.htm#single" target="_blank"><img src="./imagefiles/question11.gif" border=0"></a></th>
									<!-- ########### end of page dependent block. -->
                  </tr>

                  <tr>
                    <td class="nrm02">
                    <!-- ######### MAIN content -->
<form class=inputform action=peptidewithorganisms.jsp method=post name="searchform" onSubmit="return PeptideInputCheck(this)">
<table class="nrm02" border="0" width=100%>
<tbody>
<tr><td colspan=4 align="right"><span style="color: navy; font-weight: bold;"><%=version%></span> (<%=totalSeq%> sequences)</td></tr>
<tr><td><img src='./imagefiles/transparent_dot.png' height=25></td>
<td valign=top nowrap id='org_options'><br/><br/><b>1.</b>
<div style="display: none;">
&nbsp;Select sequence data set:<br>
&nbsp;&nbsp;&nbsp;&nbsp;a) <input type="radio"  id="select_all" name="input_option"  value="all" onClick="close_orgSelect();close_orgInput();" checked>All UniprotKB plus isoform sequences <br/>
&nbsp;&nbsp;&nbsp;&nbsp;b) 
</div>
Restrict by organism:<br/>
&nbsp;&nbsp;&nbsp;<input TYPE="radio" id="input_organism" name="input_option" value="input" onClick="close_orgSelect();show_orgInput();" >Enter an organism from UniProt <a href="http://www.uniprot.org/taxonomy/?query=complete:yes">complete proteomes</a><br>
<div id="organism_name_div">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" id="organism_name" name="organism_name" value="Type an organism name or an taxon ID here" alt="Input the organism name" autocomplete="off" onkeydown="shiftFocus(event)" onkeyup="inputSuggest();" onfocus="if(!this._haschanged){this.value=''};this._haschanged=true;" style="width:400px"/> <br> </div>
<input type="hidden" name="organism_id">
<div id="result_newline"><div id="result_display" style="width:400px"></div><br> </div>
&nbsp;&nbsp;&nbsp;<input TYPE="radio" name="input_option" value="select" onClick="close_orgInput();show_orgSelect();" >Select organisms from UniProt <a href="http://www.uniprot.org/taxonomy/?query=reference:yes">reference proteomes</a> list<br>
<span id="organismlink" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="#" name="abanner" id="A" onclick="showOrganism('A');">[A]</a>
<a href="#" name="abanner" id="B" onclick="showOrganism('B');">[B]</a>
<a href="#" name="abanner" id="C" onclick="showOrganism('C');">[C]</a>
<a href="#" name="abanner" id="DE" onclick="showOrganism('DE');">[DE]</a>
<a href="#" name="abanner" id="FG" onclick="showOrganism('FG');">[FG]</a>
<a href="#" name="abanner" id="H" onclick="showOrganism('H');">[H]</a>
<a href="#" name="abanner" id="IJKL" onclick="showOrganism('IJKL');">[IJKL]</a>
<a href="#" name="abanner" id="M" onclick="showOrganism('M');">[M]</a>
<a href="#" name="abanner" id="NO" onclick="showOrganism('NO');">[NO]</a>
<a href="#" name="abanner" id="PQ" onclick="showOrganism('PQ');">[PQ]</a>
<a href="#" name="abanner" id="R" onclick="showOrganism('R');">[R]</a>
<a href="#" name="abanner" id="S" onclick="showOrganism('S');">[S]</a>
<a href="#" name="abanner" id="T" onclick="showOrganism('T');">[T]</a>
<a href="#" name="abanner" id="UVWXYZ" onclick="showOrganism('UVWXYZ');">[UVWXYZ]</a>
<a href="#" onclick="click_close()"><img src="./imagefiles/off.png"></a></span>
<br>
<div id="show_selected_count"></div>
<span id=organism></span>
</td>
</tr>
<tr>
<td><img src='./imagefiles/transparent_dot.png' height=25></td><td colspan="4" style="white-space: nowrap;"><br/><b>2.</b>&nbsp;Insert a peptide using single letter
<a href="http://pir.georgetown.edu/pirwww/support/help.shtml#14">amino acid code</a> (3 or more) below:</td>
</tr>
<tr><td><img src="./imagefiles/transparent_dot.png" width="50" height="50"></td>
<td colspan="4" nowrap="">
&nbsp;&nbsp;
<input type=text name="keyword" id="keyword" class="keyword" size=110 onfocus="verifyOrganismInput();if(!this._haschanged){this.value=''};this._haschanged=true;" autocomplete="off"> 
<input type="hidden" name="start" value=0> 
<input type="hidden" name="initialed" value="false">
<input type="hidden" name="searchtype" value="peptide">
<input type="hidden" name="rows" value="20">
	<font style="font-size: smaller; margin-left: 15px;">
	<!--
		Example: AAVEEGIVLGGGCALLR (<a href="peptidewithorganisms.jsp?keyword=AAVEEGIVLGGGCALLR&start=0&initialed=false&organism_id=all&rows=20">sample output</a>)
		Example: AAVEEGIVLGGGCALLR (<a href="peptidewithorganisms.jsp?input_option=all&organism_name=&organism_id=all&keyword=AAVEEGIVLGGGCALLR&start=0&initialed=false&searchtype=peptide&rows=20&uniref100=N&lEqi=N">sample output</a>)
		Example: <a href="peptidewithorganisms.jsp?input_option=all&organism_name=&organism_id=all&keyword=AAVEEGIVLGGGCALLR&start=0&initialed=false&searchtype=peptide&rows=20&uniref100=N&lEqi=N">AAVEEGIVLGGGCALLR</a>
-->
		<br/><br/>&nbsp;&nbsp;&nbsp;Example: <a href="javascript:void(0)" onclick="document.getElementById('keyword').value='AAVEEGIVLGGGCALLR';">AAVEEGIVLGGGCALLR</a> (<a href="peptidewithorganisms.jsp?keyword=AAVEEGIVLGGGCALLR&start=0&initialed=false&organism_id=all&rows=20">sample output</a>)
/ <a href="docs/userguide.htm#table">annotated output)</a>
	</font><br/>
	<table class=nrm02>
		<tr>
<br/><br/><b>3.</b>&nbsp;Options:<br/>
&nbsp;&nbsp;&nbsp;a) UniProt/SwissProt only<br/>&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" name="swissprot" value="Y" checked>Yes&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" name="swissprot" value="N">No<br/><br/>
&nbsp;&nbsp;&nbsp;b) Include Isoforms<br/>&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" name="isoform" value="Y" checked>Yes&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" name="isoform" value="N" >No<br/><br/>
&nbsp;&nbsp;&nbsp;c) UniRef100 representative sequences only<br/>&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" name="uniref100" value="Y" >Yes&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" name="uniref100" value="N" checked>No<br/><br/>
&nbsp;&nbsp;&nbsp;d) Treat Leucine (L) and Isoleucine (I) equivalent<br/>&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" name="lEqi" value="Y">Yes&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" name="lEqi" value="N" checked>No
</td>

		</tr>
	</table>
	<br/>
&nbsp;&nbsp;&nbsp;<input type="submit" value="Submit" class="nrm02">
&nbsp;&nbsp;&nbsp;<input type="reset"  value="Reset" class="nrm02">
</td>
		</tr>

<!--
		<tr><td></td><td class="nrm11" colspan="4" style="white-space: nowrap;">
		&nbsp;&nbsp;&nbsp;	
		<b>	Delays may be experienced due to heavy loads on our server or network traffic.</b></td>
		</tr>
-->
</tbody></table>
</form>
				            <!-- ######### end of MAIN content -->
						        </td>
                  </tr>
				
                </tbody></table>
            </td>
           </tr>
	<tr>
	<td>
		<br/>
		<p><b>Publication</b></p>
		<p style="font-size: smaller;">
Chuming Chen; Zhiwen Li; Hongzhan Huang; Baris E. Suzek; Cathy H. Wu; UniProt Consortium. <br/><a href="http://bioinformatics.oxfordjournals.org/content/29/21/2808">A fast Peptide Match Service for UniProt Knowledgebase</a>. <br/><i>Bioinformatics</i> 2013; doi: 10.1093/bioinformatics/btt484.
		</p>
	</td>
	</tr>
<!--
<tr>
<td><a href="docs/userguide.htm#restful" target="_blank">RESTful Web Services API</a> <img width=35 src='./imagefiles/New_icons.gif'></td>
</tr>
->
<!--
<tr>
<td><br/><br/>Please email <img align="center" src="images/chenc_at_udel.gif"> for bug report and feature request.</td>
</tr>
-->
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
