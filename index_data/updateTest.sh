if [ $# != 1 ] ; then
echo "USAGE: sh $0 YEARMONTH"
echo "e.g.: sh $0 201208"
exit 1
fi 
version=$1
echo $1
year=${version:0:4}
month=${version:4:2}
tools_dir=/usr/share/tomcat6/jetty/tools
data_src="/big/chenc/peptidematch_data/"$year"_"$month"/ipro.seq.uniprotkb."$year"_"$month
data_dir="/big/chenc/peptidematch_data/"$year"_"$month"/"
index_dir="/usr/share/tomcat6/jetty/solr/data/index_"$year$month
symbolic_link_dir=/usr/share/tomcat6/jetty/solr/data/test/
jetty_home=/home/lizw/jetty/
reference_file="/big/chenc/peptidematch_data/"$year"_"$month"/proteomes_reference.txt"
complete_file="/big/chenc/peptidematch_data/"$year"_"$month"/proteomes_complete.txt"
config_dir=/usr/share/tomcat6/webapps/peptidematch_test/WEB-INF/classes/config/
total_sequence=`grep ">" $data_src|wc -l`
cd $tools_dir
if [ -e $index_dir ] 
then
`rm -rf $index_dir`
fi
nohup java javaprogram.NGramIndexer -index $index_dir -gram 3 3 -data $data_src &
wait ${!}
if [ -e $index_dir ]
then
echo starting update...
cd $symbolic_link_dir
rm index
ln -s $index_dir index
cd $jetty_home
kill `ps -ef| grep "java -jar start.jar" | awk '{print $2}'`
sleep 10
nohup java -jar start.jar >> /home/lizw/jetty/solr.log  &
sleep 60
cd $config_dir
rm proteomes_reference.txt 
rm proteomes_complete.txt
rm index.properties
echo "indexpath:/usr/share/tomcat6/jetty/solr/data/index" >> index.properties 
echo "version:UniProt_"$year"_"$month >>index.properties 
echo "total_sequence: "$total_sequence >> index.properties
cd $tools_dir
nohup java javaprogram.OrganismStatistics $reference_file $config_dir"proteomes_reference.txt" &
wait ${!}
nohup java javaprogram.OrganismStatistics $complete_file $config_dir"proteomes_complete.txt" & 
wait ${!}
cp $data_dir"taxToTaxGroupWithName.txt" $config_dir"taxToTaxGroup.txt"
echo done
else
echo "index not success"
fi

