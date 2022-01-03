/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Sent iLink SentiLinkDTODTO
 **/
@SuppressWarnings('PMD.VariableNamingConventions,PMD.AvoidGlobalModifier')
public with sharing class PlaidAccountDTO extends AbstractDTO {
  public static String removeReserveFields(String responseBody) {
    responseBody = responseBody.replace('"limit"', '"balanceLimit"');
    return responseBody;
  }

  public class Response {
    public List<Account> accounts { get; set; }
    public Item item { get; set; }
    public Numbers numbers { get; set; }
    public String request_id { get; set; }
  }

  public class Account {
    public String account_id { get; set; }
    public Balance balances { get; set; }
    public String mask { get; set; }
    public String name { get; set; }
    public String official_name { get; set; }
    public String subtype { get; set; }
    public String type { get; set; }
  }

  public class Balance {
    public Double available { get; set; }
    public Double current { get; set; }
    public String iso_currency_code { get; set; }
    public Double balanceLimit { get; set; } // in json: limit
    public String unofficial_currency_code { get; set; }
  }

  public class Item {
    public List<String> available_products { get; set; }
    public List<String> billed_products { get; set; }
    // public Object error { get; set; }
    public String institution_id { get; set; }
    public String item_id { get; set; }
    public String webhook { get; set; }
  }

  public class Numbers {
    public List<Ach> ach { get; set; }
  }
  public class Ach {
    public String account { get; set; }
    public String account_id { get; set; }
    public String routing { get; set; }
    public String wire_routing { get; set; }
  }
}
