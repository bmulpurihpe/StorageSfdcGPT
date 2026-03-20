trigger caseTriggerSetNimbleOsVersion on Case (before insert, before update) {
if(CaseUtility.CASETRIGGER_FLAG )
{
  new caseSetNimbleOsVersionHandler().run();
  }
}