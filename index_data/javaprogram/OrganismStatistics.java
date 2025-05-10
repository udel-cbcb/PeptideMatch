package javaprogram;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.net.MalformedURLException;
import java.util.Arrays;
import java.util.HashMap;

import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.CommonsHttpSolrServer;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocumentList;

public class OrganismStatistics{
	public static void main(String[] args) throws IOException, SolrServerException{
	//check and get the paramters
		if(args.length<2){
			System.out.println("Usage:Java OrgnismStatistics orgnismfile updateorginismfile");
			System.exit(0);
		}
		String organismFile=args[0];
		String updateOrganismFile=args[1];
	// setup the solr server
		String solrUrl = "http://localhost:8985/solr";
		QueryResponse response;
		SolrDocumentList docs=new SolrDocumentList();
		CommonsHttpSolrServer solrServer=new CommonsHttpSolrServer(solrUrl);
		SolrQuery solrQuery;	
		//read the organism file
		FileReader fr=null;
		try {
			fr = new FileReader(organismFile);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		BufferedReader br = new BufferedReader(fr);	
		HashMap<String,String> table=new HashMap();	
		String [] fields;
		String line;
		String query;
		int result=0;
		int count =0;
		//read each line of the organism file
		//query the number of each orgianism 
		//put the result into the table
		while((line=br.readLine())!=null){
			if(count==0){
				count++;
				continue;
			}else{
			fields=line.split("\t");
			solrQuery=new SolrQuery();
			query="organismID:"+fields[0];
			solrQuery.setParam("q",query);
			solrQuery.setParam("q.op","AND");
			solrQuery.setStart(0);
			solrQuery.setRows(1);
			response=solrServer.query(solrQuery);
			docs= response.getResults();
			result=(int) docs.getNumFound();			
			table.put(fields[2], line+"\t"+result);
		   
			}
			}
		br.close();
		fr.close();
		//sort the table
		FileWriter fw=new FileWriter(updateOrganismFile);
		BufferedWriter bw = new BufferedWriter(fw);
		Object[] key = table.keySet().toArray();
		Arrays.sort(key);  
		for(int i = 0;i<key.length;i++){   
		line=table.get(key[i]);   
		bw.write(line+"\n");
		}		
        bw.flush();    
        bw.close();   
        fw.close();		
		}

}
