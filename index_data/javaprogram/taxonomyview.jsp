	 InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream("config/index.properties");
         Properties properties = new Properties();
         properties.load(inputStream);
         // get the value of the property
         String indexPath = properties.getProperty("indexpath");
         String version = properties.getProperty("version");
         //initial the query
	 Query finalQuery;
         BooleanQuery bQuery = new BooleanQuery();
         PhraseQuery phraseQuery = new PhraseQuery();
	 BooleanQuery organismQuery = new BooleanQuery();

         // open the index
         Directory indexDir = FSDirectory.open(new File(indexPath));
         IndexSearcher searcher = new IndexSearcher(IndexReader.open(indexDir));
         TopScoreDocCollector collector;
	 HashMap organismHitMap = new HashMap();
	 HashMap organismHitNameMap = new HashMap();
	 HashMap organismCountLineageMap = new HashMap();
         
	 peptide = peptide.replaceAll("[^a-zA-Z]", "");
         if(peptide.length() >= 3) {
         	for(int j= 0; j <= peptide.length()-3; j++) {
                //out.println(peptide.toLowerCase().substring(j, j+3));
                	phraseQuery.add(new Term("sequence", peptide.toLowerCase().substring(j, j+3)));
                }
                if(organism_id.equals("all")) {
                        finalQuery = phraseQuery;
                }
                else {
                        //out.println(peptide); 
                        for (int k = 0; k < organisms.length; k++) {
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
                int totalNumber = collector.getTotalHits();
		//out.println(totalNumber);
		collector = TopScoreDocCollector.create(totalNumber, true);
                searcher.search(finalQuery, collector);
                ScoreDoc[] hits = collector.topDocs().scoreDocs;
		String id;
		Document doc;
		String description;
		String[] features;
		int totalCount = 0;
		for (int i = 0; i < totalNumber; i++) {
                	doc = searcher.doc(hits[i].doc);
			id = (String) doc.get("id");
                	description = (String) doc.get("description");
			features = description.trim().split("\\^\\|\\^");
			//if(features[5].indexOf("thuringiensis") > 0) {
				//out.println(features[5]+"<br>");
			//}
			if(organismHitMap.get(features[6]) != null) {	
				Integer sum = (Integer)organismHitMap.get(features[6]);
				organismHitMap.put(features[6], new Integer(sum.intValue()+1));
				organismHitNameMap.put(features[6], features[5]);
				//out.println(features[6]+ ": " + (sum+1)+"<br>");
				//totalCount++;
			}
			else {
				organismHitMap.put(features[6], new Integer(1));
				organismHitNameMap.put(features[6], features[5]);
				//out.println(features[6]+ ": " + "1" +"<br>");
				totalCount++;
			}
        	}
		//out.println(totalCount);
		out.println(buildTaxonomyTree(organismHitMap, organismHitNameMap, out));	 
	}
	else {
		out.println("The query peptide must be at least 3 characters");
	}
