<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ page import="java.util.regex.*"%>
<%@ page import="java.io.*"%>

<%
	String path = application.getRealPath("/");
	String dir = new File(path).getParent();
	String start = request.getParameter("startwith");
	Pattern pattern = Pattern.compile("^[" + start + "]");
	//FileReader fs = new FileReader(dir + "/peptidematch/WEB-INF/classes/config/proteomes_reference.txt");
	FileReader fs = new FileReader(request.getRealPath("/") + "WEB-INF/classes/config/proteomes_reference.txt");
	BufferedReader br = new BufferedReader(fs);
	int organismCount = 0;
	int count = 0;	
	out.println("<table style='margin-left:10px' id='organismlist' cellspacing='0' cellpadding='0' width=1000 border='0' height='80'>");
	out.println("<tbody>");
	String eachLine;
	out.println("<tr><td><br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Organism Name [Taxon ID] (# of sequences}</b></td>");
	while ((eachLine = br.readLine()) != null) {
		//if (start.toUpperCase().startsWith("A") && count == 0) {
		//	out.println("<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;<img src='./imagefiles/org_nm_id.bmp'/></td>");
		//}
		String[] fields = eachLine.split("\t");
		organismCount=Integer.parseInt(fields[9]);
		Matcher m = pattern.matcher(fields[2]);
		if (m.find()) {
			String organism_name = fields[2].replaceAll("[\\(].*[\\)]",
					"");
			if (count > 0 && count % 2 == 0)
				out.println("</tr>");
			if (count % 2 == 0)
				out.println("<tr>");
		
			String organism_name_value = organism_name.trim().replaceAll(" ", "_");	
			String taxonURL = "<a href=\"http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+fields[0].trim()+"\">"+fields[0].trim()+"</a>";
			if (count == 0)
				out.println("<td>&nbsp;&nbsp;&nbsp;&nbsp;<input TYPE=checkbox NAME=organism_checkbox onclick='organism_list(this.value);' value="
						+ fields[0].trim()+"----"+organism_name_value
						//+ fields[0].trim()
						+ ">"
						+ organism_name.trim()
						+ " [<font color=blue>"
						//+ fields[0] + "</font>] (<font color=red>" + organismCount + "</font> seq.)</td>");
						+ taxonURL + "</font>] (<font color=red>" + organismCount + "</font> seq.)</td>");
			else
				out.println("<td>&nbsp;&nbsp;&nbsp;&nbsp;<input TYPE=checkbox NAME=organism_checkbox onclick='organism_list(this.value);' value="
						+ fields[0].trim()+"----"+organism_name_value
						//+ fields[0].trim()
						+ ">"
						+ organism_name.trim()
						+ " [<font color=blue>"
						//+ fields[0] + "</font>] (<font color=red>" + organismCount + "</font> seq.)</td>");
						+ taxonURL + "</font>] (<font color=red>" + organismCount + "</font> seq.)</td>");
			count++;
		}
	}
	if (count % 2 != 0)
		out.println("<td></td>");
	out.println("</tr>");
		
	out.println("</tbody>");
	out.println("</table>");
	out.println("<br>");
%>
