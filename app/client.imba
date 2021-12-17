import eng from './bdbt.json'
import rus from './rus.json'

for word, i in eng
	let matches = [... word.definition.matchAll(/<a href='S:(.*?)'>/g)]
	for match in matches
		word.definition = word.definition.replace(match[0], "<a onclick='javascript:strongDefinition(\"{match[1]}\");'>")
	# console.log word.definition
	# if i > 10
	# 	break
	#  "<a href='javascript:strongDefinition(\"H1\");'>H1</a>"

for word, i in rus
	let matches = [... word.definition.matchAll(/<a href='S:(.*?)'>/g)]
	for match in matches
		word.definition = word.definition.replace(match[0], "<a onclick='javascript:strongDefinition(\"{match[1]}\");'>")

let dictionary = eng

global css
	html, body
		m:0
		p:0
		ff:sans
		fs:18px

	*
		tween:all 300ms ease
		box-sizing:border-box

	a
		c:blue5




let state = {
	search: ''
	#dict_lang: 'eng'

	get dictionary_lang
		return #dict_lang

	set dictionary_lang new_val
		#dict_lang = new_val
		window.localStorage.setItem('dict_lang', #dict_lang)
		if new_val == 'rus'
			dictionary = rus
			document.title = "Полный лексикон по Стронгу и Дворецкому, 2019"
		else
			dictionary = eng
			document.title = "Brown-Driver-Briggs' Hebrew Definitions / Thayer's Greek Definitions"
		imba.commit!

}



let expanded_word = -1

tag app
	def mount
		let dict_lang = window.localStorage.getItem('dict_lang')
		if dict_lang
			state.dictionary_lang = dict_lang
			imba.commit!
		else
			let lang = window.navigator.language.toLowerCase().slice(0, 2)
			if lang == 'ua' or lang == 'uk' or lang == 'ru'
				state.dictionary_lang = 'rus'


		window.strongDefinition = do(topic)
			state.search = topic
			imba.commit!
			return undefined

		document.onfocus = do
			if document.getSelection().toString().length == 0
				$search.focus!
		$search.focus!

		
		# log stripVowels 'יִשָּׁפֵךְ‎'
		# log stripVowels 'יִשָּׁפֵך'


		# let char = "\u0591"
		# let accents = [char]
		# while char != "\u05C7"
		# 	char = String.fromCharCode(char.charCodeAt(0) + 1)
		# 	accents.push(char)
		# log accents

	


	def stripVowels rawString
		# Clear Hebrew
		let res =  rawString.replace(/[\u0591-\u05C7]/g,"")
		# Replace some letters, which are not present in a given unicode range, manually.
		res = res.replace('שׁ', 'ש')
		res = res.replace('שׂ', 'ש')
		res = res.replace('‎', '')
		

		# Clear Greek
		res = res.normalize('NFD').replace(/[\u0300-\u036f]/g, "");
		return res


	# Compute a search relevance score for an item.
	def scoreSearch item, query
		if item == null
			return 0

		let thename = stripVowels(item.toLowerCase!)
		query = stripVowels(query.toLowerCase!)
		# console.log thename, query
		let score = 0
		let p = 0 # Position within the `item`
		# Look through each character of the query string, stopping at the end(s)...

		for i in [0 ... query.length]
			# Figure out if the current letter is found in the rest of the `item`.
			const index = thename.indexOf(query[i], p)
			# If not, stop here.
			if index < 0
				break
			#  If it is, add to the score...
			score += 1
			if (index - p) < 2
				score++
			#  ... and skip the position within `item` forward.
			p = index

		if thename.indexOf(query) > -1
			score += 8
		if thename.indexOf(query) > -1 and thename.length - query.length < 2
			score += 8
		if thename.length == query.length
			score += 1

		# log score
		if score > query.length
			return score
		return 0


	def search
		if state.search.length > 0
			found_words = []
			for word in dictionary
				word.score = Math.max(scoreSearch(word.lexeme, state.search), scoreSearch(word.short_definition, state.search))
				if word.score or word.topic.toLowerCase! == state.search.toLowerCase!
					found_words.push(word)
			log found_words.length
			return found_words.sort(do |a, b| b.score - a.score)
		else
			return dictionary
		
	def expand index
		if expanded_word == index
			expanded_word = -1
		else
			expanded_word = index


	<self>
		<header>
			<select[bg:cooler8 p:12px font:inherit w:100% c:inherit border:none fw:bold cursor:pointer] bind=state.dictionary_lang>
				<option value="eng"> "Brown-Driver-Briggs' Hebrew Definitions / Thayer's Greek Definitions"
				<option value="rus"> "Полный лексикон по Стронгу и Дворецкому, 2019"
			<div[d:flex ai:center]>
				<input$search[w:100% d:block p:8px 16px m:8px 0 fs:1.5em bg:$bg c:$c border:1px solid cooler8] bind=state.search placeholder="Search">
				<svg[fill:$c w:36px h:100% p:12px 0 12px 8px] @click=(state.search = '', $search.focus()) viewBox="0 0 20 20">
					<title> 'Clear'
					<path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z">
		<main>
			<p> 'Results:'
			for word, index in search! when index < 64
				<div.definition .expanded=(expanded_word == index)>
					<p @click=expand(index)>
						word.lexeme + ' · ' + word.pronunciation + ' · ' + word.transliteration + ' · ' + word.short_definition
						<svg [fill:$c min-width:16px] width="16" height="10" viewBox="0 0 8 5">
							<title> 'expand'
							<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">


					if expanded_word == index
						<div[fs:1.2em p:16px 0px @off:0 h:auto @off:0px overflow:hidden bg:$bg o@off:0] innerHTML=word.definition ease>

	css
		d:flex
		fld:column

		$bg:black
		$c:white
		bg:$bg
		c:$c
		p:8px
		min-height:100vh

	css
		main, header
			max-width:1024px
			w:100%
			m:8px auto 0

		.definition
			overflow:hidden

		.definition

			p
				m:0
				p:12px 12px 12px 0
				fs:1.2em
				fw:bold
				d:flex
				jc:space-between
				ai:center
				cursor:pointer
				pos:sticky
				t:0px
				bg:$bg
				bdt:1px solid cooler8
			
			svg
				transform:$svg-transform
		
		.expanded
			$svg-transform:rotate(180deg)



imba.mount <app>