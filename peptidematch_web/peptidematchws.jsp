<%@ page trimDirectiveWhitespaces="true" %>
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
	ArrayList peptideList = new ArrayList();
	ArrayList organismList = new ArrayList();
	String format ="tab";
	QueryString qStr = null;
	String contentType = request.getContentType();
   	if (contentType != null && (contentType.indexOf("multipart/form-data") >= 0)) {
		try {
			//out.println("I am here");
			qStr = getMultiPart(request);
			peptideList = qStr.getPeptideList();
			//out.println(peptideList.size());
			organismList = qStr.getOrganismList();
			format = qStr.getFormat();
		}
		catch(ServletException se) {
			se.printStackTrace();
		}
	}
	else {
		qStr = getSinglePart(request);
		peptideList = qStr.getPeptideList();
		organismList = qStr.getOrganismList();
		format = qStr.getFormat();
	}
	if(organismList.size() == 0) {
		organismList.add("all");
	}
	if(format.length() == 0) {
		format = "tab";
	}	
	/*	
	for(int i =0; i < peptideList.size(); i++) {
		out.println("Query: "+peptideList.get(i));
	}
	for(int i =0; i < organismList.size(); i++) {
		out.println("Organism:"+organismList.get(i));
	}
	out.println("Format: "+format);
	*/	
	if(peptideList.size() == 0) {
		out.println("Missing query peptides!");
	}
	else {
		String organismName = "";
		PeptidePhraseQuery pquery = new PeptidePhraseQuery();
		int resultCount = 0;
		int organismCount = organismList.size();
		if(organismList.contains("all")) {
			pquery.queryAll(0, 1);
			organismName = "UniProtKB";
			resultCount = pquery.getResult();	
		}
		else {
			String organism = "";
			String description = "";
			String[] features;
			for(int i=0; i < organismList.size(); i++) {
				organism += organismList.get(i)+";";
			}
			organism = organism.substring(0, organism.length() -1);	
			pquery.queryByOrganismIDs(organism, 0, 1);
                       	SolrDocumentList doclist = pquery.getCurrentDocs();
                      	Iterator<SolrDocument> docItr = doclist.iterator();
                       	SolrDocument solrDoc;
                       	while (docItr.hasNext()) {
                       		solrDoc = docItr.next();
                               	description = (String) solrDoc.get("description");
                               	features = description.trim().split("\\^\\|\\^");
                               	if (organismCount == 1) {
                               		organismName = features[5];
				}
                               	else {
                              		organismName = organism;	
				}
               		}
                       	resultCount = pquery.getResult();
			//out.println(resultCount);
		}
		doSearch(request, response, peptideList, organismList, format, organismName, organismCount, resultCount);	
	}

%>

<%!
	class QueryString {
		ArrayList peptideList = null;
		ArrayList organismList = null;
		String format = null;
		ArrayList getPeptideList() {
			return peptideList;
		}		
		ArrayList getOrganismList() {
			return organismList;
		}
		String getFormat() {
			return format;
		}
		void setPeptideList(ArrayList peptideList) {
			this.peptideList = peptideList;
		}			
		void setOrganismList(ArrayList organismList) {
			this.organismList = organismList;
		}
		void setFormat(String format) {
			this.format = format;
		}			
	}
	
	class MatchedSequence {
		String accession = null;
		String description = null;
		String sequence = null;
		ArrayList matchedPeptides = new ArrayList();
		String getAccession() {
			return accession;
		} 
		String getDescription() {
			return description;
		}
		String getSequence() {
			return sequence;
		}
		ArrayList getMatchedPeptides() {
			return matchedPeptides;
		}
		void setAccession(String accession) {
			this.accession = accession;
		}
		void setDescription(String description) {
			this.description = description;
		}
		void setSequence(String sequence) {
			this.sequence = sequence;
		}
		void addMatchedPeptide(String peptide) {
			if(!matchedPeptides.contains(peptide)) {
				matchedPeptides.add(peptide);
			}
		}	
	}
	private QueryString getSinglePart(HttpServletRequest request) {
		QueryString qStr = new QueryString();
		ArrayList peptideList = new ArrayList();
		ArrayList organismList = new ArrayList();
		String format = "";
		String[] peptides;	
		String[] organisms;	
        	if (request.getParameter("query") != null) {
                	peptides = request.getParameter("query").split(",");
                	for(int i=0; i < peptides.length; i++) {
                        	if(peptideList.indexOf(peptides[i]) == -1) {
                                	peptideList.add(peptides[i].trim());
                        	}
                	}
        	}
        	if (request.getParameter("organism") != null) {
                	//out.println(request.getParameter("organism"));
                	organisms = request.getParameter("organism").split(",");
                	for(int i=0; i < organisms.length; i++) {
                        	if(organismList.indexOf(organisms[i]) == -1) {
                                	organismList.add(organisms[i].trim());
                        	}
                	}
        	}
        	else {
                	organismList.add("all");
        	}

        	if (request.getParameter("format") != null) {
                	format = request.getParameter("format");
        	}
        	else {
                	format = "tab";
        	}
		qStr.setPeptideList(peptideList);
		qStr.setOrganismList(organismList);
		qStr.setFormat(format);
		return qStr;
	}

	private  QueryString getMultiPart(HttpServletRequest request) throws ServletException {
		QueryString qStr = new QueryString();
		try {
			ArrayList peptideList = new ArrayList();
			ArrayList organismList = new ArrayList();
			String format = "";
			//PrintWriter out = response.getWriter();
        		List<FileItem> items = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
        		for (FileItem item : items) {
            			if (item.isFormField()) {
                			// Process regular form field (input type="text|radio|checkbox|etc", select, etc).
                			String fieldName = item.getFieldName();
                			String fieldValue = item.getString();
					//out.println(fieldName+ " | " + fieldValue);
					if(fieldName.equals("query")) {
						String[] peptides = fieldValue.toLowerCase().split(",");
                				for(int i=0; i < peptides.length; i++) {
                        				if(peptideList.indexOf(peptides[i]) == -1) {
                                				peptideList.add(peptides[i]);
                        				}
                				}
					}
					if(fieldName.equals("organism")) {
						String[] organisms = fieldValue.toLowerCase().split(",");
                				for(int i=0; i < organisms.length; i++) {
                        				if(organismList.indexOf(organisms[i]) == -1) {
                                				organismList.add(organisms[i]);
                        				}
                				}
					}
					if(fieldName.equals("format")) {
						format = fieldValue;
					}
            			} else {
                			// Process form file field (input type="file").
                			String fieldName = item.getFieldName();
                			String fileName = FilenameUtils.getName(item.getName());
                			InputStream is = item.getInputStream();
					String fileList = getUploadedFileList(is);
					if(fieldName.equals("queryFile")) {
						String queryList=  fileList;
                				if(queryList.length() > 0) {
                        				String[] peptides = queryList.split(",");
                					for(int i=0; i < peptides.length; i++) {
                        					if(peptideList.indexOf(peptides[i]) == -1) {
                                					peptideList.add(peptides[i]);
                        					}
                					}
                				}
        				}
					if(fieldName.equals("organismFile")) {
						String taxonList=  fileList;
                				if(taxonList.length() > 0) {
                        				String[] organisms = taxonList.split(",");
                					for(int i=0; i < organisms.length; i++) {
                        					if(organismList.indexOf(organisms[i]) == -1) {
                                					organismList.add(organisms[i]);
                        					}
                					}
                				}
        				}
            			}
        		}
			qStr.setPeptideList(peptideList);
			qStr.setOrganismList(organismList);
			qStr.setFormat(format);
    		} 
		catch (FileUploadException e) {
        		throw new ServletException("Cannot parse multipart request.", e);
        		//out.println("Cannot parse multipart request.");
			//e.printStackTrace();
    		}
		catch(IOException ioe) {
			ioe.printStackTrace();
		}
		
		return qStr;
	}
%>
<%!
	private void doSearch(HttpServletRequest request, HttpServletResponse response,  ArrayList<String> peptideList, ArrayList<String> organismList, String format, String organismName, int organismCount, int resultCount) throws ServletException, IOException {
		int totalNumber = 0;
		request.setCharacterEncoding("UTF-8");
                PrintWriter out = response.getWriter();
                // indexpath.properties is in the $tomcat_home/WEB-INF/class/
                InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/index.properties");
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

		String[] peptides = peptideList.toArray(new String[peptideList.size()]);
		String[] organisms = organismList.toArray(new String[organismList.size()]);
		Query finalQuery;
		String resultFileName = "";
		BooleanQuery organismQuery = new BooleanQuery();
		for(int i =0 ; i < peptides.length; i++) {
			resultFileName += peptides[i];
			if(i< peptides.length) {
				resultFileName += "_";
			}
		}
		resultFileName = resultFileName.substring(0, resultFileName.length()-1);
		String peptide = "";
		TreeMap matchedSequenceMap = new TreeMap();
		ArrayList matchPerPeptideList = new ArrayList();	
		for(int i= 0; i < peptides.length; i++) {
			phraseQuery = new PhraseQuery();
			peptide = peptides[i].replaceAll("[^a-zA-Z]", "");	
			if(peptide.length() >= 3) {
				for(int j= 0; j <= peptide.length()-3; j++) {
					//out.println(peptide.toLowerCase().substring(j, j+3));
					phraseQuery.add(new Term("sequence", peptide.toLowerCase().substring(j, j+3)));
				}
				if(organismName.equals("UniProtKB")) {
					finalQuery = phraseQuery;
				}
				else {
					//out.println(peptide);	
					for (int k = 0; k < organismCount; k++) {
						//out.println(organisms[k]);	
						organismQuery.add(new TermQuery(new Term("organismid", organisms[k])), BooleanClause.Occur.SHOULD);
					} 
					bQuery = new BooleanQuery();
					bQuery.add(organismQuery, BooleanClause.Occur.MUST);
					bQuery.add(phraseQuery, BooleanClause.Occur.MUST);
					finalQuery = bQuery;
				}
				collector = TopScoreDocCollector.create(10, true);
				searcher.search(finalQuery, collector);
				totalNumber = collector.getTotalHits();
				if(format.toLowerCase().equals("tab")) {
					response.setContentType("application/txt");
					response.setHeader("Cache-Control", "no-cache");			
					response.setHeader("Content-Disposition", "inline;filename="+resultFileName+".txt");
                			out = response.getWriter();
					printTabDelimitedFile(out, collector, searcher, finalQuery, totalNumber, resultCount, peptide, organismName, version);
				}	
				else if(format.toLowerCase().equals("xls")) {
					response.setContentType("application/vnd.ms-excel");
					response.setHeader("Cache-Control", "no-cache");			
					response.setHeader("Content-Disposition", "inline;filename="+resultFileName+".xls");
                			out = response.getWriter();
					printTabDelimitedFile(out, collector, searcher, finalQuery, totalNumber, resultCount, peptide, organismName, version);
				}
				else if(format.toLowerCase().equals("xml")) {
					String matchPerPeptide = getMatchPerPeptideXML(collector, searcher, finalQuery, totalNumber, resultCount, peptide, organismName, version);
					matchPerPeptideList.add(matchPerPeptide);	
				}
				else if(format.toLowerCase().equals("fasta")) {
					ArrayList<MatchedSequence> matchedSequences = getMatchedSequences(collector, searcher, finalQuery, totalNumber, peptide);
					for(int l = 0; l < matchedSequences.size(); l++) {
						String accession = matchedSequences.get(l).getAccession();
						if(matchedSequenceMap.containsKey(accession)) {
							MatchedSequence ms = (MatchedSequence)matchedSequenceMap.get(accession);
							ms.addMatchedPeptide(peptide);	
							matchedSequenceMap.put(accession, ms);
						}
						else {
							matchedSequenceMap.put(accession, matchedSequences.get(l));
						}
					}	
				}
			}
			else {
				out.println("Valid peptide length is at least 3 characters");
			}
		}
		if(matchPerPeptideList.size() > 0) {
			response.setContentType("application/xml");
			response.setHeader("Cache-Control", "no-cache");			
			response.setHeader("Content-Disposition", "inline;filename="+resultFileName+".xml");
                	out = response.getWriter();
			String xml ="<?xml version=\"1.0\"?>\n";
			xml +="<peptidematch xmlns=\"http://research.bioinformatics.udel.edu/peptidematch\" xmlns:xsi=\"http://www.w3.org/2001/XMSchema-instance\" xsi:schemaLocation=\"http://research.bioinforamtics.udel.edu/peptidematch http://research.bioinforamtics.udel.edu/peptidematch/docs/peptidematch.xsd\">\n";	
			for(int i = 0; i < matchPerPeptideList.size(); i++) {
				xml +="		"+(String)matchPerPeptideList.get(i);		
			}
			xml +="</peptidematch>\n";
			out.println(xml);		
		}
		if(matchedSequenceMap.size() > 0) {
			response.setContentType("application/txt");
			response.setHeader("Cache-Control", "no-cache");			
			response.setHeader("Content-Disposition", "inline;filename="+resultFileName+".fasta");
                	out = response.getWriter();
			Set<String> keys = matchedSequenceMap.keySet();
			for(String key: keys) {
				MatchedSequence msEntry = (MatchedSequence)matchedSequenceMap.get(key);
				String fastaEntry = ">"+msEntry.getAccession()+ " "+msEntry.getDescription()+"^|^";
				ArrayList matchedPeptides = msEntry.getMatchedPeptides();
				for(int i =0; i < matchedPeptides.size(); i++) {
					if(i==0) {
						fastaEntry +=((String)matchedPeptides.get(i)).toUpperCase();
					}
					else {
						fastaEntry +=";"+ ((String)matchedPeptides.get(i)).toUpperCase();
					}
				}
				fastaEntry +="\n"+msEntry.getSequence();
				out.println(fastaEntry);
			} 
		}		
	}
%>
<%! 
	private ArrayList<MatchedSequence> getMatchedSequences(TopScoreDocCollector collector, IndexSearcher searcher, Query finalQuery, int totalNumber, String peptide) {
		ArrayList<MatchedSequence> matchedSequences = new ArrayList<MatchedSequence>();
		try {
			Document doc = new Document();
			if(totalNumber > 0) {
				collector = TopScoreDocCollector.create(totalNumber, true);
				searcher.search(finalQuery, collector);
				ScoreDoc[] hits = collector.topDocs().scoreDocs;
				for(int i=0; i < totalNumber; i++) {
					doc = searcher.doc(hits[i].doc);
                			String id = (String) doc.get("id");
                			String description = (String) doc.get("description");
                			String sequence = (String) doc.get("sequence");
                			String[] features = description.trim().split("\\^\\|\\^");
                			String accession = features[0];
					MatchedSequence matchedSequence = new MatchedSequence();
					matchedSequence.setAccession(accession);
					matchedSequence.setDescription(description);
					matchedSequence.setSequence(sequence);
					matchedSequence.addMatchedPeptide(peptide);
					matchedSequences.add(matchedSequence);		
				}	
			}	
		}
		catch (IOException ioe) {
			ioe.printStackTrace();
		}
		return matchedSequences;
	}
	private String getMatchPerPeptideXML(TopScoreDocCollector collector, IndexSearcher searcher, Query finalQuery, int totalNumber, int resultCount, String peptide, String organismName, String version) {
		String xml = "";
		try {
			Document doc = new Document();
			xml +="<matchPerPeptide>\n";
			xml +="			<query>"+peptide.toUpperCase()+"</query>\n";
			xml +="			<db version=\""+version+"\" totalSeqs=\""+resultCount+"\">"+organismName+"</db>\n";
			xml +="			<matchProteinTotal>"+ totalNumber+"</matchProteinTotal>\n";	
		 	if (totalNumber > 0) {
                 		// not using sorter
                        	collector = TopScoreDocCollector.create(totalNumber, true);
                        	searcher.search(finalQuery, collector);
                        	ScoreDoc[] hits = collector.topDocs().scoreDocs;
			    	xml +="			<matchProteinList>\n";	
                        	for (int i = 0; i < totalNumber; i++) {
                             		doc = searcher.doc(hits[i].doc);
                             		xml += getMatchProteinXML(doc, peptide);
                        	}
				xml+="			</matchProteinList>\n";
                	}
			xml +="		</matchPerPeptide>\n";
		}
		catch (IOException ioe) {
			ioe.printStackTrace();
		}
		return xml;
	}
	
	private void printTabDelimitedFile(PrintWriter out, TopScoreDocCollector collector, IndexSearcher searcher, Query finalQuery, int totalNumber, int resultCount, String peptide, String organismName, String version) {
		try {
			Document doc = new Document();
			out.println("##Query: " + peptide.toUpperCase());
			out.println("##DB: " + resultCount + " sequence(s) from \""+ organismName + "\" ("+version+")"); 
			out.println("##Matched: " + totalNumber + " sequence(s)");
		 	if (totalNumber > 0) {
                 		// not using sorter
                        	collector = TopScoreDocCollector.create(totalNumber, true);
                        	searcher.search(finalQuery, collector);
                        	ScoreDoc[] hits = collector.topDocs().scoreDocs;
                        	/* using sorter
                        	//Sort sort = new Sort(new SortField("id",
                        	//              SortField.STRING));
                        	//TopFieldDocs topdocs = searcher.search(finalQuery,
                        	//              totalNumber, sort);
                        	ScoreDoc[] hits = topdocs.scoreDocs; */
                        	//if (request.getParameter("rows") != null)
                        	//      printOutNumber = Math.min(Integer.parseInt(request
                        	//              .getParameter("rows")), totalNumber);
                        	//else
                        	//      printOutNumber = Math.min(totalNumber, 20000);
                        	out.print("#AC\t");
                        	out.print("ID\t");
                        	out.print("ProteinName\t");
                        	out.print("Length\t");
                        	out.print("PIRSFID\t");
                        	out.print("PIRSFName\t");
                        	out.print("Organism\t");
                        	out.print("OrganismTaxonID\t");
                        	out.print("OrganismTaxonGroup\t");
                        	out.print("OrganismTaxonGroupID\t");
                        	out.print("Matched_range\n");
                        	for (int i = 0; i < totalNumber; i++) {
                             		doc = searcher.doc(hits[i].doc);
                             		printDataTable(doc, out, peptide);
                        	}
                	}
			out.println();
		}
		catch (IOException ioe) {
			ioe.printStackTrace();
		}
	}
%>

<%!
	private String getUploadedFileList(InputStream is) { 
		String fileContent = "";
		BufferedReader br = new BufferedReader(new InputStreamReader(is));
    		try {
        		StringBuilder sb = new StringBuilder();
        		String line = br.readLine();
        		while (line != null) {
            			sb.append(line.toLowerCase());
            			sb.append(",");
            			line = br.readLine();
        		}
        		String list = sb.toString();
			//PrintWriter out = response.getWriter();
			//out.println("?"+list);	
			fileContent =  list.substring(0, list.length() -1);
			//out.println("!"+content);	
		}
		catch(IOException ioe) {
			ioe.printStackTrace();
		}
		return fileContent;	
	}
%>


<%!	
	private String getMatchProteinXML(Document doc, String peptide) throws IOException {
		String id = (String) doc.get("id");
		String description = (String) doc.get("description");
		String sequence = (String) doc.get("sequence");
		String[] features = description.trim().split("\\^\\|\\^");
		String proteinID = features[0];
		String proteinName = features[2];
		String pirsfIDs = features[3];
		String pirsfID="";
		String[] pirsfs = pirsfIDs.split(";");
		for (int i=0; i < pirsfs.length; i++) {
			if(i==0) {
				pirsfID = "PIR"+pirsfs[i].trim();
			}
			else {
				pirsfID +="; PIR"+pirsfs[i].trim();
			}
		}	
		String pirsfNames = features[4];
		String pirsfName="";
		String[] pirsfns = pirsfNames.split(";");
		for (int i=0; i < pirsfns.length; i++) {
			if(i==0) {
				pirsfName = pirsfns[i].trim();
			}
			else {
				pirsfName +="; "+pirsfns[i].trim();
			}
		}	
		String organism = features[5];
		String organismTaxonID = features[6];
		//out.println(description);
		//out.println(organismTaxonID);
		String organismTaxonGroup;
		String organismTaxonGroupID;
		if(features.length == 9) {
			organismTaxonGroup = features[7];
			organismTaxonGroupID = features[8];
		}
		else {
			organismTaxonGroup = "";
			organismTaxonGroupID = "";
		}
		int counter = 0; 	
		String xml = "";
		xml +="			<matchProtein>\n";
		xml +="				<accession>"+id+"</accession>\n";
		xml +="				<id>"+proteinID+"</id>\n";
		xml +="				<name>"+proteinName+"</name>\n";	
		xml +="				<length>"+sequence.length()+"</length>\n";	
		xml +="				<pirsfID>"+pirsfID+"</pirsfID>\n";	
		xml +="				<pirsfName>"+pirsfName+"</pirsfName>\n";	
		xml +="				<organism>"+organism+"</organism>\n";	
		xml +="				<organismTaxonID>"+organismTaxonID+"</organismTaxonID>\n";	
		xml +="				<organismTaxonGroup>"+organismTaxonGroup+"</organismTaxonGroup>\n";	
		xml +="				<organismTaxonGroupID>"+organismTaxonGroupID+"</organismTaxonGroupID>\n";
		xml +="				<sequence>"+sequence+"</sequence>\n";
		xml +="				<matchRangeList>\n";
		for (int i = 0; i <= sequence.length() - peptide.length(); i++) {
			if (sequence.substring(i, i + peptide.length()).toUpperCase().equals(peptide.toUpperCase())) {
						xml +="					<matchRange start=\""+(i+1)+"\" end=\""+(i+peptide.length())+"\"/>\n";
			}
		}
		xml +="				</matchRangeList>\n";
		xml +="			</matchProtein>\n";
		return xml;
	}	
	private void printDataTable(Document doc, PrintWriter out, String originalQuery) throws IOException {
		String id = (String) doc.get("id");
		String description = (String) doc.get("description");
		String sequence = (String) doc.get("sequence");
		String[] features = description.trim().split("\\^\\|\\^");
		String proteinID = features[0];
		String proteinName = features[2];
		String pirsfIDs = features[3];
		String pirsfID="";
		String[] pirsfs = pirsfIDs.split(";");
		for (int i=0; i < pirsfs.length; i++) {
			if(i==0) {
				pirsfID = "PIR"+pirsfs[i].trim();
			}
			else {
				pirsfID +="; PIR"+pirsfs[i].trim();
			}
		}	
		String pirsfNames = features[4];
		String pirsfName="";
		String[] pirsfns = pirsfNames.split(";");
		for (int i=0; i < pirsfns.length; i++) {
			if(i==0) {
				pirsfName = pirsfns[i].trim();
			}
			else {
				pirsfName +="; "+pirsfns[i].trim();
			}
		}
		String organism = features[5];
		String organismTaxonID = features[6];
		String organismTaxonGroup;
		String organismTaxonGroupID;
		if(features.length == 9) {
			organismTaxonGroup = features[7];
			organismTaxonGroupID = features[8];
		}
		else {
			organismTaxonGroup = "";
			organismTaxonGroupID = "";
		}
		int counter = 0;
		out.print(id + "\t");
		out.print(proteinID + "\t");
		out.print(proteinName + "\t");
		out.print(sequence.length() + "\t");
		if (!pirsfID.equals("")) {
			out.print(pirsfID + "\t");
		}
		else {
			out.print(" \t");
		}
		if (!pirsfName.equals("")) {
			out.print(pirsfName + "\t");
		}
		else {
			out.print(" \t");
		}
		out.print(organism + "\t");
		out.print(organismTaxonID + "\t");
		out.print(organismTaxonGroup + "\t");
		out.print(organismTaxonGroupID + "\t");
		for (int i = 0; i <= sequence.length() - originalQuery.length(); i++) {
			if (sequence.substring(i, i + originalQuery.length()).toUpperCase().equals(originalQuery.toUpperCase())) {
				if (counter > 0) {
					out.print(";");
				}
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
		//out.println("\t"+sequence+"\t");
		out.println();
		//out.flush();
	}
%>
