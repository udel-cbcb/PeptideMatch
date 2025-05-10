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
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.JspContext;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.SimpleTagSupport;
import org.ditchnet.jsp.util.JspResponseWriter;
import org.ditchnet.xml.Xhtml;


/**
 *	@author Todd Ditchendorf
 *	@since 0.8
 *	
 *	JSP Tag that renders individual tab pane components and their tabs.
 */
public final class TabPaneTag extends SimpleTagSupport {
		
	private String id,tabTitle;
	private TabContainerTag tabContainer;
	private JspResponseWriter out = new JspResponseWriter();
	
	public void setId(final String id) {
		this.id = id;
	}
	
	public String getId() {
		return id;
	}
	
	public void setTabTitle(final String tabTitle) {
		this.tabTitle = tabTitle;
	}
	
	public String getTabTitle() {
		return tabTitle;
	}

	public void doTag() throws JspException, IOException {
		addToContainer();
		renderComponent();
	}
	
	public TabContainerTag getTabContainer() {
		if (null == tabContainer) {
			tabContainer = (TabContainerTag)
					findAncestorWithClass(this,TabContainerTag.class);
		}
		return tabContainer;
	}
	
	private void addToContainer() {
		getTabContainer().addChild(this);
	}
	
	private void renderComponent() throws JspException, IOException {
					
		out.lineBreak();
		out.startElement(Xhtml.Tag.DIV);
		out.attribute(Xhtml.Attr.ID,id);
		out.attribute(Xhtml.Attr.CLASS,TabConstants.TAB_PANE_CLASS_NAME);
		if (isSelectedTab()) {
			out.attribute(Xhtml.Attr.STYLE,"display:block;");
		} else {
			out.attribute(Xhtml.Attr.STYLE,"display:none;");
		}
		out.text(" ");
			
		getJspBody().invoke(out.getWriter());

		out.lineBreak();
		out.endElement(Xhtml.Tag.DIV);
		
		getJspContext().getOut().print(out.getBuffer());

	}

	private boolean isSelectedTab() {
		return getTabContainer().getChildren().indexOf(this) == 
						getTabContainer().getSelectedIndex();
	}
}
