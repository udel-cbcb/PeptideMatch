package query; 

import java.io.*;
import java.sql.Timestamp;
import java.util.*;
import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.concurrent.TimeUnit;
 
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.StringUtils;

import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;
import org.apache.solr.schema.FieldType;
import query.PeptidePhraseQuery;

import org.proteininformationresource.peptidematch.*;

public class DownloadBatchPeptideMatchResultsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
        if ("XMLHttpRequest".equals(request.getHeader("x-requested-with"))) {
             //   String jobId = request.getParameter("jobId");
	   //		System.out.println(" I am in get " + jobId);  
            DownloadProcess downloadProcess = (DownloadProcess) request.getSession().getAttribute("downloadProcess");
	    if(downloadProcess == null) {
	   		System.out.println(" I am in get downloadprocess is null");  
			//doPost(request, response);
            		//downloadProcess = (DownloadProcess) request.getSession().getAttribute("downloadProcess");
			
	    }
	    else { 
		System.out.println("I am in get ...");
		String info = null;
	    	if(!downloadProcess.isFinished()) {
            	 	response.setContentType("text/html");
		 	info = "<br/>"+downloadProcess.getStatus();	
			System.out.println("in get not finsihed "+ info);
            		response.getWriter().write(info);
	    	}
	    	else {
            		//response.getWriter().write("Ready for downloading");
			//System.out.println("Writing report..");
    			String fileName = "BatchPeptideMatch_"+downloadProcess.getJobId()+".txt";
        		response.setContentType( "text/plain" );
        		response.setHeader("Content-Disposition","attachment; filename=\""+fileName+"\"");
			info = downloadProcess.getReport();	
            		response.getWriter().write(info);
	    	}
	    }
        }
	else {
            request.getRequestDispatcher("downloadprogress.jsp").forward(request, response);
        }
    }

   
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
	String content = "";
        String jobId = "";
        String[] jobIds = null;
        String summary =null ;
	String[] queryPeptides;
        if(request.getParameter("jobId") != null) {
                jobId = request.getParameter("jobId");
		
	   	System.out.println(" I am in post " + jobId);  
                jobIds = jobId.split("_");
                if(jobIds != null && jobIds.length != 2) {
                        content = "<font color=red>Invalid job ID</font>";
                }
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
                        String summaryFile = batchWD+"/"+jobIds[0]+"/"+jobIds[1]+"/summary.txt";
                        summary = readFile(summaryFile);
                        String originalQueryFile = batchWD+"/"+jobIds[0]+"/"+jobIds[1]+"/originalQuery.seq";
                        String originalQuery = readFile(originalQueryFile);
			queryPeptides = originalQuery.split("\n");
                        if(summary.length() == 0) {
                                content = "<font color=red>Invalid job ID or the match results for your job ID has been deleted.</font>";
                        }
                        else if(originalQuery.length() == 0) {
                                content = "<font color=red>Invalid job ID or the match results for your job ID has been deleted.</font>";
                        }
        		if(content.length() == 0) {
        			DownloadProcess downloadProcess = new DownloadProcess();
				downloadProcess.setJobIds(jobIds);
				downloadProcess.setJobId(jobId);
				downloadProcess.setBatchWD(batchWD);
				downloadProcess.setSummary(summary);
				downloadProcess.setQueryPeptides(queryPeptides);
        			downloadProcess.setDaemon(true);
        			downloadProcess.start();
				request.getSession().setAttribute("downloadProcess", downloadProcess);
				System.out.println(request.getSession().getAttribute("downloadProcess"));
				System.out.println("In post before forward");
        			request.getRequestDispatcher("downloadprogress.jsp").forward(request, response);
				System.out.println("In post after forward");
			}
			else {
				response.getWriter().write(content);
			}
		}
        }
        else {
		System.out.println("Job ID is null");
                content = "<font color=red>Invalid job ID!</font>";
		response.getWriter().write(content);
        }
	
    }

	class DownloadProcess extends Thread {
    		private String[] jobIds;
    		private String status ="";
    		private String batchWD = "";
    		private String summary = "";
    		private String[] queryPeptides;
    		boolean finished = false;
    		private PrintWriter pw;
    		private String report = "";
		private String jobId = "";

		public void setJobId(String jobId) {
			this.jobId = jobId;
		}

		public String getJobId() {
			return this.jobId;
		}

		public String getReport() {
			return this.report;
		}

		public void setReport(String report) {
			this.report = report;
		}
	
		public void setJobIds(String[] jobIds) {
			this.jobIds = jobIds;
		}
		
		public String[] getJobIds() {
			return this.jobIds;
		}
	
		public void setStatus(String status) {
			this.status = status;
		}
		
		public String getStatus() {
			return this.status;
		}

		public void setBatchWD(String batchWD) {
			this.batchWD = batchWD;	
		}
	
		public void setSummary(String summary) {
			this.summary = summary;
		}

		public String getSummary() {
			return this.summary;
		}
	
		public String getBatchWD() {
			return this.batchWD;
		}
		
		public void setQueryPeptides(String[] queryPeptides) {
			this.queryPeptides = queryPeptides;	
		}
	        
                public String[] getQueryPeptides() {
			return this.queryPeptides;
		}	
		
		public void setPrintWriter(PrintWriter pw) {
			this.pw = pw;
		}

		public PrintWriter getPrintWriter() {
			return this.pw;
		}	
		public void run() {
        		while(!finished) {
                		doWork();
			}
		}

		public boolean isFinished() {
			return this.finished;
		}

    		private void doWork() {
			this.status = "Getting summary ...";
			System.out.println("Getting summary ...");
       			//pw.write(summary+"\n");
       			//pw.flush();
       			report += summary+"\n";
       			for(int i = 0; i < queryPeptides.length; i++) {
       				String peptide = queryPeptides[i];
                		if(peptide.length() > 0) {
                      			String matchedResultsFile = batchWD+"/"+jobIds[0]+"/"+jobIds[1]+"/outputs/"+peptide+".txt";
					this.status = "Getting results for "+peptide+" ...";
					//System.out.println("Getting results for "+peptide+" ...");
                        		//pw.write(readFile(matchedResultsFile)+"\n");
                        		//pw.flush();
                        		report += readFile(matchedResultsFile)+"\n";
                		}
       			}
			this.report = report;
       			//pw.close();
       			finished = true;
    		}
		
	}
	 public String readFile(String filePathAndName) {
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
}
