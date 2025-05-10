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
import javax.servlet.jsp.JspContext;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.SimpleTagSupport;


/**
 *	@author Todd Ditchendorf
 *	@since 0.8
 *	
 *	JSP Tag that renders an XHTML <code>input</code> element of type 
 *	<code>button</code> with a JavaScript handler to switch the focus of
 *	a specified tab container to the next tab index.
 */
 public final class NextTabButtonTag extends SimpleTagSupport {

	private String id;
	private String tabContainerId;
	
	public void setId(final String id) {
		this.id = id;
	}
	
	public void setTabContainerId(final String tabContainerId) {
		this.tabContainerId = tabContainerId;
	}
	
	public void doTag() throws IOException, JspException {
		
		StringWriter evalResult = new StringWriter();
		StringBuffer buff		= evalResult.getBuffer();
		
		buff.append("\n\t<input type=\"button\" ")
			.append("class=\"ditch-next-tab-button\" ")
			.append("onclick=\"org.ditchnet.jsp.")
			.append("TabUtils.nextTabButtonClicked(event,'")
			.append(tabContainerId).append("'); return false;\"");
		if (null != id && 0 != id.length()) {
			buff.append(" id=\"").append(id).append("\"");
		}
		buff.append(" value=\"");
		getJspBody().invoke(evalResult);
		buff.append("\" />\n");

		getJspContext().getOut().print(buff);
		
	}
	
}
