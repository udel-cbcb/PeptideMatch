package query;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Properties;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.Term;
import org.apache.lucene.search.BooleanClause.Occur;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.PhraseQuery;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.TopScoreDocCollector;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

public class TaxonCount {

	private static final long serialVersionUID = 1L;
	private PhraseQuery phraseQuery;
	private TopScoreDocCollector collector;
	private String peptide = "";
	private int totalNumber = 0;
	private Document doc = new Document();
	private IndexSearcher searcher;

	public TaxonCount() throws IOException {
		// indexpath.properties is under $tomcat_home/WEB-INF/class
		InputStream inputStream = this.getClass().getClassLoader()
				.getResourceAsStream("config/index.properties");
		Properties properties = new Properties();
		// load the inputStream using the Properties
		properties.load(inputStream);
		// get the value of the property
		String indexPath = properties.getProperty("indexpath");
		// initia the query
		Directory indexDir = FSDirectory.open(new File(indexPath));
		searcher = new IndexSearcher(IndexReader.open(indexDir));
	}

	public HashMap<String, Integer> getDistribution(String taxongroup_id,
			String organism_id, String peptide) throws IOException {
		HashMap<String, Integer> hs = new HashMap<String, Integer>();
		phraseQuery = new PhraseQuery();
		BooleanQuery booleanQuery;
		TermQuery taxongroupQuery;
		TermQuery organismQuery;

		// Construct the Phrase query
		String[] organisms = organism_id.split(";");
		if (peptide.length() >= 3) {
			for (int j = 0; j <= peptide.length() - 3; j++) {
				phraseQuery.add(new Term("sequence", peptide.toLowerCase()
						.substring(j, j + 3)));
			}

			if (organism_id.toLowerCase().equals("all")) {
				InputStream inputStream = this.getClass().getClassLoader()
						.getResourceAsStream("config/taxToTaxGroup.txt");
				BufferedReader br = new BufferedReader(new InputStreamReader(
						inputStream));
				String eachLine;
				while ((eachLine = br.readLine()) != null) {
					String[] fields = eachLine.split("\t");
					if (fields.length == 4) {
						// String groupNmae=fields[1];
						if (fields[2].trim().equals(taxongroup_id)) {
							booleanQuery = new BooleanQuery();
							taxongroupQuery = new TermQuery(new Term(
									"taxongroupid", taxongroup_id));
							organismQuery = new TermQuery(new Term(
									"organismid", fields[0].trim()));
							booleanQuery.add(taxongroupQuery, Occur.MUST);
							booleanQuery.add(organismQuery, Occur.MUST);
							booleanQuery.add(phraseQuery, Occur.MUST);
							collector = TopScoreDocCollector.create(10, true);
							searcher.search(booleanQuery, collector);
							totalNumber = collector.getTotalHits();
							if (totalNumber > 0)
								hs.put(fields[0].trim(), totalNumber);
						}
					}
				}
			}
				/*
				 * booleanQuery=new BooleanQuery(); taxongroupQuery=new
				 * TermQuery(new Term("taxongroupid",taxongroup_id));
				 * booleanQuery.add(taxongroupQuery, Occur.MUST);
				 * booleanQuery.add(phraseQuery, Occur.MUST); collector =
				 * TopScoreDocCollector.create(10, true);
				 * searcher.search(booleanQuery, collector);
				 * totalNumber=collector.getTotalHits(); if(totalNumber>0){
				 * collector = TopScoreDocCollector.create(totalNumber, true);
				 * searcher.search(phraseQuery, collector); ScoreDoc[]
				 * hits=collector.topDocs().scoreDocs; for(int
				 * i=0;i<totalNumber;i++){ doc = searcher.doc(hits[i].doc);
				 * organism_id=(String)doc.get("organismid");
				 * if(hs.containsKey(organism_id)) hs.put(organism_id,
				 * hs.get(organism_id)+1); else hs.put(organism_id,1);} }
				 */
			 else {
				for (int i = 0; i < organisms.length; i++) {
					booleanQuery = new BooleanQuery();
					taxongroupQuery = new TermQuery(new Term("taxongroupid",
							taxongroup_id));
					organismQuery = new TermQuery(new Term("organismid",
							organisms[i]));
					booleanQuery.add(taxongroupQuery, Occur.MUST);
					booleanQuery.add(organismQuery, Occur.MUST);
					booleanQuery.add(phraseQuery, Occur.MUST);
					System.out.println(booleanQuery);
					collector = TopScoreDocCollector.create(10, true);
					searcher.search(booleanQuery, collector);
					totalNumber = collector.getTotalHits();
					if (totalNumber > 0)
						hs.put(organisms[i], totalNumber);
				}
			}
		}
		return hs;

	}
}
