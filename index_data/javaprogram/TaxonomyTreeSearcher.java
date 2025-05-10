package javaprogram;

import java.io.File;
import java.io.IOException;

import org.apache.lucene.document.Document;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.Term;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.*;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.TopScoreDocCollector;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

public class TaxonomyTreeSearcher {
	public static void main(String[] args) throws IOException{
		if(args.length<2){
			System.out.println("Usage:TaxonomyTreeSearcher -dir index -lineage lineage -query query");
			System.exit(0);
		}
		String indexPath="";
		String queryid="";
		String lineage="";
		for(int i=0;i<args.length;i++){
    	if(args[i].equals("-dir"))
    		indexPath=args[++i];
    	else if(args[i].equals("-query"))
    		queryid=args[++i];
    	else if(args[i].equals("-lineage"))
    		lineage=args[++i];
		}
	 String[] lineages = lineage.split(",");	
	 String peptide = queryid;		
         //initial the query
	 Query finalQuery;
         BooleanQuery bQuery = new BooleanQuery();
         PhraseQuery phraseQuery = new PhraseQuery();
	 BooleanQuery lineageQuery = new BooleanQuery();

         // open the index
	 Directory indexDir = FSDirectory.open(new File(indexPath));
         IndexSearcher searcher = new IndexSearcher(IndexReader.open(indexDir));
         TopScoreDocCollector collector;
         
	 peptide = peptide.replaceAll("[^a-zA-Z]", "");
         if(peptide.length() >= 3) {
         	for(int j= 0; j <= peptide.length()-3; j++) {
                //out.println(peptide.toLowerCase().substring(j, j+3));
                	phraseQuery.add(new Term("sequence", peptide.toLowerCase().substring(j, j+3)));
                }
                if(lineage.equals("all")) {
                        finalQuery = phraseQuery;
                }
                else {
                        //out.println(peptide); 
                        for (int k = 0; k < lineages.length; k++) {
                         	System.out.println(lineages[k]); 
                         	//lineageQuery.add(new TermQuery(new Term("lineage", lineages[k])), BooleanClause.Occur.SHOULD);
                         	lineageQuery.add(new TermQuery(new Term("lineage", lineages[k])), BooleanClause.Occur.SHOULD);
                         	//lineageQuery.add(new TermQuery(new Term("organismid", lineages[k])), BooleanClause.Occur.SHOULD);
                        }
			System.out.println(lineageQuery);
                        bQuery = new BooleanQuery();
                        bQuery.add(lineageQuery, BooleanClause.Occur.MUST);
                        bQuery.add(phraseQuery, BooleanClause.Occur.MUST);
                        finalQuery = bQuery;
			System.out.println(finalQuery);
                }
                collector = TopScoreDocCollector.create(10, true);
                searcher.search(finalQuery, collector);
                int totalNumber = collector.getTotalHits();
		System.out.println(totalNumber);
		if(totalNumber > 0) {
		collector = TopScoreDocCollector.create(totalNumber, true);
                searcher.search(finalQuery, collector);
                ScoreDoc[] hits = collector.topDocs().scoreDocs;
		String id;
		Document doc;
		String description;
		String sequence;
		String hitlineage;
		String[] features;
		int totalCount = 0;
		for (int i = 0; i < totalNumber; i++) {
                	doc = searcher.doc(hits[i].doc);
			id = (String) doc.get("id");
                	description = (String) doc.get("description");
                	sequence = (String) doc.get("sequence");
                	hitlineage = (String) doc.get("lineage");
			System.out.println(">"+description);
			System.out.println(hitlineage);
			System.out.println(sequence);
        	}
		}
	}
	else {
		System.out.println("The query peptide must be at least 3 characters");
	}
	}	  
}
