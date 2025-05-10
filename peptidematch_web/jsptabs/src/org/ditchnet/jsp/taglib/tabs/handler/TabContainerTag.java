/*
 * The contents of this file are subject to the GNU Lesser General Public
 * License Version 2.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.gnu.org/copyleft/lesser.html
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * Developer:
 * Todd Ditchendorf, todd@ditchnet.org
 *
 */

/**
 *	@author Todd Ditchendorf
 *	@version 0.8
 *	@since 0.8
 */
package org.ditchnet.jsp.taglib.tabs.handler;

import java.io.StringWriter;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.JspContext;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.JspFragment;
import javax.servlet.jsp.tagext.SimpleTagSupport;
import org.ditchnet.jsp.util.JspResponseWriter;
import org.ditchnet.xml.Xhtml;


/**
 *	@author Todd Ditchendorf
 *	@since 0.8
 *	
 *	JSP Tag that renders a collection of tabs.
 */
public final class TabContainerTag extends SimpleTagSupport {
	
	public static final String COOKIE_PREFIX = "org.ditchnet.jsp.tabs";

	private String id;
	private String skin;
	private List children;
	private String selectedTabPaneId;
	private String urlSelectedTabPaneId;
	private int selectedIndex = 0;
	private int cookieSelectedIndex = -1;
	private String jsTabListener;
	private JspResponseWriter out = new JspResponseWriter();
	
	public void setId(final String id) {
		this.id = id;
	}
	
	public String getId() {
		return id;
	}
	
	public void setSkin(final String skin) {
		this.skin = skin.toLowerCase();
	}
	
	public String getSkin() {
		if (null == skin || 0 == skin.length()) {
			skin = "default";
		}
		return skin;
	}
	
	public void setSelectedTabPaneId(final String selectedTabPaneId) {
		this.selectedTabPaneId = selectedTabPaneId;
	}
	
	public String getSelectedTabPaneId() {
		return selectedTabPaneId;
	}
	
	void setSelectedIndex(final int selectedIndex) {
		this.selectedIndex = selectedIndex - 1;
	}
	
	int getSelectedIndex() {
		return selectedIndex;
	}
	
	private void setCookieSelectedIndex(final int selectedIndex) {
		this.cookieSelectedIndex = selectedIndex;
	}
	
	private int getCookieSelectedIndex() {
		return cookieSelectedIndex;
	}
	
	private void setUrlSelectedTabPaneId(final String selectedId) {
		this.urlSelectedTabPaneId = selectedId;
	}
	
	private String getUrlSelectedTabPaneId() {
		return urlSelectedTabPaneId;
	}
	
	public void setJsTabListener(final String jsTabListener) {
		this.jsTabListener = jsTabListener;
	}
	
	public String getJsTabListener() {
		return jsTabListener;
	}
	
	List getChildren() {
		if (null == children) {
			children = new ArrayList();
		}
		return children;
	}
	
	int getChildCount() {
		return getChildren().size();
	}
	
	void addChild(final TabPaneTag child) {
		getChildren().add(child);
	}

	public void doTag() throws JspException, IOException {
		consumeCookie();
		consumeQueryStringParam();
				
		StringWriter discardResult = new StringWriter();
		StringWriter evalResult    = new StringWriter();

		out.startElement(Xhtml.Tag.DIV);
		out.attribute(Xhtml.Attr.CLASS,TabConstants.TAB_SKIN_CLASS_NAME+getSkin());
		out.startElement(Xhtml.Tag.DIV);
		out.attribute(Xhtml.Attr.ID,id);
		out.attribute(Xhtml.Attr.CLASS,TabConstants.TAB_CONTAINER_CLASS_NAME);
		out.startElement(Xhtml.Tag.DIV);
		out.attribute(Xhtml.Attr.CLASS,TabConstants.TAB_WRAP_CLASS_NAME);

		getJspBody().invoke(evalResult);
		evalResult.getBuffer().delete(0,evalResult.getBuffer().length());
		determineSelectedIndex();
		children = null;
		getJspBody().invoke(evalResult);

		int i = 0;
		for (Iterator iter = children.iterator(); iter.hasNext();) {
			TabPaneTag tabPane = (TabPaneTag)iter.next();
			out.startElement(Xhtml.Tag.DIV);
			out.attribute(Xhtml.Attr.ID,tabPane.getId()+TabConstants.TAB_ID_SUFFIX);
			if (null != getJsTabListener() && getJsTabListener().length() > 0) {
				out.attribute(Xhtml.Attr.ONCLICK,
							  "org.ditchnet.jsp.TabUtils.tabClicked(event);" +
				getJsTabListener().trim() + "(new org.ditchnet.jsp.TabEvent(this));");
			} else {
				out.attribute(Xhtml.Attr.ONCLICK,
							  "org.ditchnet.jsp.TabUtils.tabClicked(event);");
			}
			if (i == getSelectedIndex()) {
				out.attribute(Xhtml.Attr.CLASS,TabConstants.TAB_CLASS_NAME + " " +
											   TabConstants.FOCUSED_CLASS_NAME);
			} else {
				out.attribute(Xhtml.Attr.CLASS,TabConstants.TAB_CLASS_NAME + " " + 
											   TabConstants.UNFOCUSED_CLASS_NAME);
			}
			out.startElement(Xhtml.Tag.SPAN);
			out.attribute(Xhtml.Attr.CLASS,TabConstants.TAB_BG_LEFT_CLASS_NAME);
			out.text(" ");
			out.endElement(Xhtml.Tag.SPAN);
			out.startElement(Xhtml.Tag.A);
			out.attribute(Xhtml.Attr.HREF,getTabUrl(tabPane) +
										  TabLinkTag.QUESTION_MARK +
										  TabLinkTag.PARAM_NAME_TAB_PANE_ID +
										  TabLinkTag.EQUALS +
										  tabPane.getId());
			out.attribute(Xhtml.Attr.ONCLICK,"return false;");
			
			if (null != tabPane.getTabTitle() &&
				0 < tabPane.getTabTitle().length()) {
				out.text(tabPane.getTabTitle());
			}
			out.text(" ");
			out.endElement(Xhtml.Tag.A);
			out.endElement(Xhtml.Tag.DIV);
			i++;
		}
		out.startElement(Xhtml.Tag.BR);
		out.attribute(Xhtml.Attr.CLASS,TabConstants.CLEAR_CLASS_NAME);
		out.endElement(Xhtml.Tag.BR);
		out.endElement(Xhtml.Tag.DIV);
		out.comment(TabConstants.TAB_WRAP_CLASS_NAME);
		out.startElement(Xhtml.Tag.DIV);
		out.attribute(Xhtml.Attr.CLASS,TabConstants.TAB_PANE_WRAP_CLASS_NAME);
		out.text(evalResult.getBuffer().toString());
		out.endElement(Xhtml.Tag.DIV);
		out.comment(TabConstants.TAB_PANE_WRAP_CLASS_NAME);
		out.endElement(Xhtml.Tag.DIV);
		out.comment(TabConstants.TAB_CONTAINER_CLASS_NAME);
		out.endElement(Xhtml.Tag.DIV);
		out.comment(TabConstants.TAB_SKIN_CLASS_NAME+getSkin());
		
		getJspContext().getOut().print(out.getBuffer());
	}
	
	private void determineSelectedIndex() {
		//check url first
		TabPaneTag child;
		for (int i = 0; i < getChildCount(); i++) {
			child = (TabPaneTag)getChildren().get(i);
			if (child.getId().equals(getUrlSelectedTabPaneId())) {
				setSelectedIndex(i+1);
				return;
			}
		}
		//then check cookie
		if (getCookieSelectedIndex() > -1) {
			setSelectedIndex(cookieSelectedIndex+1);
			return;
		}
		//then check jsp tag attr
		for (int i = 0; i < getChildCount(); i++) {
			child = (TabPaneTag)getChildren().get(i);
			if (child.getId().equals(getSelectedTabPaneId())) {
				setSelectedIndex(i+1);
				return;
			}
		}
	}
	
	private String getTabUrl(final TabPaneTag tabPane) {
		HttpServletRequest request = getRequest();
		return request.getRequestURL().toString();
	}
	
	private void consumeQueryStringParam() {
		String tabPaneIdParamValue = getRequest().getParameter( 
										TabLinkTag.PARAM_NAME_TAB_PANE_ID );
		if (null == tabPaneIdParamValue 
			|| 0 == tabPaneIdParamValue.length()) {
			return;
		}
		setUrlSelectedTabPaneId( tabPaneIdParamValue );
	}
	
	private void consumeCookie() {
		Cookie[] cookies = getPageCookies();
		Cookie cookie;
		String prefix,value;
		for (int i = 0; i < cookies.length; i++) {
			cookie = cookies[i];
			if (isDitchnetTabCookie(cookie)) {
				int index = cookie.getName().indexOf(":")+1;
				if (isCookieForThisContainer(cookie,index)) {
					try {
						setCookieSelectedIndex(
								Integer.parseInt(cookie.getValue()));
					} catch (NumberFormatException e) { }
				}
			}
		}
	}
	
	private HttpServletRequest getRequest() {
		PageContext pageContext = (PageContext)getJspContext();
		HttpServletRequest request = 
			(HttpServletRequest)pageContext.getRequest();
		return request;
	}
	
	private Cookie[] getPageCookies() {
		Cookie[] cookies = getRequest().getCookies();
		if (null == cookies) {
			cookies = new Cookie[0];
		}
		return cookies;
	}
	
	private boolean isDitchnetTabCookie(final Cookie cookie) {
		return 0 == cookie.getName().indexOf(COOKIE_PREFIX)	;
	}
	
	private boolean isCookieForThisContainer(final Cookie cookie,
											 final int index) {
		return cookie.getName().substring(index).equals(getId());
	}
	
}
