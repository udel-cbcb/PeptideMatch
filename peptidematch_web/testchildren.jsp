<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" %>
<%@ page session="true" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.TreeMap" %>
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
<%@ page import="query.TaxonomyTreeNode" %>
<%@ page import="query.TaxonomyLazyTreeNode" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>

<%
	//root {[1, no]}	Others {[0, no rank]}; cellular organisms {[131567, no rank]}; Viruses {[10239, superkingdom]}; unclassified sequences {[12908, no rank]}; other sequences {[28384, no rank]}
	//String firstLevelLineage = "root {[1, no]}; Others {[0, no rank]}; cellular organisms {[131567, no rank]}; Viruses {[10239, superkingdom]}; unclassified sequences {[12908, no rank]}; other sequences {[28384, no rank]}";
	//String[] taxonRec = firstLevelLineage.split("]}; ");
	//if(session == null) {
	//	response.sendRedirect("index.htm");
	//}
	 PeptidePhraseQuery peptideQuery = new PeptidePhraseQuery();
	String peptide = request.getParameter("peptide");
        String organismId = request.getParameter("organism_id");
        String numberFound=request.getParameter("numberfound");
       	
	  String uniref100Only ="N";
        String ilEquivalent = "N";
        String uniref100Value = "";
        String lEqiValue = "";
        String sortBy = "proteomic_asc";
        if(request.getParameter("sortBy") != null) {
                sortBy = request.getParameter("sortBy");
        }
        if(request.getParameter("uniref100") != null) {
                uniref100Value = "uniref100";
                uniref100Only = "Y";
        }
        if(request.getParameter("lEqi") != null) {
                ilEquivalent = "Y";
                lEqiValue = "lEqi";
        }
 
	String openedNodeId=request.getParameter("id");
        String[] idParts = openedNodeId.split("-");
	String openedNodeIdTaxon = idParts[1];
	int nodeCount = 0;
	nodeCount =Integer.parseInt(idParts[2]);
	ArrayList candidateChildren = new ArrayList();
	Map<String, Long> sortedHitOrganismsCount = new LinkedHashMap();

        if(!organismId.toLowerCase().equals("all")) {
        	if(session.getAttribute("organismsCount-"+peptide+"-"+organismId+"-"+uniref100Only+"-"+ilEquivalent) == null) {
           		sortedHitOrganismsCount = peptideQuery.queryByPeptideWithMultiOrganismWithGroup(peptide, organismId, uniref100Only, ilEquivalent, sortBy);
                        session.setAttribute("organismsCount-"+peptide+"-"+organismId+"-"+uniref100Only+"-"+ilEquivalent, sortedHitOrganismsCount);
                }
                else {
                       sortedHitOrganismsCount = (Map<String, Long>)session.getAttribute("organismsCount-"+peptide+"-"+organismId+"-"+uniref100Only+"-"+ilEquivalent);
                }
		candidateChildren = (ArrayList)session.getAttribute("candidateChildren-"+peptide+"-"+organismId+"-"+uniref100Only+"-"+ilEquivalent); 
		if(candidateChildren == null) {
			candidateChildren =  getCandidateChildren(request, sortedHitOrganismsCount);
			session.setAttribute("candidateChildren-"+peptide+"-"+organismId+"-"+uniref100Only+"-"+ilEquivalent, candidateChildren);
		}
        }
        else {
        	if(session.getAttribute("organismsCount-"+peptide+"-all"+"-"+uniref100Only+"-"+ilEquivalent) == null) {
                	sortedHitOrganismsCount = peptideQuery.queryByPeptideWithGroup(peptide, uniref100Only, ilEquivalent, sortBy);
                        session.setAttribute("organismsCount-"+peptide+"-all"+"-"+uniref100Only+"-"+ilEquivalent, sortedHitOrganismsCount);
                }
                else {
                        sortedHitOrganismsCount = (Map<String, Long>)session.getAttribute("organismsCount-"+peptide+"-all"+"-"+uniref100Only+"-"+ilEquivalent);
                }
		candidateChildren = (ArrayList)session.getAttribute("candidateChildren-"+peptide+"-"+organismId+"-"+uniref100Only+"-"+ilEquivalent); 
		if(candidateChildren == null) {
			candidateChildren =  getCandidateChildren(request, sortedHitOrganismsCount);
			session.setAttribute("candidateChildren-"+peptide+"-all"+"-"+uniref100Only+"-"+ilEquivalent, candidateChildren);
		}
       }
	//System.out.println("CandidateChildren: "+candidateChildren);

	String[] taxonRec;
  	String[] taxon;
  	String[] taxonIdAndType;
  	String taxonName;
	String taxonId;
	String type;
	int start = 0;
	int rowsPerPage = 20;	
	String op = "OR";	
	int totalMatch = 0;
	TreeMap childNodes = new TreeMap(); 
	String taxonomyTree = "";
	TaxonomyLazyTreeNode node = null;	
	TreeMap nodes = new TreeMap();
	SortedSet<String> keys = null;
	if(peptide != null && organismId != null && numberFound != null&& openedNodeId != null) {
	 		peptide = peptide.replaceAll("[^a-zA-Z]", "");
	 		if(peptide.length() >= 3) {
				
				String childrenData = request.getRealPath("/"+"WEB-INF/classes/config/condenseChildren.txt");
				//String leavesData = request.getRealPath("/"+"WEB-INF/classes/config/leaves.txt");
				ArrayList leaves = new ArrayList();
				FileInputStream in = null;
                		try {
                          		String strLine;
                          		in = new FileInputStream(childrenData);
                          		BufferedReader br = new BufferedReader(new InputStreamReader(in));
                          		while((strLine = br.readLine())!= null) {
                                  		String[] rec = strLine.split("\t");
                                  		String org = rec[0];
  						taxon = org.split(" \\{\\[");
  						taxonIdAndType = taxon[1].split(", ");
  						taxonName = taxon[0];
						taxonId = taxonIdAndType[0].trim();
						type = taxonIdAndType[1];
				  		//hasChildren.put(org, "yes");
				  		//out.println(org+"<br>");
				  		if(taxonId.equals(openedNodeIdTaxon)) {
							//out.println("I am here 3");
                                  			String taxons = rec[1];
                           				taxonRec = taxons.split("]}; "); 
								
							for(int i=0; i < taxonRec.length; i++) {
  								taxon = taxonRec[i].split(" \\{\\[");
  								taxonIdAndType = taxon[1].split(", ");
  								taxonName = taxon[0];
								taxonId = taxonIdAndType[0].trim();
								type = taxonIdAndType[1];
								if(candidateChildren.contains(taxonId)) {
								//initial the solr connection
								peptideQuery = new PeptidePhraseQuery();
								SolrDocumentList docs = new SolrDocumentList();
								int match = 0;
								if(peptide.equals("*:*")){
        								peptideQuery.queryAll(start,rowsPerPage, uniref100Only, ilEquivalent);
								}
								else {
									if(!organismId.toLowerCase().equals("all")){
        									peptideQuery.queryByPeptideWithShortLineageOrganismAndTaxonId(peptide, organismId,taxonId, start, rowsPerPage, op, uniref100Only, ilEquivalent, sortBy);
									}
									else{
        									peptideQuery.queryByPeptideWithShortLineageTaxonId(peptide, taxonId, start, rowsPerPage, op, uniref100Only, ilEquivalent, sortBy);
									}
								}
								docs = peptideQuery.getCurrentDocs();
								match = peptideQuery.getResult();
								if(match > 0) {
									nodeCount++;
									totalMatch += match;
									String nodeId = peptide+"-"+taxonId+"-"+nodeCount;
									if(nodes.get(nodeId) == null) {
                                                				if(taxonName.equals("root")) {
                                                        				node = new TaxonomyLazyTreeNode("root", Integer.parseInt(taxonId), "", nodeId, match);
                                                				}
                                                				else {
                                                        				node = new TaxonomyLazyTreeNode(taxonName, Integer.parseInt(taxonId), type, nodeId, match);
                                                				}
                                                				nodes.put(nodeId, node);
                                                				childNodes.put(nodeId, node);
                                        				}
								}
								}
							}
			 			}
					}
				}catch(Exception e){
                           		System.out.println(e);
				} finally {
					try {
						if (in != null)
							in.close();
					} catch (IOException ex) {
						ex.printStackTrace();
					}
				}
				if(totalMatch > 0) {
					Iterator iter = childNodes.keySet().iterator();
					String children = "<ul>";
					HashMap childrenNodes = new HashMap();
                        		while(iter.hasNext()) {
                                		String key = (String)iter.next();
                                        	node = (TaxonomyLazyTreeNode) nodes.get(key); 
						if(node.getName().equals("root")) {
							taxonomyTree += "<li id='"+node.getId()+"'><span style='font-weight: bold; color: navy;'>Organism</span>";
						}
						else {
							//String nodeStr = node.getName() + "	
						    	//String taxonNameUrl = "<span><a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+ node.getTaxonomyID()+"'>" +node.getName() + "</a></span>";
						    	String taxonNameUrl = "<a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+ node.getTaxonomyID()+"'>" +node.getName() + "</a>";
						    	String rank =""; 
						    	if(!node.getType().equals("no rank")) {
								if(node.getType().equals("superkingdom")) {
                                                                        rank = "<font color=red>"+node.getType()+"</font>";
                                                                }
                                                                else if(node.getType().equals("kingdom")) {
                                                                        rank = "<span style='color: orange'>["+node.getType()+"]</span>";
                                                                }
                                                                else if(node.getType().equals("phylum")) {
                                                                        rank = "<span style='color: brown'>["+node.getType()+"]</span>";
                                                                }
                                                                else if(node.getType().equals("class")) {
                                                                        rank = "<span style='color: green'>["+node.getType()+"]</span>";
                                                                }
                                                                else if(node.getType().equals("order")) {
                                                                        rank = "<span style='color: blue'>["+node.getType()+"]</span>";
                                                                }
                                                                else if(node.getType().equals("family")) {
                                                                        rank = "<span style='color: purple'>["+node.getType()+"]</span>";
                                                                }
                                                                else if(node.getType().equals("genus")) {
                                                                        rank = "<span style='color: royalblue'>["+node.getType()+"]</span>";
                                                                }
                                                                else if(node.getType().equals("species")) {
                                                                        rank = "<span style='color: pink'>["+node.getType()+"]</span>";
                                                                }

						    	}
						    	String seqCountUrl = " (<a href='peptidewithlineagetaxonid.jsp?initialed=false&start=0&rows=20&keyword="+peptide+"&organism_id="+organismId+"&total_number="+numberFound+"&taxon_name="+node.getName().replaceAll("'", "&#39;")+"&taxon_id="+node.getTaxonomyID()+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"'>"+node.getSeqCount()+"</a>)";
						    	childrenNodes.put(node.getName().toUpperCase(), "<li class='jstree-closed' id='"+node.getId()+"'>"+taxonNameUrl+rank+seqCountUrl+"</li>");

						}
                                	}
					keys = new TreeSet<String>(childrenNodes.keySet());
					for(String key: keys) {
						children += childrenNodes.get(key);
					}
				     	children += "</ul>";
					//taxonomyTree += children+"</li>";
					taxonomyTree += children;
					out.println(taxonomyTree);
					//session.setAttribute("TreeNodes"+"-"+peptide, nodes);
                        	}
				else {
					out.println("\n\n");
					//response.sendError(HttpServletResponse.SC_NOT_FOUND);	
				}	
			}
			else {
				out.println("The query peptide must be at least 3 characters");
			}
		}
		else {
			out.println("You need to specify the query peptide and organism id(s)");
		}
	//}
	
%>
<%!
	private ArrayList getCandidateChildren(HttpServletRequest request, Map<String, Long> sortedHitOrganismsCount) {
		//System.out.println("I am here");
		ArrayList hitOrgs = new ArrayList();		
		for(String org: sortedHitOrganismsCount.keySet()) {
			if(!org.equals("totalOrganismMatches") && !org.equals("totalOrganismGroups")) {
		        	String[] rec = org.split("\\<\\|\\>");
		                String orgName = rec[0];
		                String orgId = rec[1];
				hitOrgs.add(orgId);
			}
		}
		ArrayList candidateChildren = new ArrayList();
		String shortLineageFile = request.getRealPath("/"+"WEB-INF/classes/config/shortLineage.txt");
        	try {
                	String strLine;
                	FileInputStream in = new FileInputStream(shortLineageFile);
                	BufferedReader br = new BufferedReader(new InputStreamReader(in));
                	while((strLine = br.readLine())!= null) {
                        	String[] rec = strLine.split("\t");
                        	String org = rec[0];
                        	//1267486       1, 10239, 11974, 142786, 11983, 1267486
				if(hitOrgs.contains(org)) {
					//System.out.println("MyLineage: "+ rec[1]);
					String[] lineage = rec[1].split(", ");
					for(int i=0; i < lineage.length; i++) {
						//System.out.println("LIneage: "+ lineage[i]);
						if(!candidateChildren.contains(lineage[i])) {
							candidateChildren.add(lineage[i]);
						}
					}
				}
			}
			in.close();
		}
		catch(IOException ioe) {
			ioe.printStackTrace();
		}
		return candidateChildren;	
	}
%>	
