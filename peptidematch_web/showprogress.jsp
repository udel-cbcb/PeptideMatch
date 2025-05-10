<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Batch Peptide Match [PIR - Protein Information Resource]</title><!-- ##### page dependent-->
  	<link href="./imagefiles/styles.css" type="text/css" rel="stylesheet">
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
        <script type="text/javascript">
            $(document).ready(init);

            function init() {
                if (${not empty longProcess}) {
                    checkProgress();
                }
            }
            function checkProgress() {
                jQuery.get('batchpeptidematch', function(progress) {
                    jQuery('#progress').html(progress);
                        if(progress.indexOf("Finished") == -1) {
                                setTimeout(checkProgress, 1000);
                                
                        }
                });
		}
		window.onload=function () {
     var objDiv = document.getElementById("progress");
     objDiv.scrollTop = objDiv.scrollHeight;
}
        </script>
<!--
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
-->
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
<!--
 <body bgcolor="#cccccc" background="./imagefiles/bg02.gif" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0"><span id="progress" class="hide2"><form name="dialog"><table width="220" height="70" border="4" cellpadding="0" cellspacing="0" align="center" bgcolor="#FFFFFF"><tbody><tr><td align="center"> Processing ... <br><input type="text" name="bar" size="25" bar.style="color:navy;"><br></td></tr></tbody></table></form></span>
-->
 <body bgcolor="" background="./imagefiles/bg02-1.gif" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<table border="0" cellspacing="0" cellpadding="0" width="100%"><tbody><tr><td>
<map name="PIRBanner_Map">
<area shape="rect" alt="home" coords="16,16,110,60" href="http://pir.georgetown.edu/pirwww/index.shtml" target="_top">
<area shape="rect" alt="uniprot" coords="140,36,178,50" href="http://www.uniprot.org/" target="_blank">
</map>	
<table cellspacing="0" cellpadding="0" width="100%" border="0" height="80">
    <tbody><tr> 
      <td><img alt="" src="./imagefiles/PIRBanner.png" border="0" usemap="#PIRBanner_Map"></td> 
      <td width="99%" nowrap="" height="1" background="./imagefiles/blueSpacer.png">
		<img alt="" src="./imagefiles/spacer.gif" width="1" height="1" border="0">
	  </td>
      <td align="right" valign="top" height="80" width="400" background="./imagefiles/gradientHome6.png">
         <table border="0" cellpadding="0" cellspacing="0" width="400" height="80">
          <form action="http://pir.georgetown.edu/cgi-bin/textsearch.pl" id="textSearch" method="get" name="textSearchForm" style="MARGIN: 0px"></form>
            <tbody><tr>
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

          
        </tbody></table>
      </td>
    </tr>
</tbody></table>




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

<table cellspacing="0" cellpadding="0" width="100%" bgcolor="#333333" border="0"><tbody><tr>
	<td><img src="./imagefiles/leftSearch.png"></td><!-- ############### group dependent-->
	<td class="sml01" width="99%" background="./imagefiles/bgcolor.png">&nbsp;</td>
</tr></tbody></table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="docTitle"><tbody><tr>
	<td width=100></td>
          <td width="10" rowspan="2"><img height="20" src="./imagefiles/spacer.gif" width="10" alt="???"></td>
         	<td bgcolor="#336699" width=8><img height="20" src="./imagefiles/spacer.gif" width="8" alt=""></td>
		<td width=10></td>
                <td>
                <a href="http://pir.georgetown.edu/pirwww/" class="titleLink"><b>HOME</b></a>
                                                                   / <a href="http://pir.georgetown.edu/pirwww/search/" class="titleLink"><b>Search</b></a>
                    / <b><a href="batchpeptidematch.jsp">Batch Peptide Match</a></b><!-- ############### page dependent-->
    </td></tr>
</tbody></table>

<div style="margin-left: 80px;">
<table cellspacing="0" cellpadding="0" width="100%" bgcolor="#ffffff" border="0" >
    <tbody>
	<tr valign="top"> 
      <td id="inputtd" align="left" nowrap="" bgcolor="#ffffff" width="50%">
	<br/>
	<div id="progress"></div>
	<br/>
	<br/>
	<br/>
	<br/>
    </tr>
</tbody></table>
</div>
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
<script language="JavaScript" src="js/peptidesearch.js"> </script>
<!-- Input process ends -->



</html>
