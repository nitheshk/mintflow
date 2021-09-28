/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description  A basic controller for fetching NavigationMenuItems.
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class NavigationMenuItemsController {
  /**
   * Perform two SOQL queries to determine all the children NavigationMenuItems
   * belonging to the provided menuName and publishedState. This example uses the
   * NavigationLinkSet.MasterLabel for the menuName. One could also use the
   * NavigationLinkSet.Id to ensure referential integrity if the MasterLabel changes.
   *
   * NavigationLinkSet contains both Draft and Live versions of the NavigationMenuItems.
   * Use the publishedState enumeration to filter between them.
   *
   * Cacheable = true allows this function to be wired.
   */
  @AuraEnabled(cacheable=true)
  public static List<NavigationMenuItem> getNavigationMenuItems(
    String menuName,
    String publishedState
  ) {
    if (String.isEmpty(menuName)) {
      return new List<NavigationMenuItem>();
    }

    // find the link set belonging to the navigation menuName and active networkId
    NavigationLinkSet linkSet = (NavigationLinkSet) DatabaseUtils.getRecord(
      Query.newInstance(NavigationLinkSet.SObjectType)
        .addFields()
        .whereEq('DeveloperName', menuName)
        .andCon()
        .whereEq('NetworkId', Network.getNetworkId())
        .addLimit(1)
        .toString()
    );

    List<NavigationMenuItem> navMenu = (List<NavigationMenuItem>) DatabaseUtils.getRecords(
      Query.newInstance(NavigationMenuItem.SObjectType)
        .addFields(
          'Label,Target,Type,DefaultListViewId,AccessRestriction,ParentId,Position,Status,TargetPrefs'
        )
        .whereEq('NavigationLinkSetId', linkSet?.id)
        .andCon()
        .whereEq('Status', publishedState)
        .orderBy('Position')
        .toString()
    );

    system.debug('navMenu : ' + navMenu.size());
    return navMenu;
  }
}
