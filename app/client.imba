import eng from './bdbt.json'
import rus from './rus.json'
import books_map from './books_map.json'

def parseDefinitionsLinks definitions, translation
	for definition in definitions
		# Clean up unneeded spans
		definition.definition = definition.definition.replace('(<[/]?span[^>]*)>', '')
		# Avoid unneded classes on anchors
		definition.definition = definition.definition.replace('( class=\'\w+\')', '')
	
	for definition in definitions
		let pieces = definition.definition.split("'")

		let result = ''
		for piece, index in pieces
			if piece.startsWith('B:')
				result += "'https://bolls.life/" + translation + '/'
				let digits = piece.match(/\d+/g)
				try
					result += books_map[(digits[0])] + '/' + digits[1] + '/' + digits[2]
				catch e
					console.log(piece, e)

				if digits.length > 3
					result += '-' + digits[3]
				unless digits.length > 1
					console.log(digits)
				result += "' target='_blank'"
			else
				if index
					result += "'{piece}"
				else
					result += piece
			definition.definition = result

	# Parse Strong links
	let patterns = [
		/<a href='S:(.*?)'>/g,
		/<a href=\"S:(.*?)\">/g,
		/<a href=S:(.*?)>/g
	]
	for definition in definitions
		for pattern in patterns
			let matches = [... definition.definition.matchAll(pattern)]
			for match in matches
				definition.definition = definition.definition.replace(match[0], "<a onclick='javascript:strongDefinition(\"{match[1]}\");'>")

	# Unlink TWOT links
	patterns = [
		/<a class="T" href='S:(.*?)'>/g,
		/<a class="T" href=\"S:(.*?)\">/g,
		/<a class="T" href=S:(.*?)>/g
	]
	for definition in definitions
		for pattern in patterns
			let matches = [... definition.definition.matchAll(pattern)]
			for match in matches
				definition.definition = definition.definition.replace(match[0], match[1])

parseDefinitionsLinks(eng, 'YLT')
parseDefinitionsLinks(rus, 'SYNOD')

let dictionary = eng

global css
	html, body
		$bg:black
		$c:white
		$accent-color: #ffc107
		m:0
		p:0
		ff:sans
		fs:16px
		bg:$bg
		c:$c

	*
		tween:all 300ms ease
		box-sizing:border-box
		scroll-behavior: smooth

	a
		c:blue5
		cursor:pointer


	input
		-webkit-appearance: none
		-moz-appearance: none
		appearance: none

	*:focus 
		outline: none


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

let definitions_history = []

let definitions_history_index = -1

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

		# document.onfocus = do
		# 	if document.getSelection().toString().length == 0
		# 		$search.focus!
		# $search.focus!

		
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
		res = res.replace('ץ', 'צ')
		res = res.replace('ם', 'מ')
		res = res.replace('ן', 'נ')
		res = res.replace('ך', 'כ')
		res = res.replace('ף', 'פ')
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
			return found_words.sort(do |a, b| b.score - a.score)
		else
			return dictionary

	def expand index, id
		if expanded_word == index
			expanded_word = -1
		else
			expanded_word = index
			setTimeout(&, 400) do
				const definition_body = document.getElementById(id)

				if window.innerHeight > definition_body.scrollHeight + 100
					definition_body.scrollIntoView({behavior:'smooth', block:"center"})
				else
					window.scrollTo({ behavior: 'smooth', top: definition_body.offsetTop - 50, left: 0 })

	def prevDefinition
		if definitions_history_index > 0
			definitions_history_index -= 1
			state.search = definitions_history[definitions_history_index]

	def nextDefinition
		if definitions_history_index < definitions_history.length - 1
			definitions_history_index += 1
			state.search = definitions_history[definitions_history_index]
		
	def eve
		window.scrollTo({ behavior: 'smooth', top: 0, left: 0 })

		definitions_history_index += 1
		definitions_history[definitions_history_index] = state.search
		definitions_history.length = definitions_history_index + 1


	<self>
		<main>
			<select[bg:cooler8 p:12px font:inherit w:100% c:inherit border:none fw:bold cursor:pointer] bind=state.dictionary_lang>
				<option value="eng"> "Brown-Driver-Briggs' Hebrew Definitions / Thayer's Greek Definitions"
				<option value="rus"> "Полный лексикон по Стронгу и Дворецкому, 2019"
			<header>
				<button @click=prevDefinition() .disabled=(definitions_history_index == 0 or definitions_history.length == 0) title='Back'>
					<svg [t:0 l:0 transform: rotate(90deg)] width="16" height="10" viewBox="0 0 8 5">
						<title> 'Back'
						<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
				<button [l:32px t:0] @click=nextDefinition() .disabled=(definitions_history.length - 1 == definitions_history_index) title='Next'>
					<svg [transform: rotate(-90deg)] width="16" height="10" viewBox="0 0 8 5">
						<title> 'Next'
						<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">

				<input$search bind=state.search placeholder="Search" @input.debounce(300ms)=eve>

				<button [r:8px t:0] title='Clear' @click=(state.search = '', $search.focus())>
					<svg[w:36px p:12px 0 12px 8px] viewBox="0 0 20 20">
						<title> 'Clear'
						<path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z">

			<p> 'Results:'
			for word, index in search! when index < 128
				<div.definition .expanded=(expanded_word == index)>
					<p @click=expand(index, word.lexeme)>
						<span>
							<b> word.lexeme
							' · '
							word.pronunciation
							' · '
							word.transliteration
							' · '
							<b> word.short_definition
							' · '
							word.topic
						<svg [fill:$c min-width:16px] width="16" height="10" viewBox="0 0 8 5">
							<title> 'expand'
							<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">


					if expanded_word == index
						<div[fs:1.2em p:16px 0px @off:0 h:auto @off:0px overflow:hidden bg:$bg o@off:0] innerHTML=word.definition id=word.lexeme ease>

	css
		p:8px
		min-height:100vh

	css
		main
			max-width:1024px
			w:100%
			m:8px auto 0
			pb:128px
		
		header
			pos:sticky top:2px zi:999 m:8px 0
		
		header button
			bg:transparent
			border:none
			d:inline-block
			fill:$c @hover:$accent-color
			cursor:pointer
			pos:absolute
			h:100%

		header svg
			min-width:24px
			h:100%

		.disabled
			opacity:0.5
			cursor:not-allowed
		

		input
			w:100%
			d:block
			p:8px 36px 8px 68px
			m:0
			fs:1.5em
			bg:$bg
			c:$c
			border:1px solid cooler8
			shadow@focus: 0 0 64px 1px $accent-color, 0 0 0px 1px $accent-color, 0 0 128px 2px $accent-color
			rd@focus:8px

			

		.definition
			overflow:hidden

		.definition

			p
				m:0
				p:12px 12px 12px 0
				fs:1.2em
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