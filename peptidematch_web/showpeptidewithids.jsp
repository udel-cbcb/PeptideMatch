<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" %>
<%@ page session="true" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="query.PeptidePhraseQuery" %>
<html>
<head>
<link href="./imagefiles/styles.css" type="text/css" rel="stylesheet">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
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
<TITLE>Peptide Match [PIR - Protein Information Resource]</TITLE>
<style type="text/css">
body.main{
background-image:url('./imagefiles/bg02.gif');
background-color:#cccccc;
margin-left:0;
margin-top:0;
margin-right:0;
margin-bottom:0;
width:100%;
height:100%;
}
form.mainform{
margin-top:1px; 
margin-bottom:1px;
}
table.submittable{
BORDER:0;
cellpadding:0;
cellspacing:0:
width:100%;
margin-bottom:1cm;
}
table.maintable {
border:2px solid #333333;
padding: 1px;
border-collapse: collapse;
width: 100%;
table-layout: fixed;
text-align:left;
font-size:12px;
margin:1px;
font-family: Verdana, Tahoma, Arial, Helvetica, sans-serif; 
}

table.headtable{
border:1px solid #333333;
width: 99.9%;
height: 28;
bordercolor:#FFFFFF;
padding:0;
cellspacing:3;
margin:1px;
text-align:center;
background-image:url('./imagefiles/seq_ana_bg3.png');
}

table.result {
border-collapse: collapse;
width: 99.9%;
table-layout: fixed;
text-align:left;
font-size:12px;
margin:1px;
font-family: Verdana, Tahoma, Arial, Helvetica, sans-serif; 
}
table.result thead tr .header {
font-size: 1em;
text-align: left;
padding-top: 5px;
padding-bottom: 4px;
background-color: #C1D0DF;
color: #000000;	
background-image: url("./imagefiles/bg.gif");
background-repeat: no-repeat;
background-position: center right;
cursor: pointer;
}
table.result td{
border: 2px solid black;
}
table.result th{
border: 2px solid black;
}
table.result thead tr .headerSortUp {
	background-image: url("./imagefiles/asc.gif");
}
table.result thead tr .headerSortDown {
	background-image: url("./imagefiles/desc.gif");
}
td.tablecontent {
font-size:12px;
font-family: Verdana, Tahoma, Arial, Helvetica, sans-serif; 
	vertical-align: center;
	word-wrap: break-word;
}
table.headline{
margin-left:5px;
}
#highlight {
	color: red;
}
#headresult{
align:left;
color:black;
font-size: 12px;
}
#headlight{
color:black;
}
#sequencefragment{
font-family:Courier New,monospace;
}
#foot{
width:100%;
frameBorder=0;
align:left;
margin-bottom:1px;
}
#keyword{
width:500px;
}
#inputform{
margin:5px;
max-height:50px;
width:1024px;
}
.menulink{
margin-left:8px;
}
</style>

<script language="javascript">
function toggle(ac) {
        var ele = document.getElementById("toggleText"+"_"+ac);
        var text = document.getElementById("displayText"+"_"+ac);
        if(ele.style.display == "block") {
                ele.style.display = "none";
                text.innerHTML = "[More...]";
        }
        else {
                ele.style.display = "block";
                text.innerHTML = "[Less]";
        }
}
</script>
</head>
<body class="main">
<% 
//if open the page directly,don't show the result table
if(request.getParameter("organism_id")!=null&&request.getParameter("ids")!=null&request.getParameter("keyword")!=null){
String organism_id;
String originalQuery="";
if(request.getParameter("organism_id")!=null){
	organism_id=request.getParameter("organism_id");
}
else organism_id="all";
String ids;
int rowsPerPage=0;
int start=0;
int numberFound = 0;
originalQuery = request.getParameter("keyword").trim().toUpperCase();
ids = request.getParameter("ids").toUpperCase();

String uniref100Only ="N";
        String ilEquivalent = "N";
        String uniref100Value = "N";
        String lEqiValue = "N";
        String sortBy = "ac_asc";
        if(request.getParameter("sortBy") != null) {
                sortBy = request.getParameter("sortBy");
        }
        if(request.getParameter("uniref100") != null) {
                uniref100Value = request.getParameter("uniref100");
                uniref100Only = uniref100Value;
        }
        if(request.getParameter("lEqi") != null) {
                lEqiValue = request.getParameter("lEqi");
                ilEquivalent = lEqiValue;
        }

String[] idsets=ids.split(";");
rowsPerPage=idsets.length;
ArrayList<String> idList=new ArrayList();
for(int i=0;i<idsets.length;i++){
	idList.add(i, idsets[i]);
}
//initial the solr connection
PeptidePhraseQuery peptideQuery = new PeptidePhraseQuery();
SolrDocumentList docs = new SolrDocumentList();
peptideQuery.queryByIDSets(idList, rowsPerPage, ilEquivalent);
docs = peptideQuery.getCurrentDocs();
//return how many protein sequence 
numberFound = peptideQuery.getResult();	
if (numberFound > 0) {			
	%>
	<div >Showing <%=numberFound %> protein(s) here:</div>
		<table  class="headline" width="100%" border="0" cellpadding="0" cellpadding="0">
	<tbody>
	<tr>
	<td id=headresult>
	</td>
	<td align=right>
	</td>
	</tr>
	</tbody>
	</table>
<form class="mainform" name="mainform" method="post"  action="http://pir20.georgetown.edu/cgi-bin/peptidematch.pl"> 
<table class="maintable">
<tbody>
<tr>
<td>
<table class="headtable">
<tbody>
<tr>
<td> 
<table cellspacing="0" cellpadding="0" border="1"><tbody><tr><td>
<table cellspacing="0" cellpadding="0" border="0" background="./imagefiles/bg02.gif">
<tbody>
<tr> 
<td  align="right" id="select_box"><img src="./imagefiles/check_do.png" border="0"></td></tr> 
</tbody></table></td></tr></tbody></table> 
<input type="hidden" name="hidden_id" value=""> 
<input type="hidden" name="searchstr" value=""> 
     </td><td width="100%"></td><td align="right"> 
<table border="0">
<tbody><tr> 
<td nowrap=""><input type="image" name="blast" src="./imagefiles/blast.png" onclick="return verifyNums('blast','<%=organism_id%>')">
<input type="image" name="fasta" src="./imagefiles/fasta.png" onclick="return verifyNums('fasta','<%=organism_id%>')">
<input type="image" name="pat" src="./imagefiles/pat.png" onclick="return verifyNums('pat','<%=organism_id%>')">
<input type="image" name="maln" src="./imagefiles/maln.png" onclick="return verifyNums('maln','<%=organism_id%>')">
<input type="image" name="dom" src="./imagefiles/dom.png" onclick="return verifyNums('dom','<%=organism_id%>')"></td>
<td><img src="./imagefiles/transparent_dot.png" border="0" height="2" width="32"></td>
<td>
<table border="0" cellpadding="0" cellspacing="0">
				<tbody><tr>
					<td align="right"><img alt="save" src="./imagefiles/save_as.png"></td>
					<td class="nrm02" width="4" align="center">&nbsp;</td>
					<td align="center"><input type="image" alt="save as Table" onclick="return save_data('tab','<%=originalQuery%>','<%=ilEquivalent%>');" name="save_tab" src="./imagefiles/save_fxn_tbl.jpg"></td></td>
					<td class="nrm02" width="4" align="center">|</td>
					<td align="center"><input alt="save as FASTA" onclick="return save_data('fasta','<%=originalQuery%>','<%=ilEquivalent%>');" type="image" name="save_fasta" src="./imagefiles/save_fxn_fasta.jpg"></td>
					<td><img alt="" src="./imagefiles/transparent_dot.png" border="0" height="2" w
idth="50"></td>
					</tr>  
				</tbody></table>

</td>
</tr>
</tbody></table> 
</td>
</tr>
</tbody>
</table>
</td>
</tr>
<tr>
<td>	
<table class="result" id="sortedresulttable">
<thead>
<tr>
<th width=2% ><input type=checkbox id="all_box" name=all value="all"  onClick="this.value=current_sel(mainform, this.value,'<%=organism_id%>','<%=originalQuery%>','<%=ilEquivalent%>');"></th>
<%
if(uniref100Only.equals("N")){
%>
<th width=10%><b>Protein AC</b></th>
<th width=10%><b>Protein ID</b></th>
<th width=15% ><b>Protein Name</b></th>
<th width=5%><b>Length</b></th>
<th width=15%><b>Organism</b></th>
<th><b>Match Range</b></th>
<th width=13%><b>Protein Links to Proteomic DBs</b></th>
<th width=15%><b>Immune Epitope DB</b></th>
<%
}
else{
%>
<th width=12%><b>UniRef100 Cluster ID</b></th>
<th width=12%><b>Representative Protein AC</b></th>
<th width=15% ><b>Protein Name</b></th>
<th width=6%><b>Length</b></th>
<th width=15%><b>Organism</b></th>
<th><b>Match Range</b></th>
<th width=13%><b>Protein Links to Proteomic DBs</b></th>
<th width=11%><b>Immune Epitope DB</b></th>
<%
}
%>
</tr>
</thead>
<tbody>
<%		
	Iterator<SolrDocument> docItr = docs.iterator();
	while (docItr.hasNext()) {
	SolrDocument doc = docItr.next();
	String sequence=(String)doc.getFieldValue("originalSeq");
        int seqLength=sequence.length();
        String id=(String)doc.getFieldValue("ac");
        String proteinID=(String)doc.getFieldValue("proteinID");
        String proteinName=(String)doc.getFieldValue("proteinName");
        String organismName=(String)doc.getFieldValue("organismName");
        String organismID=(String)doc.getFieldValue("organismID");
        String nist = "";
        String nistStr = (String)doc.getFieldValue("nist");
        String pride = (String)doc.getFieldValue("pride");
        String peptideAtlas = (String)doc.getFieldValue("peptideAtlas");
        String peptideLibrary = "";
        String iedb = (String)doc.getFieldValue("iedb");
        String iedbStr = "";
/*
        if(nistStr.length() > 0 && !nistStr.equals("Z")) {
                String[] nistRec = nistStr.split(" ");
                nist =  "<a href=\"http://peptide.nist.gov/browser/proteins.php?description=IT&organism="+nistRec[1]+"&ProteinAccessionNum="+id+"\">NIST</a>";
                peptideLibrary += nist+", ";
        }
*/
        if(peptideAtlas.length() > 0 && !peptideAtlas.equals("Z")) {
                peptideAtlas = "<a href=https://db.systemsbiology.net/sbeams/cgi/PeptideAtlas/Search?search_key="+peptideAtlas+"&apply_action=GO&exact_match=exact_match\">PeptideAtlas</a>";
                peptideLibrary += peptideAtlas+", ";
        }
        if(pride.length() > 0 && !pride.equals("Z")) {
                pride = "<a href=\"http://www.ebi.ac.uk/pride/searchSummary.do?queryTypeSelected=identification%20accession%20number&identificationAccessionNumber="+pride+"\">PRIDE</a>";
                peptideLibrary += pride+", ";
        }
        if(peptideLibrary.indexOf(", ") > 0) {
                peptideLibrary = peptideLibrary.substring(0, peptideLibrary.length() - 2);
        }
        if(iedb.length() > 0 & !iedb.equals("Z")) {
                String[] iedbs = iedb.split(",");
                if(iedbs.length <10) {
                        for(int i=0; i < iedbs.length; i++) {
                                iedbStr += "<a href=\"http://www.iedb.org/epId/"+iedbs[i]+"\">"+iedbs[i]+"</a>, ";
                        }
                        if(iedbStr.indexOf(", ") > 0) {
                                iedbStr = iedbStr.substring(0, iedbStr.length() - 2);
                        }
                }
                else {
                        for(int i=0; i < 9; i++) {
                                iedbStr += "<a href=\"http://www.iedb.org/epId/"+iedbs[i]+"\">"+iedbs[i]+"</a>, ";
                        }
                        iedbStr += "<a id=\"displayText_"+id+"\" href=\"javascript:toggle('"+id+"');\">[More...]</a><br/><br/>";
                        iedbStr +="<div id=\"toggleText_"+id+"\" style=\"display: none; \">";
                        for(int i=9; i < iedbs.length; i++) {
                                iedbStr += "<a href=\"http://www.iedb.org/epId/"+iedbs[i]+"\">"+iedbs[i]+"</a>, ";
                        }
                        if(iedbStr.indexOf(", ") > 0) {
                                iedbStr = iedbStr.substring(0, iedbStr.length() - 2);
                        }
                        iedbStr+="</div>";
                }
        }
        String[] pids = proteinID.split("_");
        String uniprotIcon = "";
        if(pids[0].length() < 6) {
                uniprotIcon = "sp_icon.png";
        }
        else {
                uniprotIcon = "tr_icon.png";
        }

	%>
	<tr>
	<td class="tablecontent"><input type=checkbox onClick="current_sel(mainform,this.value,'<%=organism_id%>','<%=originalQuery%>','<%=ilEquivalent%>')" name=idlist value=<%=id%>></td>
 <%
   if(uniref100Only.equals("N")){
 %> 
	<td class="tablecontent"><%=id%><br><a href="http://pir.georgetown.edu/cgi-bin/ipcEntry?id=<%=id%>"><img src="./imagefiles/ipc_icon.png" border="0"></a>
	<a href="http://www.uniprot.org/uniprot/<%=id%>"><img src="./imagefiles/<%=uniprotIcon%>" border="0"></a></td>
	<td class="tablecontent"><%=proteinID%><br>
	<a href="http://www.uniprot.org/uniprot/<%=id%>"><img src="./imagefiles/<%=uniprotIcon%>" border="0"></a>
	</td>
 <%
}
else
{
%>
	<td class="tablecontent"><a href="http://www.uniprot.org/uniref/UniRef100_<%=id%>">UniRef100_<%=id%></td>
	<td class="tablecontent"><%=proteinID%><br>
	<a href="http://www.uniprot.org/uniprot/<%=id%>"><img src="./imagefiles/<%=uniprotIcon%>" border="0"></a>
	</td>

<%
}
%>
	<td class="tablecontent"><%=proteinName%><br>
	<a href='http://pir.georgetown.edu/cgi-bin/biothesaurus.pl?id=<%=id%>'>					  		
	</td>  
	<td class="tablecontent"><%=sequence.length()%></td>
	<td class="tablecontent"><a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id=<%=organismID%>'><%=organismName%></a></td> 
	<td class="tablecontent" id="sequencefragment">
<%
if(originalQuery.equals("*:*")){
	out.println(sequence);
}
else{
String color = "red";
if(ilEquivalent.equalsIgnoreCase("N")){	
  for(int i=0;i<=seqLength-originalQuery.length();i++){	
	if(sequence.substring(i, i+originalQuery.length()).equalsIgnoreCase(originalQuery)){
		if(i<5) {
			for(int j=i; j <5; j++) {
				out.print("&nbsp;");
			}
			if((i+originalQuery.length()+5)>seqLength){
				out.print(sequence.substring(0,i)+"<font color='red'>"+originalQuery+"</font>"+sequence.substring(i+originalQuery.length(),seqLength));			
			}
			else if((i+originalQuery.length()+5)<=seqLength){
			out.print(sequence.substring(0,i)+"<font color='red'>"+originalQuery+"</font>"+sequence.substring(i+originalQuery.length(),i+originalQuery.length()+5));	
			}
		}
		else {
			if((i+originalQuery.length()+5)>seqLength){
				out.print(sequence.substring(i-5,i)+"<font color='red'>"+originalQuery+"</font>"+sequence.substring(i+originalQuery.length(),seqLength));	
			}
			else if((i+originalQuery.length()+5)<=seqLength){
				out.print(sequence.substring(i-5,i)+"<font color='red'>"+originalQuery+"</font>"+sequence.substring(i+originalQuery.length(),i+originalQuery.length()+5));	
			}
		}
	out.print(" ");
	out.print(i+1);
	out.print("-");
	out.print(i+originalQuery.length());
	out.println("<br>");
	}
  }
}
else{
String subString = "";
for(int i=0;i<=seqLength-originalQuery.length();i++){
         subString = sequence.substring(i, i+originalQuery.length()).toUpperCase();	
	if(subString.replaceAll("[Ii]","L").equalsIgnoreCase(originalQuery.replaceAll("[Ii]","L"))){
            if(!subString.equalsIgnoreCase(originalQuery)) {
            StringBuffer sb = new StringBuffer();
           for(int j =0 ; j < subString.length(); j ++){
             if(subString.charAt(j) != originalQuery.charAt(j))
                    sb.append("<font color='green'>"+subString.charAt(j)+"</font>");
               else
                    sb.append(subString.charAt(j));
             }
            subString = sb.toString();
          }
		if(i<5) {
			for(int j=i; j <5; j++) {
				out.print("&nbsp;");
			}
			if((i+originalQuery.length()+5)>seqLength){
				out.print(sequence.substring(0,i)+"<font color='red'>"+subString+"</font>"+sequence.substring(i+originalQuery.length(),seqLength));			
			}
			else if((i+originalQuery.length()+5)<=seqLength){
			out.print(sequence.substring(0,i)+"<font color='red'>"+subString+"</font>"+sequence.substring(i+originalQuery.length(),i+originalQuery.length()+5));	
			}
		}
		else {
			if((i+originalQuery.length()+5)>seqLength){
				out.print(sequence.substring(i-5,i)+"<font color='red'>"+subString+"</font>"+sequence.substring(i+originalQuery.length(),seqLength));	
			}
			else if((i+originalQuery.length()+5)<=seqLength){
				out.print(sequence.substring(i-5,i)+"<font color='red'>"+subString+"</font>"+sequence.substring(i+originalQuery.length(),i+originalQuery.length()+5));	
			}
		}
	out.print(" ");
	out.print(i+1);
	out.print("-");
	out.print(i+originalQuery.length());
	out.println("<br>");
	}
  }
}
}

 %>
</td>
<td class="tablecontent"><%=peptideLibrary%></td> 
<td class="tablecontent"><%=iedbStr%></td> 

</tr>
<% } %>
</tbody>
</table>	
</td>
</tr>
</tbody>
</table>
</Form>
<input style="display:none" id="uniref100" value="<%=uniref100Value%>"></input>
<%	
//if the number sequences returned is greater than rows per page , need to paging

}
    else {
	%>
	<p>0 result returned</p>
<% } 
}

%>

</body>

<script type="text/javascript" src="./imagefiles/jquery-latest.js"></script> 
<script type="text/javascript" src="./imagefiles/jquery.tablesorter.js"></script>
<script type="text/javascript" src="./js/check_analyze.js"></script> 
<script type="text/javascript">
/*var checkflag = "false"
	function check(field,flag) { 
	   if (checkflag == "false") { 
	      for (i = 0; i < field.length; i++) { 
	         field[i].checked = true 
	      }
	      if (i == 0) { 
	         field.checked = true 
	      }
	      checkflag = "true" 
	   } else { 
	      for (i = 0; i < field.length; i++) { 
	        field[i].checked = false 
	      } 
	      if (i == 0) { 
	        field.checked = false 
	      }
	      checkflag = "false" 
	   } 
	} 
	   function test_sel(form) { 
	      var sel_num=0 
	      for(var x=0; x<form.idlist.length; x++) { 
	          if (form.idlist[x].checked==true) { 
	            sel_num++ 
	          } 
	      } 
	      if (x == 0) { 
	         if (form.idlist.checked==true) { 
	           sel_num++ 
	         } 
	      }
	      if ( sel_num >50 ) { 
	         var answer=confirm("More than 50 proteins are selected. Proceed with the most recently selected 50 entries?") 
	         if (!answer) { 
	             return false; 
	         }  
	      }  
	   }
	   function verifyNums(form,tool) { 
		     var anal=tool 
		     var curnum=0 
		     for(var x=0; x<form.idlist.length; x++) { 
		        if (form.idlist[x].checked==true) { 
		            curnum++ 
		        } 
		     } 
		     if (x == 0) { 
		        if (form.idlist.checked==true) { 
		           curnum++ 
		        } 
		     }
		     if (anal == 'blast' || anal == 'fasta' || anal == 'pat' || anal == 'hmm') { 
		         if ( curnum == 0 ) { 
		             alert('Please pick one protein first.') 
		         } else if ( curnum > 1 ) { 
		             var answer=confirm("More than one protein is selected. Process the first one?") 
		             if (answer) { 
		                newWin(form,anal) 
		             }  
		         } else if ( curnum == 1 ) { 
		                newWin(form,anal) 
		         }  
		     } 
		     if ( anal == 'maln' ) { 
				   if ( curnum < 2 ) { 
		             alert('Please pick at least two proteins.') 
		        } else if ( curnum > 50 ) { 
		             alert('Too many proteins are selected. Please narrow them down. The maximum is 50.') 
		        } else { 
		              newWin(form,anal); 
		        } 
		     } 
		     if ( anal == 'dom' ) { 
				   if ( curnum < 1 ) { 
		             alert('Please pick at least one protein.') 
		        } else if ( curnum > 50 ) { 
		             alert('Too many proteins are selected. Please narrow them down. The maximum is 50.') 
		        } else { 
		             newWin(form,anal); 
		        } 
		     } 
		     return false 
		}
	   function newWin(form,anal) { 
		   winprops = 'menubar,toolbar,status,height=600,width=750,resizable,scrollbars=yes,left=80,top=20' 
		   var tool=anal 
		   var ids='' 
		   for (i = 0; i < form.idlist.length; i++) { 
		      if (form.idlist[i].checked == true) { 
		            ids += '&idlist=' + form.idlist[i].value 
		      } 
		   } 
		   windowURL = 'http://pir.georgetown.edu/cgi-bin/seq_ana_main.pl?tool=' + tool + '&db=<%if(request.getParameter("organism_id")!=null){if(!request.getParameter("organism_id").toLowerCase().equals("all"))out.print(request.getParameter("organism_id"));else out.print("on");}else out.print("on");%>' + ids 
		   win = window.open(windowURL, tool, winprops) 
		   win.focus(); 
		} 
function current_sel(form) { 
    var all_checked=true 
    var sel_num=0 
    for(var x=0; x<form.idlist.length; x++) { 
        if (form.idlist[x].checked==true) { 
          sel_num++ 
        } else {
           all_checked=false 
        } 
    } 
    if (x == 0) { 
       if (form.idlist.checked==true) { 
         sel_num++ 
        } else {
           all_checked=false 
        } 
    }
    if (all_checked==true) { 
         form.all.checked=true
    } else {
         form.all.checked=false 
    } 
    var obj=document.getElementById('select_box') 
        var show_img='' 
    if (sel_num > 0) { 
       show_img='<input type=image onclick="return selWindow(mainform,\'checked\')" name=show_selected src=./imagefiles/show.png border=0>' 
    } 
    var sel_box='<table border=0 cellspacing=0 cellpadding=2><tr>' 
       sel_box+='<td nowrap><img src=./imagefiles/show.png/transparent_dot.png border=0 height=1 width=4>'+sel_num+'</td>' 
       sel_box+='<td><img src=./imagefiles/selected.png border=0></td>' 
       sel_box+='<td>' + show_img + '</td></tr></table>' 
		 document.getElementById('select_box').innerHTML=sel_box 
    return false 
 }
function selWindow(form,anal) { 
    winprops = 'menubar,toolbar,status,height=300,width=760,resizable,scrollbars=yes,left=80,top=20' 
    var tool='selWin' 
    var ids='' 
    var sel_num=0
    for (i = 0; i < form.idlist.length; i++) { 
       if (form.idlist[i].checked == true) { 
          ids += form.idlist[i].value+';'
          sel_num++ 
       } 
    } 
    if ( sel_num >50 ) { 
       var answer=confirm("More than 50 proteins are selected. Proceed with the most recently selected 50 entries?") 
       if (!answer) { 
           return false; 
       }  
    }
  
//    windowURL = './showpeptidewithids.jsp?organism_id=<%if(request.getParameter("organism_id")!=null)out.print(request.getParameter("organism_id"));else out.print("all");%>&keyword=<%=request.getParameter("keyword").trim().toUpperCase()%>&ids='+ ids 

	windowURL = './showpeptidewithids.jsp?organism_id=<% if(request.getParameter("organism_id")!=null) out.print(request.getParameter("organism_id")); else out.print("all");%> &keyword=<%=request.getParameter("keyword").trim().toUpperCase()%>&uniref100=<% if(request.getParameter("uniref100") != null) out.print(request.getParameter("uniref100"));%>&lEqi=<% if(request.getParameter("lEqi") != null) out.print(request.getParameter("lEqi"));%>&sortBy=<% if(request.getParameter("sortBy") != null) out.print(request.getParameter("sortBy"));%>&ids='+ ids
    win = window.open(windowURL, tool, winprops) 
    win.focus(); 
    return false; 
 }  
 
function showPeptide(originalQuery)
{
	var content=originalQuery;
 document.getElementById("peptide").innerHTML=content;  
}

function InputCheck(searchform) {
	var keyword=searchform.keyword.value;
	if(keyword=="*:*"){
		document.searchform.submit();
	}
	else
	{
	var validinput=keyword.replace(/[^a-zA-Z]+/g,'');	
	searchform.keyword.value=validinput;
	if(validinput.length>=3){	
	document.searchform.submit();
	}
	else{
		alert("Please input the keyword at least 3 valid characters(only letters are accepted)");
		searchform.keyword.focus();
		return (false);	
	}
	}
	}
*/
</script>

<script>
$.tablesorter.addParser({ 
    // set a unique id 
    id: 'starter', 
    is: function(s) { 
        // return false so this parser is not auto detected 
        return false; 
    }, 
    format: function(s) { 
        // format your data for normalization 
        return s.replace(new RegExp(/-([\s\S]*)/),""); 
    }, 
    // set type, either numeric or text 
    type: 'numeric' 
}); 

$(function() { 
    $("table").tablesorter({ 
        headers: {
        	0: {
        		sorter:false
        	},
            6: { 
                sorter:'starter' 
            } 
        } 
    }); 
});  
</script>
</html>
