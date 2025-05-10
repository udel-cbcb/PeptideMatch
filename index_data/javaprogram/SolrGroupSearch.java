package javaprogram;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.net.MalformedURLException;
import java.util.Arrays;
import java.util.List;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.*;

import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.CommonsHttpSolrServer;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocumentList;
import org.apache.solr.common.params.*;
import org.apache.solr.client.solrj.response.GroupResponse;
import org.apache.solr.client.solrj.response.GroupCommand;
import org.apache.solr.client.solrj.response.Group;

public class SolrGroupSearch{
	public static void main(String[] args) throws IOException, SolrServerException{
	//check and get the paramters
		if(args.length<1){
			System.out.println("Usage:Java SolrGroupSearch peptide");
			System.exit(0);
		}
		String query=args[0];
	// setup the solr server
		String solrUrl = "http://localhost:8985/solr";
		QueryResponse response;
		SolrDocumentList docs=new SolrDocumentList();
		SolrDocumentList gdocs=new SolrDocumentList();
		CommonsHttpSolrServer solrServer=new CommonsHttpSolrServer(solrUrl);
		SolrQuery solrQuery;	
		int result=0;
		int count =0;
		String queryField = "sequence:";
                // Construct the Phrase query
                String phraseQuery = queryField + "\"" + query.substring(0, 3).toLowerCase();
                for (int i = 1; i <= query.length() - 3; i++) {
                        phraseQuery = phraseQuery + "+" + query.substring(i, i + 3).toLowerCase();
                }
                phraseQuery += "\"";
                // Construct the solr query
                solrQuery = new SolrQuery();
                docs = new SolrDocumentList();
                solrQuery.setParam("q", phraseQuery);
                solrQuery.setParam("q.op", "AND");
                solrQuery.setParam("sort", "id asc");
		solrQuery.set(GroupParams.GROUP, true);
 		solrQuery.set(GroupParams.GROUP_MAIN, false);
 		solrQuery.setRows(Integer.MAX_VALUE);
		solrQuery.set(GroupParams.GROUP_SORT);
 		solrQuery.set(GroupParams.GROUP_FIELD, "organismid");
 		solrQuery.set(GroupParams.GROUP_TOTAL_COUNT, "true");
                System.out.println(solrQuery);
		HashMap groupCount = new HashMap();
                try {
                        response = solrServer.query(solrQuery);
			GroupResponse groupResponse = response.getGroupResponse();
			if(groupResponse != null) {
				List groupResponseValues = groupResponse.getValues();
				for(int i=0; i < groupResponseValues.size(); i++) {
					GroupCommand gcmd = (GroupCommand)groupResponseValues.get(i);	
					System.out.print(gcmd.getName()	+" "+gcmd.getMatches() + " "+gcmd.getNGroups()+"\n");
					List groups = gcmd.getValues();
					for(int j=0; j <groups.size(); j++) {
						Group group = (Group)groups.get(j);	
						gdocs = group.getResult();
						//System.out.println("Group: "+group.getGroupValue()+" "+gdocs.getNumFound());		
						groupCount.put(group.getGroupValue(), gdocs.getNumFound());
					}
					System.out.println();
					Map<String, Long> sorted = sortByValue(groupCount, gcmd.getMatches(), gcmd.getNGroups());
					for (String organism : sorted.keySet()){
    						System.out.println(organism + " " + sorted.get(organism));
					}
				}
			}
                        docs = response.getResults();
                        if (docs != null) {
                                result = (int) docs.getNumFound();
                        } else
                                result = 0;
                } catch (SolrServerException e) {
                        System.out.print("search fail ");
                }
		//result=(int) docs.getNumFound();			
		System.out.println("NumFound: "+result);
	}

		public static Map<String, Long> sortByValue(Map<String, Long> map, long totalMatches, long totalGroups) {
        List list = new LinkedList(map.entrySet());
        Collections.sort(list, new Comparator() {

            @Override
            public int compare(Object o1, Object o2) {
                return ((Comparable) ((Map.Entry) (o2)).getValue()).compareTo(((Map.Entry) (o1)).getValue());
            }
        });

        Map result = new LinkedHashMap();
	int count = 0;
	result.put("totalMatches", totalMatches);
	result.put("totalGroups", totalGroups);
        for (Iterator it = list.iterator(); it.hasNext();) {
            Map.Entry entry = (Map.Entry) it.next();
		count++;
            result.put(entry.getKey(), entry.getValue());
		if(count == 10) {
			return result;
		}
        }
        return result;
    }


		private static HashMap<String, Long> sortHashMap(HashMap<String, Long> input){
    			Map<String, Long> tempMap = new HashMap<String, Long>();
    			for (String key : input.keySet()){
        			tempMap.put(key,input.get(key));
    			}

    			List<String> mapKeys = new ArrayList<String>(tempMap.keySet());
    			List<Long> mapValues = new ArrayList<Long>(tempMap.values());
    			HashMap<String, Long> sortedMap = new LinkedHashMap<String, Long>();
    			TreeSet<Long> sortedSet = new TreeSet<Long>(mapValues);
    			Object[] sortedArray = sortedSet.toArray();
    			int size = sortedArray.length;
    			for (int i=size-1; i>=0; i--){
        			sortedMap.put(mapKeys.get(mapValues.indexOf(sortedArray[i])), 
                      		(Long)sortedArray[i]);
    			}
    			return sortedMap;
		}
}
