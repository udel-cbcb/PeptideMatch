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

import java.io.IOException;
import java.net.URLEncoder;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.SimpleTagSupport;
import org.ditchnet.jsp.taglib.tabs.listener.TabServletContextListener;


/**
 *	@author Todd Ditchendorf
 *	@since 0.8
 *	
 *	JSP Tag that renders XHTML </code>script</code> and </code>style</code> elements
 *	that link to the CSS and JavaScript resources necessary to render the 
 *	tab components on the current page. The resources that are linked to are
 *	the resources placed in a directory named </code>/org.ditchnet.taglib/</code>
 *	in the web app's root directory. These resources were placed there by
 *	the {@link org.ditchnet.jsp.taglib.tabs.listener.TabServletContextListener}.
 */
public final class TabConfigTag extends SimpleTagSupport {
	
	private String contextPath;

	public void doTag() throws JspException, IOException {
		
		StringBuffer buff = new StringBuffer();
		
		findContextPath();
		renderScriptTag(buff);
		renderStyleTag(buff);
		
		getJspContext().getOut().print(buff);
		
	}
	
	private void findContextPath() {
		PageContext pageContext = (PageContext)getJspContext();
		HttpServletRequest req = (HttpServletRequest)pageContext.getRequest();
		contextPath = req.getContextPath();
	}
	
	private void renderScriptTag(final StringBuffer buff) {
		String uri = 
			getEncodedContextRelativePath(TabServletContextListener.SCRIPT_URI);

		buff.append("\n\n\t<script type=\"text/javascript\" ")
			.append("src=\"").append(uri).append("\">")
			.append("</script>\n");
	}
	
	private void renderStyleTag(final StringBuffer buff) {
		String uri = 
			getEncodedContextRelativePath(TabServletContextListener.STYLE_URI);

		buff.append("\t<link type=\"text/css\" rel=\"stylesheet\" ")
			.append("href=\"").append(uri).append("\" />\n\n");
	}
	
	private String getEncodedContextRelativePath(final String uri) {
		return contextPath + uri;
	}


	
}
