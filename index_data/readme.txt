source classpath.txt
#create lucene index for test web site, it takes about 9 hours, run it in background
nohup java javaprogram.NGramIndexer -index ../jetty/solr/data/index_ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2018_05 -data /data/chenc/peptidematch_data/2018_05/ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2018_05 -gram 3 3 > index.log 

#Once the indexing is done.
cd /data/chenc/peptidematch_run/jetty/solr/data/
rm index
ln -s index_ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2018_05 index

# Kill solr server for test web site.
ps -ef | grep chenc | grep start.jar
kill processid

#As root, create app directory for test web site 
cd /data/chenc/apache-tomcat-7.0.76/webapps/
cp -r peptidematch_new_2018_04 peptidematch_new_2018_05
chown -R chenc:cwu peptidematch_new_2018_05
rm peptidematch_new
ln -s peptidematch_new_2018_05 peptidematch_new

cd peptidematch_new_2018_05/WEB-INF/classes/config
#modify cp.sh, change all 2018_04 to 2018_05
vi cp.sh
sh cp.sh

#change "version" and "total_sequence" values
vi index.properties 

#As chenc, start solr for test web site
cd /home/chenc/peptidematch_run/jetty
sh start.sh

#go to (http://research.bioinformatics.udel.edu/peptidematch_new/index.jsp), run a test search to warm up solr server.

#In case need to restart tomcat, as root
systemctl restart tomcat6.service

cd ../tools
#create statistics for reference and complete proteomes
nohup java javaprogram.OrganismStatistics /data/chenc/apache-tomcat-7.0.76/webapps/peptidematch_new_2018_05/WEB-INF/classes/config/proteomes_reference.txt.nocount /data/chenc/apache-tomcat-7.0.76/webapps/peptidematch_new_2018_05/WEB-INF/classes/config/proteomes_reference.txt & 
nohup java javaprogram.OrganismStatistics /data/chenc/apache-tomcat-7.0.76/webapps/peptidematch_new_2018_05/WEB-INF/classes/config/proteomes_complete.txt.nocount /data/chenc/apache-tomcat-7.0.76/webapps/peptidematch_new_2018_05/WEB-INF/classes/config/proteomes_complete.txt & 


#As root, create app directory for production web site 
cd /data/chenc/apache-tomcat-7.0.76/webapps/
cp -r peptidematch_2018_04 peptidematch_2018_05
chown -R chenc:cwu peptidematch_2018_05
#rm peptidematch
#ln -s peptidematch_2018_05 peptidematch

cd peptidematch_2018_05/WEB-INF/classes/config
#modify cp.sh, change all 2018_04 to 2018_05
vi cp.sh
sh cp.sh

#change "version" and "total_sequence" values
vi index.properties 


#On release date, as root
cd /usr/share/tomcat6/webapps/
rm peptidematch
ln -s peptidematch_2018_05 peptidematch

cd /usr/share/tomcat6/jetty/solr/data/
rm index
ln -s /home/chenc/peptidematch_run/jetty/solr/data/index_ipro.seq.uniprotkb.plus.isoform_nist_peptideAtlas_pride_iedb_lineage_shortlineage_uniref100.2018_05 index

# Kill solr server for production web site.
ps -ef | grep root | grep start.jar
kill processid

#start solr production server, 
/etc/init.d/jetty start

#go to (http://research.bioinformatics.udel.edu/peptidematch/index.jsp), run a test search to warm up solr server.
