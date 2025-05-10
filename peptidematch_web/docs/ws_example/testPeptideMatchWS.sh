curl -F query=AAVEEGIVLGGGCALLR http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_1_curl.tab
curl -F query=AAVEEGIVLGGGCALLR -F format=tab http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_1_curl.tab
curl -F query=AAVEEGIVLGGGCALLR -F format=xls http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_1_curl.xls
curl -F query=AAVEEGIVLGGGCALLR -F format=fasta http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_1_curl.fasta
curl -F query=AAVEEGIVLGGGCALLR -F format=xml http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_1_curl.xml

curl -F query=AAVEEGIVLGGGCALLR -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_1_curl_uniref100_leqi.tab
curl -F query=AAVEEGIVLGGGCALLR -F format=tab -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_1_curl_uniref100_leqi.tab
curl -F query=AAVEEGIVLGGGCALLR -F format=xls -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_1_curl_uniref100_leqi.xls
curl -F query=AAVEEGIVLGGGCALLR -F format=fasta -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_1_curl_uniref100_leqi.fasta
curl -F query=AAVEEGIVLGGGCALLR -F format=xml -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_1_curl_uniref100_leqi.xml

wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR" -O example_1_wget.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=tab" -O example_1_wget.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=xls" -O example_1_wget.xls
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=fasta" -O example_1_wget.fasta
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=xml" -O example_1_wget.xml

wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&uniref100=y&leqi=y" -O example_1_wget_uniref100_leqi.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=tab&uniref100=y&leqi=y" -O example_1_wget_uniref100_leqi.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=xls&uniref100=y&leqi=y" -O example_1_wget_unierf100_leqi.xls
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=fasta&uniref100=y&leqi=y" -O example_1_wget_uniref100_leqi.fasta
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=xml&uniref100=y&leqi=y" -O example_1_wget_uniref100_leqi.xml

curl -F query=AAVEEGIVLGGGCALLR -F organism=9606,10090 http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_2_curl.tab
curl -F query=AAVEEGIVLGGGCALLR -F organism=9606,10090 -F format=tab http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_2_curl.tab
curl -F query=AAVEEGIVLGGGCALLR -F organism=9606,10090 -F format=xls http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_2_curl.xls
curl -F query=AAVEEGIVLGGGCALLR -F organism=9606,10090 -F format=fasta http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_2_curl.fasta
curl -F query=AAVEEGIVLGGGCALLR -F organism=9606,10090 -F format=xml http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_2_curl.xml

curl -F query=AAVEEGIVLGGGCALLR -F organism=9606,10090 -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_2_curl_uniref100_leqi.tab
curl -F query=AAVEEGIVLGGGCALLR -F organism=9606,10090 -F format=tab -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_2_curl_uniref100_leqi.tab
curl -F query=AAVEEGIVLGGGCALLR -F organism=9606,10090 -F format=xls -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_2_curl_uniref100_leqi.xls
curl -F query=AAVEEGIVLGGGCALLR -F organism=9606,10090 -F format=fasta -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_2_curl_uniref100_leqi.fasta
curl -F query=AAVEEGIVLGGGCALLR -F organism=9606,10090 -F format=xml -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_2_curl_uniref100_leqi.xml

wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&organism=9606,10090" -O example_2_wget.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=tab&organism=9606,10090" -O example_2_wget.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=xls&organism=9606,10090" -O example_2_wget.xls
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=fasta&organism=9606,10090" -O example_2_wget.fasta
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=xml&organism=9606,10090" -O example_2_wget.xml

wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&organism=9606,10090&uniref100=y&leqi=y" -O example_2_wget_uniref100_leqi.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=tab&organism=9606,10090&uniref100=y&leqi=y" -O example_2_wget_uniref100_leqi.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=xls&organism=9606,10090&uniref100=y&leqi=y" -O example_2_wget_uniref100_leqi.xls
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=fasta&organism=9606,10090&uniref100=y&leqi=y" -O example_2_wget_uniref100_leqi.fasta
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR&format=xml&organism=9606,10090&uniref100=y&leqi=y" -O example_2_wget_uniref100_leqi.xml

curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_4_curl.tab
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F format=tab http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_4_curl.tab
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F format=xls http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_4_curl.xls
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F format=fasta http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_4_curl.fasta
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F format=xml http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_4_curl.xml

curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_4_curl_uniref100_leqi.tab
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F format=tab -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_4_curl_uniref100_leqi.tab
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F format=xls -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_4_curl_uniref100_leqi.xls
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F format=fasta -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_4_curl_uniref100_leqi.fasta
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F format=xml -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_4_curl_uniref100_leqi.xml

wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK" -O example_4_wget.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=tab" -O example_4_wget.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=xls" -O example_4_wget.xls
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=fasta" -O example_4_wget.fasta
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=xml" -O example_4_wget.xml

wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&uniref100=y&leqi=y" -O example_4_wget_uniref100_leqi.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=tab&uniref100=y&leqi=y" -O example_4_wget_uniref100_leqi.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=xls&uniref100=y&leqi=y" -O example_4_wget_uniref100_leqi.xls
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=fasta&uniref100=y&leqi=y" -O example_4_wget_uniref100_leqi.fasta
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=xml&uniref100=y&leqi=y" -O example_4_wget_uniref100_leqi.xml

curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F organism=9606,10090 http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_5_curl.tab
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F organism=9606,10090 -F format=tab http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_5_curl.tab
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F organism=9606,10090 -F format=xls http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_5_curl.xls
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F organism=9606,10090 -F format=fasta http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_5_curl.fasta
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F organism=9606,10090 -F format=xml http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_5_curl.xml

curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F organism=9606,10090 -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_5_curl_uniref100_leqi.tab
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F organism=9606,10090 -F format=tab -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_5_curl_uniref100_leqi.tab
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F organism=9606,10090 -F format=xls -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_5_curl_uniref100_leqi.xls
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F organism=9606,10090 -F format=fasta -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_5_curl_uniref100_leqi.fasta
curl -F query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK -F organism=9606,10090 -F format=xml -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_5_curl_uniref100_leqi.xml

wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&organism=9606,10090" -O example_5_wget.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=tab&organism=9606,10090" -O example_5_wget.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=xls&organism=9606,10090" -O example_5_wget.xls
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=fasta&organism=9606,10090" -O example_5_wget.fasta
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=xml&organism=9606,10090" -O example_5_wget.xml

wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&organism=9606,10090&uniref100=y&leqi=y" -O example_5_wget_uniref100_leqi.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=tab&organism=9606,10090&uniref100=y&leqi=y" -O example_5_wget_uniref100_leqi.tab
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=xls&organism=9606,10090&uniref100=y&leqi=y" -O example_5_wget_uniref100_leqi.xls
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=fasta&organism=9606,10090&uniref100=y&leqi=y" -O example_5_wget_uniref100_leqi.fasta
wget "http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest?query=AAVEEGIVLGGGCALLR,SVQYDDVPEYK&format=xml&organism=9606,10090&uniref100=y&leqi=y" -O example_5_wget_uniref100_leqi.xml

curl -F queryFile=@queryFile.txt -F organismFile=@organismFile.txt http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_6_curl_file.tab
curl -F queryFile=@queryFile.txt -F organismFile=@organismFile.txt -F format=tab http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_6_curl_file.tab
curl -F queryFile=@queryFile.txt -F organismFile=@organismFile.txt -F format=xls http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_6_curl_file.xls
curl -F queryFile=@queryFile.txt -F organismFile=@organismFile.txt -F format=fasta http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_6_curl_file.fasta
curl -F queryFile=@queryFile.txt -F organismFile=@organismFile.txt -F format=xml http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_6_curl_file.xml

curl -F queryFile=@queryFile.txt -F organismFile=@organismFile.txt -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_6_curl_uniref100_leqi_file.tab
curl -F queryFile=@queryFile.txt -F organismFile=@organismFile.txt -F format=tab -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_6_curl_uniref100_leqi_file.tab
curl -F queryFile=@queryFile.txt -F organismFile=@organismFile.txt -F format=xls -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_6_curl_uniref100_leqi_file.xls
curl -F queryFile=@queryFile.txt -F organismFile=@organismFile.txt -F format=fasta -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_6_curl_uniref100_leqi_file.fasta
curl -F queryFile=@queryFile.txt -F organismFile=@organismFile.txt -F format=xml -F uniref100=y -F leqi=y http://core.bioinformatics.udel.edu/peptidematch_dev/webservices/peptidematch_rest -o example_6_curl_uniref100_leqi_file.xml
