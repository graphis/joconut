class window._History
	@listeners: {} # listeners for change event
	@states: {} # collection of all states
	@loaded: no # WebKit browser fire popstate event on page load
	
	@init: ->
		if window.history.replaceState # detecting support
			window.history.replaceState { url: location.pathname }, document.title, location.pathname
			@states[location.pathname]=
				state:
					url: location.pathname
				title: document.title
			
			window.onpopstate = =>
				return @emit 'change', @states[location.pathname] if @loaded
				@loaded = yes
		else
			@states[location.hash]=
				state:
					url: location.pathname
				title: document.title
			
			window.onhashchange = =>
				@emit 'change', @states[location.hash]
	
	@emit: (event, data) ->
		for listener in @listeners[event]
			listener(data)
	
	@on: (event, listener) ->
		@listeners[event] = [] if not @listeners[event]
		@listeners[event].push listener
	
	@push: (state, title, url) ->
		document.title = title if title
		@states[if history.pushState then url else "##{ url }"]=
			state: state
			title: title
		
		if history.pushState then history.pushState(state, title, url) else location.hash = url

_History.init()

fn = ($) ->
	isLocal = new RegExp "^(#{ location.protocol }\/\/#{ location.host }|\\.|\\/|[A-Z0-9_#])", 'i' # dynamically generating regex
	
	$.expr[':'].local = (e) -> # finding local links
		return no if not e.attributes.href
		
		isLocal.test e.attributes.href.value
	
	fill = (response, callback) -> # replacing current page's content with the new one
		$container = $ $.joconut.container
		if $.joconut.container != 'body'
			try
				body = $(response).filter($.joconut.container).html()
				$container.html body
			catch err
				return emit 'error'
		else
			body = /<body[^>]*>((.|[\n\r])*)<\/body>/im.exec response
			$container.html if body then body[1] else response
		
		if body
			document.title = /<title>((.|\n\r])*)<\/title>/im.exec(response)[1] # set title
		
			$head = undefined # no need to find <head> now
		
			# load scripts, if needed
		
			loop
				tag = /<script\b[^>]*><\/script>/gm.exec response
				break if not tag
				src = /src\=.?([A-Za-z0-9-_.\/]+).?/.exec tag[0]
				break if not src
				src = src[1]
				if -1 is scripts.indexOf(src) # need to insert
					scripts.push src
					$head = $ 'head' if not $head
					$head.append tag[0]
				
				response = response.replace tag[0], ''
		
			# load stylesheets, if needed
		
			loop
				tag = /<link\b[^>]*\/?>/gm.exec response
				break if not tag
				if /rel\=.?stylesheet.?/.test tag[0]
					href = /href\=.?([A-Za-z0-9-_.\/]+).?/.exec tag[0]
					break if not href
					href = href[1]
					if -1 is stylesheets.indexOf(href) # need to insert
						stylesheets.push href
						$head = $ 'head' if not $head
						$head.append tag[0]
				
				response = response.replace tag[0], ''
		
			$('html, body').animate scrollTop: 0, 'fast' # scroll to top
		
		setTimeout -> # setting up a little timeout, waiting for HTML to get inserted
			$.joconut()
			do callback if callback
		, 50
	
	get = (options, callback) -> # GET
		emit 'beforeNew'
		$.ajax
			url: options.url
			type: 'GET'
			data: options.data
			timeout: 5000
			error: (xhr, status) ->
				callback status if callback
				emit 'error'
			beforeSend: (xhr) ->
				xhr.setRequestHeader 'X-PJAX', 'true'
			success: (response) ->
				fill response, ->
					_History.push { url: options.url }, false, options.url if options.history
					callback false, response if callback
					emit 'new'
					emit 'afterNew'
	
	_History.on 'change', (e) ->
		get url: e.state.url, history: no # just loading an URL
		emit 'new'
	
	scripts = []
	$('script').each ->
		scripts.push $(@).attr('src')
	
	stylesheets = []
	$('link').each ->
		stylesheets.push $(@).attr('href')
	
	$.joconut = -> # attach Joconut to links and forms
		$('a:local').live 'click', (e) ->
				do e.preventDefault
				
				get url: $(@).attr('href'), history: yes
	
	listeners = {}
	
	emit = (event) ->
		return if not listeners[event]
		
		listener() for listener in listeners[event]
	
	$.joconut.on = (event, listener) -> # attaching listeners to a specific event
		listeners[event] = [] if not listeners[event]
		listeners[event].push listener
	
	$.joconut.container = 'body'
	
	$ -> $.joconut() # auto-initialization
		
fn(jQuery)	