trigger MS_ContentDocumentLink on ContentDocumentLink (before insert) {
    List<ContentDocumentLink> contentDocumentLinks=new List<ContentDocumentLink>();
    for(ContentDocumentLink contentDocumentLink:Trigger.new){
        contentDocumentLink.Visibility='AllUsers';
        contentDocumentLink.ShareType='I';
        contentDocumentLinks.add(contentDocumentLink);
    }
}