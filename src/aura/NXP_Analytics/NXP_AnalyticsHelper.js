({
    // Capture page attributes in this method
    handleRouteChange: function(component){

        var loc_pathname = location.pathname;
        var loc_title = document.title;

        // Set tag values to be sent to Adobe
        var tags = {
            'urlpath': loc_pathname,
            'content_title':  loc_title
        };
        console.log('TITLE:'+loc_title);
        this.sendToOmniture(component, tags);
    },

    sendToOmniture: function(component, tags) {

        //console.log('---- START sendToOmniture ---- ');

        // If Omniture Not ready or if these events are coming from community builder, ignore it.
        if (location.href.indexOf('commeditor') >= 0) {
            return;
        }

        //Send the data captured in handleRouteChange to the window
       // console.log('Posting message...');
        window.parent.postMessage({
            'tags' :tags
        }, location.protocol + "//" + location.host);

        //console.log('---- END sendToOmniture ---- ');
    },

})