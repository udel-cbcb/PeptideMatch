package org.proteininformationresource.peptidematch; 

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

public class LongProcess extends Thread {

    private int progress;
    Query query = new Query();
    private String jobId;
    private String htmlStatus = new String();
    private String textStatus = new String();
    private String textLog = new String(); 
    private String htmlLog = new String(); 
    long totalTime = 0;
    List<String> totalUniqueProteins = new ArrayList(); 
    List<Organism> totalUniqueOrganisms = new ArrayList(); 
    List<Organism> totalUniqueTaxonGroups = new ArrayList(); 
    ArrayList<String> missedPeptideList = new ArrayList();
    Map<Organism, List<String>> orgProteinMap = new HashMap<Organism, List<String>>();

    Map<String, ArrayList<String>> perProteinMatchedPeptides = new HashMap<String, ArrayList<String>>(); 
    Map<String, String> proteinInfoMap = new HashMap<String, String>();
    StringBuffer perPeptideMatchedProteins = new StringBuffer();
    String cwd = "";
    String inputsHTML = "";
    String inputsText = "";
 
    boolean finished = false;
    Map<String, ArrayList<MatchedProtein>> matchedResults = new HashMap<String, ArrayList<MatchedProtein>>();	
	
    Map<QueryPeptide, Map<Organism, Integer>> organismCount = new HashMap<>();
    Map<QueryPeptide, Map<Organism, Integer>> taxonGroupCount = new HashMap<>();
    Map<QueryPeptide, Integer> spCount = new HashMap<>();
    Map<QueryPeptide, Integer> trCount = new HashMap<>();
    Map<QueryPeptide, Integer> isoCount = new HashMap<>();
 
    public void run() {
	while(!finished) {
		doWork();
	}
    }

    
    private void doWork() {
	 totalUniqueProteins = new ArrayList<String>();
         totalUniqueOrganisms = new ArrayList<Organism>();
         totalUniqueTaxonGroups = new ArrayList<Organism>();
         perProteinMatchedPeptides = new HashMap<String, ArrayList<String>>();


	if(query != null) {
		String[] queryPeptides = query.getPeptides();
		String[] queryPeptideIds = query.getPeptideIds();
		long lTotalStartTime = new Date().getTime();
		for(int i= 0; i < queryPeptides.length; i++) {
			String leftPadJobIndex = StringUtils.leftPad(Integer.toString(i+1), (Integer.toString(queryPeptides.length)).length(), 'X');
			String leftPadJobIndexText = StringUtils.leftPad(Integer.toString(i+1), (Integer.toString(queryPeptides.length)).length(), 'X');
			leftPadJobIndexText = leftPadJobIndexText.replaceAll("X", ""); 
			leftPadJobIndex = leftPadJobIndex.replaceAll("X", "&nbsp;"); 
			//System.out.println((Integer.toString(queryPeptides.length)).length() + ": "+leftPadJobIndex);
			String queryPeptide = queryPeptides[i];		
			String tempHTML = "";
			String tempText = "";
			if(queryPeptide != null && queryPeptide.length() > 0) {
				String queryPeptideShown = queryPeptide;
				//if(queryPeptide.length() > 100) {
				//	queryPeptideShown = queryPeptideShown.substring(0, 99);
				//} 	
				//tempHTML = "<tr><td valign=top><span style=\"font-family: courier;\">("+leftPadJobIndex+"/"+queryPeptides.length+")</span>:</td><td valign=top style=\"word-break: break-all;\">Searching <font color=gray>"+queryPeptide + "</font> ... <img src=\"images/spinning-wait-icons/wait18trans.gif\"></td><td valign=top></td></tr>"; 
				tempHTML = "<tr><td valign=top><span style=\"font-family: courier;\">("+leftPadJobIndex+"/"+queryPeptides.length+")</span>:</td><td valign=top style=\"word-break: break-all;\">Searching <font color=gray>"+getPeptideId(queryPeptide) + "</font> ... <img src=\"images/spinning-wait-icons/wait18trans.gif\"></td><td valign=top></td></tr>"; 
				htmlStatus = tempHTML + htmlStatus;
				htmlLog = htmlStatus;
				//tempText = leftPadJobIndexText+"\t"+queryPeptides.length+"\tSearching "+queryPeptide + "..."; 
				tempText = leftPadJobIndexText+"\t"+queryPeptides.length+"\tSearching "+getPeptideId(queryPeptide) + "..."; 
				textStatus = tempText + textStatus;
				textLog = textStatus;	
				long lStartTime = new Date().getTime();
				String queryPeptideFileName = "";
				if(queryPeptideIds != null) {
					queryPeptideFileName = this.getJobId() +"-"+queryPeptideIds[i]+".txt";
				}
				else {	
					queryPeptideFileName = this.getJobId() +"-"+(i+1)+".txt";
				}
				ArrayList<MatchedProtein> matchedProteins = doSearch(queryPeptide, queryPeptideFileName, query.getSelectedOrganisms(), query.getSwissprot(), query.getIsoform(), query.getUniRef100Only(), query.getLEqI(), "ac_asc", query.getTrOnly(), query.getIsoOnly());  		
			
				if(matchedProteins.size() == 0) {
                                	missedPeptideList.add(queryPeptide);
                                }
				//else {	
					QueryPeptide inPeptide = query.getQueryPeptide(queryPeptide);
					Map<Organism, Integer> peptideOrganismCount = organismCount.get(inPeptide);
					Map<Organism, Integer> peptideTaxonGroupCount = taxonGroupCount.get(inPeptide);
	
					for (MatchedProtein matchedProtein : matchedProteins) {
						String proteinAC = matchedProtein.getProteinAC();
						if(!totalUniqueProteins.contains(proteinAC)) {
							totalUniqueProteins.add(proteinAC);
						}
						//String organism = matchedProtein.getOrganism().getTaxonId();
						Organism organism = matchedProtein.getOrganism();
						if(!totalUniqueOrganisms.contains(organism)) {
							totalUniqueOrganisms.add(organism);
						}
						List<String> orgProteins = orgProteinMap.get(organism);
						if(orgProteins != null && !orgProteins.contains(proteinAC)) {
							orgProteins.add(proteinAC);
							orgProteinMap.put(organism, orgProteins);
						}
						else {
							orgProteins = new ArrayList<String>();
							orgProteins.add(proteinAC);
							orgProteinMap.put(organism, orgProteins);
							
						}	
						if(peptideOrganismCount!= null) {
							Integer orgCount = peptideOrganismCount.get(organism);
							if(orgCount != null) {
								peptideOrganismCount.put(organism, orgCount+1);
							}
							else {
								peptideOrganismCount.put(organism, 1);
							}
							organismCount.put(inPeptide, peptideOrganismCount);
						}
						else {
							peptideOrganismCount = new HashMap<Organism, Integer>();
							peptideOrganismCount.put(organism, 1);
							organismCount.put(inPeptide, peptideOrganismCount);
						}
							
						//String taxonGroup = matchedProtein.getTaxonomicGroup().getTaxonId();
						Organism taxonGroup = matchedProtein.getTaxonomicGroup();
						if(!totalUniqueTaxonGroups.contains(taxonGroup)) {
							totalUniqueTaxonGroups.add(taxonGroup);
						}
						if(peptideTaxonGroupCount != null) {	
							Integer tGCount = peptideTaxonGroupCount.get(taxonGroup);
							if(tGCount != null) {
								peptideTaxonGroupCount.put(taxonGroup, tGCount+1);
							}
							else {
								peptideTaxonGroupCount.put(taxonGroup, 1);
							}
							taxonGroupCount.put(inPeptide, peptideTaxonGroupCount);
						}
						else {
							peptideTaxonGroupCount = new HashMap<Organism, Integer>();
							peptideTaxonGroupCount.put(taxonGroup, 1);
							taxonGroupCount.put(inPeptide, peptideTaxonGroupCount);
						}
						if(matchedProtein.getReviewStatus().equals("Y")) {
							Integer peptideSPCount = spCount.get(inPeptide);
							if(peptideSPCount != null) {
								spCount.put(inPeptide, peptideSPCount+1);
							}
							else {
								spCount.put(inPeptide, 1);
							}	
						}
						else {
							Integer peptideTRCount = trCount.get(inPeptide);
							if(peptideTRCount != null) {
								trCount.put(inPeptide, peptideTRCount+1);
							}
							else {
								trCount.put(inPeptide, 1);
							}	
						}
						if(matchedProtein.getProteinAC().contains("-")) {
							Integer peptideIsoCount = isoCount.get(inPeptide);
							if(peptideIsoCount != null) {
								isoCount.put(inPeptide, peptideIsoCount+1);
							}
							else {
								isoCount.put(inPeptide, 1);
							}
						}
					}
				//}
					
				long lEndTime = new Date().getTime();
				long difference = lEndTime - lStartTime;	
				htmlStatus = htmlStatus.replace(tempHTML,  "<tr><td valign=top><span style=\"font-family: courier;\">("+leftPadJobIndex+"/"+queryPeptides.length+")</span>:</td><td valign=top style=\"word-break: break-all;\">Searching <font color=gray>"+getPeptideId(queryPeptide) + "</font></td><td valign=top>Match results [protein(s): <font color=gray>"+matchedProteins.size() +"</font>, organism(s): <font color=gray>"+countMatchedOrganisms(matchedProteins)+"</font>], Time used: <font color=gray>"+ String.format("%.2f", (float)difference/1000.0)+"</font> sec.</td></tr>\n"); 

				//}
				htmlLog = htmlStatus;
				int matchedOrganismsCount = countMatchedOrganisms(matchedProteins);
				textStatus = textStatus.replace(tempText,  leftPadJobIndexText+"\t"+getPeptideId(queryPeptide) + "\t"+matchedProteins.size() +"\t"+matchedOrganismsCount+"\t"+ String.format("%.2f", (float)difference/1000.0)+"\n"); 
				textLog = textStatus;
				//perPeptideMatchedProteins.append(queryPeptide+"\t"+matchedProteins.size()+"\t"+matchedOrganismsCount+"\n");
				perPeptideMatchedProteins.append(getPeptideId(queryPeptide)+"\t"+matchedProteins.size()+"\t"+matchedOrganismsCount+"\n");
			}
		}
		
		String tempHTML = "<tr><td>&nbsp;</td><td>Saving peptide summary report ... <img src=\"images/spinning-wait-icons/wait18trans.gif\"></td><td></td></tr>"; 
		htmlStatus = tempHTML + htmlStatus;
		savePeptideSummary();
		htmlStatus = htmlStatus.replace(tempHTML,  ""); 
		
		tempHTML = "<tr><td>&nbsp;</td><td>Saving protein summary report ... <img src=\"images/spinning-wait-icons/wait18trans.gif\"></td><td></td></tr>"; 
		htmlStatus = tempHTML + htmlStatus;
		saveProteinSummary();
		saveProteinHitMap();
		savePeptideHitMap();
	
		htmlStatus = htmlStatus.replace(tempHTML,  ""); 

		tempHTML = "<tr><td>&nbsp;</td><td>Saving protein sequences ... <img src=\"images/spinning-wait-icons/wait18trans.gif\"></td><td></td></tr>"; 
		htmlStatus = tempHTML + htmlStatus;
		saveProteinSequences();
		htmlStatus = htmlStatus.replace(tempHTML,  ""); 

		tempHTML = "<tr><td>&nbsp;</td><td>Saving summary report ... <img src=\"images/spinning-wait-icons/wait18trans.gif\"></td><td></td></tr>"; 
		htmlStatus = tempHTML + htmlStatus;
		saveSummaryReport();
		htmlStatus = htmlStatus.replace(tempHTML,  ""); 
		
		tempHTML = "<tr><td>&nbsp;</td><td>Saving taxonomic group report ... <img src=\"images/spinning-wait-icons/wait18trans.gif\"></td><td></td></tr>"; 
		htmlStatus = tempHTML + htmlStatus;
		saveTaxonGroupReport();
		htmlStatus = htmlStatus.replace(tempHTML,  ""); 
		
		tempHTML = "<tr><td>&nbsp;</td><td>Saving organism report ... <img src=\"images/spinning-wait-icons/wait18trans.gif\"></td><td></td></tr>"; 
		htmlStatus = tempHTML + htmlStatus;
		saveOrganismReport();
		htmlStatus = htmlStatus.replace(tempHTML,  ""); 
		

		long lTotalEndTime = new Date().getTime();
		totalTime = lTotalEndTime - lTotalStartTime;	
		tempHTML = "<tr><td>&nbsp;</td><td>Saving log ... <img src=\"images/spinning-wait-icons/wait18trans.gif\"></td><td></td></tr>"; 
		htmlStatus = tempHTML + htmlStatus;
		String htmlLogFileContent = this.inputsHTML+ this.getEndJobId() + this.getNoteInfo()+"<br/>\n"+ "<table>"+htmlLog+"</table>";
		htmlLogFileContent = "<table width=1200><tr><td>"+htmlLogFileContent+"</td></tr></table>";
		saveFile(this.getCWD()+"/log.html", htmlLogFileContent);
/*
</table>
<table border=0 width=100%>
*/
		
		String htmlLogHeader = this.inputsHTML+this.getEndJobId().replaceAll("\\<\\/table\\>", "") + this.getNoteInfo().replaceAll("\\<table border=0 width=100\\%\\>", "")+"<br/>\n";
		saveFile(this.getCWD()+"/logHeader.html", htmlLogHeader);
		
		String resultsSummary = "";
		int peptidesHadMatches = query.getPeptides().length - missedPeptideList.size();
		resultsSummary = "##Results summary: "+ peptidesHadMatches +" out of "+ query.getPeptides().length+" unique peptides had matches in "+ totalUniqueProteins.size()+ " protein(s) found in "+ totalUniqueOrganisms.size()+" organism(s)\n";
		resultsSummary += "##Total time used: "+formatInterval(totalTime)+"\n"; 
		String textLogFileContent = this.inputsText+ "##Job ID: "+this.getJobId() + "\n"+resultsSummary+"#Num.\tSearched peptides\tNum. matched proteins\tNum. matched organisms\tTime used (sec.)\n"+ textLog;
		saveFile(this.getCWD()+"/log.txt", textLogFileContent);
		saveMissedQueryPeptides();
		htmlStatus = htmlStatus.replace(tempHTML,  ""); 
	}
	else {
		System.out.println("query is null");
	}
	finished = true;
    }
    private String getQueryPeptideURL(String jobId, Query query, String peptide) {
	String url = "";
	String organism_id = "";
	Organism[] organisms = query.getSelectedOrganisms();
	for(Organism org : organisms) {
		organism_id += org.getTaxonId()+";";		
	}
	organism_id = organism_id.replaceAll(";$", "");
	if(organism_id.length() > 0) {
		url += "peptidewithorganisms.jsp?jobId="+jobId+"&keyword="+peptide+"&start=0&initialed=false&rows=20&organism_id="+organism_id;
	}
	else {
		url += "peptidewithorganisms.jsp?jobId="+jobId+"&keyword="+peptide+"&start=0&initialed=false&rows=20&organism_id=all";
	}
	if(query.getSwissprot().equals("Y")) {
		url = url+"&swissprot=Y";
	}
	if(query.getIsoform().equals("Y")) {
		url = url+"&isoform=Y";
	}
	if(query.getUniRef100Only().equals("Y")) {
		url = url+"&uniref100=Y";
	}
	if(query.getLEqI().equals("Y")) {
		url = url+"&lEqi=Y";
	}
	if(query.getTrOnly().equals("Y")) {
		url = url+"&trOnly=Y";
	}
	if(query.getIsoOnly().equals("Y")) {
		url = url+"&isoOnly=Y";
	}
	
	url = url+"&sortBy=ac_asc";
	
	return url;
    }

//http://research.bioinformatics.udel.edu/peptidematch_new/peptidewithtaxonid.jsp?initialed=false&start=0&rows=20&keyword=AAVEEGIVLGGGCALLR&organism_id=9544&total_number=104&taxon_name=Macaca%20mulatta%20(Rhesus%20macaque)&taxon_id=9544&swissprot=N&isoform=N&uniref100=N&lEqi=N&sortBy=proteomic_asc
private String getOrganismURL(String jobId, Query query, String peptide, Organism organism, int total_number) {
        String url = "peptidewithtaxonid.jsp?initialed=false&start=0&rows=20&jobId="+jobId+"&keyword="+peptide+"&organism_id="+organism.getTaxonId()+"&total_number="+total_number+"&taxon_name="+organism.getName()+"&taxon_id="+organism.getTaxonId();
	if(query.getSwissprot().equals("Y")) {
                url += "&swissprot=Y";
        }
        if(query.getIsoform().equals("Y")) {
                url += "&isoform=Y";
        }
        if(query.getUniRef100Only().equals("Y")) {
                url += "&uniref100=Y";
        }
        if(query.getLEqI().equals("Y")) {
                url += "&lEqi=Y";
        }
	if(query.getTrOnly().equals("Y")) {
		url = url+"&trOnly=Y";
	}
	if(query.getIsoOnly().equals("Y")) {
		url = url+"&isoOnly=Y";
	}
        url += "&sortBy=ac_asc";

        return url;
}
	//http://research.bioinformatics.udel.edu/peptidematch_new/peptidewithtaxongroup.jsp?initialed=false&start=0&rows=20&keyword=AAVEEGIVLGGGCALLR&organism_id=all&total_number=104&group_name=Euk/Animal&taxongroup_id=33208&swissprot=N&isoform=N&uniref100=N&lEqi=N&sortBy=proteomic_asc
private String getTaxonGroupURL(String jobId, Query query, String peptide, Organism taxonGroup, int total_number) {
        String url = "";
        String organism_id = "";
        Organism[] organisms = query.getSelectedOrganisms();
        for(Organism org : organisms) {
                organism_id += org.getTaxonId()+";";
        }
        organism_id = organism_id.replaceAll(";$", "");
        if(organism_id.length() > 0) {
                url += "peptidewithtaxongroup.jsp?jobId="+jobId+"&keyword="+peptide+"&start=0&initialed=false&rows=20&organism_id="+organism_id;
        }
        else {
                url += "peptidewithtaxongroup.jsp?jobId="+jobId+"&keyword="+peptide+"&start=0&initialed=false&rows=20&organism_id=all";
        }
        if(query.getSwissprot().equals("Y")) {
                url += "&swissprot=Y";
        }
        if(query.getIsoform().equals("Y")) {
                url += "&isoform=Y";
        }
        if(query.getUniRef100Only().equals("Y")) {
                url += "&uniref100=Y";
        }
        if(query.getLEqI().equals("Y")) {
                url += "&lEqi=Y";
        }
	if(query.getTrOnly().equals("Y")) {
		url = url+"&trOnly=Y";
	}
	if(query.getIsoOnly().equals("Y")) {
		url = url+"&isoOnly=Y";
	}
	url += "&total_number="+total_number;
	url += "&group_name="+taxonGroup.getName();
	url += "&taxongroup_id="+taxonGroup.getTaxonId();
        url += "&sortBy=ac_asc";

        return url;
    }

    private String getPeptideId(String peptide) {
	String[] peptides = query.getPeptides();
	String[] peptideIds = query.getPeptideIds();
	for(int i = 0; i < peptides.length; i++) {
		if(peptides[i].equals(peptide)) {
			if(peptideIds != null) {
				return peptideIds[i];
			} 
		}	
	}
	return peptide;		
    }

    private void saveSummaryReport() {
	if(this.totalUniqueProteins.size() > 0) {
	//summary += "<thead><tr><th>Query</th><th class=\"sum\">SwissProt</th><th class=\"sum\">TrEMBL</th><th class=\"sum\">Isoform</th><th class=\"sum\">Total Hits</th>";
	String summary = "<div class=\"scroll\">\n<table id=\"batch_summary\" class=\"display compact\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">\n";		
	summary += "<thead><tr><th>Query</th><th class=\"sum\">SwissProt</th><th class=\"sum\">TrEMBL</th><th class=\"sum\">Total Hits</th>";
	summary += "</tr></thread>\n";	
	summary += "<tfoot><tr><th></th><th></th><th></th><th></th>";
	summary += "</tr></tfoot>\n";	
	summary += "<tbody>\n";
	String matchedPeptides = "";
	String[] peptides = query.getPeptides();
	String[] peptideIds = query.getPeptideIds();
	for(int i = 0; i < peptides.length; i++) {
		if(!missed(peptides[i])) {
			if(peptideIds != null && peptideIds[i] != null) {
				//matchedPeptides += ">"+peptideIds[i]+"\n"+peptides[i]+"\n";
				matchedPeptides += peptides[i]+"\t"+peptideIds[i]+"\n";
			}
			else {
				matchedPeptides += peptides[i]+"\n";
			}
			int total = 0;
			//summary += "<tr><td>"+(i+1)+"</td>";
			String queryPeptideURL = getQueryPeptideURL(this.getJobId(),query, peptides[i]);
			if(peptideIds != null && peptideIds[i] != null) {
				//summary += "<td><a href=\""+queryPeptideURL+"\" title=\""+peptides[i]+"\" target=\"_blank\">"+peptideIds[i]+"</a></td>";
				summary += "<td><a href=\""+queryPeptideURL+"\" title=\""+peptides[i]+"\" target=\"_blank\">"+getPeptideId(peptides[i])+"</a></td>";
			}
			else {
				/*String sequence = "";
				if(peptides[i].length() <=50) {
					sequence = peptides[i];	
					summary += "<td><a href=\""+queryPeptideURL+"\" target=\"_blank\">"+sequence+"</a></td>";
				}
				else {
					sequence = peptides[i].substring(0, 50)+"...";	
					summary += "<td><a href=\""+queryPeptideURL+"\" title=\""+peptides[i]+"\" target=\"_blank\">"+sequence+"</a></td>";
				}*/
				summary += "<td><a href=\""+queryPeptideURL+"\" target=\"_blank\">"+wrapSeqWeb(peptides[i], 60)+"</a></td>";
			}
			QueryPeptide inPeptide = query.getQueryPeptide(peptides[i]);
			if(spCount.get(inPeptide) == null) {
				summary += "<td class=\"sum\">0</td>";
			}
			else {
				String spURL = queryPeptideURL;
				if(spURL.contains("swissprot=")) {
					spURL = spURL.replaceAll("swissprot=N", "swissprot=Y");
				}
				else {
					spURL += "&swissprot=Y";
				}
				if(isoCount.get(inPeptide) != null) {	
					summary += "<td class=\"sum\"><a href=\""+spURL+"\" target=\"_blank\">"+spCount.get(inPeptide)+" ("+isoCount.get(inPeptide)+")</a></td>";
				}
				else {
					summary += "<td class=\"sum\"><a href=\""+spURL+"\" target=\"_blank\">"+spCount.get(inPeptide)+"</a></td>";
				}
				total += spCount.get(inPeptide);
			}
			if(trCount.get(inPeptide) == null) {
				summary += "<td class=\"sum\">0</td>";
			}
			else {
				String trURL = queryPeptideURL+"&trOnly=Y";
				summary += "<td class=\"sum\"><a href=\""+trURL+"\" target=\"_blank\">"+trCount.get(inPeptide)+"</a></td>";
				total += trCount.get(inPeptide);
			}
			/*
			if(isoCount.get(inPeptide) == null) {
				summary += "<td class=\"sum\">0</td>";
			}
			else {
				String isoURL = queryPeptideURL+"&isoOnly=Y";
				summary += "<td class=\"sum\"><a href=\""+isoURL+"\" target=\"_blank\">"+isoCount.get(inPeptide)+"</a></td>";
			}
			*/
			summary += "<td class=\"sum\"><a href=\""+queryPeptideURL+"\" target=\"_blank\">"+total+"</a></td>";
			summary += "</tr>\n";
		}
	}
	summary += "</tbody>\n";
	summary += "</table>\n</div>\n";
	String summaryFile = this.getCWD()+"/summary.html";
	saveFile(summaryFile, summary);
	String matchedPeptidesFile = this.getCWD()+"/matchedPeptides.txt";
	saveFile(matchedPeptidesFile, matchedPeptides);
	}
	else {
	String summaryFile = this.getCWD()+"/summary.html";
	saveFile(summaryFile, "No matched protein");
	String matchedPeptidesFile = this.getCWD()+"/matchedPeptides.txt";
	saveFile(matchedPeptidesFile, "");

	}
    }

    private boolean missed(String peptide) {
  	for(String miss: missedPeptideList) {
		if(miss.equals(peptide)) {
			return true;
		}
	}
	return false;	
    }
	
    private void saveOrganismReport() {
	Collections.sort(this.totalUniqueOrganisms, new Comparator<Organism>() {
        	public int compare(Organism o1, Organism o2) {
            		return o1.getName().compareTo(o2.getName());
        	}
    	});	
	String[] peptides = query.getPeptides();
	/*if(peptides.length >= this.totalUniqueOrganisms.size()) {
		savePeptideVsOrganismReport();
	}
	else {
		saveOrganismVsPeptideReport();
	}*/
	// Map<QueryPeptide, Map<Organism, Integer>> organismCount 
	Map<Organism, List<QueryPeptide>> organismHitCount = new HashMap();

	 for(Organism organism: this.totalUniqueOrganisms) {
         	for(int j = 0; j < peptides.length; j++) {
                	if(!missed(peptides[j])) {
                        	QueryPeptide inPeptide = query.getQueryPeptide(peptides[j]);
                                Map<Organism, Integer> peptideOrganismCount = this.organismCount.get(inPeptide);
                                if(peptideOrganismCount != null) {
                                	if(peptideOrganismCount.get(organism) != null && peptideOrganismCount.get(organism) > 0) {
						if(organismHitCount.get(organism) == null) {
							List<QueryPeptide> hitPeptides = new ArrayList();
							hitPeptides.add(inPeptide);	
							organismHitCount.put(organism, hitPeptides);
						}
						else {
							List<QueryPeptide> hitPeptides = organismHitCount.get(organism);
							if(!hitPeptides.contains(inPeptide)) {	
								hitPeptides.add(inPeptide);	
								organismHitCount.put(organism, hitPeptides);
							}
							
						}
                                        }
                                }
                        }
                }
	}

	HashMap idToName = new HashMap();
                try {
                        InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/taxToTaxGroup.txt");
                        BufferedReader br = new BufferedReader(new InputStreamReader(inputStream));
                        String strLine;
                        while((strLine = br.readLine())!= null) {
                                String[] rec = strLine.split("\t");
                                String taxonId = rec[0];
                                String taxonName = rec[1];
                                idToName.put(taxonId, taxonName);
                        }
                        inputStream = this.getClass().getClassLoader().getResourceAsStream("config/orgNameToTaxon.txt");
                        br = new BufferedReader(new InputStreamReader(inputStream));
                        while((strLine = br.readLine())!= null) {
                                String[] rec = strLine.split("\t");
                                String taxonId = rec[1];
                                String taxonName = rec[0];
                                String name = (String)idToName.get(taxonId);
                                if(name == null || name.equals("")) {
                                        idToName.put(taxonId, taxonName);
                                }
                        }
                }
		catch(IOException ioe) {
                        ioe.printStackTrace();
                }
		
	int total = 0;
	HashMap<Organism, Integer> sortedOrganismHitCount =  new LinkedHashMap(); //new HashMap<Organism, Integer>();
	HashMap<Organism, String> sortedOrganismHitPeptides = new LinkedHashMap();
	HashMap<Organism, String> sortedOrganismHitProteins = new LinkedHashMap();

	for(Organism org: organismHitCount.keySet()) {
		List<QueryPeptide> hitPeptides = organismHitCount.get(org);
		List<String> hitProteins = orgProteinMap.get(org);
		total += hitPeptides.size();
		sortedOrganismHitCount.put(org, hitPeptides.size());
		sortedOrganismHitPeptides.put(org, getPeptideURLs(hitPeptides));
		sortedOrganismHitProteins.put(org, getProteinURLs(hitProteins));
	}
	String summary = "<div class=\"scroll\">\n<table id=\"org_summary\" class=\"display compact\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%;\">\n";		
	summary += "<thead><tr><th>Organism</th>\n";
	summary += "<th># Peptides Matched</th>\n";
	summary += "<th>Peptides Matched</th>\n";
	//summary += "<th>% Match</th>\n";
	summary += "<th># Proteins Matched</th>\n";
	summary += "<th>Proteins Matched</th>\n";
	summary += "</tr></thread>\n"; 
	summary += "<tfoot><tr><th></th><th></th><th></th><th></th><th></th>";
	summary += "</tr></tfoot>\n";	
        summary += "<tbody>\n";
	for(Organism organism: sortedOrganismHitCount.keySet()) {
		List<QueryPeptide> hitPeptides = organismHitCount.get(organism);
		List<String> hitProteins = orgProteinMap.get(organism);
		summary += "<tr>\n";
		String orgNameURL = "http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+organism.getTaxonId();
		//summary +="<td><a href=\""+orgNameURL+"\" target=\"_blank\">"+organism.getName()+"</a></td>\n";
		summary +="<td valign=\"top\"><a href=\""+orgNameURL+"\">"+idToName.get(organism.getTaxonId())+"</a></td>\n";
		summary +="<td valign=\"top\">"+ hitPeptides.size()+"</td>\n";	
		summary +="<td valign=\"top\">"+ sortedOrganismHitPeptides.get(organism)+"</td>\n";	
		summary +="<td valign=\"top\">"+ hitProteins.size()+"</td>\n";	
		summary +="<td valign=\"top\">"+ sortedOrganismHitProteins.get(organism)+"</td>\n";	
		//summary +="<td>"+ String.format("%.03f", 100.0*(0.0+hitPeptides.size()) / total)+"</td>\n";	
	}	
        summary += "</tr>\n";
        summary += "</tbody>\n";
        summary += "</table>\n</div>\n";
        String summaryFile = this.getCWD()+"/organism.html";
        saveFile(summaryFile, summary);
    }

    private String getPeptideURLs(List<QueryPeptide> hitPeptides) {
	List<String> peptideSeqs = new ArrayList<String>();
	for(QueryPeptide hit : hitPeptides) {
		peptideSeqs.add(hit.getSeq());
	}
	Collections.sort(peptideSeqs);
	String peptideURLs = "";
	for(String peptide : peptideSeqs) {
		if(peptideURLs.equals("")) {
			//peptideURLs += "<a href=\""+getQueryPeptideURL(this.getJobId(),query, peptide)+"\" target=\"_blank\">"+peptide+"</a>";
			peptideURLs += "<a href=\""+getQueryPeptideURL(this.getJobId(),query, peptide)+"\" target=\"_blank\">"+getPeptideId(peptide)+"</a>";
		}
		else {
			//peptideURLs += ", <a href=\""+getQueryPeptideURL(this.getJobId(),query, peptide)+"\" target=\"_blank\">"+peptide+"</a>";
			peptideURLs += ", <a href=\""+getQueryPeptideURL(this.getJobId(),query, peptide)+"\" target=\"_blank\">"+getPeptideId(peptide)+"</a>";
			
		}
	}
	return peptideURLs;
    }
	
    private String getProteinURLs(List<String> hitProteins) {
	Collections.sort(hitProteins);
	String proteinURLs = "";
	String proteinURL = "";
	for(String protein : hitProteins) {
		if(query.getUniRef100Only() != null && query.getUniRef100Only().equals("Y")) {
                       proteinURL = "<a href=\"http://www.uniprot.org/uniprot/UniRef100_"+protein +"\" target=\"_blank\">UniRef100_"+protein+"</a>";
                }
                else {
                      proteinURL ="<a href=\"http://www.uniprot.org/uniprot/"+protein +"\" target=\"_blank\">"+protein+"</a>";
                }
	
		if(proteinURLs.equals("")) {
			proteinURLs += proteinURL;
		}
		else {
			proteinURLs += ", "+proteinURL;
		}
	}
	return proteinURLs;
    }

    private void saveOrganismVsPeptideReport() {
	String summary = "<div class=\"scroll\">\n<table id=\"batch_summary\" class=\"display compact\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">\n";		
	summary += "<thead><tr><th>Organism</th>";
        String[] peptides = query.getPeptides();
        String[] peptideIds = query.getPeptideIds();
        for(int i = 0; i < peptides.length; i++) {
		if(!missed(peptides[i])) {
                	String queryPeptideURL = getQueryPeptideURL(this.getJobId(),query, peptides[i]);
                	if(peptideIds != null && peptideIds[i] != null) {
                        	summary += "<th><a href=\""+queryPeptideURL+"\" title=\""+peptides[i]+"\" target=\"_blank\">"+peptideIds[i]+"</a></th>";
                	}
                	else {
                        	String sequence = "";
                        	if(peptides[i].length() <=15) {
                               		sequence = peptides[i];
                                	summary += "<th><a href=\""+queryPeptideURL+"\" target=\"_blank\">"+sequence+"</a></th>";
                        	}
                        	else {
                                	sequence = peptides[i].substring(0, 15)+"...";
                                	summary += "<th><a href=\""+queryPeptideURL+"\" title=\""+peptides[i]+"\" target=\"_blank\">"+sequence+"</a></th>";
                        	}
                	}
		}
		summary += "</tr></thread>\n"; 
        	summary += "<tbody>\n";
		for(Organism organism: this.totalUniqueOrganisms) {
			summary += "<tr>";
			String orgNameURL = "http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+organism.getTaxonId();
			summary +="<td><a href=\""+orgNameURL+"\" target=\"_blank\">"+organism.getName()+"</a></td>";
        		for(int j = 0; j < peptides.length; i++) {
				if(!missed(peptides[j])) {
					QueryPeptide inPeptide = query.getQueryPeptide(peptides[j]);
                			String queryPeptideURL = getQueryPeptideURL(this.getJobId(),query, peptides[j]);
                			Map<Organism, Integer> peptideOrganismCount = this.organismCount.get(inPeptide);
                        		if(peptideOrganismCount != null) {
                                		if(peptideOrganismCount.get(organism) != null) {
                                        		String organismURL = getOrganismURL(jobId, query, peptides[i], organism, peptideOrganismCount.get(organism));
                                        		summary += "<td><a href=\""+organismURL+"\" target=\"_blank\">"+peptideOrganismCount.get(organism)+"</a></td>";
                                		}
                                		else {
                                        		summary += "<td>0</td>";
                                		}
                        		}
                        		else {
                               			summary += "<td>0</td>";
                        		}
				}
                	}
                	summary += "</tr>\n";
		}
	}
        	summary += "</tbody>\n";
        	summary += "</table>\n</div>\n";
        	String summaryFile = this.getCWD()+"/organism.html";
        	saveFile(summaryFile, summary);
    }

    private void savePeptideVsOrganismReport() {
	String summary = "<div class=\"scroll\">\n<table id=\"batch_summary\" class=\"display compact\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">\n";		
	summary += "<thead><tr><th>Query</th>";
	for(Organism org: this.totalUniqueOrganisms) {
		String orgNameURL = "http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+org.getTaxonId();
		summary +="<th><a href=\""+orgNameURL+"\" title=\""+org.getName()+"\" target=\"_blank\">"+org.getTaxonId()+"</a></th>";
	}
	summary += "<th>Total Protein Hits</th></tr></thread>\n"; 
        summary += "<tbody>\n";
        String[] peptides = query.getPeptides();
        String[] peptideIds = query.getPeptideIds();
        for(int i = 0; i < peptides.length; i++) {
		if(!missed(peptides[i])) {
			int total = 0;
			summary += "<tr>";
                	String queryPeptideURL = getQueryPeptideURL(this.getJobId(),query, peptides[i]);
                	if(peptideIds != null && peptideIds[i] != null) {
                        	summary += "<td><a href=\""+queryPeptideURL+"\" title=\""+peptides[i]+"\" target=\"_blank\">"+peptideIds[i]+"</a></td>";
                	}
                	else {
                        	String sequence = "";
                        	if(peptides[i].length() <=30) {
                                	sequence = peptides[i];
                                	summary += "<td><a href=\""+queryPeptideURL+"\" target=\"_blank\">"+sequence+"</a></td>";
                        	}
                        	else {
                                	sequence = peptides[i].substring(0, 30)+"...";
                                	summary += "<td><a href=\""+queryPeptideURL+"\" title=\""+peptides[i]+"\" target=\"_blank\">"+sequence+"</a></td>";
                        	}
                	}
                	QueryPeptide inPeptide = query.getQueryPeptide(peptides[i]);
                	Map<Organism, Integer> peptideOrganismCount = this.organismCount.get(inPeptide);
                	for(Organism organism : this.totalUniqueOrganisms) {
                        	if(peptideOrganismCount != null) {   
                                	if(peptideOrganismCount.get(organism) != null) {
                                        	String organismURL = getOrganismURL(jobId, query, peptides[i], organism, peptideOrganismCount.get(organism));
                                        	summary += "<td><a href=\""+organismURL+"\" target=\"_blank\">"+peptideOrganismCount.get(organism)+"</a></td>";
						total += peptideOrganismCount.get(organism);
                                	}
                                	else {
                                        	summary += "<td>0</td>";
                                	}
                        	}
                        	else {
                                	summary += "<td>0</td>";
                        	}
                	}
			summary += "<td><a href=\""+queryPeptideURL+"\" target=\"_blank\">"+total+"</a></td>";
                	summary += "</tr>\n";
		}
        }
        summary += "</tbody>\n";
        summary += "</table>\n</div>\n";
        String summaryFile = this.getCWD()+"/organism.html";
        saveFile(summaryFile, summary);

    }

    private void saveTaxonGroupReport() {
	if(this.totalUniqueTaxonGroups.size() > 0) {	
	Collections.sort(this.totalUniqueTaxonGroups, new Comparator<Organism>() {
        	public int compare(Organism o1, Organism o2) {
            		return o1.getName().compareTo(o2.getName());
        	}
    	});	
	String summary = "<div class=\"scroll\">\n<table id=\"batch_summary\" class=\"display compact\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">\n";		
	summary += "<thead><tr><th>Query</th>";
	String tfoot ="<tfoot><tr><th></th>";
	for(Organism taxonGroup: this.totalUniqueTaxonGroups) {
		String taxonGroupNameURL = "http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+taxonGroup.getTaxonId();
		summary +="<th class=\"sum\"><a href=\""+taxonGroupNameURL+"\" target=\"_blank\">"+taxonGroup.getName().replaceAll("\\.\\.", "Others")+"</a></th>";
		tfoot += "<th></th>\n"; 
	}
	summary += "<th class=\"sum\">Total Hits</th>\n";
	tfoot += "<th></th>\n";	
	summary += "</tr></thread>\n";	
	tfoot += "</tr></tfoot>\n";	
	summary += tfoot;
	summary += "<tbody>\n";
	String[] peptides = query.getPeptides();
	String[] peptideIds = query.getPeptideIds();
	for(int i = 0; i < peptides.length; i++) {
		if(!missed(peptides[i])) {
		int total = 0;
		//summary += "<tr><td>"+(i+1)+"</td>";
		summary += "<tr>";
		String queryPeptideURL = getQueryPeptideURL(this.getJobId(),query, peptides[i]);
		if(peptideIds != null && peptideIds[i] != null) {
			summary += "<td><a href=\""+queryPeptideURL+"\" title=\""+peptides[i]+"\" target=\"_blank\">"+peptideIds[i]+"</a></td>";
		}
		else {
			String sequence = "";
			if(peptides[i].length() <=30) {
				sequence = peptides[i];	
				summary += "<td><a href=\""+queryPeptideURL+"\" target=\"_blank\">"+sequence+"</a></td>";
			}
			else {
				sequence = peptides[i].substring(0, 30)+"...";	
				summary += "<td><a href=\""+queryPeptideURL+"\" title=\""+peptides[i]+"\" target=\"_blank\">"+sequence+"</a></td>";
			}
		}
		QueryPeptide inPeptide = query.getQueryPeptide(peptides[i]);
		Map<Organism, Integer> peptideTaxonGroupCount = this.taxonGroupCount.get(inPeptide);		
		for(Organism taxonGroup : this.totalUniqueTaxonGroups) {
			if(peptideTaxonGroupCount != null) {	
				if(peptideTaxonGroupCount.get(taxonGroup) != null) {
					String taxonGroupURL = getTaxonGroupURL(jobId, query, peptides[i], taxonGroup, peptideTaxonGroupCount.get(taxonGroup));
					summary += "<td class=\"sum\"><a href=\""+taxonGroupURL+"\" target=\"_blank\">"+peptideTaxonGroupCount.get(taxonGroup)+"</a></td>";
					total += peptideTaxonGroupCount.get(taxonGroup);
				}
				else {
					summary += "<td class=\"sum\">0</td>";
				}
			}
			else {
				summary += "<td class=\"sum\">0</td>";
			}
		}
		summary += "<td class=\"sum\"><a href=\""+queryPeptideURL+"\" target=\"_blank\">"+total+"</a></td>";
		summary += "</tr>\n";
		}
	}
	summary += "</tbody>\n";
	summary += "</table>\n</div>\n";
	String summaryFile = this.getCWD()+"/taxongroup.html";
	saveFile(summaryFile, summary);
	}
	else {
	String summaryFile = this.getCWD()+"/taxongroup.html";
	saveFile(summaryFile, "No matched protein");

	}
    }


	
    private void savePeptideSummary() {
	String summaryFile = this.getCWD()+"/peptideSummary.txt";
	String summaryContent = "##Batch Peptide Match Report (Job ID: "+this.getJobId()+")\n";
	summaryContent +=this.inputsText;
		 int peptidesHadMatches = query.getPeptides().length - missedPeptideList.size();
		summaryContent +="##Number of unique query peptides had matches: "+ peptidesHadMatches+"\n";
		summaryContent +="##Unique matched protein(s): "+ this.totalUniqueProteins.size()+"\n";
		summaryContent +="##Unique matched organism(s): "+ this.totalUniqueOrganisms.size()+"\n";
		summaryContent +="##Unique matched taxonomic group(s): "+ this.totalUniqueTaxonGroups.size()+"\n";
		summaryContent +="##Summary of per peptide matched proteins\n";
		summaryContent +="#Query peptide\tNum. matched proteins\tNum. matched organisms\n";
	//}
	summaryContent +=perPeptideMatchedProteins+"\n";
	saveFile(summaryFile, summaryContent);
    }
	
    private void saveProteinSummary() {	
	String summaryFile = this.getCWD()+"/proteinSummary.txt";
	String summaryContent = "##Batch Peptide Match Report (Job ID: "+this.getJobId()+")\n";
	summaryContent +=this.inputsText;
	//summaryContent +="##Unique matched protein(s): "+ this.totalUniqueProteins.size()+"\n";
	if(query.getUniRef100Only() != null && query.getUniRef100Only().equals("Y")) {
		 int peptidesHadMatches = query.getPeptides().length - missedPeptideList.size();
		summaryContent +="##Number of unique query peptides had matches: "+ peptidesHadMatches+"\n";
		summaryContent +="##Unique matched protein(s): "+ this.totalUniqueProteins.size()+"\n";
		summaryContent +="##Unique matched organism(s): "+ this.totalUniqueOrganisms.size()+"\n";
		summaryContent +="##Unique matched taxonomic group(s): "+ this.totalUniqueTaxonGroups.size()+"\n";
		summaryContent +="##Summary of per protein matched peptides\n";	
		summaryContent +="#UniRef100 Cluster ID\t Representative protein AC\tNum. matching peptdies\tMatching peptides\n";
	}
	else {
		 int peptidesHadMatches = query.getPeptides().length - missedPeptideList.size();
		summaryContent +="##Number of unique query peptides had matches: "+ peptidesHadMatches+"\n";
		summaryContent +="##Unique matched protein(s): "+ this.totalUniqueProteins.size()+"\n";
		summaryContent +="##Unique matched organisms(s): "+ this.totalUniqueOrganisms.size()+"\n";
		summaryContent +="##Unique matched taxonomic group(s): "+ this.totalUniqueTaxonGroups.size()+"\n";
		summaryContent +="##Summary of per protein matched peptides\n";	
		summaryContent +="#Protein AC\tNum. matching peptdies\tMatching peptides\n";
	}
	SortedSet<String> proteinACs = new TreeSet<String>(perProteinMatchedPeptides.keySet());
	System.out.println("Unique protiens: "+proteinACs.size());
	StringBuffer sb = new StringBuffer();
	int count = 0;
	for (String proteinAC : proteinACs) { 
		count++;
		if(count % 10000 == 0) {
			System.out.println(count + " has been processed " + new Date());
		}
		
   		ArrayList<String> peptides = perProteinMatchedPeptides.get(proteinAC);
		if(query.getUniRef100Only() != null && query.getUniRef100Only().equals("Y")) {
			sb.append("UniRef100_"+proteinAC +"\t"+proteinAC+"\t"+peptides.size()+"\t" + StringUtils.join(peptides, "; ")+"\n"); 
		}
		else {
			sb.append(proteinAC +"\t"+peptides.size()+"\t" + StringUtils.join(peptides, "; ")+"\n"); 
		}
	}
	saveFile(summaryFile, summaryContent+sb.toString());
	sb.setLength(0);
    }

    private void savePeptideHitMap() {
	String peptideHitMapFile = this.getCWD()+"/peptideHitMap.html";
	SortedSet<String> proteinACs = new TreeSet<String>(perProteinMatchedPeptides.keySet());
	String hitmap = "";
	hitmap += "<div class=\"scroll\">\n<table id=\"peptidehitmap\" class=\"display compact\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">\n";		
	hitmap += "<thead><tr><th>Query Peptide</th><th># Matched Proteins</th><th>Matched Proteins</th>";
	hitmap += "</tr></thread>\n";	
	hitmap += "<tfoot><tr><th></th><th></th><th></th>";
	hitmap += "</tr></tfoot>\n";	
	Map<String, List<String>> peptideMap = new TreeMap();	
	for (String proteinAC : proteinACs) { 
   		ArrayList<String> peptides = perProteinMatchedPeptides.get(proteinAC);
		for(String peptideStr : peptides) {
			String[] pa = peptideStr.split("\\(");	
                        //String peptideURL = "<a href=\""+getQueryPeptideURL(this.getJobId(),query, pa[0])+"\" target=\"_blank\">"+pa[0]+"</a>";
                        String peptideURL = "<a href=\""+getQueryPeptideURL(this.getJobId(),query, pa[0])+"\" target=\"_blank\">"+getPeptideId(pa[0])+"</a>";
			String proteinURL = "";
			if(query.getUniRef100Only() != null && query.getUniRef100Only().equals("Y")) {
                        	proteinURL = "<a href=\"http://www.uniprot.org/uniprot/UniRef100_"+proteinAC +"\" target=\"_blank\">UniRef100_"+proteinAC+"</a>";
                	}
                	else {
                        	proteinURL ="<a href=\"http://www.uniprot.org/uniprot/"+proteinAC +"\" target=\"_blank\">"+proteinAC+"</a>";
                	}
			List<String> proteinURLs = peptideMap.get(peptideURL);
			if(proteinURLs == null) {
				proteinURLs = new ArrayList<String>();
				proteinURLs.add(proteinURL);
				peptideMap.put(peptideURL, proteinURLs);
			}
			else {
				proteinURLs.add(proteinURL);
				peptideMap.put(peptideURL, proteinURLs);
			}	
		}			
	}
	for(String peptideURL : peptideMap.keySet()) {
		hitmap +="<tr><td>"+peptideURL+"</td>";
		List<String> proteinURLs = peptideMap.get(peptideURL);
		Collections.sort(proteinURLs);
		//hitmap +="<td>"+StringUtils.join(proteinURLs, ", ")+"</td>"+"<td>"+proteinURLs.size()+"</td></tr>";
		hitmap +="<td>"+proteinURLs.size()+"</td><td>"+StringUtils.join(proteinURLs, ", ")+"</td></tr>";
	}
	hitmap += "</table></div>\n";
	saveFile(peptideHitMapFile, hitmap);
	
    }

    private void saveProteinHitMap() {
	String proteinHitMapFile = this.getCWD()+"/proteinHitMap.html";
	SortedSet<String> proteinACs = new TreeSet<String>(perProteinMatchedPeptides.keySet());
	String hitmap = "";
	hitmap += "<div class=\"scroll\">\n<table id=\"proteinhitmap\" class=\"display compact\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">\n";		
	hitmap += "<thead><tr><th>Protein AC</th><th># Matched Peptides</th><th>Matched Peptides</th>";
	hitmap += "</tr></thread>\n";	
	hitmap += "<tfoot><tr><th></th><th></th><th></th>";
	hitmap += "</tr></tfoot>\n";	
	for (String proteinAC : proteinACs) { 
		hitmap +="<tr>\n";
   		ArrayList<String> peptides = perProteinMatchedPeptides.get(proteinAC);
		if(query.getUniRef100Only() != null && query.getUniRef100Only().equals("Y")) {
			hitmap +="<td><a href=\"http://www.uniprot.org/uniprot/UniRef100_"+proteinAC +"\" target=\"_blank\">UniRef100_"+proteinAC+"</a></td>";
			//+peptides.size()+"\t" + StringUtils.join(peptides, "; ")+"\n"); 
		}
		else {
			hitmap +="<td><a href=\"http://www.uniprot.org/uniprot/"+proteinAC +"\" target=\"_blank\">"+proteinAC+"</a></td>\n";
			//sb.append(proteinAC +"\t"+peptides.size()+"\t" + StringUtils.join(peptides, "; ")+"\n"); 
		}
		String peptideURLs = "";
		for(String peptideStr : peptides) {
			String[] pa = peptideStr.split("\\(");	
			if(peptideURLs.equals("")) {
                        	//peptideURLs += "<a href=\""+getQueryPeptideURL(this.getJobId(),query, pa[0])+"\" target=\"_blank\">"+pa[0]+"</a>";
                        	peptideURLs += "<a href=\""+getQueryPeptideURL(this.getJobId(),query, pa[0])+"\" target=\"_blank\">"+getPeptideId(pa[0])+"</a>";
                	}
                	else {
                        	//peptideURLs += ", <a href=\""+getQueryPeptideURL(this.getJobId(),query, pa[0])+"\" target=\"_blank\">"+pa[0]+"</a>";
                        	peptideURLs += ", <a href=\""+getQueryPeptideURL(this.getJobId(),query, pa[0])+"\" target=\"_blank\">"+getPeptideId(pa[0])+"</a>";
                	}
		}
		hitmap +="<td>"+peptides.size()+"</td>\n";
		hitmap +="<td>"+peptideURLs+"</td>\n";
		hitmap +="</tr>\n";
	}
	hitmap += "</table></div>\n";
	saveFile(proteinHitMapFile, hitmap);
    }

    private void saveProteinSequences() {
	String seqFile = this.getCWD()+"/proteinSeq.fasta";
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
	saveFile(seqFile, sb.toString());
	sb.setLength(0);
    }
/*
    private String getPeptideSummary(String logText) {
		String summary = "";
                String[] logs = logText.split("\n");
                 for(int i=logs.length -1; i > 0; i--) {
                        String line = logs[i];
			MatchedRangesInfo += matchedRange.getStart() +"-"+ matchedRange.getEnd();
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
				summary += peptide+"\t"+numProteins+"\t"+numOrganisms+"\n";
                        }
                 }
		return summary;
        }
*/
    private void saveFile(String filePathAndName, String fileContent) {
	System.out.println("saveFile: "+filePathAndName);
	try {
		File file = new File(filePathAndName);
		FileWriter fw = new FileWriter(file);
		BufferedWriter bw = new BufferedWriter(fw);
		bw.write(fileContent);
		bw.close();
	}
	catch(IOException ioe) {
		ioe.printStackTrace();
	}
    }

    private void appendFile(String filePathAndName, String fileContent) {
	System.out.println("appendFile: "+filePathAndName);
	try {
		File file = new File(filePathAndName);
		FileWriter fw = new FileWriter(file, true);
		BufferedWriter bw = new BufferedWriter(fw);
		bw.write(fileContent);
		bw.close();
	}
	catch(IOException ioe) {
		ioe.printStackTrace();
	}
    }

    private String readFile(String filePathAndName) {
	StringBuffer fileContent = new StringBuffer() ;
	try {
		File file = new File(filePathAndName);
		FileReader fr = new FileReader(file);	
		BufferedReader br = new BufferedReader(fr);
		String line = null;
		while((line = br.readLine()) != null) {
			fileContent.append(line+"\n");	
		} 
		br.close();
	}
	catch(IOException ioe) {
		ioe.printStackTrace();
	}
	return fileContent.toString();
    }

     
    public void setFinished(boolean finished) {
	this.finished = finished;
    }

    public boolean isFinished() {
	return this.finished;
    }


    public void setCWD(String cwd) {
	this.cwd = cwd;
    }

    public String getCWD() {
	return this.cwd;
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
    
    private ArrayList<MatchedProtein> doSearch(String queryPeptide, String queryPeptideFileName, Organism[] selectedOrganisms, String swissprot, String isoform,  String uniref100Only, String ilEquivalent, String sortBy, String trOnly, String isoOnly) {
	PeptidePhraseQuery peptideQuery = new PeptidePhraseQuery();
        SolrDocumentList docs = new SolrDocumentList();
        int numberFound = 0;
	ArrayList<MatchedProtein> matchedProteins = new ArrayList<MatchedProtein>();	
	if(selectedOrganisms == null || selectedOrganisms.length == 0) {
		peptideQuery.queryByPeptide(queryPeptide, 0, 1, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
		numberFound = peptideQuery.getResult();
		if(numberFound > 0) {
			for(int i = 0; i < numberFound; i += 300000) {
				peptideQuery.queryByPeptide(queryPeptide, i, 300000, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
				docs = peptideQuery.getCurrentDocs();
				Iterator<SolrDocument> docItr = docs.iterator();
				while(docItr.hasNext()) {
					matchedProteins.add(getMatchedProtein(queryPeptide, docItr.next(), ilEquivalent));	
				}	
			}		
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
		peptideQuery.queryByPeptideWithMultiOrganism(queryPeptide, organisms, 0, 1, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
		numberFound = peptideQuery.getResult();
		if(numberFound > 0) {
			for(int i = 0; i < numberFound; i += 300000) {
				peptideQuery.queryByPeptideWithMultiOrganism(queryPeptide, organisms, i, 300000, swissprot, isoform, uniref100Only, ilEquivalent, sortBy, trOnly, isoOnly);
				docs = peptideQuery.getCurrentDocs();
				Iterator<SolrDocument> docItr = docs.iterator();
				while(docItr.hasNext()) {
					matchedProteins.add(getMatchedProtein(queryPeptide, docItr.next(), ilEquivalent));	
				}	
			}		
		}

	}

	printPerPeptideMatchedProteinsTable(queryPeptide, queryPeptideFileName, matchedProteins);				
	countPerProteinMatch(queryPeptide, matchedProteins);
	return matchedProteins;
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

	
    private void printPerPeptideMatchedProteinsTable(String queryPeptide, String queryPeptideFileName, ArrayList<MatchedProtein> matchedProteins) {
	System.out.println("matchedProtein size: "+matchedProteins.size());
	//String filePathAndName = this.getCWD()+ "/PerPeptideMatchResults/"+queryPeptide+".txt";
	String filePathAndName = this.getCWD()+ "/PerPeptideMatchResults/"+queryPeptideFileName;
	String detailFilePathAndName = this.getCWD()+ "/perPeptideMatchDetails.txt";
	String matchedProteinsInfo = "##Query peptide: "+ queryPeptide+"\n";
	matchedProteinsInfo += "##Number of matched proteins: "+matchedProteins.size()+"\n";
	if(query.getUniRef100Only() != null && query.getUniRef100Only().equals("Y")) {
		matchedProteinsInfo += "#UniRef100 Cluster ID\tRepresentative Protein AC\tProtein Name\tLength\tOrganism\tMatched Range(s)\tProteomic Databases\tIEDB\n";
		String detailHeader = "#Query Peptide\tRank\tUniRef100 Cluster ID\tRepresentative Protein AC\tProtein Name\tLength\tOrganism\tMatched Range(s)\tProteomic Databases\tIEDB\n";
		String detailInfo ="";
		for(int i = 0; i < matchedProteins.size(); i++) {	
			MatchedProtein matchedProtein = matchedProteins.get(i);
			matchedProteinsInfo += 	matchedProtein.getTabDelimitedInfo(true);	
			//detailInfo += queryPeptide+"\t"+(i+1)+"\t"+matchedProtein.getTabDelimitedInfo(true);	
			detailInfo += getPeptideId(queryPeptide)+"\t"+(i+1)+"\t"+matchedProtein.getTabDelimitedInfo(true);	
		}
		saveFile(filePathAndName, matchedProteinsInfo);	
		try {
			File f = new File(detailFilePathAndName);
      			if(f.exists()){
				appendFile(detailFilePathAndName, detailInfo);	
      			} else {
				saveFile(detailFilePathAndName, detailHeader+detailInfo);	
      			}
		}
		catch(Exception e){
         		e.printStackTrace();
      		}
	}
	else {
		matchedProteinsInfo += "#Protein AC\tProtein ID\tProtein Name\tLength\tOrganism\tMatched Range(s)\tProteomic Databases\tIEDB\n";
		String detailHeader = "#Query Peptide\tRank\tProtein AC\tProtein ID\tProtein Name\tLength\tOrganism\tMatched Range(s)\tProteomic Databases\tIEDB\n";
		String detailInfo ="";
		for(int i = 0; i < matchedProteins.size(); i++) {	
			MatchedProtein matchedProtein = matchedProteins.get(i);
			matchedProteinsInfo += 	matchedProtein.getTabDelimitedInfo(false);	
			//detailInfo += queryPeptide+"\t"+(i+1)+"\t"+matchedProtein.getTabDelimitedInfo(false);	
			detailInfo += getPeptideId(queryPeptide)+"\t"+(i+1)+"\t"+matchedProtein.getTabDelimitedInfo(false);	
		}
		saveFile(filePathAndName, matchedProteinsInfo);	
		try {
			File f = new File(detailFilePathAndName);
      			if(f.exists()){
				appendFile(detailFilePathAndName, detailInfo);	
      			} else {
				saveFile(detailFilePathAndName, detailHeader+detailInfo);	
      			}
		}
		catch(Exception e){
         		e.printStackTrace();
      		}
	}
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

    public void setInputs(HttpServletRequest request) {
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
	String  info = "";
	String text = "";	
	info += "<table border=0 width=100%>\n";	
	info += "	<tr>\n";	
	info += "		<td style=\"width: 200px;\" valign=top nowrap><b>Sequence data set:</b> </td><td valgin=top>"+version;	
	text += "##Sequence data set: "+ version;
	String swissprot = query.getSwissprot();
	if(swissprot != null && swissprot.equals("Y")) {
		info +=	" | SwissProt";
		text +=	" | SwissProt";
	}
	String isoform = query.getIsoform();
	if(isoform != null && isoform.equals("Y")) {
		info +=	" | Isoform";
		text +=	" | Isoform";
	}

	String uniref100 = query.getUniRef100Only();
	if(uniref100 != null && uniref100.equals("Y")) {
		info +=	" | UniRef100";
		text +=	" | UniRef100";
	}
	String lEqi = query.getLEqI();
	if(lEqi != null && lEqi.equals("Y")) {
		//info += " | Leucine (L) and IsoLeucine (I) are equivalent";
		info += " | L and I are equivalent";
		//text += " | Leucine (L) and IsoLeucine (I) are equivalent";
		text += " | L and I are equivalent";
	}
	info += "		</td>\n";
	info += "	</tr>\n";	
	text += "\n";	
	Organism[] organisms = query.getSelectedOrganisms();
	if(organisms.length > 0) {
		text += "##Target organisms: ";
		info +="	<tr>\n";
		info += "		<td style=\"width: 200px;\" valign=top nowrap><b>Target organisms</b>: </td><td valign=top>";	
		for(int i = 0; i < organisms.length; i++) {
			if(i == 0) {
				info +="<a href=\"http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+ organisms[i].getTaxonId()+"\" target=\"_blank\">" +organisms[i].getName() + "</a>";	
				text += organisms[i].getName()+" ["+organisms[i].getTaxonId()+"]";
			}
			else {
				info +="; <a href=\"http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+ organisms[i].getTaxonId()+"\" target=\"_blank\">" +organisms[i].getName() + "</a>";	
				text += "; "+organisms[i].getName()+" ["+organisms[i].getTaxonId()+"]";
			}
		}
		info +="	</td></tr>\n";
		text += "\n";	
	}
	info +="	<tr>\n";
	info += "		<td style=\"width: 200px;\" valign=top nowrap><b>Unique query peptides: </b></td><td valign=top>"+query.getPeptides().length+"</td>";;	
	info +="	</tr>\n";
	text += "##Unique query peptides: "+query.getPeptides().length+"\n";	
	info += "</table>\n";	
	this.inputsHTML = info;
	this.inputsText = text;
	//System.out.println("Text: "+ text);
	saveFile(this.getCWD()+"/inputs.txt", text);
    }

    public String getInputsText() {
	return this.inputsText;
    }

    public String getInputsHTML() {
	return this.inputsHTML;
    }

	
    public String getStartJobId() {
	String  info = "";
	info += "<table border=0 width=100%>\n";	
	info +="	<tr>\n";
	info += "		<td style=\"width: 200px;\" valign=top><b>Job ID: </b></td><td valign=top>"+this.getJobId()+"<div class=\"JobId\" style=\"display: none;\">"+this.getJobId()+"</div></td>";;	
	info +="	</tr>\n";
	info += "</table>\n";	
	return info;
    }

    /*
 	<script type="text/javascript">
function submitform()
{
    document.forms["myform"].submit();
}
</script>
<form id="myform" action="submit-form.php">
Search: <input type='text' name='query'>
<a href="javascript: submitform()">Submit</a>
</form>
*/ 
    public String getEndJobId() {
	String  info = "";
	info += "<table  border=0 width=100%>\n";	
	info +="	<tr>\n";
	info += "		<td style=\"width: 200px;\" valign=top><b>Job ID: </b></td><td valign=top><a href=\"batchresultsummary.jsp?jobId="+this.getJobId()+"\">"+this.getJobId()+"</a><div class=\"JobId\" style=\"display: none;\">"+this.getJobId()+"</div></td>";;	
	info +="	</tr>\n";
	info +="	<tr>\n";
	int peptidesHadMatches = query.getPeptides().length - missedPeptideList.size();

	info += "		<td style=\"width: 200px;\" valign=top><b>Summary: </b></td><td><font color=gray>"+peptidesHadMatches + "</font> out of <font color=gray>"+ query.getPeptides().length +"</font> unique query peptides had matches in <font color=gray>"+ totalUniqueProteins.size()+ "</font> proteins(s) found in <font color=gray>"+ totalUniqueOrganisms.size()+"</font> organism(s) and <font color=gray>"+totalUniqueTaxonGroups.size()+"</font> taxonomic group(s)</td>";	
	info +="	</tr>\n";
	info +="	<tr>\n";
	info += "		<td style=\"width: 200px;\" valign=top><b>Total time used: </b></td><td valign=top><font color=gray>"+formatInterval(totalTime)+"</font></td>";	
	info +="	</tr>\n";
	info += "</table>\n";	
	return info;
    }

    public String getNoteInfo() {
	String info = "";
	info += "<table border=0 width=100%>\n";	
	info +="	<tr>\n";
	info += "		<td colspan=2 valign=top><br/>Your job has finished successfully. (<b>Note: Your results will be available for 2 weeks. Please <a href=\"selectbatchpeptidematchresults.jsp?jobId="+jobId+"\" target=\"_blank\">download</a> them ASAP</b>)</td>";;	
	info +="	</tr>\n";
	info += "</table>\n";	
	return info;
    }


    private String formatInterval(final long l)
    {
        final long hr = TimeUnit.MILLISECONDS.toHours(l);
        final long min = TimeUnit.MILLISECONDS.toMinutes(l - TimeUnit.HOURS.toMillis(hr));
        final long sec = TimeUnit.MILLISECONDS.toSeconds(l - TimeUnit.HOURS.toMillis(hr) - TimeUnit.MINUTES.toMillis(min));
        final long ms = TimeUnit.MILLISECONDS.toMillis(l - TimeUnit.HOURS.toMillis(hr) - TimeUnit.MINUTES.toMillis(min) - TimeUnit.SECONDS.toMillis(sec));
        return String.format("%02d:%02d:%02d:%03d", hr, min, sec, ms);
        //return String.format("%02d:%02d:%02d", hr, min, sec);
    }

    public String getHTMLStatus() {
	return "<table>"+htmlStatus+"</table>";
    } 
  
    public String getTextStatus() {
	return textStatus;
    } 
  
    public void setJobId(String jobId) {
	this.jobId = jobId;
    } 

    public String getJobId() {
	return this.jobId;
    }
 
    public String getHTMLLog() {
	return htmlLog;
    }
    
    public void setHTMLLog(String htmlLog) {
	this.htmlLog = htmlLog;
    } 

    public String getTextLog() {
	return textLog.toString();
    }
    
    public void setTextLog(String textLog) {
	this.textLog = textLog;
    } 

    public void setQuery(Query query) {
	this.query = query;
    }
    
    public Query getQuery() {
	return this.query;
    }
	
    public void saveOriginalQueryPeptides(Query query) {
		saveFile(this.getCWD()+"/originalQuerySeq.txt", query.getOriginalQueryPeptides());
    }
    
    public void saveMissedQueryPeptides() {
		if(missedPeptideList.size() == 0) {
			saveFile(this.getCWD()+"/missedOriginalQuerySeq.txt", "No missed query peptides");
		}
		else {
			String missedQueryPeptides = "";
			for(int i= 0; i < missedPeptideList.size(); i++) {
				String peptideId = getPeptideId(missedPeptideList.get(i));
				if(peptideId.equals(missedPeptideList.get(i))) {
					missedQueryPeptides += missedPeptideList.get(i)+"\n";	
				}
				else {
					missedQueryPeptides += ">"+peptideId+"\n"+missedPeptideList.get(i)+"\n";	
					
				}
			}
			saveFile(this.getCWD()+"/missedOriginalQuerySeq.txt", missedQueryPeptides);
		}				
    }
   
    public String wrapSeqWeb(String seq, int maxLengthPerLine) {
	char[] cArray = seq.toCharArray();
	String wrapSeq = "";
	int count = 0;
	for(int i = 0; i < cArray.length; i++) {
		wrapSeq += cArray[i];
		count++;
		if(count % maxLengthPerLine == 0) {
			wrapSeq +="<br/>";
		}
	}
	return wrapSeq;
    }
	
      private  HashMap sortByValues(HashMap map) { 
       List list = new LinkedList(map.entrySet());
       // Defined Custom Comparator here
       Collections.sort(list, new Comparator() {
            public int compare(Object o1, Object o2) {
               return ((Comparable) ((Map.Entry) (o1)).getValue())
                  .compareTo(((Map.Entry) (o2)).getValue());
            }
       });

       // Here I am copying the sorted list in HashMap
       // using LinkedHashMap to preserve the insertion order
       HashMap sortedHashMap = new LinkedHashMap();
       for (Iterator it = list.iterator(); it.hasNext();) {
              Map.Entry entry = (Map.Entry) it.next();
              sortedHashMap.put(entry.getKey(), entry.getValue());
       } 
       return sortedHashMap;
  }
}
