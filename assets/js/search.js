---

---
// Based on a script by Kathie Decora : katydecorah.com/code/lunr-and-jekyll/ updated for this project 


// Create the lunr index for the search
var index = elasticlunr(function () {
  this.use(elasticlunr.de);
  this.addField('title')
  this.addField('author')
  this.addField('layout')
  this.addField('content')
  this.addField('search')
  this.setRef('id')
});

// Add to this index the proper metadata from the Jekyll content
{% assign count = 0 %}{% for text in site.texts %}
index.addDoc({
  title: {{text.title | jsonify}},
  author: {{text.author | jsonify}},
  layout: {{text.layout | jsonify}},
  search: {{text.search | jsonify}},
  content: {{text.content | jsonify | strip_html}},
  id: {{count}}
});{% assign count = count | plus: 1 %}{% endfor %}
console.log( jQuery.type(index) );
console.log( index );

// Builds reference data (maybe not necessary for us, to check)
var store = [{% for text in site.texts %}{
  "title": {{text.title | jsonify}},
  "author": {{ text.author | jsonify }},
  "layout": {{ text.layout | jsonify }},
  "xml": "{{ '/data/' | append: text.name | append: '/' | append: text.name | append: '.xml' | relative_url }}",
  "html": "{{ text.url | relative_url }}"
}{% unless forloop.last %},{% endunless %}{% endfor %}]



// Query
var qd = {}; // Gets values from the URL
location.search.substr(1).split("&").forEach(function(item) {
    var s = item.split("="),
        k = s[0],
        v = s[1] && decodeURIComponent(s[1]);
    (k in qd) ? qd[k].push(v) : qd[k] = [v]
});

function doSearch() {
  var resultdiv = $('#results');
  var query = $('input#search').val();

  // The search is then launched on the index built with Lunr
  var result = index.search(query, {expand: true});
  resultdiv.empty();
  if (result.length == 0) {
    resultdiv.append('<div class="alert">No results found.</div>');
  } else if (result.length == 1) {
    resultdiv.append('<div class="alert">Found in '+result.length+' text</div><br/>');
  } else {
    resultdiv.append('<div class="alert">Found in '+result.length+' texts</div><br/>');
  }
  // Loop through, match, and add results
  for (var item in result) {
    var ref = result[item].ref;

    var searchitem = $(
        '<div class="result">' +
            '<p class="clickable" data-xml="'+store[ref].xml+'" data-query="'+query+'" data-html="'+store[ref].html+'">' +
                '<span style="color: #75b5aa;">▼ </span>' + store[ref].author + ': ' +store[ref].title +
            '</p>' +
            '<div class="subresults" style="display: none;"></div>' +
        '</div>'
    );

    resultdiv.append(searchitem);
}
}

$(document).ready(function() {
  if (qd.q) {
    $('input#search').val(qd.q[0]);
    doSearch();
  }
  $('input#search').on('keyup', doSearch);
});

// Toggle arrow and subresults on click
$(document).on('click', '.clickable', function() {
    var arrow = $(this).find('span');        // the ▼ arrow
    var sub = $(this).siblings('.subresults'); // the hidden div

    sub.toggle();                            // show/hide subresults
    arrow.text(sub.is(':visible') ? '▲ ' : '▼ '); // switch arrow
});
