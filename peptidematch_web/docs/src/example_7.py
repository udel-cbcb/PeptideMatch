import sys, getopt, urllib,urllib2

queryFile = ''
organismFile =''
format = ''

def main(argv):
	try:
		opts, args = getopt.getopt(argv, "qof",["queryFile=", "organismFile=", "format="])
	except getopt.GetoptError:
		print 'example_7.py -q <queryFile> -o <organismFile> -f <format>'
		sys.exit(2);
	for opt, arg in opts:
		if opt in ("-q", "--queryFile"):
			queryFile = arg
		elif opt in ("-o", "--organismFile"):
			organismFile = arg
		elif opt in ("-f", "--format"):
			format = arg
if __name__ == "__main__":
	main(sys.argv[1:])
 
print queryFile
print organismFile
print format	
url = 'http://alanine.bioinformatics.udel.edu/peptidematch_new/webservices/peptidematch_rest'

params = {
'format':format,
'query':'DPETERQ',
'organism':'5888,537012'
}

data = urllib.urlencode(params)
request = urllib2.Request(url, data)
request.add_header('User-Agent', 'Python contact')
response = urllib2.urlopen(request)
page = response.read(200000)
print page
