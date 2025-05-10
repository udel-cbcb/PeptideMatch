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

public class BatchPeptideMatchServlet extends HttpServlet {
    private String organism = "";
    private String queryPeptides = "";
    private String sortBy = "ac_asc";
    private PrintWriter out;


    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
        if ("XMLHttpRequest".equals(request.getHeader("x-requested-with"))) {
            LongProcess longProcess = (LongProcess) request.getSession().getAttribute("longProcess");
           response.setContentType("text/html");
           // Set to expire far in the past.
           response.setHeader("Expires", "Sat, 6 May 1995 12:00:00 GMT");
           // Set standard HTTP/1.1 no-cache headers.
           response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
           //Set IE extended HTTP/1.1 no-cache headers (use addHeader).
           response.addHeader("Cache-Control", "post-check=0, pre-check=0");
          // Set standard HTTP/1.0 no-cache header.
           response.setHeader("Pragma", "no-cache");
            //response.getWriter().write(longProcess.getJobId() + "<br/>"+Arrays.toString(query.getPeptides())+"<br/>"+String.valueOf(longProcess.getStatus()));
            String info = longProcess.getInputsHTML();
	    if(longProcess.isFinished()) {
		 info += "<br/>"+longProcess.getEndJobId()+"<br/>"+longProcess.getNoteInfo();	
	    }
	    else {
		 info += "<br/>"+longProcess.getStartJobId();	
	    }
            response.getWriter().write(info + "<br/><br/>"+String.valueOf(longProcess.getHTMLStatus()));
        }
	else {
            request.getRequestDispatcher("batchpeptidematchprogress.jsp").forward(request, response);
        }
    }

   
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
          // Set to expire far in the past.
           response.setHeader("Expires", "Sat, 6 May 1995 12:00:00 GMT");
           // Set standard HTTP/1.1 no-cache headers.
           response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
           //Set IE extended HTTP/1.1 no-cache headers (use addHeader).
           response.addHeader("Cache-Control", "post-check=0, pre-check=0");
          // Set standard HTTP/1.0 no-cache header.
           response.setHeader("Pragma", "no-cache");

	Map<String, String> orgIdToNameMap = new HashMap<String, String>();
	if(request.getSession().getAttribute("orgIdToNameMap") == null) {
                FileReader fs = new FileReader( request.getRealPath("/") + "WEB-INF/classes/config/orgNameToTaxon.txt");
                BufferedReader br = new BufferedReader(fs);
                String eachLine;
                String organism_id;
                String organism_name;
                String commonName=null;
		System.out.println("reading orgNameToTaxon.txt..");
                while ((eachLine = br.readLine()) != null) {
                        String[] fields = eachLine.split("\t");
                        organism_name = fields[0].replaceAll("[\\(].*[\\)]", "").trim();
                        organism_id = fields[1].trim();
                        orgIdToNameMap.put(organism_id, organism_name);
                }
                request.getSession().setAttribute("orgIdToNameMap", orgIdToNameMap);
        }
        else {
                orgIdToNameMap = (HashMap<String, String>)request.getSession().getAttribute("orgIdToNameMap");
        }

        LongProcess longProcess = new LongProcess();
       	request.getSession().setAttribute("longProcess", longProcess);
	    //Timestamp time = new Timestamp(new Date().getTime());
	    //DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
	String jobId = createJobId(request);
	Query query = processInputs(request, response);
	//System.out.println("peptide size 4: "+query.getPeptides().length);	
	String errMsg = query.getErrMsg();
	if(errMsg!= null && errMsg.length() >0) {
            	response.setContentType("text/html");
		errMsg ="<font color=navy>"+errMsg+"</font><br/><br/>";
		errMsg += "Click <a href=\"batchpeptidematch.jsp\">here</a> return to Batch Peptide Match page";
            	response.getWriter().write(errMsg);
		System.out.println(errMsg);
	}
	else {
		//System.out.println("I am should be here");
		//SimpleDateFormat dt1 = new SimpleDateFormat("yyyyy-mm-dd");
		//String parentDir = dateFormat.format(date);
		String parentDir = jobId.substring(0, 8);
		String batchWD = (String)request.getSession().getAttribute("batchWD");
		//System.out.println("input batchWD: " + batchWD);	
		try {
			//File cwd = new File(batchWD+"/"+parentDir +"/"+Integer.toString(hashCode));
			File cwd = new File(batchWD+"/"+parentDir +"/"+jobId);
			//System.out.println("creating dir 1: "+cwd.toString());
				
			if(!cwd.exists()) {
				longProcess.setCWD(cwd.toString());
				//cwd = new File(batchWD+"/"+parentDir +"/"+Integer.toString(hashCode)+"/PerPeptideMatchResults");
				cwd = new File(batchWD+"/"+parentDir +"/"+jobId+"/PerPeptideMatchResults");
				//System.out.println("creating dir 2: "+cwd.toString());
				cwd.mkdirs();	
			}
			else {
				longProcess.setCWD(cwd.toString());
				//cwd = new File(batchWD+"/"+parentDir +"/"+Integer.toString(hashCode)+"/PerPeptideMatchResults");
				cwd = new File(batchWD+"/"+parentDir +"/"+jobId+"/PerPeptideMatchResults");
				//System.out.println("creating dir 3: "+cwd.toString());
				cwd.mkdir();	
			}
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		System.out.println("peptide size 2: "+query.getPeptides().length);	
        	//longProcess.setJobId(dateFormat.format(date)+"_"+Integer.toString(hashCode));
        	longProcess.setJobId(jobId);
		longProcess.setQuery(query);
		longProcess.saveOriginalQueryPeptides(query);
		longProcess.setInputs(request);
        	longProcess.setDaemon(true);
        	longProcess.start();
        	request.getRequestDispatcher("batchpeptidematchprogress.jsp").forward(request, response);
	}
    }

    protected Query processInputs(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

	Map<String, String> orgIdToNameMap = new HashMap<String, String>();
	String errMsg = "";			
	String[] peptides = null;
        String peptide = "";	
	out = response.getWriter();
	int uploadSize = 0;
	String uploadContent = "";
	String db = "";
	String uniref100 = "N";
	String lEqi = "N";
	String swissprot = "N";
	String isoform = "N";
	String trOnly = "N";
	String isoOnly ="N";

	Query query = new Query();
	if(ServletFileUpload.isMultipartContent(request)){
             	FileItemFactory factory = new DiskFileItemFactory();
                ServletFileUpload uploadHandler = new ServletFileUpload(factory);
                try {
			List items = uploadHandler.parseRequest(request);
                        Iterator itr = items.iterator();
                        String fieldName = null;
                        while(itr.hasNext()) {
                        	FileItem item = (FileItem) itr.next();
				if(item.isFormField()) {
                              		fieldName=item.getFieldName();
                                	if(fieldName.equals("db")) {
                                		organism = item.getString().trim();
						String[] queryOrgs = organism.split(";");
						//System.out.println("QueryOrgs: " +organism);	
						orgIdToNameMap = (Map<String, String>)request.getSession().getAttribute("orgIdToNameMap");
						ArrayList<Organism> orgs = new ArrayList();
						for(int i=0; i < queryOrgs.length; i++) {
							if(queryOrgs[i] != null && queryOrgs[i].length() > 0 && !queryOrgs[i].equals("all")) {
								String name = orgIdToNameMap.get(queryOrgs[i]);
								if(name != null && name.length() > 0) {
									Organism org = new Organism(name, queryOrgs[i]);
									orgs.add(org);
								}
								else {
									System.out.println("errMsg: " +queryOrgs[i] + " has no name");	
								}
							}
							else {
								System.out.println("errMsg: empty orgId");
							}
						}
						Organism[] organisms = new Organism[orgs.size()];
						orgs.toArray(organisms);	
						query.setSelectedOrganisms(organisms);		
					}
                                	else if(fieldName.equals("peptide")) {
                                     		//peptide=item.getString().trim().toUpperCase();
                                     		peptide=item.getString().trim();
						peptide = peptide.replaceAll("\\r\\n", "\n");	
						//System.out.println("|"+peptide+"|");
						if(peptide.indexOf(">") != -1) {
							query = processInputString(peptide, query);
							/*
							String[] inputs = peptide.split("\n");
							int lineNumber = 0;
							int peptideNumber = 0;
							String currentLine = "";
							String id = "";
							String seq = "";
							String origSeq = "";
							ArrayList cleanPeptidesList = new ArrayList();
							ArrayList cleanPeptideIdsList = new ArrayList();
							for(int i = 0; i < inputs.length; i++) {
								lineNumber++;
								currentLine = inputs[i];
								if(currentLine.length() > 0) {
									//System.out.println(lineNumber+ ": "+currentLine);
									//System.out.println(id+ " ! "+seq);
									if(currentLine.startsWith(">")) {
										if(id.equals("") && peptideNumber > 0) {
											errMsg += "Invalid FASTA file: identifier is missing for the following sequence<br/>";
											errMsg += origSeq+"<br/>";	
										}
										if(!id.equals("")) {
											if(!seq.equals("")) {
												//System.out.println("I am here "+id+ " ? "+seq);
												cleanPeptideIdsList.add(id);
												cleanPeptidesList.add(seq);
												id = "";
												seq = "";
												origSeq = "";
											}
											else {
												errMsg += "Invalid FASTA file: sequence is missing for the identifier <b>"+id+"</b>!<br/>";
											}

										}
										String[] defLine = currentLine.split(" ");
										id = defLine[0];
										id = id.replaceAll(">", ""); 	
										peptideNumber++;
									}
									else {
										currentLine = currentLine.replaceAll("\\s", "");
										origSeq += currentLine+"<br/>";
										seq += currentLine;
										//System.out.println(lineNumber+ ": "+seq);
									}			
								}	
							}				
							if(!id.equals("")  && !seq.equals("")) {
								cleanPeptideIdsList.add(id);
								cleanPeptidesList.add(seq);
								id = "";
								seq = "";
								origSeq = "";
							}
							else if(id.equals("") && peptideNumber > 0) {
								errMsg += "Invalid FASTA file: identifier is missing for the following sequence!<br/>";
								errMsg += origSeq;	
							}
							else if(seq.equals("") && peptideNumber > 0) {
								errMsg += "Invalid FASTA file: sequence is missing for the identifier "+id+"!<br/>";
							}
									
							query.setOriginalQueryPeptides(peptide);
							String[] cleanPeptides = new String[cleanPeptidesList.size()];
							String[] cleanPeptideIds = new String[cleanPeptideIdsList.size()];
							query.setPeptides((String[])cleanPeptidesList.toArray(cleanPeptides));		
							query.setPeptideIds((String[])cleanPeptideIdsList.toArray(cleanPeptideIds));		
							peptides = (String[])cleanPeptidesList.toArray(cleanPeptides);
							*/
						}
						else {	
							//peptide = peptide.replaceAll("\\s", "");
							System.out.println("?"+peptide+"?");
							if(peptide.length() > 0) {
                        					peptides=peptide.split("\n");
								ArrayList cleanPeptidesList = new ArrayList();
								String originalQueryPeptides = "";
								for(int i = 0; i < peptides.length; i++) {
									//System.out.println("*"+peptides[i]+"*");
									String singlePeptide = peptides[i];
									singlePeptide = singlePeptide.replaceAll("\\s", "");
									originalQueryPeptides += singlePeptide+"\n";
									if(singlePeptide.trim().length() > 0 && !cleanPeptidesList.contains(singlePeptide.trim())) {
										cleanPeptidesList.add(singlePeptide.trim());
									}
								}		
								query.setOriginalQueryPeptides(originalQueryPeptides);
								String[] cleanPeptides = new String[cleanPeptidesList.size()];
								query.setPeptides((String[])cleanPeptidesList.toArray(cleanPeptides));		
							}
						}
                                	}
                                	else if(fieldName.equals("uniref100")) {
                                      		uniref100=item.getString().trim();
						query.setUniRef100Only(uniref100);
                                	}
                                	else if(fieldName.equals("lEqi")) {
                                      		lEqi=item.getString().trim();
						query.setLEqI(lEqi);	
                                	}
					else if(fieldName.equals("swissprot")) {
						swissprot = item.getString().trim();
						query.setSwissprot(swissprot);
					}
					else if(fieldName.equals("isoform")) {
						isoform = item.getString().trim();
						query.setIsoform(isoform);
					}
					else if(fieldName.equals("trOnly")) {
						trOnly = item.getString().trim();
						query.setTrOnly(trOnly);
					}
					else if(fieldName.equals("isoOnly")) {
						isoOnly = item.getString().trim();
						query.setIsoOnly(isoOnly);
					}

					System.out.println("uniref100: "+uniref100);
					System.out.println("lEqi: "+lEqi);
					System.out.println("swissprot: "+swissprot);
					System.out.println("isoform: "+isoform);
					System.out.println("trOnly: "+trOnly);
					System.out.println("isoOnly: "+isoOnly);
				}
                        	else {
					if(item.getSize()>0) {
						if(item.getContentType() != null && !item.getContentType().equals("text/plain")){
                                             		errMsg = "The file format you upload is: "+item.getContentType()+". "+"Only text/plain file can be supported.";
						}
                               		}
                                        uploadSize=(int) item.getSize();
                                        uploadContent=item.getString().trim().toUpperCase();
					System.out.println("UploadContent: |"+ uploadContent+"|");
						//uploadContent = uploadContent.replaceAll("\\r", "");	
					if(uploadSize > 0) {
						if(uploadContent.indexOf(">") != -1) {
							query = processInputString(uploadContent, query);
						}
						else {	
							query.setOriginalQueryPeptides(uploadContent);
                        				peptides = uploadContent.split("\n");
						
							System.out.println("uploaded content size" + peptides.length + "?");
							ArrayList cleanPeptidesList = new ArrayList();
							for(int i = 0; i < peptides.length; i++) {
								System.out.println("split pepitdes before: "+peptides[i].trim()+"|");
								if(peptides[i].trim().length() > 0 && !cleanPeptidesList.contains(peptides[i].trim())) {
									System.out.println("split pepitdes after:  "+peptides[i].trim()+"|");
									String cleanPeptide = peptides[i].trim();
									cleanPeptide = cleanPeptide.replaceAll("\\s", "");
									cleanPeptidesList.add(cleanPeptide);
								}
							}
							String[] cleanPeptides = new String[cleanPeptidesList.size()];
							System.out.println("!" + cleanPeptides.length + "!");
							query.setPeptides((String[])cleanPeptidesList.toArray(cleanPeptides));		
						//System.out.println("peptide size 1: "+query.getPeptides().length);	
						}
					}
					else if(query.getPeptides() != null && query.getPeptides().length == 0 ){
						errMsg += "The file uploaded is empty";
						System.out.println("upload size is 0");
					}
                        	}
                	}
		}
        	catch(FileUploadException ex) {
              		errMsg = "Error encountenavy while parsing the request" +"<br/>"+ex;
               		log("Error encountenavy while parsing the request",ex);
        	}
        	catch(Exception ex) {
                	errMsg = "Error encountenavy while uploading file" +"<br/>"+ex;
                	log("Error encountenavy while uploading file",ex);
        	}
	}
      	else {
              	out.println("Wrong parameters");
              	out.close();
       	}
	//if(peptides.length == 0) {
	if(query.getPeptides() !=null && query.getPeptides().length == 0) {
                errMsg = "Either you query or the file you uploaded is empty.";
	}
	query.setErrMsg(errMsg);
	System.out.println("peptide size 3: "+query.getPeptides().length);	
	System.out.println(errMsg);	
	return query;
	}

	protected Query processInputString(String peptides, Query query) {
		String[] inputs = peptides.split("\n");
		String errMsg = query.getErrMsg();
        	int lineNumber = 0;
        	int peptideNumber = 0;
        	String currentLine = "";
        	String id = "";
        	String seq = "";
        	String origSeq = "";
        	ArrayList cleanPeptidesList = new ArrayList();
        	ArrayList cleanPeptideIdsList = new ArrayList();
        	for(int i = 0; i < inputs.length; i++) {
        		lineNumber++;
                	currentLine = inputs[i];
                	if(currentLine.length() > 0) {
                   	//System.out.println(lineNumber+ ": "+currentLine);
                        //System.out.println(id+ " ! "+seq);
                        	if(currentLine.startsWith(">")) {
                                	if(id.equals("") && peptideNumber > 0) {
                                        	errMsg += "Invalid FASTA file: identifier is missing for the following sequence<br/>";
                                                errMsg += origSeq+"<br/>";
                                        }
                                        if(!id.equals("")) {
                                        	if(!seq.equals("")) {
                                                	//System.out.println("I am here "+id+ " ? "+seq);
                                                        cleanPeptideIdsList.add(id);
                                                        cleanPeptidesList.add(seq);
                                                        id = "";
                                                        seq = "";
                                                        origSeq = "";
                                                 }
                                                 else {
                                                        errMsg += "Invalid FASTA file: sequence is missing for the identifier <b>"+id+"</b>!<br/>";
                                                 }
                                        }
                                        String[] defLine = currentLine.split(" ");
                                        id = defLine[0];
                                        id = id.replaceAll(">", "");
                                        peptideNumber++;
                                 }
                                 else {
                                        currentLine = currentLine.replaceAll("\\s", "");
                                        origSeq += currentLine+"<br/>";
                                        seq += currentLine;
                                       //System.out.println(lineNumber+ ": "+seq);
                                 }
                          }
                 }
                 if(!id.equals("")  && !seq.equals("")) {
                          cleanPeptideIdsList.add(id);
                          cleanPeptidesList.add(seq);
                          id = "";
                          seq = "";
                          origSeq = "";
                 }
                 else if(id.equals("") && peptideNumber > 0) {
                          errMsg += "Invalid FASTA file: identifier is missing for the following sequence!<br/>";
			  errMsg += origSeq;
                 }
                 else if(seq.equals("") && peptideNumber > 0) {
                          errMsg += "Invalid FASTA file: sequence is missing for the identifier "+id+"!<br/>";
                 }

                 query.setOriginalQueryPeptides(peptides);
                 String[] cleanPeptides = new String[cleanPeptidesList.size()];
                 String[] cleanPeptideIds = new String[cleanPeptideIdsList.size()];
                 query.setPeptides((String[])cleanPeptidesList.toArray(cleanPeptides));
                 query.setPeptideIds((String[])cleanPeptideIdsList.toArray(cleanPeptideIds));
                 //peptides = (String[])cleanPeptidesList.toArray(cleanPeptides);
		
		return query;
	
	}
	
	private String createJobId(HttpServletRequest request) {
		String timeStamp = new SimpleDateFormat("yyyyMMddHHmmss")
				.format(new Date());
		long number = (long) Math.floor(Math.random() * 9000000000L) + 1000000000L;
		String jobId = timeStamp + "" + number/* randomGenerator(8) */;
		// System.out.println(timeStamp + " | " + number);
		return jobId;
	}
}
