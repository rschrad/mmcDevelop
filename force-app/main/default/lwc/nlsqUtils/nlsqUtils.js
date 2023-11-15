import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import hDefaultError from '@salesforce/label/c.hDefaultError';

export function getStatesByCountry(data) {
    const stateToCountry = Object.fromEntries(
        Object.entries(data.controllerValues).map(([key, value]) => [value, key])
    );

    return data.values.reduce((accumulatedStates, state) => {
        const countryIsoCode = stateToCountry[state.validFor[0]];

        return {
            ...accumulatedStates,
            [countryIsoCode]: [...(accumulatedStates?.[countryIsoCode] || []), state]
        };
    }, {});
}

/**
 * @state attribute used for url attributes
 * `const state = { status : 'success' }` -> `?status=success`
 * */
export function navigateToCommunityPage(component, pageName, state) {
    component[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
            name: pageName
        },
        state: state
    });
}

export function navigateToRecordPage(component, objectName, recordId, state) {
    component[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: recordId,
            objectApiName: objectName,
            actionName: 'view'
        },
        state: state
    });
}

export function navigateToListPage(component, objectName) {
    component[NavigationMixin.Navigate]({
        type: 'standard__objectPage',
        attributes: {
            objectApiName: objectName,
            actionName: 'list'
        }
    });
}

export function navigateToWebPage(component, url) {
    component[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
            url: url
        }
    });
}

export function showToast(component, title, message, variant, mode) {
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: mode
    });
    component.dispatchEvent(evt);
}

export function handleError(cmp, error) {
    console.error(error);
    let message = 'unknown error';
    if (typeof error === 'string') {
        message = error;
    } else if (error?.body?.message) {
        message = error.body.message;
    } else if (error != null && typeof error !== 'undefined') {
        message = error.toString();
    }
    const title = hDefaultError;
    const variant = 'error';
    showToast(cmp, title, message, variant);
}

export function convertResult(result) {
    let validRes = {};

    for (const [key, value] of Object.entries(result)) {
        validRes[`${key}`] = { value: value };
    }

    return validRes;
}