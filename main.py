from html.parser import HTMLParser
import re


# base_url = "http://www.ericlevy.com/Revel/"

# 'BDB/BDB/9/tet-BkMrk.html'
# 'BDB/BDB/9/tet01.html'
# "BDB/BDB/{letter_index}/{letter_abbrevition[tet]}{page[01]}.html"

alphabet = [
	{"index": 1,
	"abbreviation": "al",},
	{"index": 2,
	"abbreviation": "bet",},
	{"index": 3,
	"abbreviation": "gim",},
	{"index": 4,
	"abbreviation": "dal",},
	{"index": 5,
	"abbreviation": "he",},
	{"index": 6,
	"abbreviation": "waw",},
	{"index": 7,
	"abbreviation": "zay",},
	{"index": 8,
	"abbreviation": "het",},
	{"index": 9,
	"abbreviation": "tet",},
	{"index": 10,
	"abbreviation": "yod",},
	{"index": 11,
	"abbreviation": "kap",},
	{"index": 12,
	"abbreviation": "lam",},
	{"index": 13,
	"abbreviation": "mem",},
	{"index": 15,
	"abbreviation": "sam",},
	{"index": 16,
	"abbreviation": "ayi",},
	{"index": 17,
	"abbreviation": "pe",},
	{"index": 18,
	"abbreviation": "sad",},
	{"index": 18,
	"abbreviation": "sad",},
	{"index": 19,
	"abbreviation": "kop",},
	{"index": 20,
	"abbreviation": "res",},
	{"index": 21,
	"abbreviation": "sin",},
	{"index": 22,
	"abbreviation": "taw",},
	{"index": 13,
	"abbreviation": "mem",},
	{"index": 11,
	"abbreviation": "kap",},
	{"index": 17,
	"abbreviation": "pe",},
	{"index": 14,
	"abbreviation": "num",},
	{"index": 14,
	"abbreviation": "num"}
]

def pageNumber(page):
	if page < 10:
		return '0' + str(page)
	return str(page)

### letter = {"index": 1,"abbreviation": "al"}
def indexLetter(letter):
	textus = ''
	
	page = 1
	while page:
		filename = "BDB/" + str(letter["index"]) + "/" + str(letter["abbreviation"]) + pageNumber(page) + ".html"
		try:
			with open(filename, 'r') as f:
				html = f.read()
				begin = html.find('<P')
				end = html.find('</BODY>')
				text = html[begin:end]
				text = re.sub(r'<CENTER>[\s\S\w\W]+</CENTER>', '', text)
				text = text[:text.rfind('\n') - 6]
				# print(text)
				textus += text
				# print(filename)
				page += 1
		except:
			print('GO TO NEXT LETTER')
			return textus

def indexAllLetters():
	for letter in alphabet:
		textus = indexLetter(letter)
		print(letter)
		with open('textus/' + letter['abbreviation'] + '.html', 'w') as f:
			f.write(textus)

	
# indexAllLetters()







# class MyHTMLParser(HTMLParser):

#    #Initializing lists
#    lsStartTags = list()
#    lsEndTags = list()
#    lsStartEndTags = list()
#    lsComments = list()

#    #HTML Parser Methods
#    def handle_starttag(self, startTag, attrs):
#        self.lsStartTags.append(startTag)

#    def handle_endtag(self, endTag):
#        self.lsEndTags.append(endTag)

#    def handle_startendtag(self,startendTag, attrs):
#        self.lsStartEndTags.append(startendTag)

#    def handle_comment(self,data):
#        self.lsComments.append(data)


# parser = MyHTMLParser()

# with open('textus/al.html') as f:
# 	parser.feed(f.read())

# print("Start tags", parser.lsStartTags)
# # print("End tags", parser.lsEndTags)
# # print("Start End tags", parser.lsStartEndTags)
# # print("Comments", parser.lsComments)