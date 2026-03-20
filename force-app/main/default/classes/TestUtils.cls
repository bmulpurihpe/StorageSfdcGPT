public class TestUtils
{
  public static Boolean enable_isRunningTest = true;

  public static Boolean isRunningTest()
  {
    return Test.isRunningTest() && enable_IsRunningTest;
  }
}