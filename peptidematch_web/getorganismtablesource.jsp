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
<%@ page import="org.apache.commons.lang.ArrayUtils" %>

<%
	String peptide = request.getParameter("peptide");
        String organism_id = request.getParameter("organism_id");
	String numberFound=request.getParameter("numberfound");
	String swissprot = "N";
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
	
	peptide = peptide.replaceAll("[^a-zA-Z]", "");
	PeptidePhraseQuery peptideQuery = new PeptidePhraseQuery();
	Map<String, Long> sortedHitOrganismsCount = new LinkedHashMap();
 	Map<String, String> sortedOrganismsHitProteins = new LinkedHashMap();
	
	HashMap idToNameMap = new HashMap();
	HashMap taxonToTaxonGroup = new HashMap();
	long totalOrganismMatches = 0;
	long totalOrganismGroups = 0;
        if(peptide.length() >= 3) {
		
		if(session.getAttribute("taxToTaxGroup") == null) {
        		try {
                		InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/taxToTaxGroup.txt");
                		BufferedReader br = new BufferedReader(new InputStreamReader(inputStream));
                		String strLine;
                		while((strLine = br.readLine())!= null) {
                        		String[] rec = strLine.split("\t");
					if(rec.length == 4) {
                        			taxonToTaxonGroup.put(rec[0], rec[2]+"\t"+rec[3]);
					}
					else {
                        			taxonToTaxonGroup.put(rec[0], "\t");
					}
                		}
                		inputStream.close();
                		br.close();
                		session.setAttribute("taxToTaxGroup", taxonToTaxonGroup);
        		}
        		catch(Exception e) {
                		e.printStackTrace();
       			}
		}
		else {
			taxonToTaxonGroup = (HashMap)session.getAttribute("taxToTaxGroup");
		}
		
		if(organism_id !=null && !organism_id.toLowerCase().equals("all")) {
			//if(session.getAttribute("organismsCount-"+peptide+"-"+organism_id+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly) == null) {
                        	//sortedHitOrganismsCount = peptideQuery.queryByPeptideWithMultiOrganismWithGroup(peptide, organism_id, swissprot, isoform, uniref100Only, ilEquivalent, trOnly, isoOnly, "");
                        	peptideQuery.queryByPeptideWithMultiOrganism(peptide, organism_id,0,1, swissprot, isoform, uniref100Only, ilEquivalent, trOnly, isoOnly, "");
				int numHits = peptideQuery.getResult();
                        	peptideQuery.queryByPeptideWithMultiOrganism(peptide, organism_id,0,numHits, swissprot, isoform, uniref100Only, ilEquivalent, trOnly, isoOnly, "");
				ArrayList<MatchedProtein> matchedProteins = getMatchedProteins(peptideQuery.getCurrentDocs(), peptide, ilEquivalent, trOnly, isoOnly);
                                sortedHitOrganismsCount = getOrganismCount(matchedProteins);	
				sortedOrganismsHitProteins = getOrganismHitProteins(matchedProteins, uniref100Only); 

                        	session.setAttribute("organismsCount-"+peptide+"-"+organism_id+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly, sortedHitOrganismsCount);
                        	session.setAttribute("organismsHitProteins-"+peptide+"-"+organism_id+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly, sortedOrganismsHitProteins);
			/*}
			else {
				sortedHitOrganismsCount = (Map<String, Long>)session.getAttribute("organismsCount-"+peptide+"-"+organism_id+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly);
				sortedOrganismsHitProteins = (Map<String, String>)session.getAttribute("organismsHitProteins-"+peptide+"-"+organism_id+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly);
			}*/
		}
		else {
			//if(session.getAttribute("organismsCount-"+peptide+"-all"+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly) == null) {
                        	//sortedHitOrganismsCount = peptideQuery.queryByPeptideWithGroup(peptide, swissprot, isoform, uniref100Only, ilEquivalent, trOnly, isoOnly, "");
                        	peptideQuery.queryByPeptide(peptide, 0, 1, swissprot, isoform, uniref100Only, ilEquivalent, trOnly, isoOnly, "");
				int numHits = peptideQuery.getResult();
                        	peptideQuery.queryByPeptide(peptide, 0, numHits, swissprot, isoform, uniref100Only, ilEquivalent, trOnly, isoOnly, "");
				ArrayList<MatchedProtein> matchedProteins = getMatchedProteins(peptideQuery.getCurrentDocs(), peptide, ilEquivalent, trOnly, isoOnly);
                                sortedHitOrganismsCount = getOrganismCount(matchedProteins);
				sortedOrganismsHitProteins = getOrganismHitProteins(matchedProteins, uniref100Only); 
                        	session.setAttribute("organismsCount-"+peptide+"-all"+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly, sortedHitOrganismsCount);
                        	session.setAttribute("organismsHitProteins-"+peptide+"-all"+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly, sortedOrganismsHitProteins);
                	/*}
			else {
				sortedHitOrganismsCount = (Map<String, Long>)session.getAttribute("organismsCount-"+peptide+"-all"+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly);
				sortedOrganismsHitProteins = (Map<String, String>)session.getAttribute("organismsHitProteins-"+peptide+"-all"+"-"+swissprot+"-"+isoform+"-"+uniref100Only+"-"+ilEquivalent+"-"+trOnly+"-"+isoOnly);
			}*/	
		}
		for(String org: sortedHitOrganismsCount.keySet()) {
                        if(org.equals("totalOrganismMatches")) {
				totalOrganismMatches = (Long)sortedHitOrganismsCount.get(org);
			}
			else if(org.equals("totalOrganismGroups")) {
				totalOrganismGroups = (Long)sortedHitOrganismsCount.get(org);
			}
                        else {
			        String[] rec = org.split("\\<\\|\\>");
                                String orgName = rec[0];
                                String orgId = rec[1];
				idToNameMap.put(orgId, orgName);
			}
		}
	}	
	else {
		out.println("The query peptide must be at least 3 characters");
	}
	String[] cols = {"Organism", "Matches", "Percent", "Taxonomic Group"};
	//String[] cols = {"Organism", "Matches", "Percent"};
	String table = "ajax";
	JSONObject result = new JSONObject();
	JSONArray array = new JSONArray();
	
	int amount = 25;
	int start = 0;
	int echo = 0;
	int col = 0;

	String organism = "";
	String matches = "";
	String matchedProteins = "";	
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
	matchedProteins = request.getParameter("sSearch_2");
	taxonGroup = request.getParameter("sSearch_3");
	
	if(sStart != null) {
		start = Integer.parseInt(sStart);
		if(start < 0) {
			start = 0;
		}
	}
	if(sAmount != null) {
		amount = Integer.parseInt(sAmount);
		/*if(amount < 25 || amount > 100) {
			amount = 25; 
		}*/
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
	int orgCount = 0;
	int totalAfterFilter = 0;
        NumberFormat nf = NumberFormat.getInstance();
        nf.setMinimumFractionDigits(1);
        nf.setMaximumFractionDigits(1);
	//int totalAfterFilter = totalOrganismGroups;

	Set<String> keys = null;
	if(sCol != null && sDir != null && sCol1!= null && sDir!= null&&  sCol.equals("1") && sDir.equals("desc") && sCol1.equals("0") && sDir1.equals("asc")) {
		keys = sortedHitOrganismsCount.keySet();
	}
	else {
		//if(colName.equals("Matches") || colName.equals("Percent")) {
		if(colName.equals("Matches") || colName.equals("Percent")) {
			if(dir.equals("asc")) {
				sortedHitOrganismsCount = sortByValueAsc(sortedHitOrganismsCount);
			}	
			if(dir.equals("desc")) {
				sortedHitOrganismsCount = sortByValueDesc(sortedHitOrganismsCount);
			}
			keys = sortedHitOrganismsCount.keySet();			
		}
		else {
			if(dir.equals("desc")) {
				keys = new TreeSet<String>(sortedHitOrganismsCount.keySet());
			}
			else {
				//keys = sortedHitOrganismsCount.keySet();
				keys = (new TreeSet<String>(sortedHitOrganismsCount.keySet())).descendingSet();
			}
		}
	}	
	//for(String org: sortedHitOrganismsCount.keySet()) {
			//if(orgCount <= (start+amount)) {
	for(String org: keys) {
        	if(!org.equals("totalOrganismMatches") && !org.equals("totalOrganismGroups")) {
                	String[] rec = org.split("\\<\\|\\>");
                        String orgName = rec[0];
                        String orgId = rec[1];
			Organism matchedOrg = new Organism(orgName, orgId);
			JSONArray ja = new JSONArray();
			String orgMatches = ((Long) sortedHitOrganismsCount.get(org)).toString();
			String orgProteins = sortedOrganismsHitProteins.get(orgId);
			orgCount++;
			total++;
			percent = nf.format(sortedHitOrganismsCount.get(org)*100.0/totalOrganismMatches);
			if(search != null && search.length() > 0) {
					//System.out.println("search1: " + search);
				if(orgName.toUpperCase().indexOf(search.toUpperCase()) != -1 || orgMatches.indexOf(search) != -1 || orgProteins.indexOf(search) != -1) {
					String countUrl = "peptidewithtaxonid.jsp?initialed=false&start=0&rows=20&keyword="+peptide+"&organism_id="+orgId+"&total_number="+numberFound+"&taxon_name="+orgName+"&taxon_id="+orgId+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly;
                               		ja.put("<a href=\""+countUrl+"\">" +orgName+"</a>");
					ja.put(sortedHitOrganismsCount.get(org));
					ja.put(sortedOrganismsHitProteins.get(orgId));
					ja.put(percent);
					
	
					String taxonGroupStr = (String)taxonToTaxonGroup.get(orgId);
					String[] taxonGroupNames = taxonGroupStr.split("\t");
					ja.put(taxonGroupNames[1]);
					
					array.put(ja);
					totalAfterFilter++;
				} 
			}
			else {
				if(orgCount >= start && orgCount <= (start+amount)) {
					//String countUrl = "peptidewithtaxonid.jsp?initialed=false&start=0&rows=20&keyword="+peptide+"&organism_id="+organism_id+"&total_number="+numberFound+"&taxon_name="+orgName+"&taxon_id="+orgId+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"trOnly="+trOnly+"&isoOnly="+isoOnly;
					String countUrl = "peptidewithtaxonid.jsp?initialed=false&start=0&rows=20&keyword="+peptide+"&organism_id="+orgId+"&total_number="+numberFound+"&taxon_name="+orgName+"&taxon_id="+orgId+"&swissprot="+swissprotValue+"&isoform="+isoformValue+"&uniref100="+uniref100Value+"&lEqi="+lEqiValue+"&sortBy="+sortBy+"&trOnly="+trOnly+"&isoOnly="+isoOnly;
                               		ja.put("<a href=\""+countUrl+"\">" +orgName+"</a>");
					ja.put(sortedHitOrganismsCount.get(org));
					ja.put(sortedOrganismsHitProteins.get(orgId));
					ja.put(percent);
					
					String taxonGroupStr = (String)taxonToTaxonGroup.get(orgId);
					String[] taxonGroupNames = taxonGroupStr.split("\t");
					ja.put(taxonGroupNames[1]);
					
					array.put(ja);
				}
                        }
                }
	}
	result.put("sEcho", echo);
	if(totalAfterFilter > 0) {
		result.put("iTotalRecords", totalAfterFilter);
		result.put("iTotalDisplayRecords", totalAfterFilter);
	}
	else {
		result.put("iTotalRecords", totalOrganismGroups);
		result.put("iTotalDisplayRecords", totalOrganismGroups);
	}
	result.put("aaData", array);
	response.setContentType("application/json");
        response.setHeader("Cache-Control", "no-store");
        out.print(result);		
%>
<%!

	private HashMap<String, String>  getOrganismHitProteins(List<MatchedProtein> matchedProteins, String uniref100Only) {
		HashMap<String, List<String>> orgProteinMap = new LinkedHashMap();
		HashMap<String, String> orgHitProteinMap = new LinkedHashMap();

		for(MatchedProtein protein : matchedProteins) {
			//System.out.println("matched: "+protein);	
			String orgId = protein.getOrganism().getTaxonId();
			String ac = protein.getProteinAC();
			String acURL = "";
			if(uniref100Only.equals("Y")) {
                                acURL = "<a href=\"http://www.uniprot.org/uniprot/UniRef100_"+ac +"\" target=\"_blank\">UniRef100_"+ac+"</a>";
                        }
                        else {
                                acURL = "<a href=\"http://www.uniprot.org/uniprot/"+ac +"\" target=\"_blank\">"+ac+"</a>";
                        }
			List<String> acList = orgProteinMap.get(orgId);
			if(acList != null && !acList.contains(ac)) {
				acList.add(acURL);
				orgProteinMap.put(orgId, acList);
			}
			else {
				acList = new ArrayList<String>();
				acList.add(acURL);
				orgProteinMap.put(orgId, acList);
			}
		}
		for(String orgId : orgProteinMap.keySet()) {
			List<String> urls = orgProteinMap.get(orgId);
			orgHitProteinMap.put(orgId,String.join(", ", urls));
		}
		//System.out.println(matchedProteins);
		//System.out.println("????"+orgHitProteinMap);
		return orgHitProteinMap;	
	}

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

	public Map<String, Long> sortByValueDesc(Map<String, Long> map) {
                List list = new LinkedList(map.entrySet());
                Collections.sort(list, new Comparator() {
                        //@Override
                        public int compare(Object o1, Object o2) {
                                if(((Map.Entry) (o2)).getValue() == ((Map.Entry) (o1)).getValue()) {
                                        return ((Comparable)((Map.Entry) (o2)).getKey()).compareTo(((Map.Entry)(o1)).getKey());
                                }
                                return ((Comparable) ((Map.Entry) (o2)).getValue()).compareTo(((Map.Entry) (o1)).getValue());
                        }
                });

                Map result = new LinkedHashMap();
                int count = 0;
                for (Iterator it = list.iterator(); it.hasNext();) {
                        Map.Entry entry = (Map.Entry) it.next();
                        result.put(entry.getKey(), entry.getValue());
                }
                return result;
        }
	public Map<String, Long> sortByValueAsc(Map<String, Long> map) {
                List list = new LinkedList(map.entrySet());
                Collections.sort(list, new Comparator() {
                        //@Override
                        public int compare(Object o1, Object o2) {
                                if(((Map.Entry) (o2)).getValue() == ((Map.Entry) (o1)).getValue()) {
                                        return ((Comparable)((Map.Entry) (o2)).getKey()).compareTo(((Map.Entry)(o1)).getKey());
                                }
                                return ((Comparable) ((Map.Entry) (o1)).getValue()).compareTo(((Map.Entry) (o2)).getValue());
                        }
                });

                Map result = new LinkedHashMap();
                int count = 0;
                for (Iterator it = list.iterator(); it.hasNext();) {
                        Map.Entry entry = (Map.Entry) it.next();
                        result.put(entry.getKey(), entry.getValue());
                }
                return result;
        }
%>
