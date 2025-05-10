<%@ page trimDirectiveWhitespaces="true" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" %>
<%@ page session="true" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="query.PeptidePhraseQuery" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>
<%@ page import="org.apache.commons.io.FilenameUtils" %>
<%@ page import="org.apache.lucene.*" %>
<%@ page import="org.apache.lucene.search.*" %>
<%@ page import="org.apache.lucene.index.*" %>
<%@ page import="org.apache.lucene.store.*" %>
<%@ page import="org.apache.lucene.document.*" %>
<%@ page import="org.apache.solr.*" %>
<%@ page import="query.PeptidePhraseQuery" %>
<%@ page import="query.TaxonomyTreeNode" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>
<%@ page import="org.json.*" %>
<%@ page import="org.proteininformationresource.peptidematch.*" %>

<%
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
	String[] jobIds = null;
	String jobId = null;
        String dataTable = "";
        if(request.getParameter("jobId") != null) {
                jobId = request.getParameter("jobId");
                jobIds = jobId.split(":");
	}
        String logFile = batchWD+"/"+jobIds[0]+"/"+jobIds[1]+"/log.txt";
        String logContent = readFile(logFile);
	ArrayList<Log> logs = getLogs(logContent);

	 
	//String[] cols = {"Organism", "Matches", "Percent", "Taxonomic Group"};
	String[] cols = {"Organism", "Matches", "Percent"};
	String table = "ajax";
	JSONObject result = new JSONObject();
	JSONArray array = new JSONArray();
	
	int amount = 25;
	int start = 0;
	int echo = 0;
	int col = 0;

	String organism = "";
	String matches = "";
	String percent = "";	
	String taxonGroup = "";
	String dir = "asc";
	String sStart = request.getParameter("iDisplayStart");
	String sAmount = request.getParameter("iDisplayLength");
	String sEcho = request.getParameter("sEcho");
	String sCol = request.getParameter("iSortCol_0");
	String sDir = request.getParameter("sSortDir_0");
	String sCol1 = request.getParameter("iSortCol_1");
	String sDir1 = request.getParameter("sSortDir_1");
	String search = request.getParameter("sSearch");
	organism = request.getParameter("sSearch_0");
	matches = request.getParameter("sSearch_1");
	percent = request.getParameter("sSearch_2");
	taxonGroup = request.getParameter("sSearch_3");
	
	if(sStart != null) {
		start = Integer.parseInt(sStart);
		if(start < 0) {
			start = 0;
		}
	}
	if(sAmount != null) {
		amount = Integer.parseInt(sAmount);
		if(amount < 25 || amount > 100) {
			amount = 25; 
		}
	}
	if(sEcho != null) {
		echo = Integer.parseInt(sEcho);
	}
	if(sCol != null) {
		col = Integer.parseInt(sCol);
		if(col < 0 || col > 3) {
			col = 0;
		}
	}
	if(sDir != null) {
		if(!sDir.equals("asc")) {
			dir = "desc";
		}
	}
	String colName = cols[col];
	int total = 0;
	int peptideCount = 0;
	int totalAfterFilter = 0;
        //NumberFormat nf = NumberFormat.getInstance();
        //nf.setMinimumFractionDigits(1);
        //nf.setMaximumFractionDigits(1);
	for(int i= 0; i < logs.size(); i++) {
		JSONArray ja = new JSONArray();
		Log log = logs.get(i);
		int index = log.getIndex();
		String peptide = log.getPeptide();
		String numProteins = Integer.toString(log.getNumProteins());
		String numOrganisms = Integer.toString(log.getNumOrganisms());
		peptideCount++;
		total++;
		if(search != null && search.length() > 0) {
				//System.out.println("search1: " + search);
			if(peptide.toUpperCase().indexOf(search.toUpperCase()) != -1 || numProteins.indexOf(search) != -1 || numOrganisms.indexOf(search) != -1) {
				//System.out.println("search2: " + search);
				String checkbox = "<input type=\"checkbox\" name=\"checkbox-"+index+"\" value=\""+peptide+"\">";
				ja.put(checkbox);
                      		ja.put(peptide);
				ja.put(numProteins);
				ja.put(numOrganisms);
					
				array.put(ja);
				totalAfterFilter++;
			} 
		}
		else {
			if(peptideCount >= start && peptideCount <= (start+amount)) {
				String checkbox = "<input type=\"checkbox\" name=\"checkbox-"+index+"\" value=\""+peptide+"\">";
				ja.put(checkbox);
                       		ja.put(peptide);
				ja.put(numProteins);
				ja.put(numOrganisms);
				
				array.put(ja);
			}
                }
	}
	result.put("sEcho", echo);
	if(totalAfterFilter > 0) {
		result.put("iTotalRecords", totalAfterFilter);
		result.put("iTotalDisplayRecords", totalAfterFilter);
	}
	else {
		result.put("iTotalRecords", logs.size());
		result.put("iTotalDisplayRecords", logs.size());
	}
	result.put("aaData", array);
	response.setContentType("application/json");
        response.setHeader("Cache-Control", "no-store");
        out.print(result);		
%>

<%!
	public ArrayList<Log> getLogs(String logText) {
		ArrayList<Log> logList = new ArrayList<Log>(); 
		String[] logs = logText.split("\n");
		 for(int i=logs.length -1; i > 0; i--) {
			String line = logs[i];
			if(line.indexOf("Searching ") != -1) {
				String[] rec = line.split("\t");
				String indexStr = rec[0];
				indexStr.replaceAll(" ", "");
				indexStr.replaceAll("&nbsp;", "");
				int index = Integer.parseInt(rec[0]);
				int total = Integer.parseInt(rec[1]);
				String peptide = rec[2].replaceAll("Searching ", "");
				int numProteins = Integer.parseInt(rec[3]);
				int numOrganisms = Integer.parseInt(rec[4]);
			        float timeUsed = Float.parseFloat(rec[5]);		
				Log log = new Log(index, total, peptide, numProteins, numOrganisms, timeUsed); 
				logList.add(log);	
			}	
		 }
		return logList;		
	}

	private String readFile(String filePathAndName) {
        String fileContent = "";
        try {
                File file = new File(filePathAndName);
                FileReader fr = new FileReader(file);
                BufferedReader br = new BufferedReader(fr);
                String line = null;
                while((line = br.readLine()) != null) {
                        fileContent += line+"\n";
                }
                br.close();
        }
        catch(IOException ioe) {
                ioe.printStackTrace();
        }
        return fileContent;
    }

%>
