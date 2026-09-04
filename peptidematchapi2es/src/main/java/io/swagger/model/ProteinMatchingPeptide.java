package io.swagger.model;

import java.util.Objects;
import java.util.ArrayList;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import io.swagger.model.ProteinMatchRange;
import java.util.List;
import javax.validation.constraints.*;
import io.swagger.annotations.*;


@javax.annotation.Generated(value = "io.swagger.codegen.languages.JavaResteasyServerCodegen", date = "2017-11-19T01:42:04.689Z")
public class ProteinMatchingPeptide   {
  
  private String peptide = null;
  private List<ProteinMatchRange> matchRange = new ArrayList<ProteinMatchRange>();

  /**
   * Query peptide.
   **/
  
  @ApiModelProperty(value = "Query peptide.")
  @JsonProperty("peptide")
  public String getPeptide() {
    return peptide;
  }
  public void setPeptide(String peptide) {
    this.peptide = peptide;
  }

  /**
   **/
  
  @ApiModelProperty(value = "")
  @JsonProperty("matchRange")
  public List<ProteinMatchRange> getMatchRange() {
    return matchRange;
  }
  public void setMatchRange(List<ProteinMatchRange> matchRange) {
    this.matchRange = matchRange;
  }


  @Override
  public boolean equals(java.lang.Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    ProteinMatchingPeptide proteinMatchingPeptide = (ProteinMatchingPeptide) o;
    return Objects.equals(peptide, proteinMatchingPeptide.peptide) &&
        Objects.equals(matchRange, proteinMatchingPeptide.matchRange);
  }

  @Override
  public int hashCode() {
    return Objects.hash(peptide, matchRange);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class ProteinMatchingPeptide {\n");
    
    sb.append("    peptide: ").append(toIndentedString(peptide)).append("\n");
    sb.append("    matchRange: ").append(toIndentedString(matchRange)).append("\n");
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

