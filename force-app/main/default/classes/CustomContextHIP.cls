global class CustomContextHIP implements CoveoV2.HostedCustomContextInterface {
  public Map<String, Object> getCustomContext(Map<String, Object> data) {
      Id userProfileId = UserInfo.getProfileId();
      String userProfileName = [SELECT Name FROM Profile WHERE Id = :userProfileId].Name;
    return new Map<String, Object>{'groupName' => userProfileName };
  }
}