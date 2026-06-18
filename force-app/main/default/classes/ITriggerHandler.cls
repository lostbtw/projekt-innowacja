public interface ITriggerHandler {
  void beforeInsert(List<SObject> newList);
  void afterInsert(List<SObject> newList, Map<Id, SObject> newMap);
  void beforeUpdate(
    List<SObject> newList,
    Map<Id, SObject> newMap,
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  );
  void afterUpdate(
    List<SObject> newList,
    Map<Id, SObject> newMap,
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  );
  void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap);
  void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap);
  void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap);
  Boolean isDisabled();
}
