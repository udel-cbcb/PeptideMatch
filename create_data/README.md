mkdir /big/chenc/peptidematch_data/2018_04/
#go to cc1714@pir23.georgetown.edu chenc home to run perl createIProUniProtSeqDefline.pl and getTaxToTaxGroupMappingWithName.pl 
nohup scp -Cp ~/seqDefLine.txt chenc@lysine.dbi.udel.edu:/big/chenc/peptidematch_data/2018_04/

nohup scp -Cp ~/taxToTaxGroupWithName.txt chenc@lysine.dbi.udel.edu:/big/chenc/peptidematch_data/2018_04/
nohup scp -Cp /drive34/iProClass_Indexes/ipro_info/isoform/isoform.seq chenc@lysine.dbi.udel.edu:/big/chenc/peptidematch_data/2018_04/isoform.seq.2018_04
nohup scp -Cp /drive34/iProClass_Indexes/ipro_info/tmp/ipro.seq.uniprotkb chenc@lysine.dbi.udel.edu:/big/chenc/peptidematch_data/2018_04/ipro.seq.uniprotkb.2018_04 

cp /big/chenc/peptidematch_data/2018_04/* .

cp /big/wangy/uniprot_data/2018_04/UniRef100.ac .
cp ipro.seq.uniprotkb.2018_04 ipro.seq.uniprotkb.plus.isoform.2018_04.orig
cat isoform.seq.2018_04 >> ipro.seq.uniprotkb.plus.isoform.2018_04.orig

perl replaceIproSeqUniProtKBSeqDefLine.pl seqDefLine.txt ipro.seq.uniprotkb.plus.isoform.2018_04.orig > ipro.seq.uniprotkb.plus.isoform.2018_04

cat ipro.seq.uniprotkb.plus.isoform.2018_04 | grep "^>" | awk -F"\\\^\\\|\\\^" '{print $7"\t"$6}' | sort -u > ipro_names.txt

perl getUniProtOrgNameAndTaxonId.pl /big/chenc/uniprot_data/2018_04/uniprot_sprot-noev.dat /big/chenc/uniprot_data/2018_04/uniprot_trembl-noev.dat > uniprot_names.txt

cp uniprot_names.txt orgNameToTaxon.txt


perl getUniProtACToPeptideAtlas.pl /big/chenc/uniprot_data/2018_04/uniprot_sprot-noev.dat  /big/chenc/uniprot_data/2018_04/uniprot_trembl-noev.dat > UniProtACToPeptideAtlas.txt 
perl getUniProtACToPride.pl /big/chenc/uniprot_data/2018_04/uniprot_sprot-noev.dat  /big/chenc/uniprot_data/2018_04/uniprot_trembl-noev.dat > UniProtACToPride.txt 

perl computeLineage.pl taxToTaxGroupWithName.txt new_nih_taxID_scientific_name_table new_nih_taxID_parenttaxID_table lineage.txt names.txt 
cp names.txt shortNames.txt

perl computeChildren.pl ipro_names.txt new_nih_taxID_scientific_name_table new_nih_taxID_parenttaxID_table children.txt 

perl getCondenseChildren.pl lineage.txt > condenseChildren.txt

perl getShortLineage.pl lineage.txt > shortLineage.txt

cp ../2018_01/peptide_st.tb .
wget http://www.iedb.org/downloader.php?file_name=doc/epitope_full_v3.zip -O epitope_full_v3.zip
unzip epitope_full_v3.zip
sed -E 's/("([^"]*)")?,/\2\t/g' epitope_full_v3.csv | grep -v "^Epitope" | awk -F"\t" '{print $1"\t"$13}'  > epitope_full_v3.txt


wget ftp://ftp.pir.georgetown.edu/databases/idmapping/tmp/idmapping.dat.gz
perl getUniProtACToIedbMap.pl idmapping.dat.gz epitope_full_v3.txt UniProtACToIeDB.txt 


perl addNISTToIPro.pl peptide_st.tb ipro.seq.uniprotkb.plus.isoform.2018_04 > ipro.seq.uniprotkb.plus.isoform_nist.2018_04
grep "^>" ipro.seq.uniprotkb.plus.isoform_nist.2018_04 | awk -F"\\\^\\\|\\\^" '{print $6"\t"$7"\t"$8"\t"$9}' | sort -u > orgToTaxonGroup.txt

perl addPeptideAtlasToIPro.pl UniProtACToPeptideAtlas.txt ipro.seq.uniprotkb.plus.isoform_nist.2018_04 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas.2018_04 

perl addPrideToIPro.pl UniProtACToPride.txt ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas.2018_04 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride.2018_04 


perl addIeDBToIPro.pl UniProtACToIeDB.txt ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride.2018_04 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb.2018_04 

perl addLineageToIPro.pl lineage.txt ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb.2018_04 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage.2018_04 

perl addShortLineageToIPro.pl shortLineage.txt ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage.2018_04 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage.2018_04

perl addUniRef100ToIPro.pl UniRef100.ac ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage.2018_04 > ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2018_04

perl checkfield.pl /data/chenc/peptidematch_data/2018_04/ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2018_04 15

grep "^>" ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2018_04 | wc -l > count.txt 

#Go to the following directory 
cd /home/chenc/peptidematch_run/tools/
#follow readme.txt
