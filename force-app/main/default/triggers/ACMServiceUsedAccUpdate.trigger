trigger ACMServiceUsedAccUpdate on Asset(after insert, after update)
{
  new ACMServiceUsedAccUpdateHandler().run();
}