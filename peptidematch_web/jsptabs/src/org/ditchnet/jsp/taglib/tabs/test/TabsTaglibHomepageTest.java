//
//  TabsHttpUnitTest.java
//  taglibs
//
//  Created by tditchen on 3/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

package org.ditchnet.jsp.taglib.tabs.test;

import java.util.List;
import org.w3c.dom.*;
import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;
import com.meterware.httpunit.WebLink;
import com.meterware.httpunit.HTMLPage;
import com.meterware.httpunit.WebRequest;
import com.meterware.httpunit.WebResponse;
import com.meterware.httpunit.HTMLElement;
import com.meterware.httpunit.WebConversation;
import com.meterware.httpunit.GetMethodWebRequest;
import com.meterware.httpunit.scripting.ScriptableDelegate;
import com.meterware.httpunit.scripting.ScriptableDelegate;
import org.ditchnet.test.DitchBaseTestCase;
import org.ditchnet.xml.Xhtml;
import org.ditchnet.xml.dom.DomUtils;


public class TabsTaglibHomepageTest extends DitchBaseTestCase {
	
	static final String URI = "http://localhost:8080/taglibs/index.jsp";
	
	static final String TAB_CONTAINER_CLASS_NAME = "org-ditchnet-tab-container";
	static final String TAB_WRAP_CLASS_NAME		 = "ditch-tab-wrap";
	static final String TAB_CLASS_NAME		     = "ditch-tab";
	static final String TAB_BG_LEFT_CLASS_NAME   = "ditch-tab-bg-left";
	static final String TAB_PANE_WRAP_CLASS_NAME = "ditch-tab-pane-wrap";
	static final String TAB_PANE_CLASS_NAME	     = "ditch-tab-pane";	
	
	public static void main(String [] args) {
		junit.textui.TestRunner.run( suite() );
	}
	
	public static Test suite() {
		TestSuite suite = new TestSuite(
			"Test the Tabs Taglib homepage (It uses the tabs)");
		suite.addTestSuite( TabsTaglibHomepageTest.class );
		return suite;
	}

	public TabsTaglibHomepageTest(String name) {
		super(name);
	}
	
	WebConversation wc;
	WebRequest req;
	WebResponse res;
	Document doc;
	Element docEl;
	
	public void setUp() throws Exception {
		wc    = new WebConversation();
		req   = new GetMethodWebRequest( URI );
		res   = wc.getResponse( req );
		doc   = res.getDOM();
		docEl = doc.getDocumentElement();
	}
	
	public void testPageTitle() throws Exception {
		String title = res.getTitle();
		assertEquals(title,"The Ultimate JSP Tabs!");
	}
	
	public void testSkinContainerExistence() throws Exception {
		List defaultSkinContainers = DomUtils.getDescendantsByClassName(
												docEl,
												"ditch-tab-skin-default");
		assertEquals(3,defaultSkinContainers.size());
		List invisibleSkinContainers = DomUtils.getDescendantsByClassName(
												docEl,
												"ditch-tab-skin-invisible");
		assertEquals(1,invisibleSkinContainers.size());
	}
	
	public void testTabsDefaultFocusStatus() throws Exception {
		List unfocusedTabs = DomUtils.getDescendantsByClassName(
												docEl,
												"ditch-tab ditch-unfocused");
		List focusedTabs = DomUtils.getDescendantsByClassName(
												docEl,
												"ditch-tab ditch-focused");
		assertEquals(12,unfocusedTabs.size());
		assertEquals(4,focusedTabs.size());
	}
	
	public void testMainContainerExistence() throws Exception {
		Element mainContainer = doc.getElementById("tabs-main-container");
		Element overviewTab = doc.getElementById("overview-tab");
		//assertNotNull(overviewTab);
		//assertNotNull(mainContainer);
		//assertEquals(Xhtml.Tag.DIV.toString(),mainContainer.getTagName());
	}
	
	public void testScript() throws Exception {
		HTMLPage.Scriptable jsDoc = res.getScriptableObject().getDocument();
		ScriptableDelegate div = jsDoc.getElementWithID( "author" );
		//div.evaluateExpression("var mEvt = document.createEvent('MouseEvents');mEvt.initMouseEvent('click',true,false,window,1,0,0,0,0,false,false,false,false,0,null);alert(mEvt);button.dispatchEvent( mEvt);");
		//dump(div.get("name").toString());
		////dump(div.toString());
		//div.doEvent("mouseover");
		//assertNotNull(div);
	}
	
	public void testServerSideTabSwitching() throws Exception {
		WebLink overviewLink = res.getLinkWith("Overview");
		assertNotNull(overviewLink);
		res = overviewLink.click();
		doc = res.getDOM();
		Element overviewTab = doc.getElementById( "overview-tab" );
		//assertNotNull( overviewTab );
		//assertTrue(DomUtils.hasClassName(overviewTab,"ditch-focused"));
	}
	
}
