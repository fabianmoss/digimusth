// Handle clicks on Lunr search results
$(document).on('click', '.clickable', function() {
    var container = $(this).siblings('.subresults');
    var xmlPath = $(this).data('xml');    // path to XML file
    var htmlPath = $(this).data('html');  // path to HTML page
    var query = $(this).data('query');

    container.empty().append('<p>Loading...</p>');

    fetch(xmlPath)
        .then(res => res.text())
        .then(str => (new DOMParser()).parseFromString(str, "text/xml"))
        .then(xml => {
            var kwicResults = searchXMLWithKWIC(xml, query);

            container.empty();
            if (kwicResults.length === 0) {
                container.append('<p>No results found in XML.</p>');
            } else {
                kwicResults.forEach(r => {
                    //const facsParam = r.p_facs ? '#facs=' + encodeURIComponent(r.p_facs) : '';
                    const queryParam = '?q=' + encodeURIComponent(query);
                    //const link = htmlPath + queryParam + facsParam;
                   if (r.p_facs) {
                        // If r.p_facs has multiple IDs separated by space or comma, pick the first
                        facsValue = r.p_facs.split(/[\s,]+/)[0];
                    }
                    const facsParam = facsValue ? '#facs=' + encodeURIComponent(facsValue) : '';
                    const link = htmlPath + queryParam + facsParam;
                //const facsParam = r.p_facs ? '#facs=' + encodeURIComponent(r.p_facs) : '';
                //const queryParam = '&q=' + encodeURIComponent(query);
                var highlightedKWIC = r.kwic.replace(new RegExp(query, 'gi'), '<mark>$&</mark>');
                container.append('<div class="xml-result"><p>'+highlightedKWIC+' <a href="'+link + '">View full 🡵</a></p></div>');

            });
            }
        })
        .catch(err => {
            console.error('Error fetching XML:', err);
            container.empty().append('<p>Error loading XML.</p>');
        });
});

// Substring KWIC search across all XML text
function searchXMLWithKWIC(xml, query) {
    const results = [];
    const lowerQuery = query.toLowerCase();

    // look at <p> tags -> might has to be adjusted 
    const pNodes = xml.getElementsByTagName('p');

    Array.from(pNodes).forEach(p => {
        const text = p.textContent;
        const lowerText = text.toLowerCase();
        let index = lowerText.indexOf(lowerQuery);

        while (index >= 0) {
            const start = Math.max(0, index - 40);
            const end = Math.min(text.length, index + query.length + 40);
            results.push({
                kwic: '...' + text.substring(start, end) + '...',
                p_facs: p.getAttribute('facs') || null
            });
            index = lowerText.indexOf(lowerQuery, index + 1);
        }
    });

    return results;
}
