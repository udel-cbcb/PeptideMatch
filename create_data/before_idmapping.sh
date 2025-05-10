#mkdir /big/chenc/peptidematch_data/2018_05/
#go to cc1714@pir23.georgetown.edu chenc home to run perl createIProUniProtSeqDefline.pl and getTaxToTaxGroupMappingWithName.pl 
#nohup scp -Cp ~/seqDefLine.txt chenc@lysine.dbi.udel.edu:/big/chenc/peptidematch_data/2018_05/

#nohup scp -Cp ~/taxToTaxGroupWithName.txt chenc@lysine.dbi.udel.edu:/big/chenc/peptidematch_data/2018_05/
#nohup scp -Cp /drive34/iProClass_Indexes/ipro_info/isoform/isoform.seq chenc@lysine.dbi.udel.edu:/big/chenc/peptidematch_data/2018_05/isoform.seq.2018_05
#nohup scp -Cp /drive34/iProClass_Indexes/ipro_info/tmp/ipro.seq.uniprotkb chenc@lysine.dbi.udel.edu:/big/chenc/peptidematch_data/2018_05/ipro.seq.uniprotkb.2018_05 

cp /big/chenc/peptidematch_data/2018_05/* .

cp /big/wangy/uniprot_data/2018_05/UniRef100.ac .

cp ipro.seq.uniprotkb.2018_05 ipro.seq.uniprotkb.plus.isoform.2018_05.orig
cat isoform.seq.2018_05 >> ipro.seq.uniprotkb.plus.isoform.2018_05.orig

perl replaceIproSeqUniProtKBSeqDefLine.pl seqDefLine.txt ipro.seq.uniprotkb.plus.isoform.2018_05.orig > ipro.seq.uniprotkb.plus.isoform.2018_05

cat ipro.seq.uniprotkb.plus.isoform.2018_05 | grep "^>" | awk -F"\\\^\\\|\\\^" '{print $7"\t"$6}' | sort -u > ipro_names.txt

perl getUniProtOrgNameAndTaxonId.pl /big/chenc/uniprot_data/2018_05/uniprot_sprot-noev.dat /big/chenc/uniprot_data/2018_05/uniprot_trembl-noev.dat > uniprot_names.txt

cp uniprot_names.txt orgNameToTaxon.txt


perl getUniProtACToPeptideAtlas.pl /big/chenc/uniprot_data/2018_05/uniprot_sprot-noev.dat  /big/chenc/uniprot_data/2018_05/uniprot_trembl-noev.dat > UniProtACToPeptideAtlas.txt 
perl getUniProtACToPride.pl /big/chenc/uniprot_data/2018_05/uniprot_sprot-noev.dat  /big/chenc/uniprot_data/2018_05/uniprot_trembl-noev.dat > UniProtACToPride.txt 

perl computeLineage.pl taxToTaxGroupWithName.txt new_nih_taxID_scientific_name_table new_nih_taxID_parenttaxID_table lineage.txt names.txt 
cp names.txt shortNames.txt

perl computeChildren.pl ipro_names.txt new_nih_taxID_scientific_name_table new_nih_taxID_parenttaxID_table children.txt 

perl getCondenseChildren.pl lineage.txt > condenseChildren.txt

perl getShortLineage.pl lineage.txt > shortLineage.txt

cp ../2018_04/peptide_st.tb .
wget http://www.iedb.org/downloader.php?file_name=doc/epitope_full_v3.zip -O epitope_full_v3.zip
unzip epitope_full_v3.zip
sed -E 's/("([^"]*)")?,/\2\t/g' epitope_full_v3.csv | grep -v "^Epitope" | awk -F"\t" '{print $1"\t"$13}'  > epitope_full_v3.txt

