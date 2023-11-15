import { createRecord, deleteRecord } from 'lightning/uiRecordApi';
import { handleError } from 'c/nlsqUtils';
import userId from '@salesforce/user/Id';
import getDeviceInfo from '@salesforce/apex/MainDeviceInfoCtrl.getDeviceInfo';
import updateCount from '@salesforce/apex/MainDeviceInfoCtrl.updateCount';
import getUserLike from '@salesforce/apex/MainDeviceInfoCtrl.getUserLike';
import nlsqMainDeviceInfoData from './nlsqMainDeviceInfoData';

let deviceInfoData = nlsqMainDeviceInfoData;

export function loadDeviceInfo(cmp) {
    getDeviceInfo({ recordId: cmp.recordId })
        .then((result) => {
            cmp.device = result;
            cmp.isUserDesigner = result.Designer__c === userId;
            if (!result.IsActive && cmp.isUserDesigner) {
                cmp.isDesignerInactiveDevice = true;
            }
            if (cmp.device.Projects_Skills__c) {
                let deviceSkills = cmp.device.Projects_Skills__c.split(';');
                deviceSkills.forEach((element) => {
                    deviceInfoData.skillData.forEach((elem) => {
                        if (elem.skill === element) {
                            elem.display = true;
                        }
                    });
                });
            }
        })
        .catch((error) => handleError(cmp, error));
}

export function formatNumber(num) {
    if (!num) {
        return 0;
    }
    const THOUSANDS_SUFFIXES = ['k', 'M', 'G', 'T', 'P', 'E'];

    const numLog = Math.log10(num); //not supported in IE
    const suffixesAmount = THOUSANDS_SUFFIXES.length;

    if (numLog < 3) {
        return num.toString();
    }

    const toSuffixedDecimal = (val, suffixIndex) => {
        let shortNumber = Math.round((val / Math.pow(10, (suffixIndex + 1) * 3)) * 10) / 10;
        if (shortNumber >= 1000 && THOUSANDS_SUFFIXES[suffixIndex + 1]) {
            shortNumber = Math.round(shortNumber / 1000);
            suffixIndex += 1;
        }
        return shortNumber.toString() + THOUSANDS_SUFFIXES[suffixIndex];
    };

    if (Math.round(numLog / 3) > suffixesAmount) {
        return toSuffixedDecimal(num, suffixesAmount - 1);
    }

    let suffixIndex = (numLog - (numLog % 3)) / 3 - 1;

    return toSuffixedDecimal(num, suffixIndex);
}

export function updateCountField(cmp, field) {
    if (cmp.device) {
        cmp.device[field] += 1;
    }
    updateCount({ recordId: cmp.recordId, field }).catch((error) => handleError(cmp, error));
}

export function loadUserLike(cmp) {
    getUserLike({ recordId: cmp.recordId })
        .then((result) => (cmp.likeId = result))
        .catch((error) => handleError(cmp, error));
}

export function unsetLikeProduct(cmp) {
    deleteRecord(cmp.likeId)
        .then(() => {
            cmp.likeId = null;
            cmp.device.Likes_Count__c--;
        })
        .catch((error) => handleError(cmp, error))
        .finally(() => (cmp.isLikeDisabled = false));
}

export function setLikeProduct(cmp) {
    const fields = { Device__c: cmp.recordId };
    const apiName = 'Device_Like__c';
    const recordInput = { apiName, fields };
    createRecord(recordInput)
        .then((like) => {
            cmp.likeId = like.id;
            cmp.device.Likes_Count__c++;
        })
        .catch((error) => handleError(cmp, error))
        .finally(() => (cmp.isLikeDisabled = false));
}