public with sharing class FileService {
    public static void processDeviceFiles(Id recordId, List<ContentVersion> contentVersions) {
        List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();
        for (ContentVersion file : contentVersions) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
            cdl.ContentDocumentId = file.ContentDocumentId;
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
            contentLinks.add(cdl);
        }

        NLSQDMLServiceWS.updateRecords(contentVersions); // update Titles
        NLSQDMLServiceWS.insertRecords(contentLinks);
    }
}