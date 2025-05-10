<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ page import="java.util.regex.*"%>
<%@ page import="java.io.*"%>

<%
	String path = application.getRealPath("/");
	String dir = new File(path).getParent();
	String start = request.getParameter("startwith");
	Pattern pattern = Pattern.compile("^[" + start + "]");
	FileReader fs = new FileReader(dir
			+ "/peptidematch/WEB-INF/classes/config/proteomes_reference.txt");
	BufferedReader br = new BufferedReader(fs);
	int organismCount = 0;
	int count = 0;	
	out.println("<table style='margin-left:10px'id='organismlist' cellspacing='0' cellpadding='0' width='100%' border='0' height='80'>");
	out.println("<tbody>");
	String eachLine;
	while ((eachLine = br.readLine()) != null) {
		if (start.toUpperCase().startsWith("A") && count == 0) {
			out.println("<tr><td><img src='./imagefiles/org_nm_id.bmp'/></td>");
		}
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
		
			if (count == 0)
				out.println("<td><input TYPE=checkbox NAME=organism_checkbox onclick='organism_list(this.value);' value="
						+ fields[0].trim()
						+ ">"
						+ organism_name.trim()
						+ " ["
						+ fields[0] + "] (" + organismCount + " seq.)</td>");
			else
				out.println("<td><input TYPE=checkbox NAME=organism_checkbox onclick='organism_list(this.value);' value="
						+ fields[0].trim()
						+ ">"
						+ organism_name.trim()
						+ " ["
						+ fields[0] + "] (" + organismCount + " seq.)</td>");
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