package query;


import java.io.Reader;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.ngram.NGramTokenFilter;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.util.Version;


public class NGramAnalyzer extends Analyzer{
	public  int DEFAULT_MIN_NGRAM_SIZE=3;
	public  int DEFAULT_MAX_NGRAM_SIZE=8;
	StandardAnalyzer analyzer;
	private int minNgram;
	private int maxNgram;
	public NGramAnalyzer(int minNgram,int maxNgram ){
		this.minNgram=minNgram;
		this.maxNgram=maxNgram;
		 analyzer = new StandardAnalyzer(Version.LUCENE_CURRENT);
		 analyzer.setMaxTokenLength(Integer.MAX_VALUE);
	}
	public NGramAnalyzer(){
		this.minNgram=DEFAULT_MIN_NGRAM_SIZE;
		this.maxNgram=DEFAULT_MAX_NGRAM_SIZE;
		analyzer = new StandardAnalyzer(Version.LUCENE_CURRENT);
	}
	
	@Override
	public TokenStream tokenStream(String fieldName, Reader reader) {
		// TODO Auto-generated method stub
	
		return new NGramTokenFilter(analyzer.tokenStream(fieldName, reader),minNgram,maxNgram);
	}

	
	
}
