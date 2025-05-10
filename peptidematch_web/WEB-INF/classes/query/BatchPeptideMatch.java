package query;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.*;
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Properties;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.Term;
import org.apache.lucene.search.BooleanClause;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.PhraseQuery;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.TopScoreDocCollector;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;

public class BatchPeptideMatch extends HttpServlet {
	/**
	 * This servlet is used to provide batch peptides retrieve
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private PrintWriter out;
	private String id;;
	private String description;
	private String sequence;
	private String[] features;
	private String proteinID;
	private String proteinName;
	private String pirsfID;
	private String organism;

		
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		out = response.getWriter();
		// indexpath.properties is in the $tomcat_home/WEB-INF/class/
		InputStream inputStream = this.getClass().getClassLoader()
				.getResourceAsStream("config/index.properties");
		Properties properties = new Properties();
		properties.load(inputStream);
		// get the value of the property
		String indexPath = properties.getProperty("indexpath");
		String version = properties.getProperty("version");
		//initial the query
		BooleanQuery bQuery = new BooleanQuery();
		PhraseQuery phraseQuery;
		// open the index
		Directory indexDir = FSDirectory.open(new File(indexPath));
		IndexSearcher searcher = new IndexSearcher(IndexReader.open(indexDir));
		TopScoreDocCollector collector;
		String organism = "";
		StringBuilder fileName = new StringBuilder();
		StringBuilder organism_part = new StringBuilder();
		String[] peptides = null;
		String peptide = "";
		int totalNumber = 0;
		int uploadSize=0;
		int maxLength=400;
		String uploadContent="";
		Document doc = new Document();
		//using the Solr to get the total matched sequences
		//PeptidePharseQuery is for quering the total result, not for retrieve the result data
		PeptidePhraseQuery pquery = new PeptidePhraseQuery();	
			//process the form data
			if(ServletFileUpload.isMultipartContent(request)){
				FileItemFactory factory = new DiskFileItemFactory();
				ServletFileUpload uploadHandler = new ServletFileUpload(factory);
				try {
					/*
					 * Parse the request
					 */
					List items = uploadHandler.parseRequest(request);
					Iterator itr = items.iterator();
					String fieldName;
					while(itr.hasNext()) {
						FileItem item = (FileItem) itr.next();
						/*
						 * Handle Form Fields.
						 */
						if(item.isFormField()) {				
							fieldName=item.getFieldName().toLowerCase();
						if(fieldName.equals("db"))
							organism = item.getString().trim();
						else if(fieldName.equals("peptide"))
						    peptide=item.getString().trim();
						} 
						else {
							//Handle Uploaded files.
							if(item.getSize()>0&&!item.getContentType().equals("text/plain")){		
									out.println(System.getProperty("java.io.tmpdir"));
									out.println("The file format you upload is: "+item.getContentType());
									out.println("Only text/plain file can be supported");
									out.close();
								}
								else{
									uploadSize=(int) item.getSize();
									uploadContent=item.getString();
								}
						}
					}
				} 
				catch(FileUploadException ex) {
					log("Error encountered while parsing the request",ex);
				} 
				catch(Exception ex) {
					log("Error encountered while uploading file",ex);
					}
			}
		else {
			out.println("Wrong parameters");
			out.close();
		}
			
	
	  if(uploadSize>0)
			peptides = uploadContent.split("\n");
	  else if(peptide.length()>0) 
				peptides=peptide.split(";");
	  else
	  {
				out.println("Please check the query you enter or the file you uploaded is not null");
				out.close();
		}
	HashMap<String, ArrayList> hitProteins = new HashMap<String, ArrayList>();
	 //only 400 peptides will be processed
	  		maxLength=Math.min(peptides.length, 400);
			String[] organisms = organism.split(";");
			int organismCount = organisms.length;
			int resultCount = 0;
			String organismName = "";
			// get the number of the candidate sequences for all the organisms
			if (organism.toLowerCase().equals("all")) {
				pquery.queryAll(0, 1);
				organismName = "UniProtKB";
				resultCount = pquery.getResult();
			} 
			else {
				pquery.queryByOrganismIDs(organism, 0, 1);
				SolrDocumentList doclist = pquery.getCurrentDocs();
				Iterator<SolrDocument> docItr = doclist.iterator();
				SolrDocument solrDoc;
				resultCount = pquery.getResult();				
				if (organismCount == 1&&resultCount>0) {
					solrDoc = docItr.next();
					features = ((String) solrDoc.get("description")).trim().split("\\^\\|\\^");	
					organismName = features[5];
				}
				else organismName = organism;
				
			}
			//set the file name
			fileName.append(peptides[0]);
			for (int i = 1; i < peptides.length; i++)
				fileName.append("_" + peptides[i]);
			organism_part.append(organisms[0]);
			for (int i = 1; i < organismCount; i++) 
				organism_part.append("_"+organisms[i]);
			StringBuilder outFileName =new StringBuilder();
			outFileName.append(organism_part.toString().substring(0,Math.min(25, organism_part.toString().length())).toUpperCase());
			outFileName.append("_");
			outFileName.append(fileName.toString().substring(0, Math.min(25, fileName.toString().length())).toUpperCase());
			outFileName.append(".txt");
			response.setContentType("text/plain;");
			response.setHeader("Content-disposition", "attachment;filename=" + outFileName.toString());
			Query finalQuery;
			//for each peptide, using the Lucene to dowload the query
			BooleanQuery organismQuery = new BooleanQuery();
			int count = 0;
			if(peptides.length>400) out.println("You have input/uploaded: "+peptides.length+" peptides. Only the first 400 peptides will be processed");
			for (int s = 0; s < maxLength; s++) {
				phraseQuery = new PhraseQuery();
				peptide = peptides[s].replaceAll("[^a-zA-Z]", "");
				// Construct the Phrase query
				if (peptide.length() >= 3) {
					for (int j = 0; j <= peptide.length() - 3; j++) {
						phraseQuery.add(new Term("sequence", peptide.toLowerCase().substring(j, j + 3)));
					}
					if (organism.equals("all")) 
						finalQuery = phraseQuery;
					 else {
						for (int i = 0; i < organismCount; i++) {
							organismQuery.add(new TermQuery(new Term(
									"organismid", organisms[i])),
									BooleanClause.Occur.SHOULD);
						}
						bQuery = new BooleanQuery();
						bQuery.add(organismQuery, BooleanClause.Occur.MUST);
						bQuery.add(phraseQuery, BooleanClause.Occur.MUST);
						finalQuery = bQuery;
					}
					//get the matched sequence number
					collector = TopScoreDocCollector.create(10, true);
					searcher.search(finalQuery, collector);
					totalNumber = collector.getTotalHits();
					//if more than 1 peptides, get a new line
					if (count > 0)
						out.println("");
						//out.println("Searching "+peptide.toUpperCase()+"<br/>");
					// Print out the header
					out.println("##Query: " + peptide.toUpperCase() + "\t");
					out.println("##DB: " + resultCount + " sequence(s) from \""
							+ organismName + "\" (" + version + ")" + "\t");
					out.println("##Matched: " + totalNumber + " sequence(s)");
			
					if (totalNumber > 0) {
						// not using sorter
						 collector = TopScoreDocCollector.create(totalNumber,true);
						 searcher.search(finalQuery, collector);
						 ScoreDoc[] hits = collector.topDocs().scoreDocs;
						/* using sorter
						//Sort sort = new Sort(new SortField("id",
						//		SortField.STRING));
						//TopFieldDocs topdocs = searcher.search(finalQuery,
						//		totalNumber, sort);
						ScoreDoc[] hits = topdocs.scoreDocs; */
						//if (request.getParameter("rows") != null)
						//	printOutNumber = Math.min(Integer.parseInt(request
						//		.getParameter("rows")), totalNumber);
						//else
						//	printOutNumber = Math.min(totalNumber, 20000);
						out.print("#AC\t");
						out.print("ID\t");
						out.print("Protein_Name\t");
						out.print("Length\t");
						out.print("Organism\t");
						//out.print("Proteomic Databases\t");
						//out.print("IEDB\t");
						out.print("Matched_range\t");
						out.println("");
						for (int i = 0; i < totalNumber; i++) {
							doc = searcher.doc(hits[i].doc);
							hitProteins = printTable(doc, response, peptide, hitProteins);
						}

					}
				} 
				//if the peptide length is less than 3, then print the error
				else {
					out.println("##Query: " + peptide.toUpperCase() + "\t");
					out.println("##DB: " + resultCount + " sequences from "
							+ organismName + " (" + version + ")" + "\t");
					out.println("##Total Matched: " + totalNumber);
					out.println("Valid peptide length is at least 3 characerters");
				}
				count++;
			}
		Map hitProteinsCount = new LinkedHashMap();
		Iterator iter = hitProteins.keySet().iterator();
		while(iter.hasNext()) {
			String key = (String)iter.next();
			ArrayList peptideList = (ArrayList)hitProteins.get(key);
			hitProteinsCount.put(key, peptideList.size());	
		}
		hitProteinsCount = sortByValueDesc(hitProteinsCount);	
		out.println("\n\n##Summary of Matched Proteins");
		out.print("#AC\t");
		out.print("ID\t");
		out.print("Protein_Name\t");
		out.print("Organism\t");
		out.print("Organism Taxononmy ID\t");
		out.print("Taxononmic Group\t");
		out.print("Taxononmic Group ID\t");
		out.print("Num. Matched Peptides\n");
		iter = hitProteinsCount.keySet().iterator();
		while(iter.hasNext()) {
			String key = (String)iter.next();
			String[] features = key.trim().split("\\^\\|\\^");
			out.print(features[0]+"\t");
			out.print(features[1]+"\t");
			out.print(features[3]+"\t");
			out.print(features[6]+"\t");
			out.print(features[7]+"\t");
			out.print(features[8]+"\t");
			out.print(features[9]+"\t");
			out.print(hitProteinsCount.get(key)+"\n");
		}
		out.flush();
		out.close();
	}

	public Map<String, Long> sortByValueDesc(Map<String, Long> map) {
                List list = new LinkedList(map.entrySet());
                Collections.sort(list, new Comparator() {
                        //@Override
                        public int compare(Object o1, Object o2) {
                                if(((Map.Entry) (o2)).getValue() == ((Map.Entry) (o1)).getValue()) {
                                        return ((Comparable)((Map.Entry) (o1)).getKey()).compareTo(((Map.Entry)(o2)).getKey());
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


	// print the result as fasta forat
	protected HashMap<String, ArrayList> printTable(Document doc, HttpServletResponse response, String originalQuery, HashMap<String, ArrayList> hitProteins) throws IOException {
		out = response.getWriter();
		ArrayList peptides;
		id = (String) doc.get("id");
		description = (String) doc.get("description");
		if(hitProteins != null) {
			if(hitProteins.get(id+"^|^"+description) == null) {
				peptides = new ArrayList();
				peptides.add(originalQuery);
				hitProteins.put(id+"^|^"+description, peptides);
			}
			else {
				peptides = (ArrayList)hitProteins.get(id+"^|^"+description);
				if(!peptides.contains(originalQuery)) {
					peptides.add(originalQuery);
					hitProteins.put(id+"^|^"+description, peptides);
				}	
			}
		}
		else {
			hitProteins = new HashMap();
			peptides = new ArrayList();
			peptides.add(originalQuery);
			hitProteins.put(id+"^|^"+description, peptides);
		}
		
		sequence = (String) doc.get("sequence");
		features = description.trim().split("\\^\\|\\^");
		proteinID = features[0];
		proteinName = features[2];
		pirsfID = features[3];
		organism = features[5];
		
		int counter = 0;
		out.print(id + "\t");
		out.print(proteinID + "\t");
		out.print(proteinName + "\t");
		out.print(sequence.length() + "\t");
		out.print(organism + "\t");
		/*if (!pirsfID.equals(""))
			out.print("PIR" + pirsfID + "\t");
		else
			out.print(" \t");
		String proteomicDBs = "";
		if(!features[9].equals("X")) {
			proteomicDBs += "NIST, ";
		}	
		if(!features[10].equals("X")) {
			proteomicDBs += "PeptideAtlas, ";
		}	
		if(!features[11].equals("X")) {
			proteomicDBs += "PRIDE, ";
		}
		out.print(proteomicDBs.substring(0, proteomicDBs.length() -2 )+"\t");
		out.print(features[12]+"\t");		
		*/

		for (int i = 0; i <= sequence.length() - originalQuery.length(); i++) {
			if (sequence.substring(i, i + originalQuery.length()).toUpperCase()
					.equals(originalQuery.toUpperCase())) {
				if (counter > 0)
					out.print(";");
				out.print(i + 1);
				out.print("-");
				out.print(i + originalQuery.length());
				out.print(" ");
				if (i < 5
						&& (i + originalQuery.length() + 5) > sequence.length()) {
					out.print(sequence.substring(0, i)
							+ originalQuery.toUpperCase()
							+ sequence.substring(i + originalQuery.length(),
									sequence.length()));
				} else if (i < 5
						&& (i + originalQuery.length() + 5) <= sequence
								.length()) {
					out.print(sequence.substring(0, i)
							+ originalQuery.toUpperCase()
							+ sequence.substring(i + originalQuery.length(), i
									+ originalQuery.length() + 5));
				} else if (i >= 5
						&& (i + originalQuery.length() + 5) > sequence.length()) {
					out.print(sequence.substring(i - 5, i)
							+ originalQuery.toUpperCase()
							+ sequence.substring(i + originalQuery.length(),
									sequence.length()));
				} else if (i >= 5
						&& (i + originalQuery.length() + 5) <= sequence
								.length()) {
					out.print(sequence.substring(i - 5, i)
							+ originalQuery.toUpperCase()
							+ sequence.substring(i + originalQuery.length(), i
									+ originalQuery.length() + 5));
				}
				counter++;
			}
		}
		out.println("");
		out.flush();
		return hitProteins;
	}
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request,response);
	}

}
