public with sharing class MS_CaseHandler extends MS_TriggerHandler{
    public MS_CaseHandler() {
        super();
    }

    public void bulkBefore() {
        MS_CaseAssignOwnerId.assignOwnerId();
    }
}