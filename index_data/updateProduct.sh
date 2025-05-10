if [ $# != 1 ] ; then
echo "USAGE: sh $0 YEARMONTH"
echo "e.g.: sh $0 201208"
exit 1
fi
version=$1
echo $1
year=${version:0:4}
month=${version:4:2}
test_config_path=/usr/share/tomcat6/webapps/peptidematch_test/WEB-INF/classes/config/
config_path=/usr/share/tomcat6/webapps/peptidematch/WEB-INF/classes/config/
index_dir=/usr/share/tomcat6/jetty/solr/data/
jetty_home=/usr/share/tomcat6/jetty/
cd $config_path
rm proteomes_reference.txt
rm proteomes_complete.txt
rm index.properties 
cp $test_config_path"proteomes_reference.txt" ./
cp $test_config_path"proteomes_complete.txt" ./
cp $test_config_path"index.properties" ./
cp $test_config_path"taxToTaxGroup.txt" ./
kill `ps -ef| grep "java -Xms5120M -Xmx10240M -jar start.jar" | awk '{print $2}'`
cd $index_dir
rm index
ln -s "index_"$year$month index
cd $jetty_home
sh start.sh &
