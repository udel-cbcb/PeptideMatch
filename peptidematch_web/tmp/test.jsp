<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>
<%@ page import="org.apache.lucene.*" %>
<%@ page import="org.apache.lucene.search.*" %>
<%@ page import="org.apache.lucene.index.*" %>
<%@ page import="org.apache.lucene.store.*" %>
<%@ page import="org.apache.lucene.document.*" %>
<%@ page import="org.apache.solr.*" %>
<%@ page import="query.PeptidePhraseQuery" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>

<%
	try {
        List<FileItem> items = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
        for (FileItem item : items) {
            if (item.isFormField()) {
                // Process regular form field (input type="text|radio|checkbox|etc", select, etc).
                String fieldname = item.getFieldName();
                String fieldvalue = item.getString();
		out.println(fieldname+ " | " + fieldvalue);
                // ... (do your job here)
            } else {
                // Process form file field (input type="file").
                String fieldname = item.getFieldName();
                String filename = FilenameUtils.getName(item.getName());
                InputStream filecontent = item.getInputStream();
		BufferedReader br = new BufferedReader(new InputStreamReader(filecontent));
                                try {
                                        StringBuilder sb = new StringBuilder();
                                        String line = br.readLine();
                                        while (line != null) {
                                                sb.append(line);
                                                sb.append(",");
                                                line = br.readLine();
                                }
                                        String list = sb.toString();
                                        out.println(list.substring(0, list.length() -1));
                                } finally {
                                        br.close();
                                }

                // ... (do your job here)
            }
        }
    } catch (FileUploadException e) {
        throw new ServletException("Cannot parse multipart request.", e);
    }
%>
