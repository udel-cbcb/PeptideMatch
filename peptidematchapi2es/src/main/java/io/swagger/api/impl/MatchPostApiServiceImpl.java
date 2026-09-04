package io.swagger.api.impl;

import io.swagger.api.*;
import io.swagger.model.*;
import io.swagger.model.Error;

import java.util.List;

import io.swagger.api.NotFoundException;

import java.io.InputStream;

import javax.ws.rs.core.Response;
import javax.ws.rs.core.SecurityContext;

import org.proteininformationresource.peptidematch.MatchService;
import org.proteininformationresource.peptidematch.MatchServiceUtil;
import org.proteininformationresource.peptidematch.Query;

@javax.annotation.Generated(value = "io.swagger.codegen.languages.JavaResteasyServerCodegen", date = "2017-11-05T01:48:13.887Z")
public class MatchPostApiServiceImpl extends MatchPostApiService {
	@Override
	public Response matchPostPostJSON(String peptides, String taxonids, Boolean swissprot, Boolean isoform, Boolean uniref100, Boolean leqi, Integer offset, Integer size, SecurityContext securityContext) throws NotFoundException {
		// do some magic!
		// return Response.ok().entity(new
		// ApiResponseMessage(ApiResponseMessage.OK, "magic!")).build();
		if(MatchServiceUtil.validateInputs(peptides) != null) {
			return Response.status(Response.Status.BAD_REQUEST).entity(MatchServiceUtil.validateInputs(peptides)).build();
		}
		Query query = MatchServiceUtil.getQuery(peptides, taxonids, swissprot, isoform, uniref100, leqi, offset, size);
		MatchService service = new MatchService(query);
		Report report = service.doSearch(query);
		return Response.ok().entity(report).build();
	}
	
	@Override
	public Response matchPostPostXML(String peptides, String taxonids, Boolean swissprot, Boolean isoform, Boolean uniref100, Boolean leqi, Integer offset, Integer size, SecurityContext securityContext) throws NotFoundException {
		if(MatchServiceUtil.validateInputs(peptides) != null) {
			return Response.status(Response.Status.BAD_REQUEST).entity(MatchServiceUtil.validateInputs(peptides)).build();
		}
		Query query = MatchServiceUtil.getQuery(peptides, taxonids, swissprot, isoform, uniref100, leqi, offset, size);
		MatchService service = new MatchService(query);
		Report report = service.doSearch(query);
		return Response.ok().entity(report).build();
	}

	@Override
	public Response matchPostPostFASTA(String peptides, String taxonids, Boolean swissprot, Boolean isoform, Boolean uniref100, Boolean leqi, Integer offset, Integer size, SecurityContext securityContext) throws NotFoundException {
		if(MatchServiceUtil.validateInputs(peptides) != null) {
			return Response.status(Response.Status.BAD_REQUEST).entity(MatchServiceUtil.validateInputs(peptides)).build();
		}
		Query query = MatchServiceUtil.getQuery(peptides, taxonids, swissprot, isoform, uniref100, leqi, offset, size);
		MatchService service = new MatchService(query);
		Report report = service.doSearch(query);
		return Response.ok().entity(MatchServiceUtil.getFASTA(report)).build();
	}

	@Override
	public Response matchPostPostTSV(String peptides, String taxonids, Boolean swissprot, Boolean isoform, Boolean uniref100, Boolean leqi, Integer offset, Integer size, SecurityContext securityContext) throws NotFoundException {
		if(MatchServiceUtil.validateInputs(peptides) != null) {
			return Response.status(Response.Status.BAD_REQUEST).entity(MatchServiceUtil.validateInputs(peptides)).build();
		}
		Query query = MatchServiceUtil.getQuery(peptides, taxonids, swissprot, isoform, uniref100, leqi, offset, size);
		MatchService service = new MatchService(query);
		Report report = service.doSearch(query);
		return Response.ok().entity(MatchServiceUtil.getTSV(report)).build();
	}
}
