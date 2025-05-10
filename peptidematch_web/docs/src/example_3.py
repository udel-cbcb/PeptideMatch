import urllib,urllib2

url = 'http://alanine.bioinformatics.udel.edu/peptidematch_new/webservices/peptidematch_rest'

params = {
'format':'tab',
'query':'DPETERQ',
'organism':'5888,537012'
}

data = urllib.urlencode(params)
request = urllib2.Request(url, data)
request.add_header('User-Agent', 'Python contact')
response = urllib2.urlopen(request)
page = response.read(200000)
print page
