package io.swagger.api;

import io.swagger.model.*;
import io.swagger.api.MatchPostApiService;
import io.swagger.api.factories.MatchPostApiServiceFactory;

import io.swagger.annotations.ApiParam;
import io.swagger.jaxrs.*;

import io.swagger.model.Error;
import io.swagger.model.Report;

import java.util.List;
import io.swagger.api.NotFoundException;

import java.io.InputStream;

import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.SecurityContext;
import javax.ws.rs.*;
import javax.validation.constraints.*;

@Path("/match_post")
@Produces({ "application/json", "application/xml", "text/x-fasta", "text/tab-separated-values" })
@io.swagger.annotations.Api(description = "the match_post API")
@javax.annotation.Generated(value = "io.swagger.codegen.languages.JavaResteasyServerCodegen", date = "2017-11-05T01:48:13.887Z")
public class MatchPostApi {
	private final MatchPostApiService delegate = MatchPostApiServiceFactory.getMatchPostApi();

	@POST
	@Consumes({ "application/x-www-form-urlencoded" })
	@Produces({ "application/json" })
	@io.swagger.annotations.ApiOperation(value = "Do peptide match using POST method.", notes = "Retrieve UniProtKB protein sequences that would exactly match to the query peptides using POST method.", response = Report.class, tags = { "Peptide Match API 2.0", })
	@io.swagger.annotations.ApiResponses(value = { @io.swagger.annotations.ApiResponse(code = 200, message = "Match report.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 400, message = "Bad request. Number of query peptides is larger than 100.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 500, message = "Unexpected error.", response = Report.class) })
	public Response matchPostPostJSON(
			@ApiParam(value = "A list of comma-separated peptide sequences (up to 100). Each sequence consists of 3 or more amino acids.", required = true, defaultValue = "AAVEEGIVLGGGCALLR,SVQYDDVPEYK") @FormParam("peptides") String peptides,
			@ApiParam(value = "A list fo comma-separated NCBI taxonomy IDs.", defaultValue = "9606,10090") @FormParam("taxonids") String taxonids,
			@ApiParam(value = "Only search SwissProt protein sequences.", defaultValue = "true") @FormParam("swissprot") Boolean swissprot,
			@ApiParam(value = "Include isoforms.", defaultValue = "false") @FormParam("isoform") Boolean isoform,
			@ApiParam(value = "Only search UniRef100 protein sequences.", defaultValue = "false") @FormParam("uniref100") Boolean uniref100,
			@ApiParam(value = "Treat Leucine (L) and Isoleucine (I) equivalent.", defaultValue = "false") @FormParam("leqi") Boolean leqi,
			@ApiParam(value = "Off set, page starting point, with default value 0.", defaultValue ="0") @FormParam("offset") Integer offset,
			@ApiParam(value = "Page size with default value 100. When page size is -1, it returns all records and offset will be ignored.", defaultValue="100") @FormParam("size") Integer size,
			@Context SecurityContext securityContext) throws NotFoundException {
		return delegate.matchPostPostJSON(peptides, taxonids, swissprot, isoform, uniref100, leqi, offset, size, securityContext);
	}

	@POST
	@Consumes({ "application/x-www-form-urlencoded" })
	@Produces({ "application/xml" })
	@io.swagger.annotations.ApiOperation(value = "Do peptide match using POST method.", notes = "Retrieve UniProtKB protein sequences that would exactly match to the query peptides using POST method.", response = Report.class, tags = { "Peptide Match API 2.0", })
	@io.swagger.annotations.ApiResponses(value = { @io.swagger.annotations.ApiResponse(code = 200, message = "Match report.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 400, message = "Bad request. Number of query peptides is larger than 100.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 500, message = "Unexpected error.", response = Report.class) })
	public Response matchPostPostXML(
			@ApiParam(value = "A list of comma-separated peptide sequences (up to 100). Each sequence consists of 3 or more amino acids.", required = true, defaultValue = "AAVEEGIVLGGGCALLR,SVQYDDVPEYK") @FormParam("peptides") String peptides,
			@ApiParam(value = "A list fo comma-separated NCBI taxonomy IDs.", defaultValue = "9606,10090") @FormParam("taxonids") String taxonids,
			@ApiParam(value = "Only search SwissProt protein sequences.", defaultValue = "true") @FormParam("swissprot") Boolean swissprot,
			@ApiParam(value = "Include isoforms.", defaultValue = "false") @FormParam("isoform") Boolean isoform,
			@ApiParam(value = "Only search UniRef100 protein sequences.", defaultValue = "false") @FormParam("uniref100") Boolean uniref100,
			@ApiParam(value = "Treat Leucine (L) and Isoleucine (I) equivalent.", defaultValue = "false") @FormParam("leqi") Boolean leqi,
			@ApiParam(value = "Off set, page starting point, with default value 0.", defaultValue ="0") @FormParam("offset") Integer offset,
			@ApiParam(value = "Page size with default value 100. When page size is -1, it returns all records and offset will be ignored.", defaultValue="100") @FormParam("size") Integer size,
			@Context SecurityContext securityContext) throws NotFoundException {
		return delegate.matchPostPostXML(peptides, taxonids, swissprot, isoform, uniref100, leqi, offset, size, securityContext);
	}

	@POST
	@Consumes({ "application/x-www-form-urlencoded" })
	@Produces({ "text/x-fasta" })
	@io.swagger.annotations.ApiOperation(value = "Do peptide match using POST method.", notes = "Retrieve UniProtKB protein sequences that would exactly match to the query peptides using POST method.", response = Report.class, tags = { "Peptide Match API 2.0", })
	@io.swagger.annotations.ApiResponses(value = { @io.swagger.annotations.ApiResponse(code = 200, message = "Match report.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 400, message = "Bad request. Number of query peptides is larger than 100.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 500, message = "Unexpected error.", response = Report.class) })
	public Response matchPostPostFASTA(
			@ApiParam(value = "A list of comma-separated peptide sequences (up to 100). Each sequence consists of 3 or more amino acids.", required = true, defaultValue = "AAVEEGIVLGGGCALLR,SVQYDDVPEYK") @FormParam("peptides") String peptides,
			@ApiParam(value = "A list fo comma-separated NCBI taxonomy IDs.", defaultValue = "9606,10090") @FormParam("taxonids") String taxonids,
			@ApiParam(value = "Only search SwissProt protein sequences.", defaultValue = "true") @FormParam("swissprot") Boolean swissprot,
			@ApiParam(value = "Include isoforms.", defaultValue = "false") @FormParam("isoform") Boolean isoform,
			@ApiParam(value = "Only search UniRef100 protein sequences.", defaultValue = "false") @FormParam("uniref100") Boolean uniref100,
			@ApiParam(value = "Treat Leucine (L) and Isoleucine (I) equivalent.", defaultValue = "false") @FormParam("leqi") Boolean leqi,
			@ApiParam(value = "Off set, page starting point, with default value 0.", defaultValue ="0") @FormParam("offset") Integer offset,
			@ApiParam(value = "Page size with default value 100. When page size is -1, it returns all records and offset will be ignored.", defaultValue="100") @FormParam("size") Integer size,
			@Context SecurityContext securityContext) throws NotFoundException {
		return delegate.matchPostPostFASTA(peptides, taxonids, swissprot, isoform, uniref100, leqi, offset, size, securityContext);
	}

	@POST
	@Consumes({ "application/x-www-form-urlencoded" })
	@Produces({ "text/tab-separated-values" })
	@io.swagger.annotations.ApiOperation(value = "Do peptide match using POST method.", notes = "Retrieve UniProtKB protein sequences that would exactly match to the query peptides using POST method.", response = Report.class, tags = { "Peptide Match API 2.0", })
	@io.swagger.annotations.ApiResponses(value = { @io.swagger.annotations.ApiResponse(code = 200, message = "Match report.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 400, message = "Bad request. Number of query peptides is larger than 100.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 500, message = "Unexpected error.", response = Report.class) })
	public Response matchPostPostTSV(
			@ApiParam(value = "A list of comma-separated peptide sequences (up to 100). Each sequence consists of 3 or more amino acids.", required = true, defaultValue = "AAVEEGIVLGGGCALLR,SVQYDDVPEYK") @FormParam("peptides") String peptides,
			@ApiParam(value = "A list fo comma-separated NCBI taxonomy IDs.", defaultValue = "9606,10090") @FormParam("taxonids") String taxonids,
			@ApiParam(value = "Only search SwissProt protein sequences.", defaultValue = "true") @FormParam("swissprot") Boolean swissprot,
			@ApiParam(value = "Include isoforms.", defaultValue = "false") @FormParam("isoform") Boolean isoform,
			@ApiParam(value = "Only search UniRef100 protein sequences.", defaultValue = "false") @FormParam("uniref100") Boolean uniref100,
			@ApiParam(value = "Treat Leucine (L) and Isoleucine (I) equivalent.", defaultValue = "false") @FormParam("leqi") Boolean leqi,
			@ApiParam(value = "Off set, page starting point, with default value 0.", defaultValue ="0") @FormParam("offset") Integer offset,
			@ApiParam(value = "Page size with default value 100. When page size is -1, it returns all records and offset will be ignored.", defaultValue="100") @FormParam("size") Integer size,
			@Context SecurityContext securityContext) throws NotFoundException {
		return delegate.matchPostPostTSV(peptides, taxonids, swissprot, isoform, uniref100, leqi, offset, size, securityContext);
	}
}
