<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="http://jspcontrols.net/tags/core" prefix="jc" %>
<jc:component id="Notebook1">
  <jc:tabcontrol>
    <jc:tabpage label="Tab1">
      <p>Sample tabbed notebook, first page.</p>
    </jc:tabpage>
    <jc:tabpage label="Tab2">
      <p>Sample tabbed notebook, second page.</p>
    </jc:tabpage>
  </jc:tabcontrol>
</jc:component>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <body>
    <div id="Notebook1">
      <jsp:include page="notebook1.jsp"/>
    </div>
    ...
  </body>
</html>
