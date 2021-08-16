import dictionary from './bdbt.json'


global css
	html
		ff:sans
	*
		tween:all 300ms ease

let state = {
	search: ''
}

let expanded_word = -1

tag app
	# Compute a search relevance score for an item.
	def scoreSearch item, query
		let thename = item.toLowerCase()
		query = query.toLowerCase!
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

		if thename.indexOf(query) > -1 or query.indexOf(thename) > -1
			score += 12
		# log score
		return score


	def search
		if state.search.length > 0
			found_words = []
			for word in dictionary
				word.score = scoreSearch(word.lexeme, state.search)
				if word.score > state.search.length * 0.75
					found_words.push(word)
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
			<svg[w:200px h:auto] src='./logo.svg'>
			<input[w:100% d:block p:8px 16px m:8px 0 fs:1.5em] bind=state.search>
		<main>
			for word, index in search! when index < 64
				<div.definition .expanded=(expanded_word == index) tabIndex=0>
					<p @click=expand(index)>
						word.lexeme
						<svg width="16" height="10" viewBox="0 0 8 5">
							<title> 'expand'
							<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">

					<div[fs:1.2em p:8px] innerHTML=word.definition>

	css
		d:flex
		fld:column

		main, header
			max-width:1024px
			w:100%
			m:auto

		.definition
			max-height:62px
			of:hidden
			pos:relative

			p
				m:0
				p:16px
				fs:24px
				d:flex
				jc:space-between
				ai:center
				cursor:pointer
				pos:sticky
				t:0px
				bg:white
				bdb:1px solid gray4
			
			svg
				transform:$svg-transform
		
		.expanded
			max-height:50vh
			of:auto
			$svg-transform:rotate(180deg)






imba.mount <app>