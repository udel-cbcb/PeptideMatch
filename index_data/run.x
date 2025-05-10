#create lucene index for test web site, it takes about 9 hours, run it in background
java javaprogram.NGramIndexer -index ../jetty/solr/data/index_ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2015_07 -data /work/chenc/peptidematch_data/2015_07/ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2015_07 -gram 3 3 > index.log.new 

