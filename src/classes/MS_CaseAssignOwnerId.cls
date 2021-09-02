public with sharing class MS_CaseAssignOwnerId {

    public static void assignOwnerId() {
        List<Group> groups = [SELECT Id, Name FROM Group WHERE Type = 'Queue'];
        List<Case> cases = Trigger.new;
        Map<String, Id> mapOfId = new Map<String, Id>();
        for(Group gr : groups) {
            mapOfId.put(gr.Name, gr.Id);
        }

        for(Case c : cases) {
            if(c.Type == 'Payment') {
                c.OwnerId = mapOfId.get(c.Type);
            } else if(c.Type == 'Technical') {
                c.OwnerId = mapOfId.get(c.Type);
            } else if(c.Type == 'Shipment') {
                c.OwnerId = mapOfId.get(c.Type);
            }
        }
    }
}