package io.swagger.model;

import java.util.Objects;
import java.util.ArrayList;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;

import io.swagger.model.ReportResults;
import io.swagger.model.ReportSearchParameters;

import java.util.List;

import javax.validation.constraints.*;
import javax.ws.rs.core.GenericEntity;
import javax.xml.bind.annotation.XmlRootElement;

import io.swagger.annotations.*;

@XmlRootElement(name = "report")
@javax.annotation.Generated(value = "io.swagger.codegen.languages.JavaResteasyServerCodegen", date = "2017-11-18T03:46:12.401Z")
public class Report   {
  
  private Integer numberFound = null;
  private Integer qtime = null;
  private Integer status = null;
  private ReportSearchParameters searchParameters = null;
  private List<ReportResults> results = new ArrayList<ReportResults>();

  /**
   * Number of documents found.
   **/
  
  @ApiModelProperty(value = "Number of documents found.")
  @JsonProperty("numberFound")
  public Integer getNumberFound() {
    return numberFound;
  }
  public void setNumberFound(Integer numberFound) {
    this.numberFound = numberFound;
  }

  /**
   * Number of leading documents to skip.
   **/
  

  /**
   * Query response time in milliseocnds.
   **/
  
  @ApiModelProperty(value = "Query response time in milliseocnds.")
  @JsonProperty("qtime")
  public Integer getQtime() {
    return qtime;
  }
  public void setQtime(Integer qtime) {
    this.qtime = qtime;
  }

  /**
   * Query response status.
   **/
  
  @ApiModelProperty(value = "Query response status.")
  @JsonProperty("status")
  public Integer getStatus() {
    return status;
  }
  public void setStatus(Integer status) {
    this.status = status;
  }

  /**
   **/
  
  @ApiModelProperty(value = "")
  @JsonProperty("searchParameters")
  public ReportSearchParameters getSearchParameters() {
    return searchParameters;
  }
  public void setSearchParameters(ReportSearchParameters searchParameters) {
    this.searchParameters = searchParameters;
  }

  /**
   **/
  
  @ApiModelProperty(value = "")
  @JsonProperty("results")
  public List<ReportResults> getResults() {
	    GenericEntity<List<ReportResults>> entity = new GenericEntity<List<ReportResults>>(results) {};

    return results;
	 //   return entity;
  }
  public void setResults(List<ReportResults> results) {
    this.results = results;
  }


  @Override
  public boolean equals(java.lang.Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    Report report = (Report) o;
    return Objects.equals(numberFound, report.numberFound) &&
        Objects.equals(qtime, report.qtime) &&
        Objects.equals(status, report.status) &&
        Objects.equals(searchParameters, report.searchParameters) &&
        Objects.equals(results, report.results);
  }

  @Override
  public int hashCode() {
    return Objects.hash(numberFound, qtime, status, searchParameters, results);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class Report {\n");
    
    sb.append("    numberFound: ").append(toIndentedString(numberFound)).append("\n");
    sb.append("    qtime: ").append(toIndentedString(qtime)).append("\n");
    sb.append("    status: ").append(toIndentedString(status)).append("\n");
    sb.append("    searchParameters: ").append(toIndentedString(searchParameters)).append("\n");
    sb.append("    results: ").append(toIndentedString(results)).append("\n");
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

