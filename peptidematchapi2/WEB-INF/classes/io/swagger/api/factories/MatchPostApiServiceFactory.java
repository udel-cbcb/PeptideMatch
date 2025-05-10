package io.swagger.api.factories;

import io.swagger.api.MatchPostApiService;
import io.swagger.api.impl.MatchPostApiServiceImpl;

@javax.annotation.Generated(value = "io.swagger.codegen.languages.JavaResteasyServerCodegen", date = "2017-11-05T01:48:13.887Z")
public class MatchPostApiServiceFactory {

   private final static MatchPostApiService service = new MatchPostApiServiceImpl();

   public static MatchPostApiService getMatchPostApi()
   {
      return service;
   }
}
