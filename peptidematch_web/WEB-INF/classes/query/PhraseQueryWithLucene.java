package query;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.net.MalformedURLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.ArrayList;
import java.util.List;

//import javaprogram.NGramAnalyzer;

import org.apache.lucene.analysis.SimpleAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.Term;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.NGramPhraseQuery;
import org.apache.lucene.search.PhraseQuery;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopScoreDocCollector;
import org.apache.lucene.search.TotalHitCountCollector;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.util.Version;



public class PhraseQueryWithLucene {

	private FileReader fileReader;;
	private String index="index3";
	private Directory indexDir ;
	private IndexSearcher searcher;
	//private PhraseQuery phraseQuery;
	private Query optimizedQuery;
	private BooleanQuery boolQuery;
	private TopScoreDocCollector collector;
	private int totalHist;
	private ArrayList<Document> documents;
	private NGramPhraseQuery phraseQueryOptimizer;
	
	public static void main(String[] args) throws IOException, NumberFormatException, org.apache.lucene.queryParser.ParseException{
		if(args.length<2){
			System.out.println("Usage: PhraseQueryWithLucene start rows");
			System.exit(0);
		}
		String start=args[0];
		String rows=args[1];
		PhraseQueryWithLucene phraseQuery=new PhraseQueryWithLucene();
		phraseQuery.queryByPeptide("AAAAAAAAAA",Integer.parseInt(start),Integer.parseInt(rows));
		Document doc;
		ArrayList docs=phraseQuery.getDoc();
		String id="";
		
		for(int i=0;i<docs.size();i++){
			doc=(Document) docs.get(i);
			System.out.println(doc.get("id"));
		}
		
	}

	public PhraseQueryWithLucene() throws IOException{
		indexDir= FSDirectory.open(new File(index));
		searcher = new IndexSearcher(IndexReader.open(indexDir,true));
	} 

	//query by the peptide which is no more than 5 characters
	public void queryByPeptide(String query,int start,int rows) throws CorruptIndexException, IOException, org.apache.lucene.queryParser.ParseException{
		
		documents=new ArrayList();
		//phraseQuery=new PhraseQuery();
		phraseQueryOptimizer=new NGramPhraseQuery(3);
		
		for(int j=0;j<=query.length()-3;j++){
			phraseQueryOptimizer.add(new Term("sequence",query.substring(j,j+3).toLowerCase()));
		}
	
		optimizedQuery=phraseQueryOptimizer.rewrite(null);
		System.out.println(optimizedQuery);
		TotalHitCountCollector	total = new TotalHitCountCollector();	
		try {
			searcher.search(optimizedQuery,total);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
		int totalHits=	total.getTotalHits();
		System.out.println(totalHits);
		if(totalHits>0){
		collector = TopScoreDocCollector.create(totalHits, true);	
		try {
			searcher.search(optimizedQuery,collector);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		ScoreDoc[] hits=	collector.topDocs().scoreDocs;
		int count = Math.min(totalHits - start, rows);
		System.out.println(count);
		for (int i = start; i < (start+count); i++) {	 
			System.out.println(i);
			int docId = hits[i].doc;
			documents.add(searcher.doc(docId));
		}
		}
		else documents=null;
	}

	public void queryByPeptideWithOrganism(String query,String organism_id,int rows,int start){

	}
	//query by peptide by the ID sets
	public void queryByIDSets(ArrayList IDSets,int rowsPerPage){

	}  
	public void queryByOrganismID(String organismID){

	} 
	public void queryCatalogByOrganismID(String organismID){

	} 

	//store the results from the peptide search
	public int getResult(){
		return this.totalHist;
	}


	public ArrayList<Document> getDoc(){
		return	documents;
	}
}

