package query;

import java.io.*;
import java.util.*;
import javax.servlet.*;
import java.util.Arrays;
import javax.servlet.http.*;
import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.sql.Timestamp;
import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;
import org.apache.commons.io.output.*;
import org.apache.commons.io.FilenameUtils;
import org.apache.lucene.*;
//import org.apache.lucene.search.*;
import org.apache.lucene.index.*;
import org.apache.lucene.store.*;
import org.apache.lucene.document.*;
import query.PeptidePhraseQuery;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.proteininformationresource.peptidematch.*;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.StringUtils;

public class PeptideMatchWS extends HttpServlet {
	private static final long serialVersionUID = 1L;
	ArrayList peptideList = new ArrayList();
	ArrayList organismList = new ArrayList();
	ArrayList missedPeptideList = new ArrayList();

	String format ="tab";
	Query query = new Query();
	String uniref100 = "N";
	String lEqi = "N";
	String inputsText = "";
	String inputsXML = "";
	String resultsFileName = "";
	String contentType = "";
	int jobId;
	Map<String, ArrayList<String>> perProteinMatchedPeptides = new HashMap<String, ArrayList<String>>();
	Map<String, String> proteinInfoMap = new HashMap<String, String>();
	StringBuffer perPeptideMatchedProteins = new StringBuffer();
	 ArrayList totalUniqueProteins = new ArrayList();
    	ArrayList totalUniqueOrganisms = new ArrayList();
		
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { 
		PrintWriter out ;
		perPeptideMatchedProteins.setLength(0);
		request.setCharacterEncoding("UTF-8");
                out = response.getWriter();
		String contentType = request.getContentType();
   		if (contentType != null && (contentType.indexOf("multipart/form-data") >= 0)) {
			try {
				query = getMultiPart(request, out);
			}
			catch(ServletException se) {
				se.printStackTrace();
			}
		}
		else {
			query = getSinglePart(request, out);
		}
		if(query.getPeptides().length  == 0) {
			out.println("Missing query peptides!");
		}
		else {
			String[] queryPeptides = query.getPeptides();
			jobId = getJobId(request);
			setInputs(request);
                	out = response.getWriter();
			format = query.getOutputFormat();
			System.out.println("Out format: "+format);
			if(format.equals("tab")) {
				contentType = "text/plain";
				resultsFileName = "PeptideMatch-"+jobId+".txt";	
				response.setContentType(contentType);
                		response.setHeader("Cache-Control", "no-cache");
                		response.setHeader("Content-Disposition", "inline;filename="+resultsFileName);
				out.print(inputsText+"\n");
			}
			else if(format.equals("xls")) {
				contentType = "application/vnd.ms-excel";
				resultsFileName = "PeptideMatch-"+getJobId(request)+".xls";	
				response.setContentType(contentType);
                		response.setHeader("Cache-Control", "no-cache");
                		response.setHeader("Content-Disposition", "inline;filename="+resultsFileName);
				out.print(inputsText+"\n");
			}
			else if(format.equals("xml")) {
				contentType = "text/xml";
				resultsFileName = "PeptideMatch-"+getJobId(request)+".xml";	
				response.setContentType(contentType);
                		response.setHeader("Cache-Control", "no-cache");
                		response.setHeader("Content-Disposition", "inline;filename="+resultsFileName);
				out.print(inputsXML+"\n");
			}
			else if(format.equals("fasta")) {
				contentType = "text/plain";
				resultsFileName = "PeptideMatch-"+getJobId(request)+".fasta";	
				response.setContentType(contentType);
                		response.setHeader("Cache-Control", "no-cache");
                		response.setHeader("Content-Disposition", "inline;filename="+resultsFileName);
			}
			out.flush();
			totalUniqueProteins = new ArrayList<String>();
			totalUniqueOrganisms = new ArrayList<String>();
			perProteinMatchedPeptides = new HashMap<String, ArrayList<String>>();
																		
			for(int i = 0; i < queryPeptides.length; i++) {
				String queryPeptide = queryPeptides[i];
				if(queryPeptide != null && queryPeptide.length() > 0) {
					ArrayList<MatchedProtein> matchedProteins = doSearch(queryPeptide, query.getSelectedOrganisms(), query.getUniRef100Only(), query.getLEqI(), "ac_asc", out, format); 
					if(matchedProteins.size() == 0) {
						missedPeptideList.add(queryPeptide);
					}	
					for (MatchedProtein matchedProtein : matchedProteins) {
                                        	String proteinAC = matchedProtein.getProteinAC();
                                        	if(!totalUniqueProteins.contains(proteinAC)) {
                                                	totalUniqueProteins.add(proteinAC);
                                        	}
                                        	String organism = matchedProtein.getOrganism().getTaxonId();
                                        	if(!totalUniqueOrganisms.contains(organism)) {
                                                	totalUniqueOrganisms.add(organism);
                                        	}
                                	}
        				countPerProteinMatch(queryPeptide, matchedProteins);
					if(format.equals("tab") || format.equals("xls") || format.equals("xml")) {	
        					//printPerPeptideMatchedProteinsTable(out, queryPeptide, matchedProteins, format);
						int matchedOrganismsCount = countMatchedOrganisms(matchedProteins);
						if(format.equals("xml")) {
							perPeptideMatchedProteins.append("<perPeptideMatchInfo>\n");
							perPeptideMatchedProteins.append("<queryPeptide>"+queryPeptide+"</queryPeptide>\n");
							perPeptideMatchedProteins.append("<numberOfMatchedProteins>"+matchedProteins.size()+"</numberOfMatchedProteins>\n");
							perPeptideMatchedProteins.append("<numberOfMatchedOrganisms>"+matchedOrganismsCount+"</numberOfMatchedOrganisms>\n");
							perPeptideMatchedProteins.append("</perPeptideMatchInfo>\n");
						}
						else {
							perPeptideMatchedProteins.append(queryPeptide+"\t"+matchedProteins.size()+"\t"+matchedOrganismsCount+"\n");
						}
					}
				}
			}
			for(int i = 0; i < totalUniqueProteins.size();i++) {
				System.out.println("unique proteins "+jobId+" | "+totalUniqueProteins.get(i)+"|");
			}	
			if(format.equals("tab") || format.equals("xls") || format.equals("xml")) {	
				if(format.equals("xml")) {
					out.print("<perPeptideMatchSummaryReport>\n");
					out.print("<numberPeptidesHadMatches>"+(query.getPeptides().length - missedPeptideList.size())+"</numberPeptidesHadMatches>\n");
					out.print("<uniqueMatchedProteins>"+this.totalUniqueProteins.size()+"</uniqueMatchedProteins>\n");	
					out.print("<uniqueMatchedOrganisms>"+this.totalUniqueOrganisms.size()+"</uniqueMatchedOrganisms>\n");	
					out.print(perPeptideMatchedProteins.toString());
					out.print("</perPeptideMatchSummaryReport>\n");
					
					out.print("<perProteinMatchSummaryReport>\n");
					SortedSet<String> proteinACs = new TreeSet<String>(perProteinMatchedPeptides.keySet());
       					System.out.println("Unique protiens: "+proteinACs.size());
        				StringBuffer sb = new StringBuffer();
        				for (String proteinAC : proteinACs) {
                				ArrayList<String> peptides = perProteinMatchedPeptides.get(proteinAC);
						sb.append("<perProteinMatchInfo>\n");
						if(query.getUniRef100Only() != null && query.getUniRef100Only().equals("Y")) {
                					sb.append("<UniRef100ClusterID>UniRef100_"+proteinAC +"</UniRef100ClusterID>\n");
                					sb.append("<proteinAC>"+proteinAC +"</proteinAC>\n");
						}
						else {
                					sb.append("<proteinAC>"+proteinAC +"</proteinAC>\n");
						}
						sb.append("<numberOfMatchingPeptides>"+peptides.size()+"</numberOfMatchingPeptides>\n");
						sb.append("<matchingPeptides>\n");
						for(int i = 0; i < peptides.size(); i++) {
							sb.append("<matchingPeptide>"+peptides.get(i)+"</matchingPeptide>\n");
						}
						sb.append("</matchingPeptides>\n");
						sb.append("</perProteinMatchInfo>\n");
        				}
					out.print(sb.toString());
					out.print("</perProteinMatchSummaryReport>\n");
					sb.setLength(0);
				}
				else {
					out.print("##Per peptide matched protein summary report\n");
					out.print("##Number of peptides had matches: "+ (query.getPeptides().length - missedPeptideList.size())+"\n");
					out.print("##Unique matched protein(s): "+ this.totalUniqueProteins.size()+"\n");
        				out.print("##Unique matched organisms(s): "+ this.totalUniqueOrganisms.size()+"\n");
					out.print("#Query peptide\tNum. matched proteins\tNum. matched organisms\n");
					out.print(perPeptideMatchedProteins.toString()+"\n");
					out.print("##Per protein matching peptide summary report\n");
					out.print("##Unique matched protein(s): "+ this.totalUniqueProteins.size()+"\n");
        				out.print("##Unique matched organisms(s): "+ this.totalUniqueOrganisms.size()+"\n");
					if(query.getUniRef100Only() != null && query.getUniRef100Only().equals("Y")) {
        					out.print("#UniRef100 ClusterID\tRepresentative protein AC\tNum. matching peptdies\tMatching peptides\n");
					}
					else {
        					out.print("#Protein AC\tNum. matching peptdies\tMatching peptides\n");
					}
        				SortedSet<String> proteinACs = new TreeSet<String>(perProteinMatchedPeptides.keySet());
        				System.out.println("Unique protiens: "+proteinACs.size());
        				StringBuffer sb = new StringBuffer();
        				for (String proteinAC : proteinACs) {
                				ArrayList<String> peptides = perProteinMatchedPeptides.get(proteinAC);
						if(query.getUniRef100Only() != null && query.getUniRef100Only().equals("Y")) {
                					sb.append("UniRef100_"+proteinAC+"\t"+proteinAC +"\t"+peptides.size()+"\t" + StringUtils.join(peptides, "; ")+"\n");
						}
						else {
                					sb.append(proteinAC +"\t"+peptides.size()+"\t" + StringUtils.join(peptides, "; ")+"\n");
						}
        				}
					out.print(sb.toString());
					sb.setLength(0);
				}
			}
			else if(format.equals("fasta")) {
        			SortedSet<String> proteinACs = new TreeSet<String>(perProteinMatchedPeptides.keySet());
        			System.out.println("Unique protiens: "+proteinACs.size());
        			StringBuffer sb = new StringBuffer();
        			for (String proteinAC : proteinACs) {
                			ArrayList<String> peptides = perProteinMatchedPeptides.get(proteinAC);
                			String[] proteinInfos = proteinInfoMap.get(proteinAC).split("\n");
                			String info = proteinInfos[0];
                			String seq = proteinInfos[1];
                			sb.append(info+"^|^"+StringUtils.join(peptides, "; ")+"\n");
                			sb.append(seq+"\n");
        			}
				out.print(sb.toString());
				sb.setLength(0);
			}	
				
			if(query.getOutputFormat().equals("xml")) {
				out.print("</peptideMatch>\n");
			}
			out.flush();
			out.close();
		}
	}

	private int countMatchedOrganisms(ArrayList<MatchedProtein> matchedProteins) {
        ArrayList matchedOrgs = new ArrayList();
        for (MatchedProtein matchedProtein : matchedProteins) {
                String matchedOrg = matchedProtein.getOrganism().getTaxonId();
                if(!matchedOrgs.contains(matchedOrg)) {
                        matchedOrgs.add(matchedOrg);
                }
        }
        return matchedOrgs.size();
    }
	private int getJobId(HttpServletRequest request) {
		DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            	Date date = new Date();
            	Timestamp time = new Timestamp(date.getTime());
            	String ip = request.getRemoteAddr();
            	String jobId = ip + time.toString();
        	int hashCode = jobId.hashCode();
        	if(hashCode < 0) {
                	hashCode *= -1;
        	}	
		return hashCode;
	}
	private void setInputs(HttpServletRequest request) {
        	Properties properties = new Properties();
        	InputStream inputStream = null;
        	String version = (String) request.getSession().getAttribute("version");
        	if(version == null) {
                	try {
                        	inputStream = this.getClass().getClassLoader().getResourceAsStream("config/index.properties");
                        	properties.load(inputStream);
                        	version = properties.getProperty("version");
                        	request.getSession().setAttribute("version", version);
                	}
                	catch(IOException ioe) {
                        	ioe.printStackTrace();
                	}
        	}
        	String text = "";
		String xml = "";
		      xml +="<peptideMatch xmlns=\"http://research.bioinformatics.udel.edu/peptidematch\" xmlns:xsi=\"http://www.w3.org/2001/XMSchema-instance\" xsi:schemaLocation=\"http://research.bioinforamtics.udel.edu/peptidematch http://research.bioinforamtics.udel.edu/peptidematch/docs/peptidematch.xsd\">\n";
		      xml += " <queryInfo>\n";
		      xml += "	<sequenceDataSet>\n";
		      xml += "		<version>"+version+"</version>\n";
        	text += "##Sequence data set: "+ version;
        	String uniref100 = query.getUniRef100Only();
        	if(uniref100 != null && uniref100.equals("Y")) {
                	text += " | UniRef100";
		       xml += "		<uniref100Only>yes</uniref100Only>\n";
        	}
		else {
		       xml += "		<uniref100Only>no</uniref100Only>\n";
		}
        	String lEqi = query.getLEqI();
        	if(lEqi != null && lEqi.equals("Y")) {
                	//text += " | Leucine (L) and IsoLeucine (I) are equivalent";
                	text += " | L and I are equivalent";
		       xml += "		<lEqi>yes</lEqi>\n";
        	}
		else {
		       xml += "		<lEqi>no</lEqi>\n";
		}
		      xml += "	</sequenceDataSet>\n";
        	text += "\n";
		text += "##Job ID: "+jobId+"\n";
			xml += "  <jobId>"+ jobId+"</jobId>\n";
        	Organism[] organisms = query.getSelectedOrganisms();
        	if(organisms != null && organisms.length > 0) {
                	text += "##Target organisms: ";
		      xml += "	<targetOrganisms>\n";
                	for(int i = 0; i < organisms.length; i++) {
                        	if(i == 0) {
                                	text += organisms[i].getName()+" ["+organisms[i].getTaxonId()+"]";
                        	}
                        	else {
                                	text += "; "+organisms[i].getName()+" ["+organisms[i].getTaxonId()+"]";
                        	}
		      	xml += "	<organism name=\""+ organisms[i].getName()+"\" taxononomyId=\""+organisms[i].getTaxonId()+"\"/>\n";
                	}
		      xml += "	</targetOrganisms>\n";
                	text += "\n";
        	}
        	text += "##Unique query peptides: "+query.getPeptides().length+"\n";
		xml +="	<uniqueQueryPeptides>"+query.getPeptides().length+"</uniqueQueryPeptides>\n";
		xml +="</queryInfo>\n";
        	inputsText = text;
		inputsXML = xml;
	}

	
	private Map<String, String> getOrgIdToNameMap(HttpServletRequest request) {
	 	Map<String, String> orgIdToNameMap = new HashMap<String, String>();
		if(request.getSession().getAttribute("orgIdToNameMap") == null) {
			try {
                		FileReader fs = new FileReader( request.getRealPath("/") + "WEB-INF/classes/config/orgNameToTaxon.txt");
                		BufferedReader br = new BufferedReader(fs);
                		String eachLine;
                		String organism_id;
                		String organism_name;
                		System.out.println("reading orgNameToTaxon.txt..");
                		while ((eachLine = br.readLine()) != null) {
                        		String[] fields = eachLine.split("\t");
                        		organism_name = fields[0].replaceAll("[\\(].*[\\)]", "").trim();
                        		organism_id = fields[1].trim();
                        		orgIdToNameMap.put(organism_id, organism_name);
                		}
				fs.close();
			}
			catch(IOException ioe) {
				ioe.printStackTrace();
			}
                	request.getSession().setAttribute("orgIdToNameMap", orgIdToNameMap);
        	}
        	else {
                	orgIdToNameMap = (HashMap<String, String>)request.getSession().getAttribute("orgIdToNameMap");
        	}
		return orgIdToNameMap;
	}

	Query getSinglePart(HttpServletRequest request, PrintWriter out) {
        	if (request.getParameter("query") != null) {
                	String[] peptides = request.getParameter("query").split(",");
			query.setPeptides(peptides);
        	}
        	if (request.getParameter("organism") != null) {
                	//out.println(request.getParameter("organism"));
                	String[] organisms = request.getParameter("organism").split(",");
			Organism[] selectedOrganisms = new Organism[organisms.length];
                        Map<String, String> orgIdToNameMap = getOrgIdToNameMap(request); 
                        for(int i=0; i < organisms.length; i++) {
                        	String taxonId = organisms[i];
                                String organismName = orgIdToNameMap.get(taxonId);
                                Organism organism = new Organism(organismName, taxonId);
                                selectedOrganisms[i] = organism;
                        }
                        if(selectedOrganisms.length > 0) {
                                query.setSelectedOrganisms(selectedOrganisms);
                        }
        	}
        	if (request.getParameter("format") != null) {
                	format = request.getParameter("format");
        	}
		else {
			format = "tab";
		}
		query.setOutputFormat(format);
                if(request.getParameter("uniref100")!=null) {
                        uniref100=request.getParameter("uniref100").trim().toUpperCase();
                }
                query.setUniRef100Only(uniref100);
                if(request.getParameter("leqi")!=null) {
                        lEqi=request.getParameter("leqi").trim().toUpperCase();
               	} 
                query.setLEqI(lEqi);
		return query;
	}

	Query getMultiPart(HttpServletRequest request, PrintWriter out) throws ServletException {
		Query query = new Query();
		try {
			//PrintWriter out = response.getWriter();
        		List<FileItem> items = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
        		for (FileItem item : items) {
            			if (item.isFormField()) {
                			// Process regular form field (input type="text|radio|checkbox|etc", select, etc).
                			String fieldName = item.getFieldName();
                			String fieldValue = item.getString();
					//out.println(fieldName+ " | " + fieldValue);
					if(fieldName.equals("query")) {
						String[] peptides = fieldValue.toUpperCase().split(",");
						ArrayList cleanPeptidesList = new ArrayList();
                                                String originalQueryPeptides = "";
                                                for(int i = 0; i < peptides.length; i++) {
                                                	originalQueryPeptides += peptides[i]+"\n";
                                                        if(peptides[i].length() > 0 && !cleanPeptidesList.contains(peptides[i])) {
                                                       		cleanPeptidesList.add(peptides[i].trim());
                                                        }
                                                }
                                                query.setOriginalQueryPeptides(originalQueryPeptides);
                                                String[] cleanPeptides = new String[cleanPeptidesList.size()];
                                                query.setPeptides((String[])cleanPeptidesList.toArray(cleanPeptides));
					}
					if(fieldName.equals("organism")) {
						String[] organisms = fieldValue.toUpperCase().split(",");
						Organism[] selectedOrganisms = new Organism[organisms.length];
						Map<String, String> orgIdToNameMap = getOrgIdToNameMap(request);
                				for(int i=0; i < organisms.length; i++) {
							String taxonId = organisms[i];
							String organismName = orgIdToNameMap.get(taxonId);
							Organism organism = new Organism(organismName, taxonId);	
							selectedOrganisms[i] = organism;
                				}
						if(selectedOrganisms.length > 0) {
							query.setSelectedOrganisms(selectedOrganisms);
						}	
					}
					if(fieldName.equals("format")) {
						format = fieldValue;
					}
					else {
						format = "tab";
					}
					query.setOutputFormat(format);
					if(fieldName.equals("uniref100")) {
                                                uniref100=item.getString().trim().toUpperCase();
                                        }
                                        query.setUniRef100Only(uniref100);
                                        if(fieldName.equals("leqi")) {
                                                lEqi=item.getString().trim().toUpperCase();
                                        }
                                        query.setLEqI(lEqi);
            			} else {
                			// Process form file field (input type="file").
                			String fieldName = item.getFieldName();
                			String fileName = FilenameUtils.getName(item.getName());
                			InputStream is = item.getInputStream();
					String fileList = getUploadedFileContent(is);
					if(fieldName.equals("queryFile")) {
						String queryList=  fileList;
                				if(queryList.length() > 0) {
							if(queryList.indexOf(">") != -1) {
								query = processInputString(queryList, query);
							}
							else {
                        					String[] peptides = queryList.split("\n");
								ArrayList cleanPeptidesList = new ArrayList();
                                                		String originalQueryPeptides = "";
                                                		for(int i = 0; i < peptides.length; i++) {
                                                			originalQueryPeptides += peptides[i]+"\n";
                                                        		if(peptides[i].length() > 0 && !cleanPeptidesList.contains(peptides[i])) {
                                                       				cleanPeptidesList.add(peptides[i].trim());
                                                        		}
                                                		}
                                                		query.setOriginalQueryPeptides(originalQueryPeptides);
                                                		String[] cleanPeptides = new String[cleanPeptidesList.size()];
                                                		query.setPeptides((String[])cleanPeptidesList.toArray(cleanPeptides));
							}
                				}
						else {
							out.println("queryFile is empty");
							out.close();
						}
        				}
					if(fieldName.equals("organismFile")) {
						String taxonList=  fileList;
                				if(taxonList.length() > 0) {
                        				String[] organisms = taxonList.split("\n");
							Organism[] selectedOrganisms = new Organism[organisms.length];
							Map<String, String> orgIdToNameMap = getOrgIdToNameMap(request); 
                					for(int i=0; i < organisms.length; i++) {
								String taxonId = organisms[i];
								String organismName = orgIdToNameMap.get(taxonId);
								Organism organism = new Organism(organismName, taxonId);	
								selectedOrganisms[i] = organism;
                					}
							if(selectedOrganisms.length > 0) {
								query.setSelectedOrganisms(selectedOrganisms);
							}	
                				}
        				}
            			}
        		}
    		} 
		catch (FileUploadException e) {
        		throw new ServletException("Cannot parse multipart request.", e);
        		//out.println("Cannot parse multipart request.");
			//e.printStackTrace();
    		}
		catch(IOException ioe) {
			ioe.printStackTrace();
		}
		
		return query;
	}

	 private ArrayList<MatchedProtein> doSearch(String queryPeptide, Organism[] selectedOrganisms, String uniref100Only, String ilEquivalent, String sortBy, PrintWriter out, String format) {
        PeptidePhraseQuery peptideQuery = new PeptidePhraseQuery();
        SolrDocumentList docs = new SolrDocumentList();
        int numberFound = 0;
        ArrayList<MatchedProtein> matchedProteins = new ArrayList<MatchedProtein>();
        if(selectedOrganisms == null || selectedOrganisms.length == 0) {
		long startTime = System.currentTimeMillis();
                peptideQuery.queryByPeptide(queryPeptide, 0, 1, uniref100Only, ilEquivalent, sortBy);
		long estimatedTime = System.currentTimeMillis() - startTime;	
		System.out.println("search time: " + estimatedTime + " " + queryPeptide);
                numberFound = peptideQuery.getResult();
                if(numberFound > 0) {
			printPerPeptideMatchedProteinsTableHeader(out, queryPeptide, numberFound, format); 
                        for(int i = 0; i < numberFound; i += 100) {
                                peptideQuery.queryByPeptide(queryPeptide, i, 100, uniref100Only, ilEquivalent, sortBy);
                                docs = peptideQuery.getCurrentDocs();
                                Iterator<SolrDocument> docItr = docs.iterator();
                                while(docItr.hasNext()) {
                                        MatchedProtein matchedProtein = getMatchedProtein(queryPeptide, docItr.next(), ilEquivalent);
                                        matchedProteins.add(matchedProtein);
					printMatchedProteinInfo(matchedProtein, out, format);	
                                }
				out.flush();
                        } 
			printPerPeptideMatchedProteinsTableFooter(out, format); 
                }
        }
        else {
                String organisms = "";
                for(int i=0; i < selectedOrganisms.length; i++) {
                        System.out.println("index "+i+" "+selectedOrganisms[i].getTaxonId());
                        if(i == 0) {
                                organisms += selectedOrganisms[i].getTaxonId();
                        }
                        else {
                                organisms += ";"+selectedOrganisms[i].getTaxonId();
                        }
                }
                System.out.println("selectedOrgs: "+ organisms);
		long startTime = System.currentTimeMillis();
                peptideQuery.queryByPeptideWithMultiOrganism(queryPeptide, organisms, 0, 1, uniref100Only, ilEquivalent, sortBy);
		long estimatedTime = System.currentTimeMillis() - startTime;	
		//System.out.println("search time: " + estimatedTime);
		System.out.println("search time: " + estimatedTime + " " + queryPeptide);
                numberFound = peptideQuery.getResult();
                if(numberFound > 0) {
			printPerPeptideMatchedProteinsTableHeader(out, queryPeptide, numberFound, format); 
                        for(int i = 0; i < numberFound; i += 100) {
                                peptideQuery.queryByPeptideWithMultiOrganism(queryPeptide, organisms, i, 100, uniref100Only, ilEquivalent, sortBy);
                                docs = peptideQuery.getCurrentDocs();
                                Iterator<SolrDocument> docItr = docs.iterator();
                                while(docItr.hasNext()) {
                                        //matchedProteins.add(getMatchedProtein(queryPeptide, docItr.next(), ilEquivalent));
                                        MatchedProtein matchedProtein = getMatchedProtein(queryPeptide, docItr.next(), ilEquivalent);
                                        matchedProteins.add(matchedProtein);
					printMatchedProteinInfo(matchedProtein, out, format);	
                                }
				out.flush();
                        }
			printPerPeptideMatchedProteinsTableFooter(out, format); 
                }

        }
        return matchedProteins;
    }

	String getUploadedFileContent(InputStream is) { 
		String fileContent = "";
		BufferedReader br = new BufferedReader(new InputStreamReader(is));
    		try {
        		StringBuilder sb = new StringBuilder();
        		String line = br.readLine();
			System.out.println("|"+line+"|");
			line = line.trim();
			line = line.replaceAll("\r\n", ""); 
        		while (line != null) {
            			//sb.append(line.toUpperCase());
            			//sb.append(",");
				System.out.println("|"+line+"|");
				line = line.trim();
				line = line.replaceAll("\r\n", ""); 
				sb.append(line+"\n");
            			line = br.readLine();
        		}
        		String list = sb.toString();
			//fileContent =  list.substring(0, list.length() -1);
			fileContent =  list;
			sb.setLength(0);
		}
		catch(IOException ioe) {
			ioe.printStackTrace();
		}
		return fileContent;	
	}

	 private MatchedProtein getMatchedProtein(String queryPeptide, SolrDocument doc, String ilEquivalent) {
        MatchedProtein matchedProtein = new MatchedProtein();

        matchedProtein.setProteinAC((String)doc.getFieldValue("ac"));

        String proteinID = (String)doc.getFieldValue("proteinID");
        matchedProtein.setProteinID(proteinID);

        String[] ids = proteinID.split("_");
        String reviewStatus = "";
        if(ids[0].length() < 6) {
                reviewStatus = "Y";
        }
        else {
                reviewStatus = "N";
        }
        matchedProtein.setReviewStatus(reviewStatus);
        matchedProtein.setProteinName((String)doc.getFieldValue("proteinName"));

        String organismName = (String)doc.getFieldValue("organismName");
        String organismID = (String)doc.getFieldValue("organismID");
        Organism org = new Organism(organismName, organismID);
        matchedProtein.setOrganism(org);

        String taxonomicGroupName = (String)doc.getFieldValue("taxongroupName");
        String taxonomicGroupID = (String)doc.getFieldValue("taxongroupID");
        Organism taxonomicGroup = new Organism(taxonomicGroupName, taxonomicGroupID);
        matchedProtein.setTaxonomicGroup(taxonomicGroup);

        String nist = (String)doc.getFieldValue("nist");
        String pride = (String)doc.getFieldValue("pride");
        String peptideAtlas = (String)doc.getFieldValue("peptideAtlas");
        String iedb = (String)doc.getFieldValue("iedb");
/*
        if(nist.length() > 0 && !nist.equals("Z")) {
                matchedProtein.setNIST(nist);
        }
*/
        if(peptideAtlas.length() > 0 && !peptideAtlas.equals("Z")) {
                matchedProtein.setPeptideAtlas(peptideAtlas);
        }
        if(pride.length() > 0 && !pride.equals("Z")) {
                matchedProtein.setPride(pride);
        }
        if(iedb.length() > 0 && !iedb.equals("Z")) {
               String[] iedbs = iedb.split(",");
                matchedProtein.setIEDB(iedbs);
        }
        String originalSeq = (String)doc.getFieldValue("originalSeq");
        matchedProtein.setSequence(originalSeq);
        matchedProtein.setSeqLength(originalSeq.length());
        matchedProtein.setMatchedRanges(getMatchedRanges(queryPeptide, originalSeq, ilEquivalent));

        return matchedProtein;
    }

	private MatchedRange[] getMatchedRanges(String originalQueryPeptide, String originalSeq, String ilEquivalent) {
        String sequence = originalSeq;
        String queryPeptide = originalQueryPeptide;
        ArrayList<MatchedRange> matchedRangeList = new ArrayList<MatchedRange>();
        if(ilEquivalent.equals("Y")) {
                sequence = sequence.replaceAll("L", "I");
                queryPeptide = queryPeptide.replaceAll("L", "I");
        }
        int seqLength = sequence.length();
        for(int i=0; i<=seqLength-queryPeptide.length(); i++){
                if(sequence.substring(i, i+queryPeptide.length()).toUpperCase().equals(queryPeptide.toUpperCase())){
                        MatchedRange matchRange = new MatchedRange((i+1), i+queryPeptide.length());
                        if(ilEquivalent.equals("Y")) {
                                ArrayList<Integer> replacedPosList = new ArrayList<Integer>();
                                for(int j = i; j < i+queryPeptide.length(); j++) {
                                        char originalChar = originalSeq.charAt(j);
                                        char replacedChar = sequence.charAt(j);
                                        if(originalChar != replacedChar && originalChar != originalQueryPeptide.charAt(j-i)) {
                                                replacedPosList.add(new Integer(j+1));
                                        }
                                }
                                int[] replacedPos = ArrayUtils.toPrimitive(replacedPosList.toArray(new Integer[0]));
                                matchRange.setReplacedPos(replacedPos);
                        }
                        matchedRangeList.add(matchRange);
                }
        }
        MatchedRange[] matchedRanges = new MatchedRange[matchedRangeList.size()];
        matchedRangeList.toArray(matchedRanges);
        return matchedRanges;
    }

	private void printPerPeptideMatchedProteinsTableHeader(PrintWriter out, String queryPeptide, int totalMatchedProteins, String format) {
		if(format.equals("tab") || format.equals("xls")) {
                        out.print("##Query peptide: "+ queryPeptide+"\n");
                        out.print("##Number of matched proteins: "+totalMatchedProteins+"\n");
                        if(query.getUniRef100Only() != null && !query.getUniRef100Only().equals("Y")) {
                                out.print("#Protein AC\tProtein ID\tProtein Name\tLength\tOrganism\tMatched Range(s)\tProteomic Databases\tIEDB\n");
                        }
                        else {
                                out.print("#UniRef100 Cluster ID\tRepresentative Protein AC\tProtein Name\tLength\tOrganism\tMatched Range(s)\tProteomic Databases\tIEDB\n");
                        }
                }
                else if(format.equals("xml")) {
                        out.print("<matchPerPeptide>\n");
                        out.print("<queryPeptide>"+queryPeptide+"</queryPeptide>\n");
                        out.print("<numberOfMatchedProteins>"+totalMatchedProteins+"</numberOfMatchedProteins>\n");
                }
		out.flush();
	}

	private void printPerPeptideMatchedProteinsTableFooter(PrintWriter out, String format) {
		if(format.equals("tab") || format.equals("xls")) {
			out.print("\n");
		}
		else if(format.equals("xml")) { 
			out.print("</matchPerPeptide>\n");
		}
		out.flush();
	}
		

	private void printPerPeptideMatchedProteinsTable(PrintWriter out, String queryPeptide, ArrayList<MatchedProtein> matchedProteins, String format) {
		if(format.equals("tab") || format.equals("xls")) {
        		out.print("##Query peptide: "+ queryPeptide+"\n");
        		out.print("##Number of matched proteins: "+matchedProteins.size()+"\n");
			if(query.getUniRef100Only() != null && !query.getUniRef100Only().equals("Y")) {
        			out.print("#Protein AC\tProtein ID\tProtein Name\tLength\tOrganism\tMatched Range(s)\tProteomic Databases\tIEDB\n");
        			for(int i = 0; i < matchedProteins.size(); i++) {
                			MatchedProtein matchedProtein = matchedProteins.get(i);
                			out.print(matchedProtein.getTabDelimitedInfo(false));
        			}
				out.print("\n");
			}
			else {
        			out.print("#UniRef100 Cluster ID\tRepresentative Protein AC\tProtein Name\tLength\tOrganism\tMatched Range(s)\tProteomic Databases\tIEDB\n");
        			for(int i = 0; i < matchedProteins.size(); i++) {
                			MatchedProtein matchedProtein = matchedProteins.get(i);
                			out.print(matchedProtein.getTabDelimitedInfo(true));
        			}
				out.print("\n");
			}
		}
		else if(format.equals("xml")) { 
			out.print("<matchPerPeptide>\n");
			out.print("<queryPeptide>"+queryPeptide+"</queryPeptide>\n");
			out.print("<numberOfMatchedProteins>"+matchedProteins.size()+"</numberOfMatchedProteins>\n");	
			
			if(query.getUniRef100Only() != null && query.getUniRef100Only().equals("Y")) {
        			for(int i = 0; i < matchedProteins.size(); i++) {
                			MatchedProtein matchedProtein = matchedProteins.get(i);
                			out.print(matchedProtein.getXMLInfo(true));
				}
				out.print("</matchPerPeptide>\n");
			}
			else {
        			for(int i = 0; i < matchedProteins.size(); i++) {
                			MatchedProtein matchedProtein = matchedProteins.get(i);
                			out.print(matchedProtein.getXMLInfo(false));
				}
				out.print("</matchPerPeptide>\n");
			}
		}
    	}

	private void printMatchedProteinInfo(MatchedProtein matchedProtein, PrintWriter out, String format) {
		if(format.equals("tab") || format.equals("xls")) {
			if(query.getUniRef100Only() != null && query.getUniRef100Only().equals("Y")) {
                		out.print(matchedProtein.getTabDelimitedInfo(true));
			}
			else {
                		out.print(matchedProtein.getTabDelimitedInfo(false));
			}
		}
		else if(format.equals("xml")) { 
			if(query.getUniRef100Only() != null && query.getUniRef100Only().equals("Y")) {
                		out.print(matchedProtein.getXMLInfo(true));
			}
			else {
                		out.print(matchedProtein.getXMLInfo(false));
			}
		}
		//out.flush();
	}


	 private void countPerProteinMatch(String peptide, ArrayList<MatchedProtein> matchedProteins) {
                for(int i = 0; i < matchedProteins.size(); i++) {
                        MatchedProtein matchedProtein = (MatchedProtein)matchedProteins.get(i);
                        String proteinAC = matchedProtein.getProteinAC();
                        if(perProteinMatchedPeptides.get(proteinAC) == null) {
                                ArrayList<String> peptideList = new ArrayList<String>();
                                peptideList.add(peptide+"("+matchedProtein.getMatchedRangeInfo()+")");
                                perProteinMatchedPeptides.put(proteinAC, peptideList);
				proteinInfoMap.put(proteinAC, matchedProtein.getIProClassInfo()+"\n"+matchedProtein.getSequence());
                        }
                        else {
                                ArrayList<String> peptideList = perProteinMatchedPeptides.get(proteinAC);
                                if(!peptideList.contains(peptide+"("+matchedProtein.getMatchedRangeInfo()+")")) {
                                        peptideList.add(peptide+"("+matchedProtein.getMatchedRangeInfo()+")");
                                        perProteinMatchedPeptides.put(proteinAC, peptideList);
					proteinInfoMap.put(proteinAC, matchedProtein.getIProClassInfo()+"\n"+matchedProtein.getSequence());
                                }
                        }
                }
    }
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
                doGet(request,response);
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
                   	System.out.println(lineNumber+ ": "+currentLine);
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
}
