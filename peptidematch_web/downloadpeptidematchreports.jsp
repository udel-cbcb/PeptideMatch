<%@ page session="true" %>
<%@ page import="java.io.*" %>
<%@ page import ="java.util.*" %>
<%@ page import ="java.util.zip.*" %>
<%@ page import = "javax.servlet.*" %>
<%
	String content = "";
	String[] reports = request.getParameterValues("reports");
   	if (reports != null) {
      		for (int i = 0; i < reports.length; i++) 
      		{
         		content += ("<b>"+reports[i]+"<b><br/>");
      		}
   	}
   	else content += ("<b>none<b>");
/*public class Zipall
{ 
public static void main(String[] args) throws IOException 
{ 
File[] files = {new File("test1.txt"), new File("test2.txt")}; 
String dirPath = "testdir"; 
File zipFileName = new File("myArchive.zip"); 
ZipOutputStream out = new ZipOutputStream(new FileOutputStream(zipFileName)); 
zipFiles(files, out); 
zipDirectory(dirPath, out); 
out.close(); 
} 
*/

	String jobId = "";
	content = "";	
	if(request.getParameter("jobId") != null) {
		jobId = request.getParameter("jobId");
		if(content.length() == 0) {
			Properties properties = new Properties();
        		InputStream inputStream = null;
        		String batchWD = (String) request.getSession().getAttribute("batchWD");
        		if(batchWD == null) {
                		try {
                       			inputStream = this.getClass().getClassLoader().getResourceAsStream("config/index.properties");
                        		properties.load(inputStream);
                        		batchWD = properties.getProperty("batchWD");
                        		request.getSession().setAttribute("batchWD", batchWD);
                		}
                		catch(IOException ioe) {
                        		ioe.printStackTrace();
                		}
        		}
			//if(reports.length == 1 && !reports[0].equals("perPeptideDetails")) {
			if(reports.length == 1) {
				content = sendTextFile(batchWD, jobId, reports[0], response);	
			}
			else {
				content = sendZipFile(batchWD, jobId, reports, response);	
				//System.out.println("reportlength: "+reports.length);	
			} 
		}
	}
	else {
		content = "<font color=red>Invalid job ID!</font>";
	}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Batch Peptide Match [PIR - Protein Information Resource]</title><!-- ##### page dependent-->
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
<script type="text/javascript">
window.onload = function(){ document.getElementById("loading").style.display = "none" }   
</script>

<style>
 <style type="text/css">
loading {width: 100%;height: 100%;top: 0px;left: 0px;position: fixed;display: block; z-index: 99}

loading-image {position: absolute;top: 40%;left: 45%;z-index: 100} 
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
 <body bgcolor="" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
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
<!--
<div id="loading">
<img id="loading-image" src="images/spinning-wait-icons/wait24trans.gif" alt="Loading..." />
</div>
-->
<div style="margin-left: 80px;">
<table cellspacing="0" cellpadding="0" width="100%" bgcolor="#ffffff" border="0" >
    <tbody>
	<tr valign="top"> 
      <td id="inputtd" align="left" nowrap="" bgcolor="#ffffff" width="50%">
	<br/>
	<%= content %>	
	<br/>
	<br/>
	<br/>
      </td>
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
<%!
	private String readFile(String filePathAndName) {
		System.out.println(filePathAndName);
        	StringBuffer fileContent = new StringBuffer();
        	try {
                	File file = new File(filePathAndName);
                	FileReader fr = new FileReader(file);
                	BufferedReader br = new BufferedReader(fr);
                	String line = null;
                	while((line = br.readLine()) != null) {
                        	fileContent.append(line+"\n");
                	}
                	br.close();
        	}
        	catch(IOException ioe) {
                	ioe.printStackTrace();
        	}
        	return fileContent.toString();
    	}

	

	private void zipFiles(File[] files, ZipOutputStream zos) { 
		System.out.println("Zip files ...");
		try { 
			byte[] buffer = new byte[1024]; 
			//ZipOutputStream out = new ZipOutputStream(new FileOutputStream(zipFileName)); 
			//out.setLevel(Deflater.DEFAULT_COMPRESSION); 
			for (int i = 0; i < files.length; i++) { 
				System.out.println("???Before :"+files[i].getName());
				FileInputStream in = new FileInputStream(files[i]); 
				//zos.putNextEntry(new ZipEntry(files[i].getPath())); 

				//zos.putNextEntry(new ZipEntry(files[i].getPath())); 
				zos.putNextEntry(new ZipEntry(files[i].getName())); 
				int len; 
				while ((len = in.read(buffer)) > 0) { 
					zos.write(buffer, 0, len); 
				}	 
				//out.closeEntry(); 
				in.close(); 
				System.out.println("???after :"+files[i].getName());
			} 
			//out.close(); 
		} 
		catch (IllegalArgumentException iae) { 
			iae.printStackTrace(); 
		} 
		catch (FileNotFoundException fnfe) { 
			fnfe.printStackTrace(); 
		} 
		catch (IOException ioe) { 
			ioe.printStackTrace(); 
		} 
	} 


	private void zipDirectory(String dirPath, ZipOutputStream zos) throws IOException { /* Place appropriate code form your "zipdirectory" method here */ 
		System.out.println("Zip dir: " + dirPath);
		File f = new File(dirPath);
		String[] flist = f.list();
		for(int i=0; i<flist.length; i++) { 
			File ff = new File(f,flist[i]); 
			if(ff.isDirectory()) { 
				zipDirectory(ff.getPath(),zos); 
				continue; 
			} 
			String[] filepath = ff.getPath().split("/"); 
			ZipEntry entries = null;
			if(filepath.length > 6) {
				entries = new ZipEntry(filepath[6]+"/"+filepath[7]); 
			}
			else {
				entries = new ZipEntry(filepath[6]); 
			}
			//ZipEntry entries = new ZipEntry(filepath); 
			//ZipEntry entries = new ZipEntry(ff.getParentFile().getName()); 
			zos.putNextEntry(entries); 
			FileInputStream fis = new FileInputStream(ff); 
			int buffersize = 1024; 
			byte[] buffer = new byte[buffersize]; 
			int count; 
			while((count = fis.read(buffer)) != -1) {
				zos.write(buffer,0,count); 
			} 
			fis.close();
		}
	}

/*
	private String getFileContentsInDir(String dir) {
		String contents = "";
		File folder = new File(dir);
  		File[] listOfFiles = folder.listFiles(); 
  		for (int i = 0; i < listOfFiles.length; i++)  {
   			if (listOfFiles[i].isFile())  {
   				Stirng fileName = listOfFiles[i].getName();
       				if (fileName.endsWith(".txt") || fileName.endsWith(".TXT")) {
					contents += readFile(dir+"/"+fileName) + "\n";
        			}
     			}
  		}
		return contents;
	}
*/ 
        private String sendZipFile(String batchWD, String jobId, String[] reports, HttpServletResponse response) {
		String parentDir = jobId.substring(0, 8);
		String file = null;
		String attachmentFileName = "BatchPeptideMatch-"+jobId+".zip";
		System.out.println("attached file name: "+ attachmentFileName);
		String msg = "";
		try {	
			ServletOutputStream sos = response.getOutputStream();
               		response.setContentType("application/zip");
               		response.setHeader("Content-Disposition", "attachment; filename=\""+attachmentFileName+"\"");
			File[] files = new File[reports.length];
			int count = 0;
			
			ZipOutputStream out = new ZipOutputStream(sos);
			for(int i = 0; i < reports.length; i++) {
				if(reports[i].equals("perPeptideDetails")) {
					String dirPath = batchWD+"/"+parentDir+"/"+jobId+"/PerPeptideMatchResults/";
					//System.out.println(dirPath);
					zipDirectory(dirPath, out);
                        		file = batchWD+"/"+parentDir+"/"+jobId+"/perPeptideMatchDetails.txt";                       
					System.out.println("Details: " + file);
					files[count++] = new File(file);
				}
				else {
					if(reports[i].equals("perPeptideSummary")) {
                        			file = batchWD+"/"+parentDir+"/"+jobId+"/peptideSummary.txt";                       
						files[count++] = new File(file);
                			}
                			else if(reports[i].equals("perProteinSummary")) {
                        			file = batchWD+"/"+parentDir+"/"+jobId+"/proteinSummary.txt";                       
						files[count++] = new File(file);
                			}
					else if(reports[i].equals("proteinSeqs")) {
						file = batchWD+"/"+parentDir+"/"+jobId+"/proteinSeq.fasta";			
						files[count++] = new File(file);
					}
                			else if(reports[i].equals("queryPeptides")) {
                        			file = batchWD+"/"+parentDir+"/"+jobId+"/originalQuerySeq.txt";                     
						files[count++] = new File(file);
                			}
                			else if(reports[i].equals("missedQueryPeptides")) {
                        			file = batchWD+"/"+parentDir+"/"+jobId+"/missedOriginalQuerySeq.txt";                     
						files[count++] = new File(file);
                			}
                			else if(reports[i].equals("log")) {
                        			file = batchWD+"/"+parentDir+"/"+jobId+"/log.txt";                  
						files[count++] = new File(file);
                			}
				}	
			}
			zipFiles(files, out);		 
			out.close();	
		}
		catch(IOException ioe) {
			ioe.printStackTrace();
		}
		
		return msg;	
	}
	
        private String sendTextFile(String batchWD, String jobId, String report, HttpServletResponse response) {
		String parentDir = jobId.substring(0, 8);
		String file = null;
		String attachmentFileName = null;
		String msg = "";
		//System.out.println("report: "+ report);
		if(report.equals("perPeptideSummary")) {
			file = batchWD+"/"+parentDir+"/"+jobId+"/peptideSummary.txt";			
			attachmentFileName = "BatchPeptideMatch-"+jobId+"-peptideSummary.txt";
		}
		else if(report.equals("perProteinSummary")) {
			file = batchWD+"/"+parentDir+"/"+jobId+"/proteinSummary.txt";			
			attachmentFileName = "BatchPeptideMatch-"+jobId+"-proteinsummary.txt";
		}
		else if(report.equals("proteinSeqs")) {
			file = batchWD+"/"+parentDir+"/"+jobId+"/proteinSeq.fasta";			
			attachmentFileName = "BatchPeptideMatch-"+jobId+"-proteinSeq.fasta";
		}
		else if(report.equals("queryPeptides")) {
			file = batchWD+"/"+parentDir+"/"+jobId+"/originalQuerySeq.txt";			
			attachmentFileName = "BatchPeptideMatch-"+jobId+"-originalQuerySeq.txt";
		}
		else if(report.equals("missedQueryPeptides")) {
			file = batchWD+"/"+parentDir+"/"+jobId+"/missedOriginalQuerySeq.txt";			
			attachmentFileName = "BatchPeptideMatch-"+jobId+"-missedOriginalQuerySeq.txt";
		}
		else if(report.equals("log")) {
			file = batchWD+"/"+parentDir+"/"+jobId+"/log.txt";			
			attachmentFileName = "BatchPeptideMatch-"+jobId+"-log.txt";
		}
		else if(report.equals("perPeptideDetails")) {
			file = batchWD+"/"+parentDir+"/"+jobId+"/perPeptideMatchDetails.txt";			
			attachmentFileName = "BatchPeptideMatch-"+jobId+"-perPeptideMatchDetails.txt";
		}

                String fileContent = readFile(file);
                if(fileContent.length() == 0) {
                        msg = "<font color=red>Invalid job ID or the match results for your job ID has been deleted.</font>";
                }
                else {
			try {
                		response.setContentType( "text/plain" );
                        	response.setHeader("Content-Disposition","attachment; filename=\""+attachmentFileName+"\"");
                        	PrintWriter outputs = response.getWriter();
                        	outputs.write(fileContent);
                        	outputs.flush();
                        	outputs.close();
			}
			catch(IOException ioe) {
				ioe.printStackTrace();
			}
               }
		return msg;
	}
%>
