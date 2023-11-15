const requiredFields = ['FirstName', 'LastName', 'Email', 'terms', 'privacy'];

export function validateField(component, name, data) {
    const field = component.template.querySelector(`[data-name="${name}"]`);
    const errorField = component.template.querySelector(`[data-name="${name}-error"]`);

    if (data) {
        field.classList.remove('slds-has-error');
        errorField.classList.add('slds-hide');
    } else {
        field.classList.add('slds-has-error');
        errorField.classList.remove('slds-hide');
    }
}

export function validateRequiredFields(component) {
    let isValid = true;

    requiredFields.forEach((name) => {
        const field = component.template.querySelector(`[name="${name}"]`);

        if (!field.value || field.value === 'false') {
            isValid = false;
            validateField(component, name, false);
        }
    });

    if (component.rolesValue.length === 0) {
        isValid = false;
        validateField(component, 'Portal_Roles__c', false);
    }

    if (!component.currentContact.MailingCountryCode) {
        component.template.querySelector('c-nlsq-country-and-state').reportValidity('country');
        isValid = false;
    }

    if (
        component.statesByCountry[component.currentContact.MailingCountryCode] &&
        !component.currentContact.MailingStateCode
    ) {
        component.template.querySelector('c-nlsq-country-and-state').reportValidity('state');
        isValid = false;
    }

    return isValid;
}