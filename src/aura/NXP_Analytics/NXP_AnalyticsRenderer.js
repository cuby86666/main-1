({
    // Your renderer method overrides go here
    afterRender: function(component, helper) {
        /*
        console.log('---- START afterRender ---- ');
        this.superAfterRender();
        //var omnitureReady = component.get("v.omnitureReady");
        if (!omnitureReady) {
            // Listen for Omniture Readiness
            window.addEventListener('message', function(event) {
                if (event.data === 'omnitureReady') {
                    component.set("v.omnitureReady", true);
                    console.log('Omniture is Ready!');
                    helper.handleRouteChange(component);
                }
            });
        }

        console.log('afterRender omnitureReady: '+omnitureReady);
        console.log('---- END afterRender ---- ');*/
    }
})