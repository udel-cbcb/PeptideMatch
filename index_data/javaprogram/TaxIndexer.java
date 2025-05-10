package javaprogram;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.util.Version;



public class TaxIndexer {

	public static void main(String[] args) throws Exception {
		String usage =
				"Usage:\tSimpleIndexer [-index dir] [-data dataFile]";
		//program manual 
		if (args.length > 0 && ("-h".equals(args[0]) || "-help".equals(args[0]))) {
			System.out.println(usage);
			System.exit(0);
		}
		else if(args.length != 4) { 
			System.out.println(usage);
			System.exit(0);
		}
		//define indexing parameters
		String index = "index";
		String dataFilePath = null;
	
		//get the paramters from the user input
		for (int i = 0; i < args.length; i++) {
			if ("-index".equals(args[i])) {
				index = args[i+1];
				i++;
			} else if ("-data".equals(args[i])) {
				dataFilePath = args[i+1];
				i++;
			}
		}
		//call the functions to index
		if(dataFilePath != null) {	
			File indexDir = new File(index);
			File dataFile = new File(dataFilePath);			
			index(indexDir, dataFile);
		}
		else{
			System.out.println("No Index");
			System.exit(0);
		}
	}

	//main entry of the index
	public static void index(File indexDir, File dataFile) throws IOException {
		// if the directory exists, then delete the directory
		//check the index data
		if (!dataFile.exists()) {
			throw new IOException(dataFile + " does not exist");
		}
		long begin = System.currentTimeMillis(); 
		try {
			// call the NGramAnalyzer
			StandardAnalyzer analyzer = new StandardAnalyzer(Version.LUCENE_CURRENT);
			//	
			IndexWriter writer = new IndexWriter(FSDirectory.open(indexDir), analyzer, false, IndexWriter.MaxFieldLength.UNLIMITED);
			System.out.println("Indexing to directory '" +indexDir+ "'...");
			System.out.println("Indexing '" +dataFile+ "'...");
			indexDataFile(writer, dataFile);
			System.out.println("Optimizing...");
			writer.optimize();
			writer.close();
			//      System.out.println(end.getTime() - start.getTime() + " total milliseconds");
			long elapsed = System.currentTimeMillis() - begin; 
			DateFormat df = new SimpleDateFormat("HH 'hours', mm 'mins,' ss 'seconds'"); 
			df.setTimeZone(TimeZone.getTimeZone("GMT+0")); 
			System.out.println(df.format(new Date(elapsed))); 
		} catch (IOException e) {
			System.out.println(" caught a " + e.getClass() +
					"\n with message: " + e.getMessage());
		}
	}


	public static boolean deleteDir(File dir) {
		if (dir.isDirectory()) {
			String[] children = dir.list();
			for (int i=0; i<children.length; i++) {
				boolean success = deleteDir(new File(dir, children[i]));
				if (!success) {
					return false;
				}
			}
		}
		// The directory is now empty so delete it
		return dir.delete();
	}
//indexing entry
	protected static void indexDataFile(IndexWriter writer, File dataFile) throws IOException {
		FileReader fr = new FileReader(dataFile);
		BufferedReader br = new BufferedReader(fr);
		String eachLine = br.readLine();
		while ((eachLine=br.readLine()) != null) {
					addDoc(writer, eachLine);
		}
	}
//add the documents
	protected static void addDoc(IndexWriter w, String field, String value) throws IOException {
		Document doc = new Document();
		doc.add(new Field(field, value, Field.Store.YES, Field.Index.ANALYZED));
		w.addDocument(doc);
	}
// add the documents. the main function
	protected static void addDoc(IndexWriter w, String value) throws IOException {
		/* delimit */
		String fieldDelimiter=" ";
		Document doc = new Document();
					String[] fields=value.split(fieldDelimiter);
					String child_ID = fields[0];
				//	System.out.println(child_ID);
					String parent_ID=fields[1];
				
				doc.add(new Field("child_id", child_ID, Field.Store.YES, Field.Index.NOT_ANALYZED));
				doc.add(new Field("parent_id",parent_ID,Field.Store.YES,Field.Index.NOT_ANALYZED));
	            w.addDocument(doc);
			}
	}





