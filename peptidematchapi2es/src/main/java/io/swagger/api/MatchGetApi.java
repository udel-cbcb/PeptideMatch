package io.swagger.api;

import io.swagger.model.*;
import io.swagger.api.MatchGetApiService;
import io.swagger.api.factories.MatchGetApiServiceFactory;

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

@Path("/match_get")
@Produces({ "application/json", "application/xml", "text/x-fasta", "text/tab-separated-values" })
@io.swagger.annotations.Api(description = "the match_get API")
@javax.annotation.Generated(value = "io.swagger.codegen.languages.JavaResteasyServerCodegen", date = "2017-11-05T01:48:13.887Z")
public class MatchGetApi {
	private final MatchGetApiService delegate = MatchGetApiServiceFactory.getMatchGetApi();

	@GET
	@Produces({ "application/json" })
	@io.swagger.annotations.ApiOperation(value = "Do peptide match using GET method.", notes = "Retrieve UniProtKB protein sequences that would exactly match to the query peptides using GET method.", response = Report.class, tags = { "Peptide Match API 2.0", })
	@io.swagger.annotations.ApiResponses(value = { @io.swagger.annotations.ApiResponse(code = 200, message = "Match report.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 400, message = "Bad request. Number of query peptides is larger than 100.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 500, message = "Unexpected error.", response = Report.class) })
	public Response matchGetGetJSON(@NotNull @QueryParam("peptides") String peptides, @QueryParam("taxonids") String taxonids,
			@QueryParam("swissprot") Boolean swissprot, @QueryParam("isoform") Boolean isoform, @QueryParam("uniref100") Boolean uniref100,
			@QueryParam("leqi") Boolean leqi, @QueryParam("offset") Integer offset, @QueryParam("size") Integer size, @Context SecurityContext securityContext)
			throws NotFoundException {
		return delegate.matchGetGetJSON(peptides, taxonids, swissprot, isoform, uniref100, leqi, offset, size, securityContext);
	}

	@GET
	@Produces({ "application/xml" })
	@io.swagger.annotations.ApiOperation(value = "Do peptide match using GET method.", notes = "Retrieve UniProtKB protein sequences that would exactly match to the query peptides using GET method.", response = Report.class, tags = { "Peptide Match API 2.0", })
	@io.swagger.annotations.ApiResponses(value = { @io.swagger.annotations.ApiResponse(code = 200, message = "Match report.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 400, message = "Bad request. Number of query peptides is larger than 100.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 500, message = "Unexpected error.", response = Report.class) })
	public Response matchGetGetXML(@NotNull @QueryParam("peptides") String peptides, @QueryParam("taxonids") String taxonids,
			@QueryParam("swissprot") Boolean swissprot, @QueryParam("isoform") Boolean isoform, @QueryParam("uniref100") Boolean uniref100,
			@QueryParam("leqi") Boolean leqi,@QueryParam("offset") Integer offset, @QueryParam("size") Integer size, @Context SecurityContext securityContext) throws NotFoundException {
		return delegate.matchGetGetXML(peptides, taxonids, swissprot, isoform, uniref100, leqi, offset, size,securityContext);
	}

	@GET
	@Produces({ "text/x-fasta" })
	@io.swagger.annotations.ApiOperation(value = "Do peptide match using GET method.", notes = "Retrieve UniProtKB protein sequences that would exactly match to the query peptides using GET method.", response = Report.class, tags = { "Peptide Match API 2.0", })
	@io.swagger.annotations.ApiResponses(value = { @io.swagger.annotations.ApiResponse(code = 200, message = "Match report.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 400, message = "Bad request. Number of query peptides is larger than 100.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 500, message = "Unexpected error.", response = Report.class) })
	public Response matchGetGetFASTA(@NotNull @QueryParam("peptides") String peptides, @QueryParam("taxonids") String taxonids,
			@QueryParam("swissprot") Boolean swissprot, @QueryParam("isoform") Boolean isoform, @QueryParam("uniref100") Boolean uniref100,
			@QueryParam("leqi") Boolean leqi,@QueryParam("offset") Integer offset, @QueryParam("size") Integer size, @Context SecurityContext securityContext) throws NotFoundException {
		return delegate.matchGetGetFASTA(peptides, taxonids, swissprot, isoform, uniref100, leqi, offset, size,securityContext);
	}

	@GET
	@Produces({ "text/tab-separated-values" })
	@io.swagger.annotations.ApiOperation(value = "Do peptide match using GET method.", notes = "Retrieve UniProtKB protein sequences that would exactly match to the query peptides using GET method.", response = Report.class, tags = { "Peptide Match API 2.0", })
	@io.swagger.annotations.ApiResponses(value = { @io.swagger.annotations.ApiResponse(code = 200, message = "Match report.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 400, message = "Bad request. Number of query peptides is larger than 100.", response = Report.class),

	@io.swagger.annotations.ApiResponse(code = 500, message = "Unexpected error.", response = Report.class) })
	public Response matchGetGetTSV(@NotNull @QueryParam("peptides") String peptides, @QueryParam("taxonids") String taxonids,
			@QueryParam("swissprot") Boolean swissprot, @QueryParam("isoform") Boolean isoform, @QueryParam("uniref100") Boolean uniref100,
			@QueryParam("leqi") Boolean leqi, @QueryParam("offset") Integer offset, @QueryParam("size") Integer size, @Context SecurityContext securityContext) throws NotFoundException {
		return delegate.matchGetGetTSV(peptides, taxonids, swissprot, isoform, uniref100, leqi, offset, size,securityContext);
	}
}
