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
import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.JspContext;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.SimpleTagSupport;


/**
 *	@author Todd Ditchendorf
 *	@since 0.8
 *	
 *	JSP Tag that renders an XHTML </code>a</code> element that handles targeting
 *	a specific tab on the current page or another page.
 */
public final class TabLinkTag extends SimpleTagSupport {
	
	static final String QUESTION_MARK = "?";
	static final String EQUALS		  = "=";
	static final String AMPERSAND	  = "&amp;";
	
	public static final String PARAM_NAME_TAB_PANE_ID 
		= "orgDitchnetTabPaneId";
	
	private String id,href,selectedTabPaneId;
	
	public void setId(final String id) {
		this.id = id;
	}
	
	public void setHref(final String href) {
		this.href = href;
	}
	
	public void setSelectedTabPaneId(final String selectedTabPaneId) {
		this.selectedTabPaneId = selectedTabPaneId;
	}
	
	private boolean hrefHasQueryString() {
		return href.indexOf( QUESTION_MARK ) > -1;
	}
	
	private String getUrlParamString() {
		String prefix;
		if (hrefHasQueryString()) {
			prefix = AMPERSAND;
		} else {
			prefix = QUESTION_MARK;
		}
		StringBuffer buff = new StringBuffer();
		buff.append(prefix).append(PARAM_NAME_TAB_PANE_ID).append(EQUALS)
			.append(selectedTabPaneId);
		return buff.toString();
	}

	public void doTag() throws JspException, IOException {
				
		StringWriter evalResult = new StringWriter();
		StringBuffer buff = evalResult.getBuffer();
		
		buff.append("\n<a ");
		if (isHrefSameAsRequestURI()) {
			buff.append("onclick=\"org.ditchnet.jsp.")
				.append("TabUtils.tabLinkClicked(event,'")
				.append(selectedTabPaneId)
				.append("'); return false;\" href=\"")
				.append(getRequest().getRequestURL());
		} else {
			buff.append("href=\"").append(href).append(getUrlParamString());
		}
		if (null != id && 0 != id.length()) {
			buff.append(" id=\"").append(id).append("\"");
		}
		buff.append("\">");
		
		getJspBody().invoke(evalResult);
		
		buff.append("</a>\n");
		
		getJspContext().getOut().print(buff);
		
	}
	
	private boolean isHrefSameAsRequestURI() {
		return null == href;
	}
	
	private HttpServletRequest getRequest() {
		PageContext pageContext = (PageContext)getJspContext();
		HttpServletRequest request = 
			(HttpServletRequest)pageContext.getRequest();
		return request;
	}
	
}
