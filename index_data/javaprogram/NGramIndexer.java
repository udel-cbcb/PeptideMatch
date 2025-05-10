package javaprogram;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.text.DecimalFormat;
import java.util.Date;
import java.util.TimeZone;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.util.Version;
import org.apache.lucene.analysis.PerFieldAnalyzerWrapper;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.NumericField;

public class NGramIndexer {

	public static void main(String[] args) throws Exception {
		String usage =
				"Usage:\tNGramIndexer [-index dir] [-gram lowerGram UpperGram] [-data dataFile]";
		//program manual 
		if (args.length > 0 && ("-h".equals(args[0]) || "-help".equals(args[0]))) {
			System.out.println(usage);
			System.exit(0);
		}
		else if(args.length != 7) { 
			System.out.println(usage);
			System.exit(0);
		}
		//define indexing parameters
		String index = "index";
		String dataFilePath = null;
		int lowerGram=3;
		int upperGram=3;
		//get the paramters from the user input
		for (int i = 0; i < args.length; i++) {
			if ("-index".equals(args[i])) {
				index = args[i+1];
				i++;
			} else if ("-data".equals(args[i])) {
				dataFilePath = args[i+1];
				i++;
			}
			else if("-gram".equals(args[i])){
				lowerGram=Integer.parseInt(args[++i]);
				upperGram=Integer.parseInt(args[++i]);
			} 
		}
		//call the functions to index
		if(dataFilePath != null) {	
			File indexDir = new File(index);
			File dataFile = new File(dataFilePath);			
			index(indexDir, dataFile,lowerGram,upperGram);
		}
		else{
			System.out.println("No Index");
			System.exit(0);
		}
	}

	//main entry of the index
	public static void index(File indexDir, File dataFile, int lowerGram,int upperGram) throws IOException {
		// if the directory exists, then delete the directory
		if (indexDir.exists()) {
			deleteDir(indexDir);
		}
		//check the index data
		if (!dataFile.exists()) {
			throw new IOException(dataFile + " does not exist");
		}
		long begin = System.currentTimeMillis(); 
		try {
			// call the NGramAnalyzer
			NGramAnalyzer ngramAnalyzer = new NGramAnalyzer(lowerGram,upperGram);
			PerFieldAnalyzerWrapper analyzer = new PerFieldAnalyzerWrapper(ngramAnalyzer);
			analyzer.addAnalyzer("fullLineage", new StandardAnalyzer(Version.LUCENE_CURRENT));
			analyzer.addAnalyzer("shortLineage", new StandardAnalyzer(Version.LUCENE_CURRENT));
			//IndexWriter writer = new IndexWriter(FSDirectory.open(indexDir), ngramAnalyzer, true, IndexWriter.MaxFieldLength.UNLIMITED);
			IndexWriter writer = new IndexWriter(FSDirectory.open(indexDir), analyzer, true, IndexWriter.MaxFieldLength.UNLIMITED);
			writer.setMaxFieldLength(Integer.MAX_VALUE);
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
		String record = "";
		while (eachLine != null) {
			if(eachLine.startsWith(">")) {
				if(record.length() > 0) {
					addDoc(writer, record);
					record = eachLine+"\n";
				}
				else {
					record += eachLine+"\n";
				}
			}
			else {
				record += eachLine;
			}
			eachLine = br.readLine();
		}
		if(record.length() > 0) {
			record += "\n";
			//addDoc(writer, "record", record);
			addDoc(writer, record);
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
		String delimiter = "\n";
		String fieldDelimiter=" ";
		Document doc = new Document();
		String[] lines = value.split(delimiter);
		String line = "";
		String proteinID ="";
		String proteinName = "";
		String organismName= "";
		String organismID="";
		String taxongroupID="";
		String taxongroupName="";
		String nist = "";
		String pride = "";
		String atlas = "";
		String iedb = "";
		String fullLineage = "";
		String shortLineage = "";
		String uniref100 = "";
		String originalSeq = "";
		String LToISeq = "";
		String sptr = "";
		String isoform = "";

		for(int i = 0; i < lines.length; i++) {
			line = lines[i].trim();
			if(line.length() > 0) {
				if(line.startsWith(">")) {
					String[] fields=line.split(fieldDelimiter);
					String ac = fields[0].substring(1);
					System.out.println(ac);
					if(ac.contains("-")) {
						isoform = "Y";
					}
					else {
						isoform = "N";
					}	
					String description=line.substring(ac.length()+2, line.length());
					//System.out.println("ID: |"+id+"|");
					//doc.add(new Field("ID", id, Field.Store.YES, Field.Index.NOT_ANALYZED));
					String[] features=description.trim().split("\\^\\|\\^");
					//>A0FGY6 A0FGY6_9ARCH^|^^|^Methyl coenzyme M reductase (Fragment)^|^^|^^|^uncultured archaeon^|^115547^|^Archaea/..^|^2157^|^X^|^X^|^X^|^^|^1, 131567, 2157, 48510, 115547^|^1, 131567, 2157, 115547^|^UniRef100_A0FGY6	
					proteinID = features[0];
					String[] ids = proteinID.split("_");
					if(ids[0].length() <6) {
						sptr = "sp";
					}
					else {
						sptr = "tr";
					}
					proteinName = features[2];
					organismName= features[5];	
					organismID=features[6];
					if(features[7].length() > 0) {
					 	taxongroupName=features[7];
					}
					else {
					 	taxongroupName="other";
					}	
					if(features[8].length() > 0) {
					 	taxongroupID=features[8];
					}
					else {
					 	taxongroupID="null";
					}
					if(features[9].length() > 0&&!features[9].equals("Z")) {
					 	nist =features[9];
					 	//nist ="Y";
					}
					else {
					 	nist="Z";
					}
					if(features[10].length() > 0 && !features[10].equals("Z")) {
					 	//atlas =features[10];
					 	atlas ="Y";
					}
					else {
					 	atlas="Z";
					}
					if(features[11].length() > 0 && !features[11].equals("Z")) {
					 	//pride =features[11];
					 	pride ="Y";
					}
					else {
					 	pride="Z";
					}
					if(features[12].length() > 0 && !features[12].equals("Z")) {
					 	iedb =features[12];
					 	//iedb ="Y";
					}
					else {
					 	iedb="Z";
					}
					fullLineage = features[13];
					shortLineage = features[14];
					if(features.length == 16 && features[15].length() >0) {		
						uniref100 = features[15];
					}
					if(uniref100.length() > 0) {
						uniref100 = "Y";
					}
					else {
						uniref100 = "";
					}
					if(organismID.equals("")) {
							organismID="N/A";
					}
					doc.add(new Field("ac", ac, Field.Store.YES, Field.Index.NOT_ANALYZED));
					doc.add(new Field("proteinID", proteinID, Field.Store.YES, Field.Index.NOT_ANALYZED));
					doc.add(new Field("proteinName",proteinName,Field.Store.YES,Field.Index.NOT_ANALYZED));
					doc.add(new Field("organismName",organismName,Field.Store.YES,Field.Index.NOT_ANALYZED));
					doc.add(new Field("organismID",organismID,Field.Store.YES,Field.Index.NOT_ANALYZED));
					doc.add(new Field("taxongroupName",taxongroupName,Field.Store.YES,Field.Index.NOT_ANALYZED));
					doc.add(new Field("taxongroupID",taxongroupID,Field.Store.YES,Field.Index.NOT_ANALYZED));
					doc.add(new Field("nist", nist, Field.Store.YES,Field.Index.NOT_ANALYZED));
					doc.add(new Field("peptideAtlas", atlas, Field.Store.YES,Field.Index.NOT_ANALYZED));
					doc.add(new Field("pride", pride, Field.Store.YES,Field.Index.NOT_ANALYZED));
					doc.add(new Field("iedb", iedb, Field.Store.YES,Field.Index.NOT_ANALYZED));
					doc.add(new Field("fullLineage",fullLineage,Field.Store.YES,Field.Index.ANALYZED));
					doc.add(new Field("shortLineage",shortLineage,Field.Store.YES,Field.Index.ANALYZED));
					doc.add(new Field("uniref100",uniref100,Field.Store.YES,Field.Index.NOT_ANALYZED));
					doc.add(new Field("sptr",sptr,Field.Store.YES,Field.Index.NOT_ANALYZED));
					doc.add(new Field("isoform",isoform,Field.Store.YES,Field.Index.NOT_ANALYZED));
				}
				else {
					doc.add(new Field("originalSeq", line.toUpperCase(), Field.Store.YES, Field.Index.ANALYZED));
					//if(line.toUpperCase().indexOf("L") != -1) {
						doc.add(new Field("lToiSeq", line.toUpperCase().replaceAll("L", "I"), Field.Store.NO, Field.Index.ANALYZED));
					//}
					doc.add(new Field("length", NumberUtils.pad(line.length()), Field.Store.YES, Field.Index.NOT_ANALYZED));
				}
			}
		}
		if(!nist.equals("Z")) {
			doc.setBoost(10.0f);		
		}
		else if(!atlas.equals("Z")) {
			doc.setBoost(9.0f);		
		}
		else if(!pride.equals("Z")) {
			doc.setBoost(8.0f);		
		}
		else if(!iedb.equals("Z")) {
			doc.setBoost(7.0f);		
		}
		w.addDocument(doc);
	}

}



