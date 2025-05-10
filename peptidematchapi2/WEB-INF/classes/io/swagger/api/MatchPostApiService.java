package io.swagger.api;

import io.swagger.api.*;
import io.swagger.model.*;
import io.swagger.model.Error;

import java.util.List;

import io.swagger.api.NotFoundException;

import java.io.InputStream;

import javax.ws.rs.core.Response;
import javax.ws.rs.core.SecurityContext;

@javax.annotation.Generated(value = "io.swagger.codegen.languages.JavaResteasyServerCodegen", date = "2017-11-05T01:48:13.887Z")
public abstract class MatchPostApiService {
	public abstract Response matchPostPostJSON(String peptides, String taxonids, Boolean swissprot, Boolean isoform, Boolean uniref100, Boolean leqi,
			Integer offsets, Integer size, SecurityContext securityContext) throws NotFoundException;

	public abstract Response matchPostPostXML(String peptides, String taxonids, Boolean swissprot, Boolean isoform, Boolean uniref100, Boolean leqi,
			Integer offsets, Integer size, SecurityContext securityContext) throws NotFoundException;

	public abstract Response matchPostPostFASTA(String peptides, String taxonids, Boolean swissprot, Boolean isoform, Boolean uniref100, Boolean leqi,
			Integer offsets, Integer size, SecurityContext securityContext) throws NotFoundException;

	public abstract Response matchPostPostTSV(String peptides, String taxonids, Boolean swissprot, Boolean isoform, Boolean uniref100, Boolean leqi,
			Integer offsets, Integer size, SecurityContext securityContext) throws NotFoundException;
}
