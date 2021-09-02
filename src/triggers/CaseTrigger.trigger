trigger CaseTrigger on Case (before insert) {

    MS_TriggerHandler handler = new MS_CaseHandler();
    handler.execute();
}