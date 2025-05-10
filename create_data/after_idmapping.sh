wget ftp://ftp.pir.georgetown.edu/databases/idmapping/tmp/idmapping.dat.gz -O idmapping.dat.gz
perl getUniProtACToIedbMap.pl idmapping.dat.gz epitope_full_v3.txt UniProtACToIeDB.txt 


perl addNISTToIPro.pl peptide_st.tb ipro.seq.uniprotkb.plus.isoform.2018_05 > ipro.seq.uniprotkb.plus.isoform_nist.2018_05
grep "^>" ipro.seq.uniprotkb.plus.isoform_nist.2018_05 | awk -F"\\\^\\\|\\\^" '{print $6"\t"$7"\t"$8"\t"$9}' | sort -u > orgToTaxonGroup.txt

perl addPeptideAtlasToIPro.pl UniProtACToPeptideAtlas.txt ipro.seq.uniprotkb.plus.isoform_nist.2018_05 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas.2018_05 

perl addPrideToIPro.pl UniProtACToPride.txt ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas.2018_05 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride.2018_05 


perl addIeDBToIPro.pl UniProtACToIeDB.txt ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride.2018_05 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb.2018_05 

perl addLineageToIPro.pl lineage.txt ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb.2018_05 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage.2018_05 

perl addShortLineageToIPro.pl shortLineage.txt ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage.2018_05 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage.2018_05

perl addUniRef100ToIPro.pl UniRef100.ac ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage.2018_05 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2018_05

perl checkfield.pl ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2018_05 15

grep "^>" ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2018_05 | wc -l > count.txt 

#Go to the following directory 
cd /data/chenc/peptidematch_run/tools/
#follow readme.txt
