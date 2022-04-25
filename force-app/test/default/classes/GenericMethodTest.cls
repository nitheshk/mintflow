@istest
public with sharing class GenericMethodTest {
  //NavigationMenuItemsController test
  @istest
  private static void NavigationMenuItemsControllerTest() {
    NavigationMenuItemsController.getNavigationMenuItems('', 'publishedState');

    NavigationMenuItemsController.getNavigationMenuItems('menuName', 'publishedState');
  }

  //NavigationLinkSetPickList test
  @istest
  private static void NavigationLinkSetPickListTest() {
    NavigationLinkSetPickList obj = new NavigationLinkSetPickList();
    obj.getDefaultValue();

    obj.getValues();
  }
}
