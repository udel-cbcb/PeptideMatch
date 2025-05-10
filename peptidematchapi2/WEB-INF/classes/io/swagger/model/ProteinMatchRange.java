package io.swagger.model;

import java.util.Objects;
import java.util.ArrayList;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import java.util.List;
import javax.validation.constraints.*;
import io.swagger.annotations.*;


@javax.annotation.Generated(value = "io.swagger.codegen.languages.JavaResteasyServerCodegen", date = "2017-11-19T01:42:04.689Z")
public class ProteinMatchRange   {
  
  private Integer start = null;
  private Integer end = null;
  private List<Integer> replacedLocs = new ArrayList<Integer>();

  /**
   **/
  
  @ApiModelProperty(value = "")
  @JsonProperty("start")
  public Integer getStart() {
    return start;
  }
  public void setStart(Integer start) {
    this.start = start;
  }

  /**
   **/
  
  @ApiModelProperty(value = "")
  @JsonProperty("end")
  public Integer getEnd() {
    return end;
  }
  public void setEnd(Integer end) {
    this.end = end;
  }

  /**
   **/
  
  @ApiModelProperty(value = "")
  @JsonProperty("replacedLocs")
  public List<Integer> getReplacedLocs() {
    return replacedLocs;
  }
  public void setReplacedLocs(List<Integer> replacedLocs) {
    this.replacedLocs = replacedLocs;
  }


  @Override
  public boolean equals(java.lang.Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    ProteinMatchRange proteinMatchRange = (ProteinMatchRange) o;
    return Objects.equals(start, proteinMatchRange.start) &&
        Objects.equals(end, proteinMatchRange.end) &&
        Objects.equals(replacedLocs, proteinMatchRange.replacedLocs);
  }

  @Override
  public int hashCode() {
    return Objects.hash(start, end, replacedLocs);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class ProteinMatchRange {\n");
    
    sb.append("    start: ").append(toIndentedString(start)).append("\n");
    sb.append("    end: ").append(toIndentedString(end)).append("\n");
    sb.append("    replacedLocs: ").append(toIndentedString(replacedLocs)).append("\n");
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

