<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
		
<%@ page contentType="text/html" %>
<%@ taglib prefix="tab" uri="http://ditchnet.org/jsp-tabs-taglib" %>
		
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>				
	<tab:tabConfig />
</head>
	
<body>
<tab:tabContainer id="foo-bar-container">
	
	<tab:tabPane id="foo" tabTitle="Foo!">
		Foo is cool!
	</tab:tabPane>

	<tab:tabPane id="bar" tabTitle="Bar!">
		<c:out value="Bar is cooler!" />
	</tab:tabPane>

</tab:tabContainer>
</body>
</html>
