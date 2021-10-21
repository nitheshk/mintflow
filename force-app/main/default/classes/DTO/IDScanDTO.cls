public with sharing class IDScanDTO extends AbstractDTO {
  public class Response {
    public Result result;
    public Verification verification;
    public Authentication authentication;
    public String responseID;
  }
  public class Authentication {
    public Double score;
    public Breakdown breakdown;
    public List<String> warning;
  }

  public class RecaptureCheck {
    public Boolean passed;
    public Integer code;
    public String reason;
    public String severity;
  }

  public class Breakdown {
    public ImageQuality image_quality;
    public ImageQuality security_feature_check;
    public RecaptureCheck recapture_check;
  }

  public class Verification {
    public Boolean passed;
    public ResultZ result;
  }

  public class ResultZ {
    public Boolean notexpired;
  }

  public class Result {
    public String documentNumber;
    public String firstName;
    public String middleName;
    public String lastName;
    public String fullName;
    public String sex;
    public String height;
    public String weight;
    public Integer age;
    public String dob;
    public Integer dob_day;
    public Integer dob_month;
    public Integer dob_year;
    public String expiry;
    public Integer expiry_day;
    public Integer expiry_month;
    public Integer expiry_year;
    public Integer daysToExpiry;
    public String issued;
    public Integer issued_day;
    public Integer issued_month;
    public Integer issued_year;
    public String address1;
    public String address2;
    public String postcode;
    public String documentType;
    public String issuerOrg_region_full;
    public String issuerOrg_region_abbr;
    public String issuerOrg_iso3;
    public String nationality_full;
  }

  public class ImageQuality {
    public Boolean passed;
  }
}
