<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" %>
<%@ page session="true" %>
<%

int start = 0;
int rowsPerPage = 20;
int numberFound = 0;
String originalQuery = request.getParameter("keyword");
start= Integer.parseInt(request.getParameter("start"));
numberFound = Integer.parseInt(request.getParameter("numberfound"));
String organism_id = request.getParameter("organism_id");
String taxon_id = request.getParameter("taxon_id");
String taxon_name = request.getParameter("taxon_name");
rowsPerPage = Integer.parseInt(request.getParameter("rows"));
String uniref100 = request.getParameter("uniref100");
String lEqi = request.getParameter("lEqi");
String sortBy = request.getParameter("sortBy");
if (numberFound > rowsPerPage) {
	if( start/ rowsPerPage >6)
           out.print("<a href=\"#\" onClick=\"pagingwithtaxonid('true','"+originalQuery+"','"+organism_id+"','"+taxon_id+"','"+taxon_name+"','0','"+rowsPerPage+"','"+numberFound+"','"+uniref100+"','"+lEqi+"','"+sortBy+"')\"><<</a>&nbsp;");

//	if the page is not at the first page, then produce a previous action	
	if(start>0){
                out.print("<a href=\"#\" onClick=\"pagingwithtaxonid('true','"+originalQuery+"','"+organism_id+"','"+taxon_id+"','"+taxon_name+"','"+(start-rowsPerPage)+"','"+rowsPerPage+"','"+numberFound+"','"+uniref100+"','"+lEqi+"','"+sortBy+"')\">[Previous]</a>&nbsp;");
				}
//if the page is at the first 6 page, 
			if (start / rowsPerPage < 6) {
				//10 pages are showed at a time,if the paging is less then 10 pages, break at the result page	
				for (int i = 1; i <= 10; i++) {
					if ((i - 1) * rowsPerPage > (numberFound-1))break;
					if (i == start / rowsPerPage + 1)
                out.print("<a href=\"#\" onClick=\"pagingwithtaxonid('true','"+originalQuery+"','"+organism_id+"','"+taxon_id+"','"+taxon_name+"','"+(i-1)*rowsPerPage+"','"+rowsPerPage+"','"+numberFound+"','"+uniref100+"','"+lEqi+"','"+sortBy+"')\"><b>["+i+"]</b></a>&nbsp;");
					else{
                out.print("<a href=\"#\" onClick=\"pagingwithtaxonid('true','"+originalQuery+"','"+organism_id+"','"+taxon_id+"','"+taxon_name+"','"+(i-1)*rowsPerPage+"','"+rowsPerPage+"','"+numberFound+"','"+uniref100+"','"+lEqi+"','"+sortBy+"')\">["+i+"]</a>&nbsp;");
						}
				}
	//if the page is at more then 6, then produce the previous 4 page link and the next 5 page link, if the next 5 page is more than the total  
			} else {
				for (int i = (start / rowsPerPage - 4); i <= (start/rowsPerPage + 5); i++) {
					if ((i - 1) * rowsPerPage > (numberFound-1))
						break;
					if (i == start / rowsPerPage + 1)
                out.print("<a href=\"#\" onClick=\"pagingwithtaxonid('true','"+originalQuery+"','"+organism_id+"','"+taxon_id+"','"+taxon_name+"','"+(i-1)*rowsPerPage+"','"+rowsPerPage+"','"+numberFound+"','"+uniref100+"','"+lEqi+"','"+sortBy+"')\"><b>["+i+"]</b></a>&nbsp;");
					else
                out.print("<a href=\"#\" onClick=\"pagingwithtaxonid('true','"+originalQuery+"','"+organism_id+"','"+taxon_id+"','"+taxon_name+"','"+(i-1)*rowsPerPage+"','"+rowsPerPage+"','"+numberFound+"','"+uniref100+"','"+lEqi+"','"+sortBy+"')\">["+i+"]</a>&nbsp;");
				}
			}
			
			if((start+rowsPerPage)<numberFound){
                out.print("<a href=\"#\" onClick=\"pagingwithtaxonid('true','"+originalQuery+"','"+organism_id+"','"+taxon_id+"','"+taxon_name+"','"+(start+rowsPerPage)+"','"+rowsPerPage+"','"+numberFound+"','"+uniref100+"','"+lEqi+"','"+sortBy+"')\">[NEXT]</a>&nbsp;");
			}
			//if the page is more then 10 page then produce the fast paging
			if((numberFound-1)/rowsPerPage+1>10){
				//if the page is at the first 6 paging, then produce the fast paging
				//or the page is at the 5 page before, also produce the page
				if(start/rowsPerPage<((numberFound-1)/rowsPerPage-4)||start / rowsPerPage < 6)
                out.print("<a href=\"#\" onClick=\"pagingwithtaxonid('true','"+originalQuery+"','"+organism_id+"','"+taxon_id+"','"+taxon_name+"','"+((numberFound-1)/rowsPerPage)*rowsPerPage+"','"+rowsPerPage+"','"+numberFound+"','"+uniref100+"','"+lEqi+"','"+sortBy+"')\">>></a>&nbsp;");
			} 
		}
else out.println("<b>[1]</b>");
%>
