perl addShortLineageToIPro.pl shortLineage.txt ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage.2017_04 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage.2017_04

perl addUniRef100ToIPro.pl UniRef100.ac ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage.2017_04 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2017_04

perl checkfield.pl /work/chenc/peptidematch_data/2017_04/ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2017_04 15

grep "^>" ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2017_04 | wc -l > count.txt 

