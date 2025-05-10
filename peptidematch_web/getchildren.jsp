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
	String peptide = request.getParameter("peptide");
        String organismId = request.getParameter("organism_id");
        String numberFound=request.getParameter("numberfound");

	 String swissprot ="N";
        String isoform = "N";
        String uniref100Only ="N";
        String ilEquivalent = "N";
        String swissprotValue = "N";
        String isoformValue = "N";
        String uniref100Value = "N";
        String lEqiValue = "N";
        String sortBy = "ac_asc";
       	
	String trOnly = "N";
        String trOnlyValue = "N";
        String isoOnly = "N";
        String isoOnlyValue = "N";

        if(request.getParameter("sortBy") != null) {
                sortBy = request.getParameter("sortBy");
        }
        if(request.getParameter("swissprot") != null) {
                swissprotValue = request.getParameter("swissprot");
                swissprot = swissprotValue;
        }
        if(request.getParameter("isoform") != null) {
                isoformValue = request.getParameter("isoform");
                isoform = isoformValue;
        }
        if(request.getParameter("uniref100") != null) {
                uniref100Value = request.getParameter("uniref100");
                uniref100Only = uniref100Value;
        }
        if(request.getParameter("lEqi") != null) {
                lEqiValue = request.getParameter("lEqi");
                ilEquivalent = lEqiValue;
        }
        if(request.getParameter("trOnly") != null) {
                trOnlyValue = request.getParameter("trOnly");
                trOnly = trOnlyValue;
        }
        if(request.getParameter("isoOnly") != null) {
                isoOnlyValue = request.getParameter("isoOnly");
                isoOnly = isoOnlyValue;
        }
 
	String openedNodeId=request.getParameter("id");
        String[] idParts = openedNodeId.split("-");
	String openedNodeIdTaxon = idParts[1];
	int nodeCount = 0;
	nodeCount =Integer.parseInt(idParts[2]);

	ArrayList candidateChildren = new ArrayList();
        Map<String, Long> sortedHitOrganismsCount = new LinkedHashMap();
	PeptidePhraseQuery peptideQuery = new PeptidePhraseQuery();

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
				String childrenData = request.getRealPath("/"+"WEB-INF/classes/config/children.txt");
				//String leavesData = request.getRealPath("/"+"WEB-INF/classes/config/leaves.txt");
				ArrayList leaves = new ArrayList();
                		try {
                          		String strLine;
                          		FileInputStream in = new FileInputStream(childrenData);
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
								//if(candidateChildren.contains(taxonId)) {
								//initial the solr connection
								//PeptidePhraseQuery peptideQuery = new PeptidePhraseQuery();
								peptideQuery = new PeptidePhraseQuery();
								SolrDocumentList docs = new SolrDocumentList();
								int match = 0;
								if(peptide.equals("*:*")){
        								peptideQuery.queryAll(start,rowsPerPage, swissprot, isoform, uniref100Only, ilEquivalent, trOnly, isoOnly);
								}
								else {
									if(!organismId.toLowerCase().equals("all")){
        									peptideQuery.queryByPeptideWithFullLineageOrganismAndTaxonId(peptide, organismId,taxonId, start, rowsPerPage, op, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
									}
									else{
        									peptideQuery.queryByPeptideWithFullLineageTaxonId(peptide, taxonId, start, rowsPerPage, op, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
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
								//}
							}
			 			}
					}
					in.close();	
						
				}catch(Exception e){
                           		System.out.println(e);
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
						    	String taxonNameUrl = "<span><a href='http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+ node.getTaxonomyID()+"'>" +node.getName() + "</a></span>";
						    	String rank =""; 
						    	if(!node.getType().equals("no rank")) {
								//rank = "<span style='color: navy;'>["+node.getType()+"]</span>";
								if(node.getType().equals("superkingdom")) {
                                                                        rank = "<span style='color: red'>["+node.getType()+"]</span>";
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
						    	//String seqCountUrl = "<span style='padding: 0 20px;'><a href='peptidewithlineagetaxonid.jsp?initialed=false&start=0&rows=20&keyword="+peptide+"&organism_id="+organismId+"&total_number="+numberFound+"&taxon_name="+node.getName().replaceAll("'", "&#39;")+"&taxon_id="+node.getTaxonomyID()+"'>"+node.getSeqCount()+"</a></span>";
						    	//String seqCountUrl = " (<a href='peptidewithlineagetaxonid.jsp?initialed=false&start=0&rows=20&keyword="+peptide+"&organism_id="+organismId+"&total_number="+numberFound+"&taxon_name="+node.getName().replaceAll("'", "&#39;")+"&taxon_id="+node.getTaxonomyID()+"'>"+node.getSeqCount()+"</a>)";
						    	//childrenNodes.put(node.getName().toUpperCase(), "<li class='jstree-closed' id='"+node.getId()+"'>"+taxonNameUrl+rank+seqCountUrl+"</li>");
							String link = "<a href='peptidewithlineagetaxonid.jsp?initialed=false&start=0&rows=20&keyword="+peptide+"&organism_id="+organismId+"&total_number="+node.getSeqCount()+"&taxon_name="+ node.getName().replaceAll("'", "&#39;")+"&taxon_id="+node.getTaxonomyID()+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly+"'>"+node.getName() + " " + rank+ " ("+node.getSeqCount()+")</a>";
                                                    childrenNodes.put(node.getName().toUpperCase(), "<li class='jstree-closed' id='"+node.getId()+"'>"+link);
						}
                                	}
					keys = new TreeSet<String>(childrenNodes.keySet());
					for(String key: keys) {
						children += childrenNodes.get(key);
					}
				     	children += "</ul>";
					taxonomyTree += children+"</li>";
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
