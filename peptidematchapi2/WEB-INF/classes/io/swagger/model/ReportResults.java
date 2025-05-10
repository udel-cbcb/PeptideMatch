package io.swagger.model;

import java.util.Objects;
import java.util.ArrayList;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import io.swagger.model.Protein;
import java.util.List;
import javax.validation.constraints.*;
import io.swagger.annotations.*;


@javax.annotation.Generated(value = "io.swagger.codegen.languages.JavaResteasyServerCodegen", date = "2017-11-18T03:46:12.401Z")
public class ReportResults   {
  
  private String queryPeptide = null;
  private List<Protein> proteins = new ArrayList<Protein>();

  /**
   * Query peptide sequence.
   **/
  
  @ApiModelProperty(value = "Query peptide sequence.")
  @JsonProperty("queryPeptide")
  public String getQueryPeptide() {
    return queryPeptide;
  }
  public void setQueryPeptide(String queryPeptide) {
    this.queryPeptide = queryPeptide;
  }

  /**
   **/
  
  @ApiModelProperty(value = "")
  @JsonProperty("proteins")
  public List<Protein> getProteins() {
    return proteins;
  }
  public void setProteins(List<Protein> proteins) {
    this.proteins = proteins;
  }


  @Override
  public boolean equals(java.lang.Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    ReportResults reportResults = (ReportResults) o;
    return Objects.equals(queryPeptide, reportResults.queryPeptide) &&
        Objects.equals(proteins, reportResults.proteins);
  }

  @Override
  public int hashCode() {
    return Objects.hash(queryPeptide, proteins);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class ReportResults {\n");
    
    sb.append("    queryPeptide: ").append(toIndentedString(queryPeptide)).append("\n");
    sb.append("    proteins: ").append(toIndentedString(proteins)).append("\n");
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

