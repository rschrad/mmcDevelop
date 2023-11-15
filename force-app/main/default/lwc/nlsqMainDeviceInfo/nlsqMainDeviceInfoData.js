import NEILSQUIRE_RESOURCES from '@salesforce/resourceUrl/neilsquireResources';
import nlsqMainDeviceInfoLabels from './nlsqMainDeviceInfoLabels';

let labels = nlsqMainDeviceInfoLabels;
let icons = {
    likes: NEILSQUIRE_RESOURCES + '/img/likeStatistic.svg',
    downloads: NEILSQUIRE_RESOURCES + '/img/downloadStatistic.svg',
    shares: NEILSQUIRE_RESOURCES + '/img/shareStatistic.svg',
    views: NEILSQUIRE_RESOURCES + '/img/viewsStatistic.svg',
    electronics: NEILSQUIRE_RESOURCES + '/img/electronicsIcon.svg',
    mechanics: NEILSQUIRE_RESOURCES + '/img/mechanicsIcon.svg',
    customPCB: NEILSQUIRE_RESOURCES + '/img/customPCBIcon.svg',
    printing3d: NEILSQUIRE_RESOURCES + '/img/3DPrintingIcon.svg',
    laserCutting: NEILSQUIRE_RESOURCES + '/img/laserCuttingIcon.svg',
    software: NEILSQUIRE_RESOURCES + '/img/softwareIcon.svg',
    other: NEILSQUIRE_RESOURCES + '/img/otherIcon.svg'
};
let skillData = [
    {
        iconSrc: icons.electronics,
        skill: labels.labelElectronicSkill,
        display: false
    },
    {
        iconSrc: icons.mechanics,
        skill: labels.labelMechanicsSkill,
        display: false
    },
    {
        iconSrc: icons.customPCB,
        skill: labels.labelCustomPCBSkill,
        display: false
    },
    {
        iconSrc: icons.printing3d,
        skill: labels.labelPrinting3dSkill,
        display: false
    },
    {
        iconSrc: icons.laserCutting,
        skill: labels.labelLaserCuttingSkill,
        display: false
    },
    {
        iconSrc: icons.software,
        skill: labels.labelSoftwareSkill,
        display: false
    },
    {
        iconSrc: icons.other,
        skill: labels.labelOtherSkill,
        display: false
    }
];

export default {
    icons,
    skillData
};