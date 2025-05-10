package javaprogram;

import java.io.File;
import java.io.IOException;

import org.apache.lucene.document.Document;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.Term;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.TopScoreDocCollector;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

public class TaxSearcher {
	public static void main(String[] args) throws IOException{
		if(args.length<2){
			System.out.println("Usage:TaxSearcher -dir index -field field -query query");
			System.exit(0);
		}
		String indexPath="";
		String queryid="";
		String field="";
		for(int i=0;i<args.length;i++){
    	if(args[i].equals("-dir"))
    		indexPath=args[++i];
    	else if(args[i].equals("-query"))
    		queryid=args[++i];
    	else if(args[i].equals("-field"))
    		field=args[++i];
		}
	
		Directory indexDir = FSDirectory.open(new File(indexPath));
		Document doc=new Document();
		IndexSearcher searcher = new IndexSearcher(IndexReader.open(indexDir));
	  TermQuery tQuery=new TermQuery(new Term(field,queryid));
	  TopScoreDocCollector collector = TopScoreDocCollector.create(10, true);	
	  searcher.search(tQuery, collector);
	  ScoreDoc[] hits = collector.topDocs().scoreDocs;  
	 int numberFound=collector.getTotalHits();
	 if(numberFound>0){
		 int number=Math.min(10, numberFound);
		  for(int i=0;i<number;i++){
				 doc = searcher.doc(hits[i].doc);
				 if(field.equals("child_id"))
				 System.out.println(doc.get("child_id")+":"+doc.get("parent_id"));
				 else 
				System.out.println(doc.get("id")+":"+doc.get("organismid")+":"+doc.get("sequence"));
				 }
	  }
	  
	}

}
