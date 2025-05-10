package query;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class HighLight{
	public String highLight(String content,String query){
	//tempContent is used to store the temp highlight content
	//start is used to record the last high light content offset
		int contentLength=content.length();
		int queryLength=query.length();
		int start=0;
		List<String> tempContent=new ArrayList();
		String returnContent="";
		
		for(int i=0;i<=contentLength-queryLength;){
			if(content.substring(i, i+queryLength).equals(query)){
				tempContent.add(content.substring(start,i));
				tempContent.add("<b id=highlight>"+content.substring(i,i+queryLength)+"</b>");
				i+=queryLength;
				start=i;
				continue;
			}
			else i++;
			
		}
		//start==0 means no high light happened
		if(start==0)returnContent=content;
		else{
		Iterator<String> itr=tempContent.iterator();	
		while(itr.hasNext()){
			returnContent+=itr.next();
		}	
		//if the last offset is less than the content length, should store the string behind that
		if(start<content.length())returnContent+=content.substring(start,content.length());
			
		}
		return returnContent;
	}


}
