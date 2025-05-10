<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ page import="java.util.regex.*"%>
<%@ page import="java.io.*"%>

<%
	String path = application.getRealPath("/");
	String dir = new File(path).getParent();
	if (request.getParameter("startwith") != null) {
		String start = request.getParameter("startwith").toLowerCase();
		if (!start.equals("")) {
			Pattern pattern = Pattern.compile("^" + start);
			//FileReader fs = new FileReader( dir + "/peptidematch/WEB-INF/classes/config/proteomes_complete.txt");
			FileReader fs = new FileReader( request.getRealPath("/") + "WEB-INF/classes/config/proteomes_complete.txt");
			BufferedReader br = new BufferedReader(fs);
			int count = 0;
			String eachLine;
			String organism_id;
			String organism_name;
			String commonName;
			boolean match = false;
			while ((eachLine = br.readLine()) != null) {
				String[] fields = eachLine.split("\t");
				organism_id = fields[0].trim();
				organism_name = fields[2]
						.replaceAll("[\\(].*[\\)]", "").trim();
				commonName = fields[3].trim();
				Matcher name = pattern.matcher(organism_name
						.toLowerCase());
				Matcher number = pattern.matcher(organism_id);
				Matcher common = pattern.matcher(commonName
						.toLowerCase());
				if (name.find() || number.find() || common.find()) {
					count++;
					common.reset();
					if (count == 1) {
						out.println("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<select id='organism_select' size=5 onkeydown='leftFocus(event)' onkeypress='checkEnter(event)' onclick='setSuggestValue(this.value)'>");
						if (common.find()) {
							out.print("<option value='" + organism_name
									+ " (" + commonName + ")"
									+ " [" + organism_id + "]'"
									+ " selected >" + organism_name
									+ " (" + commonName + ")" + " ["
									+ organism_id + "]</option>");
						} else {
							out.print("<option value='" + organism_name
									+ " [" + organism_id + "]'"
									+ " selected >" + organism_name
									+ " [" + organism_id + "]</option>");
						}

					} else {
						if (common.find()) {
							out.print("<option value='" + organism_name
									+ " (" + commonName + ")"
									+ " [" + organism_id + "]'"
									+ ">" + organism_name
									+ " (" + commonName + ")" + " ["
									+ organism_id + "]</option>");
						} else {
							out.print("<option value='" + organism_name
									+ " [" + organism_id + "]'"
									+ ">" + organism_name
									+ " [" + organism_id + "]</option>");
						}
					}
				}
			}
			if (count > 0)
				out.println("</select>");

		}
	}
%>
