package io.swagger.model;

import java.util.Objects;
import java.util.ArrayList;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import javax.validation.constraints.*;
import io.swagger.annotations.*;


@javax.annotation.Generated(value = "io.swagger.codegen.languages.JavaResteasyServerCodegen", date = "2017-11-18T03:46:12.401Z")
public class ReportSearchParameters   {
  
  private String taxonids = null;
  private Boolean swissprot = null;
  private Boolean isoform = null;
  private Boolean uniref100 = null;
  private Boolean leqi = null;
  private Integer offset = null;
  private Integer size = null;

  /**
   * NCBI taxonomy IDs.
   **/
  
  @ApiModelProperty(value = "NCBI taxonomy IDs.")
  @JsonProperty("taxonids")
  public String getTaxonids() {
    return taxonids;
  }
  public void setTaxonids(String taxonids) {
    this.taxonids = taxonids;
  }

  /**
   * Only search SwissProt protein sequences.
   **/
  
  @ApiModelProperty(value = "Only search SwissProt protein sequences.")
  @JsonProperty("swissprot")
  public Boolean getSwissprot() {
    return swissprot;
  }
  public void setSwissprot(Boolean swissprot) {
    this.swissprot = swissprot;
  }

  /**
   * Include isoforms.
   **/
  
  @ApiModelProperty(value = "Include isoforms.")
  @JsonProperty("isoform")
  public Boolean getIsoform() {
    return isoform;
  }
  public void setIsoform(Boolean isoform) {
    this.isoform = isoform;
  }

  /**
   * Only search UniRef100 protein sequences.
   **/
  
  @ApiModelProperty(value = "Only search UniRef100 protein sequences.")
  @JsonProperty("uniref100")
  public Boolean getUniref100() {
    return uniref100;
  }
  public void setUniref100(Boolean uniref100) {
    this.uniref100 = uniref100;
  }

  /**
   * Treat Leucine (L) and Isoleucine (I) equivalent.
   **/
  
  @ApiModelProperty(value = "Treat Leucine (L) and Isoleucine (I) equivalent.")
  @JsonProperty("leqi")
  public Boolean getLeqi() {
    return leqi;
  }
  public void setLeqi(Boolean leqi) {
    this.leqi = leqi;
  }

  /**
   * Off set, page starting point, with default value 0
   **/
  
  @ApiModelProperty(value = "Off set, page starting point, with default value 0")
  @JsonProperty("offset")
  public Integer getOffset() {
    return offset;
  }
  public void setOffset(Integer offset) {
    this.offset = offset;
  }

  /**
   * Page size with default value 100. When page size is -1, it returns all records and offset will be ignored
   **/
  
  @ApiModelProperty(value = "Page size with default value 100. When page size is -1, it returns all records and offset will be ignored")
  @JsonProperty("size")
  public Integer getSize() {
    return size;
  }
  public void setSize(Integer size) {
    this.size = size;
  }


  @Override
  public boolean equals(java.lang.Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    ReportSearchParameters reportSearchParameters = (ReportSearchParameters) o;
    return Objects.equals(taxonids, reportSearchParameters.taxonids) &&
        Objects.equals(swissprot, reportSearchParameters.swissprot) &&
        Objects.equals(isoform, reportSearchParameters.isoform) &&
        Objects.equals(uniref100, reportSearchParameters.uniref100) &&
        Objects.equals(leqi, reportSearchParameters.leqi) &&
        Objects.equals(offset, reportSearchParameters.offset) &&
        Objects.equals(size, reportSearchParameters.size);
  }

  @Override
  public int hashCode() {
    return Objects.hash(taxonids, swissprot, isoform, uniref100, leqi, offset, size);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class ReportSearchParameters {\n");
    
    sb.append("    taxonids: ").append(toIndentedString(taxonids)).append("\n");
    sb.append("    swissprot: ").append(toIndentedString(swissprot)).append("\n");
    sb.append("    isoform: ").append(toIndentedString(isoform)).append("\n");
    sb.append("    uniref100: ").append(toIndentedString(uniref100)).append("\n");
    sb.append("    leqi: ").append(toIndentedString(leqi)).append("\n");
    sb.append("    offset: ").append(toIndentedString(offset)).append("\n");
    sb.append("    size: ").append(toIndentedString(size)).append("\n");
    sb.append("}");
    return sb.toString();
  }

  /**
   * Convert the given object to string with each line indented by 4 spaces
   * (except the first line).
   */
  private String toIndentedString(java.lang.Object o) {
    if (o == null) {
      return "null";
    }
    return o.toString().replace("\n", "\n    ");
  }
}

