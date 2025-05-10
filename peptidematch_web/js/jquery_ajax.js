function showHitSummary(initialed,keyword,organism_id,start,rows,numberfound,swissprotValue,isoformValue,uniref100Value,lEqiValue,sortBy,trOnly,isoOnly)
{
	var parameter=new Array();
	parameter[parameter.length]=new param('initialed',initialed);
	parameter[parameter.length]=new param('keyword',keyword);
	parameter[parameter.length]=new param('organism_id',organism_id);
	parameter[parameter.length]=new param('start',start);
	parameter[parameter.length]=new param('rows',rows);
        parameter[parameter.length]=new param('numberfound',numberfound);
        parameter[parameter.length]=new param('swissprot',swissprotValue);
        parameter[parameter.length]=new param('isoform',isoformValue);
        parameter[parameter.length]=new param('uniref100',uniref100Value);
        parameter[parameter.length]=new param('lEqi',lEqiValue);
        parameter[parameter.length]=new param('sortBy',sortBy);
        parameter[parameter.length]=new param('trOnly',trOnly);
        parameter[parameter.length]=new param('isoOnly',isoOnly);
	jQuery.ajax({
		url : "./server/summarygraph.jsp",
		type : "get",
		dataType: "html",
		data:parameter,
		beforeSend : function() {
                jQuery("#sumtable").html("<img src='./imagefiles/loading.gif'/>");
                jQuery("#sumtable").css("text-align","center");
		},
		success:function(data) {
                var parts = data.split("||||");
                jQuery("#sumtable").html(parts[0]);         
                jQuery('#browse_link a').attr("href",parts[1]);
                jQuery("#browse_by").show(); 
                jQuery("#sumtable").css("text-align","left");
		},
		error:function(req, status, error){
	        alert("Error,Please try later ");
                jQuery("#sumtable").css("text-align","left");
		},
		complete:function(data) {		
		}
	});
}

function sortTable(initialed,keyword,organism_id,taxon_id,taxon_name,taxongroup_id,group_name,start,rows,numberfound,swissprotValue,isoformValue, uniref100Value,lEqiValue,trOnly, isoOnly, header_id)
{
  var sort_header = header_id.split("_");
  var previous_sort = document.getElementById("current_sortby").value.split("_");
  if(sort_header[0] == previous_sort[0])
  {
    if(previous_sort[1] == "desc")
    sortBy = previous_sort[0]+"_"+ "asc";
  else
    sortBy = previous_sort[0]+"_"+ "desc";
    paging(initialed,keyword,organism_id,taxon_id,taxon_name,taxongroup_id,group_name,start,rows,numberfound,swissprotValue,isoformValue,uniref100Value,lEqiValue,sortBy, trOnly, isoOnly);
  }
  else
  {
    sortBy = sort_header[0]+"_"+"asc";
    paging(initialed,keyword,organism_id,taxon_id,taxon_name,taxongroup_id,group_name,start,rows,numberfound,swissprotValue,isoformValue,uniref100Value,lEqiValue,sortBy,trOnly, isoOnly);
  }
  global_list = [];
  showSelected(0,keyword,organism_id,lEqiValue);
}

function getPageContent(parameter,sortBy)
{	
	jQuery.ajax({
		url : "./server/tablecontent.jsp",
		type : "get",
		dataType: "html",
		data:parameter,
		beforeSend : function() {
                jQuery("#result_content").html("<tr><td colspan='9' align='center'><img src='./imagefiles/loading.gif'/></td></tr>");
		},
		success:function(data) {
                  jQuery("#result_content").html(data);         
		},
		error:function(req, status, error){
			alert("Error,Please try later ");
		},
		complete:function(data) {		
		}
	}).done(function(){
            jQuery('#current_sortby').val(sortBy);
            var elements = sortBy.split("_");
            var id = "#"+elements[0]+"_"+"header";
            if(elements[1] == "asc")
              classtype = "headerSortUp";
            else
              classtype = "headerSortDown";
            jQuery('.header').removeClass("headerSortDown");
            jQuery('.header').removeClass("headerSortUp");
            jQuery(id).addClass(classtype);
            updateCheckbox();		
});		
}

function paging(initialed,keyword,organism_id,taxon_id,taxon_name,taxongroup_id,group_name,start,rows,numberfound,swissprotValue,isoformValue,uniref100Value,lEqiValue,sortBy,trOnly,isoOnly)
{	
	var parameter=new Array();
        var constraint = document.getElementById('constraint').value;
	parameter[parameter.length]=new param('constraint',constraint);
	parameter[parameter.length]=new param('initialed',initialed);
	parameter[parameter.length]=new param('keyword',keyword);
	parameter[parameter.length]=new param('organism_id',organism_id);
	parameter[parameter.length]=new param('taxon_id',taxon_id);
	parameter[parameter.length]=new param('taxon_name',taxon_name);
	parameter[parameter.length]=new param('taxongroup_id',taxongroup_id);
	parameter[parameter.length]=new param('group_name',group_name);
	parameter[parameter.length]=new param('start',start);
	parameter[parameter.length]=new param('rows',rows);
        parameter[parameter.length]=new param('numberfound',numberfound);
	parameter[parameter.length]=new param('swissprot',swissprotValue);
	parameter[parameter.length]=new param('isoform',isoformValue);
	parameter[parameter.length]=new param('uniref100',uniref100Value);
        parameter[parameter.length]=new param('lEqi',lEqiValue);
        parameter[parameter.length]=new param('sortBy',sortBy);
        parameter[parameter.length]=new param('trOnly',trOnly);
        parameter[parameter.length]=new param('isoOnly',isoOnly);
        getPageContent(parameter,sortBy);
	jQuery.ajax({
		url : "./server/paging.jsp",
		type : "get",
		dataType: "html",
		data:parameter,
		beforeSend : function() {
		},
		success:function(data) {
                  jQuery("#div-paging").html(data); 
              		},
		error:function(req, status, error){
			alert("Error,Please try later ");
		},
		complete:function(data) {
		}
	}).done(function(){
          });
}



/*
function pagingWithTaxOnId(initialed,keyword,organism_id,taxon_id,taxon_name,start,rows,numberfound,swissprotValue,isoformValue,uniref100Value,lEqiValue,sortBy)
{	
	var parameter=new Array();
	parameter[parameter.length]=new param('constraint',"withtaxonid");
	parameter[parameter.length]=new param('initialed',initialed);
	parameter[parameter.length]=new param('keyword',keyword);
	parameter[parameter.length]=new param('organism_id',organism_id);
        parameter[parameter.length]=new param('taxon_id',taxon_id);
        parameter[parameter.length]=new param('taxon_name',taxon_name);
	parameter[parameter.length]=new param('start',start);
	parameter[parameter.length]=new param('rows',rows);
        parameter[parameter.length]=new param('numberfound',numberfound);
	parameter[parameter.length]=new param('swissprot',swissprotValue);
	parameter[parameter.length]=new param('isoform',isoformValue);
	parameter[parameter.length]=new param('uniref100',uniref100Value);
        parameter[parameter.length]=new param('lEqi',lEqiValue);
        parameter[parameter.length]=new param('sortBy',sortBy);
        getPageContent(parameter);
	jQuery.ajax({
		url : "/peptidematch_dev/server/paging.jsp",
		type : "get",
		dataType: "html",
		data:parameter,
		beforeSend : function() {
		},
		success:function(data) {
                  jQuery("#div-paging").html(data); 
		},
		error:function(req, status, error){
			alert("Error,Please try later ");
		},
		complete:function(data) {
		},
	}).done(function(){
          });
}

function pagingWithTaxOnGroup(initialed,keyword,organism_id,taxongroup_id,group_name,start,rows,numberfound,swissprotValue,isoformValue,Vuniref100Value,lEqiValue,sortBy)
{	
	var parameter=new Array();
	parameter[parameter.length]=new param('constraint',"withtaxongroup");
	parameter[parameter.length]=new param('initialed',initialed);
	parameter[parameter.length]=new param('keyword',keyword);
	parameter[parameter.length]=new param('organism_id',organism_id);
        parameter[parameter.length]=new param('taxongroup_id',taxongroup_id);
        parameter[parameter.length]=new param('group_name',group_name);
	parameter[parameter.length]=new param('start',start);
	parameter[parameter.length]=new param('rows',rows);
        parameter[parameter.length]=new param('numberfound',numberfound);
	parameter[parameter.length]=new param('swissprot',swissprotValue);
	parameter[parameter.length]=new param('isoform',isoformValue);
	parameter[parameter.length]=new param('uniref100',uniref100Value);
        parameter[parameter.length]=new param('lEqi',lEqiValue);
        parameter[parameter.length]=new param('sortBy',sortBy);
        getPageContent(parameter);
	jQuery.ajax({
		url : "/peptidematch_dev/server/paging.jsp",
		type : "get",
		dataType: "html",
		data:parameter,
		beforeSend : function() {
		},
		success:function(data) {
                  jQuery("#div-paging").html(data); 
		},
		error:function(req, status, error){
			alert("Error,Please try later ");
		},
		complete:function(data) {
		},
	}).done(function(){
          });
}

function pagingWithLineageTaxOnId(initialed,keyword,organism_id,taxon_id,taxon_name,start,rows,numberfound,swissprotValue,isoformValue,uniref100Value,lEqiValue,sortBy)
{	
	var parameter=new Array();
	parameter[parameter.length]=new param('constraint',"withlineage");
	parameter[parameter.length]=new param('initialed',initialed);
	parameter[parameter.length]=new param('keyword',keyword);
	parameter[parameter.length]=new param('organism_id',organism_id);
        parameter[parameter.length]=new param('taxon_id',taxon_id);
        parameter[parameter.length]=new param('taxon_name',taxon_name);
	parameter[parameter.length]=new param('start',start);
	parameter[parameter.length]=new param('rows',rows);
        parameter[parameter.length]=new param('numberfound',numberfound);
	parameter[parameter.length]=new param('swissprot',swissprotValue);
	parameter[parameter.length]=new param('isoform',isoformValue);
	parameter[parameter.length]=new param('uniref100',uniref100Value);
        parameter[parameter.length]=new param('lEqi',lEqiValue);
        parameter[parameter.length]=new param('sortBy',sortBy);
        getPageContent(parameter);
	jQuery.ajax({
		url : "/peptidematch_dev/server/paging.jsp",
		type : "get",
		dataType: "html",
		data:parameter,
		beforeSend : function() {
		},
		success:function(data) {
                  jQuery("#div-paging").html(data); 
		},
		error:function(req, status, error){
			alert("Error,Please try later ");
		},
		complete:function(data) {
		},
	}).done(function(){
          });
}

function pagingWithOrganismsNoProteomics(initialed,keyword,organism_id,start,rows,numberfound,swissprotValue,isoformValue,uniref100Value,lEqiValue,sortBy)
{	
	var parameter=new Array();
	parameter[parameter.length]=new param('pagingConstraint',"withorganisms");
	parameter[parameter.length]=new param('initialed',initialed);
	parameter[parameter.length]=new param('originalquery',keyword);
	parameter[parameter.length]=new param('organism_id',organism_id);
	parameter[parameter.length]=new param('start',start);
	parameter[parameter.length]=new param('rows',rows);
        parameter[parameter.length]=new param('numberfound',numberfound);
	parameter[parameter.length]=new param('swissprot',swissprotValue);
	parameter[parameter.length]=new param('isoform',isoformValue);
	parameter[parameter.length]=new param('uniref100',uniref100Value);
        parameter[parameter.length]=new param('lEqi',lEqiValue);
        parameter[parameter.length]=new param('sortBy',sortBy);
        getPageContent(parameter);
	jQuery.ajax({
		url : "/peptidematch_dev/server/paging.jsp",
		type : "get",
		dataType: "html",
		data:parameter,
		beforeSend : function() {
		},
		success:function(data) {
                  jQuery("#div-paging").html(data); 
		},
		error:function(req, status, error){
			alert("Error,Please try later ");
		},
		complete:function(data) {
		},
	}).done(function(){
          });
}
*/


var param=function(name,value){
	this.name=name;
	this.value=value;
}
