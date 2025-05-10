package io.swagger.api.factories;

import io.swagger.api.MatchGetApiService;
import io.swagger.api.impl.MatchGetApiServiceImpl;

@javax.annotation.Generated(value = "io.swagger.codegen.languages.JavaResteasyServerCodegen", date = "2017-11-05T01:48:13.887Z")
public class MatchGetApiServiceFactory {

   private final static MatchGetApiService service = new MatchGetApiServiceImpl();

   public static MatchGetApiService getMatchGetApi()
   {
      return service;
   }
}
