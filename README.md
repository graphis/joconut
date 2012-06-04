# Joconut

Never load a full page on every request again.

# Getting Started
Download the [production version][min] or the [development version][max].

[min]: https://raw.github.com/vdemedes/joconut/master/dist/joconut.min.js
[max]: https://raw.github.com/vdemedes/joconut/master/dist/joconut.js

Include it in your web pages(1.3kb minified and gzipped):

```html
<script src="joconut.min.js"></script> <!-- you must include jQuery before that -->
```

That's it! Now, all your local links will not cause page refresh. Remote links will work as expected.

## Events

You can listen to some events Joconut can emit using **on** method:
```javascript
$.joconut.on('error', function(){ // fires on timeout, page without <body>, invalid requests
	alert('Error while loading new page!');
});

$.joconut.on('new', function(){ // Page changed
	alert('New page!');
});

$.joconut.on('beforeNew', function(){ // page will be loaded now
	alert('Before loading new page');
});

$.joconut.on('afterNew', function(){ // page was just loaded
	alert('After loading new page');
});
```

## Extra

You can force Joconut to replace only part of the page by specifying selector of that part:

```javascript
$.joconut.container = '#container'; // default is 'body'
```

# Features

- Lightweight(1.3kb minified and gzipped)
- Detects and loads scripts and stylesheets from fetched pages, if they do not exist in the current one
- HTML5 History API support with fallback to location.hash
- Can replace only specific part of the page

# How is it different from the existing PJAX plugin?

1. 1.3kb minified and gzipped
2. Auto-detects and loads JS and CSS from fetched pages, if needed
3. No need to set up or configure

# Browser support

[pushstate]: http://caniuse.com/#search=pushstate
[hashchange]: http://caniuse.com/#search=hashchange

Joconut can work in browsers, which support HTML5 History API or hashchange event. For the list of supported browsers check out these links: [pushstate][pushstate] and [hashchange][hashchange]

# Tests

You should have **node** to be installed. ```cd test && npm i connect route66 && node server.js```. Navigate to http://localhost:3000 after that and play.

# License

Copyright (c) 2012 Vadim Demedes  
Licensed under the MIT license.