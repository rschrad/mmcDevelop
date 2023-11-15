({
    init: function (component) {
        component.set("v.userId", $A.get("$SObjectType.CurrentUser.Id"));
    },

    handleRecordUpdated: function (component, event) {
        const eventParams = event.getParams();
        let currentUser;
        let maker;
        let requestor;

        if (eventParams.changeType === "LOADED") {
            currentUser = component.get("v.userId");
            maker = component.get("v.request.Maker__c");
            requestor = component.get("v.request.OwnerId");
        }

        if (eventParams.changeType === "CHANGED" && eventParams.changedFields.Maker__c) {
            maker = eventParams.changedFields.Maker__c.value;
        }

        const isMakerPresent = maker !== null;
        const isShown = isMakerPresent ? currentUser === maker || currentUser === requestor : false;
        component.set("v.isShown", isShown);
    },

    handleReceiveMessage: function (component, event) {
        if (event) {
            const id = event.getParam("recordId");

            if (id) component.set("v.isShown", true);
        }
    }
});