perl addIeDBToIPro.pl UniProtACToIeDB.txt ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride.2017_01 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb.2017_01 

perl addLineageToIPro.pl lineage.txt ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb.2017_01 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage.2017_01 

perl addShortLineageToIPro.pl shortLineage.txt ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage.2017_01 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage.2017_01

perl addUniRef100ToIPro.pl UniRef100.ac ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage.2017_01 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2017_01

#perl addUniRefACsToIPro.pl UniNREF.tbl.link  ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2017_01 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100_unirefAcs.2017_01

perl checkfield.pl /work/chenc/peptidematch_data/2017_01/ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2017_01 15

grep "^>" ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2017_01 | wc -l > count.txt 

#Go to the following directory 
cd /home/chenc/peptidematch_run/tools/
#follow readme.txt
