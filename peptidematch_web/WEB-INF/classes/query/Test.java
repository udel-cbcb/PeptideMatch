package query;

import org.proteininformationresource.peptidematch.Organism;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import org.apache.lucene.index.IndexReader;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

public class Test {
	public static void main(String[] args) throws IOException{
		String indexPath = "/usr/share/tomcat6/jetty/solr/data/index";       	
		//initia the query 
		Directory indexDir = FSDirectory.open(new File(indexPath));
		IndexSearcher searcher = new IndexSearcher(IndexReader.open(indexDir));	
		FileReader fr=new FileReader(new File("/usr/share/tomcat6/webapps/peptidematch_test/WEB-INF/classes/config/taxToTaxGroup.txt"));
		BufferedReader br=new BufferedReader(fr);
		
		String line="";
		while((line=br.readLine())!=null){
			String[] fields=line.split("\t");
			if(fields.length==4)
			System.out.println(fields[2]);
		}
		
		Organism org = new Organism();		
		
		
	}

}
