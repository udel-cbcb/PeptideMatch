<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" %>
<%@ page session="true" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="query.PeptidePhraseQuery" %>
<%@ page import="java.io.*" %>
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
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>


<%
	String errMsg = null;
	String peptide = request.getParameter("peptide");
	String db = "all";
	String dbStr = "gpmDB, NIST Peptide Libraries, PeptideAtlas, PRIDE";
	if(request.getParameter("db") != null) {
		db = request.getParameter("db");
		if(db.equals("gpmdb")) {
			dbStr = "gpmDB";
		}
		else if(db.equals("nist")) {
			dbStr = "NIST Peptide Libraries";
		}
		else if(db.equals("peptideatlas")) {
			dbStr = "PeptideAtlas";
		}
		else if(db.equals("pride")) {
			dbStr = "PRIDE";
		}
	}
	if(peptide == null) {
		errMsg = "<span style=\"color: red;\">You need to specify the query peptide!</span><br/>";	
	}
	peptide = peptide.replaceAll("[^a-zA-Z]", "");
        if(peptide.length() < 3) {
		errMsg += "<span style=\"color: red;\">The query peptide must be at least 3 characters!</span><br/>";	
	}		
	String spectraInfo = "Nothing found in gpmDB, NIST Peptide Libraries, PeptideAtlas or PRIDE databases";
	//HashMap savedPeptideSpectraInfo = (HashMap)session.getAttribute("peptideSpectraInfo");
	if(errMsg == null) {
		//if(savedPeptideSpectraInfo == null || savedPeptideSpectraInfo.get(peptide+"_"+db) == null) {
			//System.out.println("session info");
			HashMap gpmdb = null;
			HashMap nist = null;
			HashMap peptideatlas = null;
			HashMap pride = null;
			String spectraMatchInfo = "";
			SortedSet<String> keys = null;
			if(db.equals("all")) {
				gpmdb = checkGPMDBAll(peptide);
				//nist = checkNISTAll(peptide);
				peptideatlas = checkPeptideAtlasAll(peptide, out);
				pride = checkPrideAll(peptide);
				Iterator iter = null;
				//if(gpmdb.size() > 0 || nist.size() > 0 || peptideatlas.size() > 0 || pride.size() > 0) {
				if(gpmdb.size() > 0 || peptideatlas.size() > 0 || pride.size() > 0) {
					String gpmdbRecord = null;
					String nistRecord = null; 
					String peptideatlasRecord = null;
					String prideRecord = null;
					ArrayList orgs = new ArrayList();
					if(gpmdb.size() > 0) {
						gpmdbRecord = "<tr><td align=\"center\">gpmDB</td><td>";
						keys = new TreeSet<String>(gpmdb.keySet());
						iter = keys.iterator();
						while(iter.hasNext()) {
							String key = (String)iter.next();	
   							String value = (String)gpmdb.get(key);
							//String url = "http://gpmdb.thegpm.org/thegpm-cgi/dblist_pep.pl?seq="+peptide;
							gpmdbRecord +="<a href=\""+value+"\">"+key+"</a>; ";
						}
						if(gpmdbRecord.indexOf("; ") > 0) {
							gpmdbRecord = gpmdbRecord.substring(0, gpmdbRecord.length()-2);	
						}
						gpmdbRecord +="</td></tr>\n";
					}
/*
					if(nist.size() > 0) {
						nistRecord = "<tr><td align=\"center\" style=\"white-space: nowrap;\">NIST Peptide Libraries</td><td>";
						keys = new TreeSet<String>(nist.keySet());
						iter = keys.iterator();
						while(iter.hasNext()) {
							String key = (String)iter.next();	
   							String value = (String)nist.get(key);
							//String url = "http://peptide.nist.gov/browser/peptide_stat.php?description=IT&organism="+key+"&pep_seq="+peptide;
							//System.out.println(url);
							nistRecord +="<a href=\""+value+"\">"+key+"</a>; ";
						}
						if(nistRecord.indexOf("; ") > 0) {
							nistRecord = nistRecord.substring(0, nistRecord.length()-2);	
						}
						nistRecord += "</td></tr>\n";
					}
*/
					if(peptideatlas.size() > 0) {
						peptideatlasRecord = "<tr><td align=\"center\">PeptideAtlas</td><td>";
						keys = new TreeSet<String>(peptideatlas.keySet());
						iter = keys.iterator();
						while(iter.hasNext()) {
							String key = (String)iter.next();	
   							String value = (String)peptideatlas.get(key);
							//String url = "https://db.systemsbiology.net/sbeams/cgi/PeptideAtlas/Search?search_key="+peptide+"&apply_action=GO&exact_match=exact_match";
							String url = "https://db.systemsbiology.net/sbeams/cgi/PeptideAtlas/GetPeptide?_tab=3&organism_name="+key+"&searchWithinThis=Peptide+Sequence&searchForThis="+peptide+"&action=QUERY";
							peptideatlasRecord +="<a href=\""+value+"\">"+key+"</a>; ";
							//peptideatlasRecord +="<a href=\""+url+"\">"+key+"</a>; ";
						}
						if(peptideatlasRecord.indexOf("; ") > 0) {
							peptideatlasRecord = peptideatlasRecord.substring(0, peptideatlasRecord.length()-2);	
						}
						peptideatlasRecord += "</td></tr>\n";
					}
					if(pride.size() > 0) {
						prideRecord = "<tr><td align=\"center\">PRIDE</td><td>";
						if(pride.get("error") == null) {
							keys = new TreeSet<String>(pride.keySet());
							iter = keys.iterator();
							while(iter.hasNext()) {
								String key = (String)iter.next();	
   								String value = (String)pride.get(key);
								if(!key.equals("all")&&!key.equals("hasMore")) {
									//String url = "https://db.systemsbiology.net/sbeams/cgi/PeptideAtlas/Search?search_key="+key+"&apply_action=GO&exact_match=exact_match";
									prideRecord +="<a href=\""+value+"\">"+key+"</a>; ";
								}
							}
							if(pride.get("hasMore")!= null) {
								prideRecord +="<a href=\""+(String)pride.get("all")+"\">"+" [More...]"+"</a>; ";
							}
							if(prideRecord.indexOf("; ") > 0) {	
								prideRecord = prideRecord.substring(0, prideRecord.length()-2);	
							}
						}
						else {
							prideRecord += "Source database is currently not available."; 
						}
						prideRecord += "</td></tr>\n";
					}
					/*
					Set gpmdbSet = gpmdb.keySet();
					Iterator iter = gpmdbSet.iterator();
					while(iter.hasNext()) {
						String key = (String)iter.next();	
					}
					Set peptideatlasSet = peptideatlas.keySet();
					iter = peptideatlasSet.iterator();
					while(iter.hasNext()) {
						String key = (String)iter.next();	
						if(!orgs.contains(key)) {
							orgs.add(key);
						}
					}
					Set nistSet = nist.keySet();
					iter = nistSet.iterator();
					while(iter.hasNext()) {
						String key = (String)iter.next();	
						if(!orgs.contains(key)) {
							orgs.add(key);
						}
					}*/
					spectraMatchInfo += "<table class=\"sample\" width=\"100%\">\n";
					spectraMatchInfo += "	<tr><th width=\"20%\">Proteomics Databases</th><th>Follow the links to view more information</th></tr>\n";
					if(gpmdbRecord != null) {
						spectraMatchInfo += gpmdbRecord;
					}	
					if(nistRecord != null) {
						spectraMatchInfo += nistRecord;
					}	
					if(peptideatlasRecord != null) {
						spectraMatchInfo += peptideatlasRecord;
					}	
					if(prideRecord != null) {
						spectraMatchInfo += prideRecord;
					}	
					spectraMatchInfo += "</table>\n";			
					/*
					Collections.sort(orgs);
					for(int i=0; i < orgs.size(); i++) {
						String org = (String)orgs.get(i);
						String gpmdbUrl = (String) gpmdb.get(org);
						String nistUrl = (String) nist.get(org);
						String peptideatlasUrl = (String) peptideatlas.get(org);
						if(gpmdbUrl != null || nistUrl != null || peptideatlasUrl != null) {
							if((i+1)% 2 == 0) {
								spectraMatchInfo += "	<tr bgcolor=lightgray><td>"+org+"</td><td>";
							}
							else {
								spectraMatchInfo += "	<tr><td>"+org+"</td><td>";
							}
							String links = "";
							if(gpmdbUrl != null) {
								links += "<a href=\""+gpmdbUrl+"\">gpmDB</a>"+ "; ";
							}
							if(nistUrl != null) {
								links += "<a href=\""+nistUrl+"\">NIST Peptide Libraries</a>"+ "; ";
							}
							if(peptideatlasUrl != null) {
								links += "<a href=\""+peptideatlasUrl+"\">Peptide Atlas</a>" +"; ";
							}
							links = links.substring(0, links.length() -2);
							spectraMatchInfo += links + "	</td></tr>\n";
						}
					}
					*/
				}
				else {
					spectraMatchInfo = "Nothing found in gpmDB, NIST Peptide Libraries, PeptideAtlas or PRIDE databases.";
				}
			}
			else if(db.equals("gpmdb")) {
				dbStr = "gpmDB";
				gpmdb = checkGPMDBAll(peptide);
                                if(gpmdb.size() > 0) {
					String url = "http://gpmdb.thegpm.org/thegpm-cgi/dblist_pep.pl?seq="+peptide;
					response.sendRedirect(url);
					return;
                                }
                                else {
                                        spectraMatchInfo = "Nothing found in gpmDB database.";
                                }
			}
			else if(db.equals("nist")) {
				dbStr = "NIST Peptide Librares";
                                nist = checkNISTAll(peptide);
                                if(nist.size() > 0) {
					ArrayList orgs = new ArrayList();
                                        Set nistSet = nist.keySet();
                                        Iterator iter = nistSet.iterator();
                                        while(iter.hasNext()) {
                                                String key = (String)iter.next();
                                                if(!orgs.contains(key)) {
                                                        orgs.add(key);
                                                }
                                        }
					if(orgs.size() == 1) {
                                                String org = (String)orgs.get(0);
                                                String nistUrl = (String) nist.get(org);
						response.sendRedirect(nistUrl);	
						return;
					}
					else {
						spectraMatchInfo = "<table border=0 class=\"sample\">\n";
                                        	spectraMatchInfo += "   <tr><th align=center>Organism Name</th></tr>\n";
						Collections.sort(orgs);
                                        	for(int i=0; i < orgs.size(); i++) {
                                                	String org = (String)orgs.get(i);
                                                	String nistUrl = (String) nist.get(org);
                                                	if(nistUrl != null) {
                                                        	if((i+1)% 2 == 0) {
                                                                	spectraMatchInfo += "   <tr bgcolor=lightgray><td align=center><a href=\""+nistUrl+"\">"+org+"</a></td>";
                                                        	}
                                                        	else {
                                                                	spectraMatchInfo += "   <tr><td align=center><a href=\""+nistUrl+"\">"+org+"</a></td>";
                                                        	}
                                                        	spectraMatchInfo += "   </tr>\n";
                                                	}
                                        	}
                                        	spectraMatchInfo += "</table>\n";
					}
                                }
                                else {
                                        spectraMatchInfo = "Nothing found in NIST Peptide Libraries.";
				}
			}
			else if(db.equals("pride")) {
				dbStr = "PRIDE";
				pride = checkPrideAll(peptide);
				if(pride.size() > 0) {
					if(pride.get("error") == null) {
						response.sendRedirect((String)pride.get("all"));
						return;
					}
					else {
                                        	spectraMatchInfo = "Source database is currently not available.";
					}
				}
                                else {
                                        spectraMatchInfo = "Nothing found in PRIDE database";
				}
			}	
			else if(db.equals("peptideatlas")) {
				dbStr = "Peptide Atlas";
				peptideatlas = checkPeptideAtlasAll(peptide, out);
                                if(peptideatlas.size() > 0) {
					String url = "https://db.systemsbiology.net/sbeams/cgi/PeptideAtlas/Search?search_key="+peptide+"&apply_action=GO&exact_match=exact_match"; 
					response.sendRedirect(url);
					return;
                                }
                                else {
                                        spectraMatchInfo = "Nothing found in Peptide Atlas database.";
				}
			}
			spectraInfo = spectraMatchInfo;	
 			/*savedPeptideSpectraInfo = new HashMap();
			savedPeptideSpectraInfo.put(peptide+"_"+db, spectraInfo);
			session.setAttribute("peptideSpectraInfo", savedPeptideSpectraInfo);
			*/
		/*}
		else {
			spectraInfo = (String)savedPeptideSpectraInfo.get(peptide+"_"+db);
		}*/
	}
%>
<%!
/*
	private ArrayList getMatchedSpectraLibraryOrganims(String[] queryOrgs) {
		ArrayList matchedList = new ArrayList();
		ArrayList organismList = new ArrayList();
		try {
			InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/nist_organisms_taxon.txt");
			BufferedReader taxonReader = new BufferedReader(new InputStreamReader(inputStream));
			String line = taxonReader.readLine();
			String[] rec = null;
			while(line != null) {
				rec = line.split("\t");
				if(!organismList.contains(rec[3])) {
					organismList.add(rec[3]);
				}		
				line = taxonReader.readLine();
			}
			inputStream = this.getClass().getClassLoader().getResourceAsStream("config/gpmdb_organisms_taxon.txt");
			taxonReader = new BufferedReader(new InputStreamReader(inputStream));
			line = taxonReader.readLine();
			while(line != null) {
				rec = line.split("\t");
				if(!organismList.contains(rec[3])) {
					organismList.add(rec[3]);
				}		
				line = taxonReader.readLine();
			}
			inputStream = this.getClass().getClassLoader().getResourceAsStream("config/peptide_atlas_taxon.txt");
			taxonReader = new BufferedReader(new InputStreamReader(inputStream));
			line = taxonReader.readLine();
			while(line != null) {
				rec = line.split("\t");
				if(!organismList.contains(rec[3])) {
					organismList.add(rec[3]);
				}		
				line = taxonReader.readLine();
			}
		}
		catch(IOException ioe) {
			ioe.printStackTrace();
		}
		for(int i=0; i < queryOrgs.length; i++) {
			if(organismList.contains(queryOrgs[i])) {
				matchedList.add(queryOrgs[i]);
			}
		}
		return matchedList; 
	}
*/	
	private String checkNIST(JspWriter out, String peptide, String organismId) {
		InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/nist_organisms_taxon.txt");
		try {
			BufferedReader taxonReader = new BufferedReader(new InputStreamReader(inputStream));
			String line = taxonReader.readLine();
			HashMap map = new HashMap();
			while(line != null) {
				String[] rec = line.split("\t");
				map.put(rec[3], rec[0]);		
				line = taxonReader.readLine();
				//out.println(line+"<br>");
			}
			String url = "http://peptide.nist.gov/browser/peptide_stat.php?description=IT&organism="+map.get(organismId)+"&pep_seq="+peptide;	
			//out.println(url);
			BufferedReader reader = new BufferedReader(new InputStreamReader(new URL(url).openStream()));
			line = reader.readLine();
			//out.println("?"+line);
			while(line != null) {
				String match = "Peptide Sequence: "+peptide;
				if(line.toUpperCase().indexOf(match.toUpperCase()) > 0) {
					return url;
				}	
				line = reader.readLine();
			}
			//return url;
		}
		catch(IOException ioe) {
			ioe.printStackTrace();
		}
		return "";
	}
	private HashMap checkNISTAll(String peptide) {
		HashMap urls = new HashMap();
		InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/nist_organisms_taxon.txt");
		try {
			BufferedReader taxonReader = new BufferedReader(new InputStreamReader(inputStream));
			String line = taxonReader.readLine();
			HashMap map = new HashMap();
			ArrayList orgs = new ArrayList();
			while(line != null) {
				//out.println(line+"<br>");
				String[] rec = line.split("\t");
				map.put(rec[0], rec[1]);		
				orgs.add(rec[0]);
				line = taxonReader.readLine();
			}
			for(int i=0; i < orgs.size(); i++) {
				String org = (String) orgs.get(i);
				String url = "http://peptide.nist.gov/browser/peptide_stat.php?description=IT&organism="+org+"&pep_seq="+peptide;	
				BufferedReader reader = new BufferedReader(new InputStreamReader(new URL(url).openStream()));
				line = reader.readLine();
				while(line != null) {
					String match = "Peptide Sequence: "+peptide;
					if(line.toUpperCase().indexOf(match.toUpperCase()) > 0) {
						//urls.put((String) map.get(org), url);
						urls.put(org, url);
						//out.println(org+" | "+(String)map.get(org)+"<br>");
					}	
					line = reader.readLine();
				}
			}
		}
		catch(IOException ioe) {
			ioe.printStackTrace();
		}
		return urls;
	}
	
	private HashMap checkPrideAll(String peptide) {
		HashMap urls = new HashMap();
		HashMap tmpUrls = new HashMap();
		String line;
		int count = 0;
		HashMap taxonIdToName = new HashMap();
		//String prideTSVUrl = "http://central.biomart.org/martservice/results?query=%3C!DOCTYPE%20Query%3E%3CQuery%20client=%22true%22%20processor=%22TSV%22%20limit=%22-1%22%20header=%221%22%3E%3CDataset%20name=%22pride%22%20config=%22pride_config%22%3E%3CFilter%20name=%22peptide_sequence%22%20value=%22"+peptide+"%22/%3E%3CAttribute%20name=%22experiment_ac%22/%3E%3CAttribute%20name=%22sample_name%22/%3E%3CAttribute%20name=%22sample_description_comment%22/%3E%3CAttribute%20name=%22newt_name%22/%3E%3CAttribute%20name=%22newt_ac%22/%3E%3C/Dataset%3E%3C/Query%3E";
		String prideTSVUrl = "http://central.biomart.org/martservice/results?query=%3C!DOCTYPE%20Query%3E%3CQuery%20client=%22true%22%20processor=%22TSV%22%20limit=%22-1%22%20header=%221%22%3E%3CDataset%20name=%22pride%22%20config=%22pride_config%22%3E%3CFilter%20name=%22peptide_sequence%22%20value=%22"+peptide+"%22/%3E%3CAttribute%20name=%22experiment_ac%22/%3E%3CAttribute%20name=%22newt_name%22/%3E%3CAttribute%20name=%22newt_ac%22/%3E%3CAttribute%20name=%22sample_name%22/%3E%3CAttribute%20name=%22sample_description_comment%22/%3E%3C/Dataset%3E%3C/Query%3E";
		System.out.println(prideTSVUrl);		
		HashMap taxonToLongName = new HashMap();
		ArrayList taxonNames = new ArrayList();
		try {
			BufferedReader reader = new BufferedReader(new InputStreamReader(new URL(prideTSVUrl).openStream()));
			while((line = reader.readLine()) != null) {
				//if(!line.startsWith("PRIDE Experiment Accession") && !line.equals("error=true")) {
				if(!line.startsWith("PRIDE Experiment Accession")) {
					count++;
					if(line.equals("error=true")) {
						tmpUrls.put("error", "error=true");
						System.out.println("pride error1");
						urls.put("error", "PRIDE database is not available");	
					}
					else {
						//System.out.println(line+"<br/>");
						String[] rec = line.split("\t");
						String orgName = rec[1];
						String orgTaxonId = rec[2];
						if(!taxonNames.contains(orgName)) {
							taxonNames.add(orgName);
						}
						String savedName = (String)taxonToLongName.get(orgTaxonId);
						//System.out.println(orgName+"\t before |"+orgTaxonId + "| saved: |"+savedName+"|");
						if(savedName == null) {
							taxonToLongName.put(orgTaxonId, orgName);		
						}
						else if(savedName.length() < orgName.length()) {
							taxonToLongName.put(orgTaxonId, orgName);		
							//System.out.println(orgName+"\t after "+orgTaxonId);
						}		
						String orgUrl = "http://central.biomart.org/martwizard/#!/Protein_sequence_and_structure?mart=PRIDE+%28EBI%2C+UK%29&step=4&peptide_sequence="+peptide+"&attributes=name%2Ctype%2Csample_name%2Cnewt_name%2Cnewt_ac%2Cbrenda%2Csample_description_comment%2Cexperiment_ac&species_filter="+orgName;	
						//urls.put(orgName+"^|^"+orgTaxonId, orgUrl);
						if(orgName.length() > 0) {
							//System.out.println(orgName+"\t"+orgUrl);
							tmpUrls.put(orgName, orgUrl);
						}
					}
				}	
			}
			if(count > 1 ) {
				System.out.println("count: " +count);
				if(tmpUrls.get("error") == null) {
					String allPrideMatchUrl = "http://central.biomart.org/martwizard/#!/Protein_sequence_and_structure?mart=PRIDE+%28EBI%2C+UK%29&step=4&peptide_sequence="+peptide+"&attributes=name%2Ctype%2Csample_name%2Cnewt_name%2Cnewt_ac%2Cbrenda%2Csample_description_comment%2Cexperiment_ac";
					//urls.put("ALL^|^all", allPrideMatchUrl);	
					urls.put("all", allPrideMatchUrl);	
					System.out.println("pride error2");
					if(taxonNames.size() > taxonToLongName.size()) {
						urls.put("hasMore", allPrideMatchUrl);
					}
				}
				else {
					urls.put("error", "PRIDE database is not available");	
					System.out.println("pride error3");
				}
			}
			Set keys = taxonToLongName.keySet();
                        Iterator iter = keys.iterator();
                        while(iter.hasNext()) {	
				String taxon = (String)iter.next();
				String value = (String)taxonToLongName.get(taxon);
				//System.out.println(taxon+" ?? "+value);	
				if(tmpUrls.get(value) != null) {
					urls.put(value, tmpUrls.get(value));
				}	
			}
		}
		catch (IOException ioe) {
			ioe.printStackTrace();
		}
		System.out.println("Final urls: "+urls.size());
		return urls;
	}

	
	private HashMap getCompleteProteomes() {
		InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/proteomes_complete.txt");
		HashMap map = new HashMap();
		try {
			BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
			String line = reader.readLine();
			while(line != null) {
				String[] rec = line.split("\t");
				map.put(rec[0], rec[2]);		
				line = reader.readLine();
			}
		}
		catch(IOException ioe) {
			ioe.printStackTrace();
		}
		return map;
	}

	private String checkGPMDB(String peptide, String organismId) {
		InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/gpmdb_organisms_taxon.txt");
		String url = "http://gpmdb.thegpm.org/thegpm-cgi/dblist_pep.pl?seq="+peptide;	
		try {
			BufferedReader taxonReader = new BufferedReader(new InputStreamReader(inputStream));
			String line = taxonReader.readLine();
			HashMap map = new HashMap();
			while(line != null) {
				String[] rec = line.split("\t");
				map.put(rec[3], rec[0]);		
				line = taxonReader.readLine();
				//out.println(line+"<br>");
			}
			//out.println(url);
			BufferedReader reader = new BufferedReader(new InputStreamReader(new URL(url).openStream()));
			line = reader.readLine();
			//out.println(line);
			while(line != null) {
				if(line.equals("No identifications found for \""+peptide+"\"")) {
					return "";
				}
				else {
					String matchOrganism = "<i>"+map.get(organismId)+"</i>";
					if(line.toUpperCase().indexOf(matchOrganism.toUpperCase()) > 0) {
						return url;
					}	
				}
				line = reader.readLine();
			}
		}
		catch(IOException ioe) {
			ioe.printStackTrace();
		}
		return "";
	}

	private HashMap checkGPMDBAll(String peptide) {
		HashMap urls = new HashMap();
		InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/gpmdb_organisms_taxon.txt");
		String url = "http://gpmdb.thegpm.org/thegpm-cgi/dblist_pep.pl?seq="+peptide;	
		try {
			BufferedReader taxonReader = new BufferedReader(new InputStreamReader(inputStream));
			String line = taxonReader.readLine();
			ArrayList orgs = new ArrayList();	
			HashMap map = new HashMap();
			while(line != null) {
				String[] rec = line.split("\t");
				map.put(rec[0], rec[1]);		
				orgs.add(rec[0]);	
				line = taxonReader.readLine();
			}
			BufferedReader reader = new BufferedReader(new InputStreamReader(new URL(url).openStream()));
			line = reader.readLine();
			while(line != null) {
				if(line.equals("No identifications found for \""+peptide+"\"")) {
					return null;
				}
				else {
					for(int i=0; i < orgs.size(); i++) {
						String org = (String) orgs.get(i);
						if(line.toUpperCase().indexOf(org.toUpperCase()) > 0) {
							//urls.put((String)map.get(org), url);	
							urls.put(org, url);	
						}
					}	
				}
				line = reader.readLine();
			}
		}
		catch(IOException ioe) {
			ioe.printStackTrace();
		}
		return urls;
	}

	private String checkPeptideAtlas(JspWriter out, String peptide, String organismId) {
		InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/peptide_atlas_taxon.txt");
		String url = "https://db.systemsbiology.net/sbeams/cgi/PeptideAtlas/Search?search_key="+peptide+"&apply_action=GO&exact_match=exact_match";	
		try {
			BufferedReader taxonReader = new BufferedReader(new InputStreamReader(inputStream));
			String line = taxonReader.readLine();
			HashMap map = new HashMap();
			while(line != null) {
				String[] rec = line.split("\t");
				map.put(rec[3], rec[0]);		
				line = taxonReader.readLine();
			}
			BufferedReader reader = new BufferedReader(new InputStreamReader(new URL(url).openStream()));
			line = reader.readLine();
			while(line != null) {
				if(line.equals("There were no matches in the index to match your search key \'"+peptide+"\'")) {
					return "";
				}
				else {
					String matchOrganism = map.get(organismId)+": ";
					if(line.toUpperCase().indexOf(matchOrganism.toUpperCase()) > 0 && line.indexOf(peptide)>0) {
						return url;
					}	
				}
				line = reader.readLine();
			}
		}
		catch(IOException ioe) {
			ioe.printStackTrace();
		}
		return "";
	}
	
	private HashMap checkPeptideAtlasAll(String peptide, JspWriter out) {
		HashMap urls = new HashMap();
		try {
			InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/peptide_atlas_taxon.txt");
			String url = "https://db.systemsbiology.net/sbeams/cgi/PeptideAtlas/Search?search_key="+peptide+"&apply_action=GO&exact_match=exact_match";	
			//String url = "https://db.systemsbiology.net/sbeams/cgi/PeptideAtlas/Search?search_key="+peptide+"&apply_action=GO";	
			BufferedReader taxonReader = new BufferedReader(new InputStreamReader(inputStream));
			String orgline = taxonReader.readLine();
			HashMap map = new HashMap();
			ArrayList orgs = new ArrayList();
			while(orgline != null) {
				String[] rec = orgline.split("\t");
				map.put(rec[0], rec[1]);		
				orgs.add(rec[0]);
				orgline = taxonReader.readLine();
			}
			taxonReader.close();
			//URL oracle = new URL("https://db.systemsbiology.net/sbeams/cgi/PeptideAtlas/Search?search_key=AAVEEGIVLGGGCALLR&apply_action=GO&exact_match=exact_match");
			URL oracle = new URL(url);
        		BufferedReader in = new BufferedReader(new InputStreamReader(oracle.openStream()));

        		String line;
			Boolean isSummary = false;
			String directHit = "";
			String selected = "option selected";
			//String peptideSequence = "<TR NAME='getpeptide_overview' ID='getpeptide_overview' CLASS='tbl_visible' ><TD NOWRAP bgcolor=\"cccccc\" >Peptide Sequence</TD><TD  >"+peptide+"</TD></TR>";
			String peptideSequence = "<A HREF=http://proteininformationresource.org/cgi-bin/peptidematch?peptide="+peptide+" TARGET=_BLANK color=blue>"+peptide+"</A></SPAN></TD></TR>";
        		while ((line = in.readLine()) != null) {
				if(line.equals("There were no matches in the index to match your search key \'"+peptide+"\'")) {
					//System.out.println(peptide+" no match");	
					return null;
				}
				else {
					if(line.indexOf("Peptide hits") > 0) {
						isSummary = true;		
						
					}
					for(int i=0; i < orgs.size(); i++) {
						String org = (String)orgs.get(i);
//<A ONCLICK="toggle_tbl('tbl1');"><IMG ID='tbl1_gif' TITLE='Show/Hide Section' SRC='/sbeams/images/small_gray_minus.gif'></A>  Human: <A HREF="/sbeams/cgi/PeptideAtlas/GetPeptide?atlas_build_id=353&searchWithinThis=Peptide+Name&searchForThis=PAp00097790&action=QUERY"><font style="BACKGROUND-COLOR: CCCCCC">IIISPEENVTLTCTAENQLER</font></A> - find <B>1</B> identifier in <B>3</B> builds , observed >= <B>13</B> times </TD></TR></TABLE><TABLE><TR NAME='tbl1' ID='tbl1' CLASS='tbl_visible' ><TD COLSPAN=2><TABLE  CLASS="sortable" BORDER=0 CELLPADDING=2 CELLSPACING=2>

						if(isSummary && line.toUpperCase().indexOf(org.toUpperCase()) > 0 && line.indexOf(peptide)>0 && line.indexOf("Show/Hide Section") > 0) {
							//urls.put((String)map.get(org), url);	
							//System.out.println(line);
							//System.out.println(sep+"\n"+link[0]);
							
							String sep = "</A>  "+org+": <A HREF=\"";
							String[] link = line.split(sep);
							sep ="</font></A> - find";
							String[] link1 = link[1].split(sep);
							sep = "\"><font style=\"BACKGROUND-COLOR: CCCCCC\">"+peptide; 
							String link2 = link1[0].replace(sep, ""); 
							url = "https://db.systemsbiology.net"+link2;
							urls.put(org, url);	
						}
						if(line.toUpperCase().indexOf(org.toUpperCase()) > 0 && line.indexOf(selected)>0) {
							directHit = org;
						}
						if(directHit.equals(org) && line.indexOf(peptideSequence)>0) {
							//urls.put((String)map.get(org), url);	
							urls.put(org, url);	
						}
					}	
				}
			}
			in.close();
		}
		catch(IOException ioe) {
			ioe.printStackTrace();
		}
		return urls;
	}
%>
<html>
<head>
<link href="./imagefiles/styles.css" type="text/css" rel="stylesheet">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<script type="text/javascript">
/*
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-39280281-1']);
  _gaq.push(['_trackPageview']);
  _gaq.push(['_trackPageLoadTime']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
*/
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
td.searchLable {
	color:#ffffff;
	font-family:Verdana,Arial, Helvetica, sans-serif;
	font-size:10px;
	font-weight:bold
}
.searchBannerBox {
font-family: Verdana, Tahoma, Arial, Helvetica, sans-serif; 
font-size: 11px; 
WIDTH: 180px;  
HEIGHT:18px
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
}
.menulink{
margin-left:8px;
}
#show_organism{
display:none;
}
table.sample {
	border-width: 2px;
	border-spacing: 4px;
	border-style: outset;
	border-color: ;
	border-collapse: collapse;
	background-color: ;
}
table.sample th {
	border-width: 2px;
	padding: 4px;
	border-style: inset;
	border-color: gray;
	background-color: white;
	-moz-border-radius: ;
}
table.sample td {
	border-width: 2px;
	padding: 4px;
	border-style: inset;
	border-color: gray;
	background-color: white;
	-moz-border-radius: ;
}

</style>
</head>
<body class="main">
<MAP NAME="PIRBanner_Map">
<AREA SHAPE="rect" alt="home" COORDS="16,16,110,60" HREF="http://pir.georgetown.edu/pirwww/index.shtml" TARGET="_top">
<AREA SHAPE="rect" alt="uniprot" COORDS="140,36,178,50" HREF="http://www.uniprot.org/" TARGET="_blank">
</MAP>	
<table cellspacing="0" cellpadding="0" width="100%" border="0" height="80">
<tr> 
      <td><img alt="" src="./imagefiles/PIRBanner.png" border="0" usemap="#PIRBanner_Map"></td> 
      <td width="99%" nowrap="" height="1" background="./imagefiles/blueSpacer.png">
		<img alt="" src="./imagefiles/spacer.gif" width="1" height="1" border="0">
	  </td>
      <td align="right" valign="top" height="80" width="400" background="./imagefiles/gradientHome6.png">
         <table border="0" cellpadding="0" cellspacing="0" width="400" height="80">
          <form action="http://pir.georgetown.edu/cgi-bin/textsearch.pl" id="textSearch" method="get" name="textSearchForm" style="MARGIN: 0px">
   <tr>
              <td width="400" colspan="10"><img alt="" src="./imagefiles/spacer.gif" width="400" height="30"></td>
            </tr>  
            <tr>
              <td><img alt="" src="./imagefiles/spacer.gif" width="60" height="1"></td>
	            <td><input type="radio" name="sitesearch" checked=""></td>
	            <td align="right" nowrap="" class="searchLable">Protein Search</td>
	            <td><input type="radio" name="sitesearch" value="sitesearch"></td>
	            <td align="right" nowrap="" class="searchLable">Site Search</td>
	            <td><img alt="" src="./imagefiles/spacer.gif" width="8" height="1"></td>
              <td align="right"><input alt="submit" type="image" src="./imagefiles/but06.png" border="0" width="18" height="16" name="submit"></td>
              <td><img alt="" src="./imagefiles/spacer.gif" width="2" height="1"></td>
              <td align="right"><input alt="query" name="query0" type="text" class="searchBannerBox" style="background:#CED9E7;" value=""></td>
              <td><img alt="" src="./imagefiles/spacer.gif" width="6" height="1"></td>
            </tr>
<input type="hidden" name="field0" value="ALL">
<input type="hidden" name="search" value="1">
</form>
 </table>
      </td>
    </tr>

</table>

<table cellSpacing=0 cellPadding=0 width=100% bgColor=#333333 border=0><tr>
<TD><img src='./imagefiles/leftSearch.png'></TD><!-- ############### group dependent-->
<td class=sml01 width=99% background='./imagefiles/bgcolor.png'>&nbsp;</td>
<noscript>
    <td>
			<table bgcolor="#4a4a4a" width="100%" height="21" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="nrm02" nowrap>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="http://pir.georgetown.edu/pirwww/index.shtml" class="m"><font face=verdana size="2pt" color="white">Home</font></a> &nbsp;&nbsp;&nbsp;&nbsp; 
						<a href="http://pir.georgetown.edu/pirwww/about/" class="m"><font face=verdana size="2pt" color="white">About PIR</font></a>&nbsp;&nbsp;&nbsp;&nbsp; 
						<a href="http://pir.georgetown.edu/pirwww/dbinfo/" class="m"><font face=verdana size="2pt" color="white">Databases</font></a> &nbsp;&nbsp;&nbsp;&nbsp; 
						<a href="http://pir.georgetown.edu/pirwww/search/" class="m"><font face=verdana size="2pt" color="white">Search/Retrieval</font></a> &nbsp;&nbsp;&nbsp;&nbsp; 
						<a href="http://pir.georgetown.edu/pirwww/search/" class="m"><font face=verdana size="2pt" color="white">Download</font></a> &nbsp;&nbsp;&nbsp;&nbsp; 
						<a href="http://pir.georgetown.edu/pirwww/support/" class="m"><font face=verdana size="2pt" color="white">Support</font></a>
					</td>
				</tr>
			</table>
		</td>
</noscript>
</tr>
</table>
<table style="margin-left: 100px;" border="0" cellspacing="0" cellpadding="0" class="docTitle"><tbody><tr>
          <td width="10" rowspan="2"><img height="20" src="./imagefiles/spacer.gif" width="10" alt=""></td>
<td>
   <table border="0" cellpadding="0" cellspacing="0" width="8" height="20">
      <tbody><tr>
         <td bgcolor="#336699"><img height="20" src="./imagefiles/spacer.gif" width="8" alt=""></td>
      </tr>
   </tbody></table>
</td>
<td width="10"><img height="20" src="./imagefiles/spacer.gif" width="10" alt=""></td>

                <td>
                <a href="http://pir.georgetown.edu/pirwww/" class="titleLink"><b>HOME</b></a>
                                                                   / <a href="http://pir.georgetown.edu/pirwww/search/" class="titleLink"><b>Search</b></a>
                    / <b><a href="index.jsp">Peptide Match</a></b><!-- ############### page dependent-->
    </td></tr>
</tbody></table>
<br/>
<% if(errMsg != null) {%>
<table style="font-size: 13px; margin-left: 50px; width:100%">
        <tr>
                <td><%=errMsg%>
                </td>
        </tr>
</table>
<% } else {%>
<table style="font-size: 11pt; margin-left: 100px;"> 
	<tr>
		<td align=right><b>Query peptide:</b></td><td><%=peptide.toUpperCase() %></td>
	</tr>
	<tr>
		<td align=right><b>Database(s) Searched:</b></td><td><%=dbStr%></td>
	</tr>
	<tr>
		<td align=right valign=top><b>Matched Mass Spectra:</b></td><td valign=top><%=spectraInfo%></td>
	</tr>
<!--
	<tr>
		<td align=right><br/><br/><br/>Back to Peptide Match</td><td><br/><br/><br/><a title='return to searching page' href=./index.jsp><img src=./imagefiles/restart.png border=0></a></td>
	</tr>
-->
</table>
<% } %>
<br/>
<br/>
<br/>
<br/>
<table cellspacing="0" cellpadding="0" width="100%" bgcolor="#eeeeee" border="0" class="nrm02">
  <tbody>
    <tr> 
<td align="center" valign="middle" nowrap="" bgcolor="#71a1cf">
<img src="./imagefiles/pirlogo2.png" alt="PIR">
</td>
 <td align="left" valign="top"> 
<table background="./imagefiles/spacer.gif" width="686" border="0" cellpadding="3" cellspacing="0" class="nrm02">
<tbody>
<tr> 
<td align="left" valign="bottom" nowrap="">
                  &nbsp;<a href="http://pir.georgetown.edu/pirwww/" target="_blank" class="footerMenu">Home</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/about/" target="_blank" class="footerMenu">About PIR</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/dbinfo" target="_blank" class="footerMenu">Databases</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/search/" target="_blank" class="footerMenu">Search/Analysis</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/download/" target="_blank" class="footerMenu">Download</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/support/" target="_blank" class="footerMenu">Support</a>
              </td>
              <td align="right" valign="bottom" nowrap="" class="nrm01">
                  &nbsp;<a href="http://pir.georgetown.edu/pirwww/support/sitemap.shtml" target="_blank" class="footer">SITE MAP</a>
                  |&nbsp;<a href="http://pir.georgetown.edu/pirwww/about/linkpir.shtml" target="_blank" class="footer">TERMS OF USE</a>
              </td>
            </tr>
            <tr> 
              <td colspan="2" align="center" nowrap="" class="footer3"><span class="nrm10"><font color="#999999"> &copy; 2018</font>
                                    <img src="./imagefiles/spacer.gif" alt="" width="20" height="1">
                                    <b><a href="http://pir.georgetown.edu/pirwww/index.shtml" target="_blank">Protein Information Resource</a></b>
                                    <img src="./imagefiles/spacer.gif" alt="" width="105" height="1"></span></td>
            </tr>

            <tr><td colspan="2" nowrap=""><table border="0" cellpadding="2" cellspacing="0" class="nrm02" width="100%">
                         <tbody><tr><td><img src="./imagefiles/spacer.gif" alt="" width="50" height="1"></td>
                             <td nowrap="" align="center" class="footer"><a href="http://bioinformatics.udel.edu/"><font color="#999999">University of Delaware</font></a>
                                          <br><font color="#999999">15 Innovation Way, Suite 205
                                          <br>Newark, DE 19711, USA</font></td>
                             <td><img src="./imagefiles/spacer.gif" alt="" width="20" height="1"></td>

                            <td nowrap="" align="center" class="footer"><a href="http://gumc.georgetown.edu/"><font color="#999999">Georgetown University Medical Center</font></a>
                                  <br><font color="#999999">3300 Whitehaven Street, NW, Suite 1200
                                  <br>Washington, DC 20007, USA</font></td>
                          </tr></tbody></table></td>
            </tr>
          </tbody>
        </table></td>
			<td width="99%">&nbsp;
			</td>       
    </tr>
</tbody>
</table>
</body>
<!-- Menu Related -->
<script language="javascript" src="./imagefiles/milonic_src.js"
	type="text/javascript"></script>
<script language="javascript">
  if(ns4) _d.write("<scr"+"ipt language=JavaScript src=./imagefiles/mmenuns4.js><\/scr"+"ipt>");		
    else _d.write("<scr"+"ipt language=JavaScript src=./imagefiles/mmenudom.js><\/scr"+"ipt>"); 
</script>
<script language="JavaScript" src="./imagefiles/mmenudom.js"></script>
<script>function getflta(ap){return _f}</script>
<script language="javascript" src="./imagefiles/menu_data.js"
	type="text/javascript"></script>

<!-- Menu Related ends -->
<script type="text/javascript" src="./imagefiles/jquery-latest.js"></script> 
<script type="text/javascript" src="./imagefiles/jquery.tablesorter.js"></script>

</html>


