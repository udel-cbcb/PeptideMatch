package io.swagger.model;

import java.util.Objects;
import java.util.ArrayList;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import io.swagger.annotations.ApiModel;
import io.swagger.model.ProteinMatchingPeptide;
import java.util.List;
import javax.validation.constraints.*;
import io.swagger.annotations.*;

@ApiModel(description="Matched UniProt protein")
@javax.annotation.Generated(value = "io.swagger.codegen.languages.JavaResteasyServerCodegen", date = "2017-11-19T01:42:04.689Z")
public class Protein   {
  
  private String reviewStatus = null;
  private String ac = null;
  private String id = null;
  private String name = null;
  private String orgName = null;
  private Integer orgTaxonId = null;
  private String orgTaxonGroupName = null;
  private Integer orgTaxonGroupId = null;
  private String sequence = null;
  private List<ProteinMatchingPeptide> matchingPeptide = new ArrayList<ProteinMatchingPeptide>();

  /**
   * SwissProt or TrEMBL entry.
   **/
  
  @ApiModelProperty(value = "SwissProt or TrEMBL entry.")
  @JsonProperty("reviewStatus")
  public String getReviewStatus() {
    return reviewStatus;
  }
  public void setReviewStatus(String reviewStatus) {
    this.reviewStatus = reviewStatus;
  }

  /**
   * Protein accession number.
   **/
  
  @ApiModelProperty(value = "Protein accession number.")
  @JsonProperty("ac")
  public String getAc() {
    return ac;
  }
  public void setAc(String ac) {
    this.ac = ac;
  }

  /**
   * Protein ID.
   **/
  
  @ApiModelProperty(value = "Protein ID.")
  @JsonProperty("id")
  public String getId() {
    return id;
  }
  public void setId(String id) {
    this.id = id;
  }

  /**
   * Protein name.
   **/
  
  @ApiModelProperty(value = "Protein name.")
  @JsonProperty("name")
  public String getName() {
    return name;
  }
  public void setName(String name) {
    this.name = name;
  }

  /**
   * Organism name.
   **/
  
  @ApiModelProperty(value = "Organism name.")
  @JsonProperty("orgName")
  public String getOrgName() {
    return orgName;
  }
  public void setOrgName(String orgName) {
    this.orgName = orgName;
  }

  /**
   * Organism taxonomy ID.
   **/
  
  @ApiModelProperty(value = "Organism taxonomy ID.")
  @JsonProperty("orgTaxonId")
  public Integer getOrgTaxonId() {
    return orgTaxonId;
  }
  public void setOrgTaxonId(Integer orgTaxonId) {
    this.orgTaxonId = orgTaxonId;
  }

  /**
   * Organism taxonomy group name.
   **/
  
  @ApiModelProperty(value = "Organism taxonomy group name.")
  @JsonProperty("orgTaxonGroupName")
  public String getOrgTaxonGroupName() {
    return orgTaxonGroupName;
  }
  public void setOrgTaxonGroupName(String orgTaxonGroupName) {
    this.orgTaxonGroupName = orgTaxonGroupName;
  }

  /**
   * Organism taxonomy group ID.
   **/
  
  @ApiModelProperty(value = "Organism taxonomy group ID.")
  @JsonProperty("orgTaxonGroupId")
  public Integer getOrgTaxonGroupId() {
    return orgTaxonGroupId;
  }
  public void setOrgTaxonGroupId(Integer orgTaxonGroupId) {
    this.orgTaxonGroupId = orgTaxonGroupId;
  }

  /**
   * Protein sequence.
   **/
  
  @ApiModelProperty(value = "Protein sequence.")
  @JsonProperty("sequence")
  public String getSequence() {
    return sequence;
  }
  public void setSequence(String sequence) {
    this.sequence = sequence;
  }

  /**
   **/
  
  @ApiModelProperty(value = "")
  @JsonProperty("matchingPeptide")
  public List<ProteinMatchingPeptide> getMatchingPeptide() {
    return matchingPeptide;
  }
  public void setMatchingPeptide(List<ProteinMatchingPeptide> matchingPeptide) {
    this.matchingPeptide = matchingPeptide;
  }


  @Override
  public boolean equals(java.lang.Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    Protein protein = (Protein) o;
    return Objects.equals(reviewStatus, protein.reviewStatus) &&
        Objects.equals(ac, protein.ac) &&
        Objects.equals(id, protein.id) &&
        Objects.equals(name, protein.name) &&
        Objects.equals(orgName, protein.orgName) &&
        Objects.equals(orgTaxonId, protein.orgTaxonId) &&
        Objects.equals(orgTaxonGroupName, protein.orgTaxonGroupName) &&
        Objects.equals(orgTaxonGroupId, protein.orgTaxonGroupId) &&
        Objects.equals(sequence, protein.sequence) &&
        Objects.equals(matchingPeptide, protein.matchingPeptide);
  }

  @Override
  public int hashCode() {
    return Objects.hash(reviewStatus, ac, id, name, orgName, orgTaxonId, orgTaxonGroupName, orgTaxonGroupId, sequence, matchingPeptide);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class Protein {\n");
    
    sb.append("    reviewStatus: ").append(toIndentedString(reviewStatus)).append("\n");
    sb.append("    ac: ").append(toIndentedString(ac)).append("\n");
    sb.append("    id: ").append(toIndentedString(id)).append("\n");
    sb.append("    name: ").append(toIndentedString(name)).append("\n");
    sb.append("    orgName: ").append(toIndentedString(orgName)).append("\n");
    sb.append("    orgTaxonId: ").append(toIndentedString(orgTaxonId)).append("\n");
    sb.append("    orgTaxonGroupName: ").append(toIndentedString(orgTaxonGroupName)).append("\n");
    sb.append("    orgTaxonGroupId: ").append(toIndentedString(orgTaxonGroupId)).append("\n");
    sb.append("    sequence: ").append(toIndentedString(sequence)).append("\n");
    sb.append("    matchingPeptide: ").append(toIndentedString(matchingPeptide)).append("\n");
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

