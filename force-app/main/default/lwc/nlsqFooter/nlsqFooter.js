import { LightningElement } from 'lwc';
import NEILSQUIRE_RESOURCES from '@salesforce/resourceUrl/neilsquireResources';
import importLabels from './nlsqFooterLabels';
export default class NlsqFooter extends LightningElement {
    footerLogo = NEILSQUIRE_RESOURCES + '/img/logoWhite.svg';
    letterIcon = NEILSQUIRE_RESOURCES + '/img/Message.svg';
    facebookIcon = NEILSQUIRE_RESOURCES + '/img/facebookIcon.svg';
    instagramIcon = NEILSQUIRE_RESOURCES + '/img/instagramIcon.svg';
    linkedinIcon = NEILSQUIRE_RESOURCES + '/img/linkedinIcon.svg';
    twitterIcon = NEILSQUIRE_RESOURCES + '/img/twitterIcon.svg';
    youtubeIcon = NEILSQUIRE_RESOURCES + '/img/youtubeIcon.svg';

    labels = importLabels;

    get currentYear() {
        return new Date().getFullYear();
    }
}