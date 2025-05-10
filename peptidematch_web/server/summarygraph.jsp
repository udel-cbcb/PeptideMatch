<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" %>
<%@ page session="true" %>
<%@ page import="org.apache.solr.common.SolrDocumentList" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="org.apache.solr.common.SolrDocument" %>
<%@ page import="org.apache.solr.schema.FieldType" %>
<%@ page import="query.PeptidePhraseQuery" %>
<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="org.proteininformationresource.peptidematch.*" %>
<%@ page import="org.apache.commons.lang.ArrayUtils" %>
<%
if(request.getParameter("initialed")!=null &&request.getParameter("keyword")!=null &&request.getParameter("start")!=null &&request.getParameter("rows")!=null &&request.getParameter("organism_id")!=null){
	//session.invalidate();
	
        Map<String, String> orgIdToNameMap = new HashMap<String, String>();
	Properties properties = new Properties();
        InputStream inputStream = null;
        String version = (String) session.getAttribute("version");
	if(version == null) {
        	try {
                	inputStream = this.getClass().getClassLoader().getResourceAsStream("config/index.properties");
                	properties.load(inputStream);
                	version = properties.getProperty("version");
			session.setAttribute("version", version);
        	}
        	catch(IOException ioe) {
                	ioe.printStackTrace();
        	}
	}
	String originalQuery="";	
	int start=0;
	int rowsPerPage=1;
	String swissprot = "N";
	String isoform = "N";
	String swissprotValue = "N";
	String isoformValue = "N";
	String uniref100Only ="N";
        String ilEquivalent = "N";
        String uniref100Value = "N";
        String lEqiValue = "N";
        String sortBy = "ac_asc";
	String resultConstraint = "N";	
	String trOnly = "N";
        String trOnlyValue = "N";
        String isoOnly = "N";
        String isoOnlyValue = "N";

        if(request.getParameter("constraint")!= null) {
                resultConstraint = request.getParameter("constraint");
        }
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
	
	originalQuery = request.getParameter("keyword").trim().toUpperCase();
	start = Integer.parseInt(request.getParameter("start"));
	rowsPerPage = Integer.parseInt(request.getParameter("rows"));
	String organism_ID=request.getParameter("organism_id");
	//initial the solr connection
	PeptidePhraseQuery peptideQuery = new PeptidePhraseQuery();
	SolrDocumentList docs = new SolrDocumentList();
	int numberFound = 0;
	Map<String, Long> sortedHitOrganismsCount = new LinkedHashMap();
	Map<String, Long> sortedHitTaxonGroupsCount = new LinkedHashMap();
	System.out.println("before query: " + new Date());
	if(originalQuery.equals("*:*")){
		peptideQuery.queryAll(start,rowsPerPage, swissprot, isoform, uniref100Only, sortBy, trOnly, isoOnly);
	}
	else{
		originalQuery=originalQuery.replaceAll("[^a-zA-Z]", "");
		if(!organism_ID.toLowerCase().equals("all")) {
			peptideQuery.queryByPeptideWithMultiOrganism(originalQuery, organism_ID, 0, 1, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
			int numHits = peptideQuery.getResult();	
			if(session.getAttribute("organismsCount-"+originalQuery+"-"+organism_ID+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly) == null) {
				if(numHits > 2000) {	
					System.out.println("before org group search: "+ new Date());
					sortedHitOrganismsCount = peptideQuery.queryByPeptideWithMultiOrganismWithGroup(originalQuery, organism_ID, swissprot, isoform,  uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
					System.out.println("after org group search: "+ new Date());
				}
				else {
					System.out.println("org counting organism directly: " + numHits);
					peptideQuery.queryByPeptideWithMultiOrganism(originalQuery, organism_ID, 0, numHits, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
					ArrayList<MatchedProtein> matchedProteins = getMatchedProteins(peptideQuery.getCurrentDocs(), originalQuery, ilEquivalent, trOnly, isoOnly);
					sortedHitOrganismsCount = getOrganismCount(matchedProteins);
				}
				session.setAttribute("organismsCount-"+originalQuery+"-"+organism_ID+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly, sortedHitOrganismsCount);
			}
			else {
				sortedHitOrganismsCount = (Map<String, Long>) session.getAttribute("organismsCount-"+originalQuery+"-"+organism_ID+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly); 
			}
			if(session.getAttribute("taxonGroupsCount-"+originalQuery+"-"+organism_ID+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly) == null) {
				System.out.println("before taxon group group search: "+ new Date());
				sortedHitTaxonGroupsCount = getTaxonGroupCount(originalQuery, organism_ID, swissprot, isoform,  uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly); 
				System.out.println("after taxon group group search: "+ new Date());
				session.setAttribute("taxonGroupsCount-"+originalQuery+"-"+organism_ID+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly, sortedHitTaxonGroupsCount);
			}
			else {
				sortedHitTaxonGroupsCount = (Map<String, Long>)session.getAttribute("taxonGroupsCount-"+originalQuery+"-"+organism_ID+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly);
			}		
		}
		else {
			peptideQuery.queryByPeptide(originalQuery, 0, 1, swissprot, isoform,  uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
			int numHits = peptideQuery.getResult();	
			if(session.getAttribute("organismsCount-"+originalQuery+"-all"+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly) == null) {
				if(numHits > 2000) {	
					System.out.println("before org group search: "+ new Date());
					sortedHitOrganismsCount = peptideQuery.queryByPeptideWithGroup(originalQuery, swissprot, isoform,  uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
					System.out.println("after org group search: "+ new Date());
				}
				else {
					System.out.println("all counting organism directly start : "+numHits + " " + new Date());
					peptideQuery.queryByPeptide(originalQuery, 0, numHits, swissprot, isoform,  uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
					ArrayList<MatchedProtein> matchedProteins = getMatchedProteins(peptideQuery.getCurrentDocs(), originalQuery, ilEquivalent, trOnly, isoOnly);
					sortedHitOrganismsCount = getOrganismCount(matchedProteins);
					System.out.println("all counting organism directly end : "+numHits + " " + new Date());
				}
				session.setAttribute("organismsCount-"+originalQuery+"-all"+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly, sortedHitOrganismsCount);
			}
			else {
				sortedHitOrganismsCount = (Map<String, Long>)session.getAttribute("organismsCount-"+originalQuery+"-all"+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly);
			}
			if(session.getAttribute("taxonGroupsCount-"+originalQuery+"-all"+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly) == null) {
				System.out.println("before taxon group group search: "+ new Date());
				sortedHitTaxonGroupsCount = getTaxonGroupCount(originalQuery, "all", swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly); 
				System.out.println("after taxon group group search: "+ new Date());
				session.setAttribute("taxonGroupsCount-"+originalQuery+"-all"+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly, sortedHitTaxonGroupsCount);
			}
			else {
				sortedHitTaxonGroupsCount = (Map<String, Long>)session.getAttribute("taxonGroupsCount-"+originalQuery+"-all"+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly);
			}
		}
	}
	System.out.println("after query: " + new Date());
	docs = peptideQuery.getCurrentDocs();
	//store the id sets of protein sequences which are matched the keyword
	//return how many protein sequence 
	numberFound = peptideQuery.getResult();	
String[] sum = createHitSummary(sortedHitOrganismsCount, sortedHitTaxonGroupsCount, originalQuery, organism_ID, numberFound, swissprotValue, isoformValue, uniref100Value, lEqiValue, sortBy, trOnly, isoOnly);
	System.out.println("after creating summary: "+ new Date());
   out.println(sum[0]+"||||"+sum[1]);
//   out.println(sum[0]);
}
%>

<%!
	
	private ArrayList<MatchedProtein> getMatchedProteins(SolrDocumentList docs, String queryPeptide, String ilEquivalent, String trOnly, String isoOnly) {
		ArrayList<MatchedProtein> matchedProteins = new ArrayList<MatchedProtein>();
		Iterator<SolrDocument> docItr = docs.iterator();
		int count = 0;
                while(docItr.hasNext()) {
                	matchedProteins.add(getMatchedProtein(queryPeptide, docItr.next(), ilEquivalent, trOnly, isoOnly));
			count++;
                }
		System.out.println("matchedProteins: " + count);	
		return matchedProteins;		
	}

	
	private Map<String, Long> getTaxonGroupCount(ArrayList<MatchedProtein> matchedProteins) {
		HashMap<String, Long> hits = new HashMap<String, Long>();
		Map<String, Long> sortedHits = new LinkedHashMap();
		Map<String, Long> taxonGroups = new HashMap<String, Long>();
		int totalHits = 0;
		int totalTaxonGroups = 0;
		for(int i = 0; i < matchedProteins.size(); i++) {
			MatchedProtein protein = (MatchedProtein)matchedProteins.get(i);
			Organism taxonGroup = protein.getTaxonomicGroup();
			String taxonGroupName = taxonGroup.getName();
			String taxonGroupId = taxonGroup.getTaxonId();
			if(taxonGroups.get(taxonGroupName+"<|>"+taxonGroupId) == null) {
				taxonGroups.put(taxonGroupName+"<|>"+taxonGroupId, Long.valueOf(1));
			}
			else {
				Long taxonGroupCounts = (Long)taxonGroups.get(taxonGroupName+"<|>"+taxonGroupId);
				taxonGroups.put(taxonGroupName+"<|>"+taxonGroupId, taxonGroupCounts+ Long.valueOf(1)); 
			}			
		}
		totalHits = matchedProteins.size();
		sortedHits = sortByValue(taxonGroups, Long.valueOf(totalHits), "totalTaxonGroupMatches", Long.valueOf(taxonGroups.size()), "totalTaxonGroups");	
				
		return sortedHits;		
	}
	
	private Map<String, Long> getOrganismCount(ArrayList<MatchedProtein> matchedProteins) {
		HashMap<String, Long> hits = new HashMap<String, Long>();
		Map<String, Long> sortedHits = new LinkedHashMap();
		Map<String, Long> organisms = new HashMap<String, Long>();
		int totalHits = 0;
		int totalOrganisms = 0;
		for(int i = 0; i < matchedProteins.size(); i++) {
			MatchedProtein protein = (MatchedProtein)matchedProteins.get(i);
			Organism organism = protein.getOrganism();
			String organismName = organism.getName();
			String organismTaxonId = organism.getTaxonId();
			if(organisms.get(organismName+"<|>"+organismTaxonId) == null) {
				organisms.put(organismName+"<|>"+organismTaxonId, Long.valueOf(1));
			}
			else {
				Long organismCounts = (Long)organisms.get(organismName+"<|>"+organismTaxonId);
				organisms.put(organismName+"<|>"+organismTaxonId, organismCounts+ Long.valueOf(1)); 
			}			
		}
		System.out.println("organism size: " + organisms.size());
		totalHits = matchedProteins.size();
		sortedHits = sortByValue(organisms, Long.valueOf(totalHits), "totalOrganismMatches", Long.valueOf(organisms.size()), "totalOrganismGroups");	
				
		return sortedHits;		

	}
	
	private Map<String, Long> getTaxonGroupCount(String peptide, String organism_id, String swissprot, String isoform, String uniref100Only, String ilEquivalent, String sortBy, String trOnly, String isoOnly) {
		HashMap<String, Long> hits = new HashMap<String, Long>();
		Map<String, Long> sortedHits = new LinkedHashMap();
        	try {
			InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/taxongroup.txt");
			BufferedReader br = new BufferedReader(new InputStreamReader(inputStream));
                	String strLine;
			PeptidePhraseQuery query = null;
			int hitCount = 0;
			int totalHits = 0;
			int totalTaxonGroups = 0;
                	while((strLine = br.readLine())!= null) {
				String[] rec = strLine.split("\t");
				String group = rec[0];
				String taxonGroupName = rec[1];
				String groupID = rec[2];
				query=new PeptidePhraseQuery();
				if(organism_id.toLowerCase().equals("all")) {
					query.queryByPeptideWithTaxonGroup(peptide, groupID, 0, 1, swissprot, isoform,  uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
				}
				else {
					query.queryByPeptideWithOrganismAndGroup(peptide, organism_id, groupID, 0, 1, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
				}
				hitCount = query.getResult();
				totalHits += hitCount;
				if(hitCount > 0) {
					totalTaxonGroups++;
					hits.put(taxonGroupName+"<|>"+groupID, Long.valueOf(hitCount));	 	
				}
				//hits.put(groupID, Long.valueOf(hitCount));	 	
                	}
			inputStream.close();
			br.close();
			sortedHits = sortByValue(hits, Long.valueOf(totalHits), "totalTaxonGroupMatches", Long.valueOf(totalTaxonGroups), "totalTaxonGroups");	
        	}
        	catch(Exception e) {
                	e.printStackTrace();
        	}
		return sortedHits;
	}

	private Map<String, Long> sortByValue(Map<String, Long> map, Long totalMatches, String totalMatchesStr, Long totalGroups, String totalGroupsStr) {
                List list = new LinkedList(map.entrySet());
                Collections.sort(list, new Comparator() {
                        //@Override
                        public int compare(Object o1, Object o2) {
                                if(((Map.Entry) (o2)).getValue() == ((Map.Entry) (o1)).getValue()) {
					//System.out.println(((Map.Entry) (o2)).getKey()+" " +((Map.Entry)(o1)).getKey());	
					return ((Comparable)((Map.Entry) (o2)).getKey()).compareTo(((Map.Entry)(o1)).getKey());	
				}
					//System.out.println(((Map.Entry) (o2)).getKey()+" " +((Map.Entry)(o2)).getValue() + " | " + ((Map.Entry) (o1)).getKey()+" " +((Map.Entry)(o1)).getValue());	
                                return ((Comparable) ((Map.Entry) (o2)).getValue()).compareTo(((Map.Entry) (o1)).getValue());
                        }
                });

                Map result = new LinkedHashMap();
                int count = 0;
                //result.put("totalTaxonGroupMatches", totalMatches);
                //result.put("totalTaxonGroups", totalGroups);
                result.put(totalMatchesStr, totalMatches);
                result.put(totalGroupsStr, totalGroups);
                for (Iterator it = list.iterator(); it.hasNext();) {
                        Map.Entry entry = (Map.Entry) it.next();
                        result.put(entry.getKey(), entry.getValue());
                }
                return result;
        }

private MatchedProtein getMatchedProtein(String queryPeptide, SolrDocument doc, String ilEquivalent, String trOnly, String isoOnly) {
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
        if(nist.length() > 0 && !nist.equals("Z")) {
                matchedProtein.setNIST(nist);
        }
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
        matchedProtein.setMatchedRanges(getMatchedRanges(queryPeptide, originalSeq, ilEquivalent, trOnly, isoOnly));

        return matchedProtein;
    }

private MatchedRange[] getMatchedRanges(String originalQueryPeptide, String originalSeq, String ilEquivalent, String trOnly, String isoOnly) {
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

		
	private String[] createHitSummary(Map<String, Long> sortedHitOrganismsCount, Map<String, Long> sortedHitTaxonGroupsCount, String originalQuery, String organism_ID, int numberFound, String swissprotValue, String isoformValue, String uniref100Value, String lEqiValue, String sortBy, String trOnly, String isoOnly) {
		long totalOrganismMatches =0 ;
		long totalOrganismGroups =0 ;
		long totalTaxonGroupMatches =0 ;
		long totalTaxonGroups =0 ;
		int totalShow = 5;
		String orgsUrl = "";
		HashMap taxonToName = new HashMap();
        	try {
			InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/taxToTaxGroup.txt");
			BufferedReader br = new BufferedReader(new InputStreamReader(inputStream));
                	String strLine;
                	while((strLine = br.readLine())!= null) {
				String[] rec = strLine.split("\t");
				taxonToName.put(rec[0], rec[1]);
                	}
			inputStream.close();
			br.close();
        	}
        	catch(Exception e) {
                	e.printStackTrace();
        	}

		String chart = "";
		
		       chart += "<script type=\"text/javascript\">\n";
		       chart += " function drawVisualization() {\n";
		       chart += "   var orgData = google.visualization.arrayToDataTable([\n";
		       chart += "   	['OrganismCount', 'Hits per organsim'], \n";
			int topOrgCount = 0;
			int topOrgTotal = 0;
		       if(sortedHitOrganismsCount.keySet().size() > 7) {
				for(String key: sortedHitOrganismsCount.keySet()) {
					if(key.equals("totalOrganismMatches")) {
						totalOrganismMatches = sortedHitOrganismsCount.get(key);
					}
					else if(key.equals("totalOrganismGroups")) {
						totalOrganismGroups = sortedHitOrganismsCount.get(key);
					}
					else {
						//String orgName = (String) taxonToName.get(key);
						String[] rec = key.split("\\<\\|\\>");
						String orgName = rec[0];
						orgName = orgName.replaceAll("'", "&#39;");
						long orgCount = (Long)sortedHitOrganismsCount.get(key);	
						topOrgCount++;
						if(topOrgCount <= totalShow) {
							chart += "['"+orgName+"', "+orgCount+"],\n";
							topOrgTotal += orgCount;
						}
						else {
							chart += "['Others', "+ (totalOrganismMatches - topOrgTotal)+"],\n";
							break;
						}
					}
				}
		       }
		       else {
				for(String key: sortedHitOrganismsCount.keySet()) {
					if(key.equals("totalOrganismMatches")) {
						totalOrganismMatches = sortedHitOrganismsCount.get(key);
					}
					else if(key.equals("totalOrganismGroups")) {
						totalOrganismGroups = sortedHitOrganismsCount.get(key);
					}
					else {
						//String orgName = (String) taxonToName.get(key);
						String[] rec = key.split("\\<\\|\\>");
						String orgName = rec[0];
						orgName = orgName.replaceAll("'", "&#39;");
						long orgCount = (Long)sortedHitOrganismsCount.get(key);	
						chart += "['"+orgName+"', "+orgCount+"],\n";
					}
				}


			}
			chart = chart.substring(0, chart.length() -2)+"\n";
			chart += "]);\n";

			chart += "   var taxonGroupData = google.visualization.arrayToDataTable([\n";
                       chart += "       ['TaxonGroupCount', 'Hits per taxonGroup'], \n";
                        int topTaxonGroupCount = 0;
                        int topTaxonGroupTotal = 0;
                       if(sortedHitTaxonGroupsCount.keySet().size() > 7) {
                                for(String key: sortedHitTaxonGroupsCount.keySet()) {
                                        if(key.equals("totalTaxonGroupMatches")) {
                                                totalTaxonGroupMatches = sortedHitTaxonGroupsCount.get(key);
                                        }
                                        else if(key.equals("totalTaxonGroups")) {
                                                totalTaxonGroups = sortedHitTaxonGroupsCount.get(key);
                                        }
                                        else {
						String[] rec = key.split("\\<\\|\\>");
						String taxonGroupId =  rec[1];
						String taxonGroupName = rec[0];
                                                long taxonGroupCount = (Long)sortedHitTaxonGroupsCount.get(key);
                                                topTaxonGroupCount++;
                                                if(topTaxonGroupCount <= totalShow) {
                                                        chart += "['"+taxonGroupName+"', "+taxonGroupCount+"],\n";
                                                        topTaxonGroupTotal += taxonGroupCount;
                                                }
                                                else {
                                                        chart += "['Others', "+ (totalTaxonGroupMatches - topTaxonGroupTotal)+"],\n";
                                                        break;
                                                }
                                        }
                                }
                       }
                       else {
                                for(String key: sortedHitTaxonGroupsCount.keySet()) {
                                        if(key.equals("totalTaxonGroupMatches")) {
                                                totalTaxonGroupMatches = sortedHitTaxonGroupsCount.get(key);
                                        }
                                        else if(key.equals("totalTaxonGroups")) {
                                                totalTaxonGroups = sortedHitTaxonGroupsCount.get(key);
                                        }
                                        else {
						String[] rec = key.split("\\<\\|\\>");
						String taxonGroupId =  rec[1];
						String taxonGroupName = rec[0];
                                                long taxonGroupCount = (Long)sortedHitTaxonGroupsCount.get(key);
                                                chart += "['"+taxonGroupName+"', "+taxonGroupCount+"],\n";
                                        }
                                }


                        }
			chart = chart.substring(0, chart.length() -2)+"\n";
                        chart += "]);\n";  
			chart += "var options = {\n";
			//chart += "	colors: ['red', 'orange', 'brown', 'green', 'blue', 'navy'],\n";
			chart += "	colors: ['DodgerBlue', 'DeepSkyBlue', 'Lavender', 'LightBlue', 'LightSkyBlue', 'LightSteelBlue'],\n";
			chart += "	legend: 'none', \n";
			//chart += "	backgroundColor: { fill: 'transparent'}, \n";
			chart += "	backgroundColor: { fill: 'none'}, \n";
			//chart += "	backgroundColor: { stroke:null, fill: null, strokeSize: 0}, \n";
			chart += "	pieSliceText: 'none',\n"; 
			chart += "	 chartArea: {top:10, width:150, height:150},\n";  
                	chart += "	tooltipTextStyle: {bold: true, fontSize: 11}}\n";
			chart += "var orgChart = new google.visualization.PieChart(document.getElementById('orgChart'))\n";
			chart += "	orgChart.draw(orgData, options);\n";
			chart += "var taxonGroupChart = new google.visualization.PieChart(document.getElementById('taxonGroupChart'))\n";
			chart += "	taxonGroupChart.draw(taxonGroupData, options);\n";
			chart += "}\n";
		       //chart += "google.load('visualization', '1', {\"callback\" : drawVisualization})\n";			
		       //chart += "google.load('visualization', '1', {packages: ['corechart']})\n";			
			//chart += "google.setOnLoadCallback(drawVisualization);\n"; 
		       chart += "google.load('visualization', '1', {packages: ['corechart'], callback: drawVisualization})\n";			
		        chart += "</script>";			

			String	colors[]  = {"DodgerBlue", "DeepSkyBlue", "Lavender", "LightBlue", "LightSkyBlue", "LightSteelBlue"};
			//String colors[] = {"red", "orange", "brown", "green", "blue", "navy"};
			chart += "<table width=\"100%\" border=0>\n";
			chart += "	<tr>\n";
			chart += "		<td width=\"50%\" align=\"right\">\n";
			chart += "		<table border=0 width=\"100%\" align=\"right\">\n";
			chart += "			<tr><th align=center colspan=\"2\" style=\"font-size: small;\">Organisms (Total: "+totalOrganismGroups+", #seqs: "+totalOrganismMatches+")</th></tr>\n";	
			chart += "			<tr>\n";
			chart += "				<td align=\"right\">\n";
			//chart += "					<div style=\"background:url(./imagefiles/bg02.gif);\">\n";
			chart += "					<div id=\"orgChart\" style=\" width: 170px; height: 170px; \"></div>\n";
			//chart += "					</div>\n";
			chart += "				</td>\n";
			chart += "				<td width=\"55%\" align=\"left\">\n";	
			chart += "					<table border=0 style=\"font-size: 14px;\">\n";
			topOrgCount = 0;
			topOrgTotal = 0;
			NumberFormat nf = NumberFormat.getInstance();
			nf.setMinimumFractionDigits(1);
			nf.setMaximumFractionDigits(1);
			if(sortedHitOrganismsCount.keySet().size() > 7) {
                                for(String key: sortedHitOrganismsCount.keySet()) {
                                        if(!key.equals("totalOrganismMatches") && !key.equals("totalOrganismGroups")) {
                                                //String orgName = (String) taxonToName.get(key);
						String[] rec = key.split("\\<\\|\\>");
						String orgName = rec[0];
						orgName = orgName.replaceAll("'", "&#39;");
						String orgId = rec[1];
                                                long orgCount = (Long)sortedHitOrganismsCount.get(key);
                                                topOrgCount++;
                                                if(topOrgCount <= totalShow) {
							String countUrl = "peptidewithtaxonid.jsp?initialed=false&start=0&rows=20&keyword="+originalQuery+"&organism_id="+organism_ID+"&total_number="+numberFound+"&taxon_name="+orgName+"&taxon_id="+orgId+"&swissprot="+swissprotValue+"&isform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly ;
                                                       chart += "					<tr><td style=\"background-color: "+colors[topOrgCount-1]+";\" width=10px>&nbsp;<td nowrap>"+orgName+" [<a href=\""+countUrl+"\">"+orgCount+"</a>, "+nf.format(100.0*orgCount/totalOrganismMatches)+"%]</td></tr>\n";
                                                        //chart += "					<tr><td style=\"background-color: "+colors[topOrgCount-1]+";\" width=10px>&nbsp;<td nowrap>"+orgName+" ["+orgCount+", "+nf.format(100.0*orgCount/totalOrganismMatches)+"%]</td></tr>\n";
                                                        topOrgTotal += orgCount;
                                                }
                                                else {
							int othersCount = (int)totalOrganismMatches - topOrgTotal;
							orgsUrl = "organismtableview.jsp?peptide="+originalQuery+"&organism_id="+organism_ID+"&numberfound="+numberFound +"&total_orgs="+sortedHitOrganismsCount.get("totalOrganismGroups")+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly;
                                                        chart += "					<tr><td style=\"background-color: "+colors[topOrgCount-1]+";\" width=10px>&nbsp;<td nowrap><a href=\""+orgsUrl+"\">Others</a> ["+ othersCount+", "+nf.format(100.0*othersCount/totalOrganismMatches)+"%]</td></tr>\n";
                                                        break;
                                                }
                                        }
                                }
                       }
                       else {
                                for(String key: sortedHitOrganismsCount.keySet()) {
                                        if(!key.equals("totalOrganismMatches") && !key.equals("totalOrganismGroups")) {
                                                //String orgName = (String) taxonToName.get(key);
						String[] rec = key.split("\\<\\|\\>");
						String orgName = rec[0];
						orgName = orgName.replaceAll("'", "&#39;");
						String orgId = rec[1];
                                                long orgCount = (Long)sortedHitOrganismsCount.get(key);
                                                topOrgCount++;
						String countUrl = "peptidewithtaxonid.jsp?initialed=false&start=0&rows=20&keyword="+originalQuery+"&organism_id="+organism_ID+"&total_number="+numberFound+"&taxon_name="+orgName+"&taxon_id="+orgId+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly;
                                                //chart += "					<tr><td style=\"background-color: "+colors[topOrgCount-1]+";\" width=10px>&nbsp;<td nowrap>"+orgName +" ["+orgCount+", "+100*orgCount/totalOrganismMatches+"%]</td></tr>\n";
                                                chart += "					<tr><td style=\"background-color: "+colors[topOrgCount-1]+";\" width=10px>&nbsp;<td nowrap>"+orgName +" [<a href=\""+countUrl+"\">"+orgCount+"</a>, "+100*orgCount/totalOrganismMatches+"%]</td></tr>\n";
                                        }
                                }
				orgsUrl = "organismtableview.jsp?peptide="+originalQuery+"&organism_id="+organism_ID+"&numberfound="+numberFound +"&total_orgs="+sortedHitOrganismsCount.get("totalOrganismGroups")+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly;
                        }
			chart += "					</table>\n";	
			chart += "				</td>\n";	
			chart += "			</tr>\n";	
			chart += "		</table>\n";	
			chart += "		</td>\n";
			

			chart += "              <td width=\"50%\" align=\"left\">\n";
                        chart += "              <table border=0 width=\"100%\" align=\"right\">\n";
                        chart += "                      <tr><th align=center colspan=\"2\" style=\"font-size: small;\">Taxonomic Groups (Total: "+totalTaxonGroups+", #seqs: "+totalTaxonGroupMatches+")</th></tr>\n";
                        chart += "                      <tr>\n";
                        chart += "                              <td align=\"right\">\n";
                        chart += "                                      <div id=\"taxonGroupChart\" style=\" width: 170px; height: 170px;\"></div>\n";
                        chart += "                              </td>\n";
                        chart += "                              <td width=\"55%\" align=\"left\">\n";
                        chart += "                                      <table border=0 style=\"font-size: 14px;\">\n";
                        topTaxonGroupCount = 0;
                        topTaxonGroupTotal = 0;
                        if(sortedHitTaxonGroupsCount.keySet().size() > 7) {
                                for(String key: sortedHitTaxonGroupsCount.keySet()) {
                                        if(!key.equals("totalTaxonGroupMatches") && !key.equals("totalTaxonGroups")) {
						String[] rec = key.split("\\<\\|\\>");
                                                String taxonGroupId =  rec[1];
                                                String taxonGroupName = rec[0];
                                                long taxonGroupCount = (Long)sortedHitTaxonGroupsCount.get(key);
                                                topTaxonGroupCount++;
                                                if(topTaxonGroupCount <= totalShow) {
							String countUrl = "peptidewithtaxongroup.jsp?initialed=false&start=0&rows=20&keyword="+originalQuery+"&organism_id="+organism_ID+"&total_number="+numberFound+"&group_name="+taxonGroupName+"&taxongroup_id="+taxonGroupId+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly;	
                                                        chart += "                                      <tr><td style=\"background-color: "+colors[topTaxonGroupCount-1]+";\" width=10px>&nbsp;<td nowrap>"+taxonGroupName+" [<a href=\""+countUrl+"\">"+taxonGroupCount+"</a>, "+nf.format(100.0*taxonGroupCount/totalTaxonGroupMatches)+"%]</td></tr>\n";
                                                        topTaxonGroupTotal += taxonGroupCount;
                                                }
                                                else {
							String  othersUrl = "taxongroup.jsp?peptide="+originalQuery+"&organism_id="+organism_ID+"&numberfound="+numberFound+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly;
                                                        int othersCount = (int)totalTaxonGroupMatches - topTaxonGroupTotal;
                                                        chart += "                                      <tr><td style=\"background-color: "+colors[topTaxonGroupCount-1]+";\" width=10px>&nbsp;<td nowrap><a href=\""+othersUrl+"\">Others</a> ["+ othersCount+", "+nf.format(100.0*othersCount/totalTaxonGroupMatches)+"%]</td></tr>\n";
                                                        break;
                                                }
                                        }
                                }
                       }
                       else {
                                for(String key: sortedHitTaxonGroupsCount.keySet()) {
                                        if(!key.equals("totalTaxonGroupMatches") && !key.equals("totalTaxonGroups")) {
						String[] rec = key.split("\\<\\|\\>");
                                                String taxonGroupId =  rec[1];
                                                String taxonGroupName = rec[0];
                                                long taxonGroupCount = (Long)sortedHitTaxonGroupsCount.get(key);
                                                topTaxonGroupCount++;
						String countUrl = "peptidewithtaxongroup.jsp?initialed=false&start=0&rows=20&keyword="+originalQuery+"&organism_id="+organism_ID+"&total_number="+numberFound+"&group_name="+taxonGroupName+"&taxongroup_id="+taxonGroupId+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly;	
                                                chart += "                                      <tr><td style=\"background-color: "+colors[topTaxonGroupCount-1]+";\" width=10px>&nbsp;<td nowrap>"+taxonGroupName+" [<a href=\""+countUrl+"\">"+taxonGroupCount+"</a>, "+nf.format(100.0*taxonGroupCount/totalTaxonGroupMatches)+"%]</td></tr>\n";
                                               // chart += "                                      <tr><td style=\"background-color: "+colors[topTaxonGroupCount-1]+";\" width=10px>&nbsp;<td nowrap>"+taxonGroupName +" ["+taxonGroupCount+", "+100*taxonGroupCount/totalTaxonGroupMatches+"%]</td></tr>\n";
                                        }
                                }
                        }
                        chart += "                                      </table>\n";
                        chart += "                              </td>\n";      
                        chart += "                      </tr>\n";
                        chart += "              </table>\n";
                        chart += "              </td>\n"; 	
			chart += "	</tr>\n";	
			chart += "</table>\n";	
		String[] results = new String[2];	
		results[0] = chart;
		System.out.println(chart);
		results[1] = orgsUrl;
		return results;	
	}
%>
