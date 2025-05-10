package query;

import java.util.LinkedList;
import java.util.Queue;
import java.util.Comparator;
import java.util.Arrays;

/**
 * 
 */

/**
 * @author chenc
 * 
 */
public class TaxonomyLazyTreeNode implements Comparable<TaxonomyLazyTreeNode> {
	private TaxonomyLazyTreeNode parent;
	private TaxonomyLazyTreeNode[] children = new TaxonomyLazyTreeNode[0];
	private String name;
	private String type;
	private String id;
	
	public TaxonomyLazyTreeNode(String name, int taxonomyID, String type, String id) {
		super();
		this.name = name;
		this.taxonomyID = taxonomyID;
		this.type = type;
		this.id = id;
	}

	public TaxonomyLazyTreeNode(String name, int taxonomyID, String type, String id, int seqCount) {
		super();
		this.name = name;
		this.taxonomyID = taxonomyID;
		this.seqCount = seqCount;
		this.type = type;
		this.id = id;
	}

	public TaxonomyLazyTreeNode() {
		// TODO Auto-generated constructor stub
	}

	public String getId() {
		return this.id;
	}

	public void setId(String id) {
		this.id = id;
	}	
	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	private int taxonomyID;
	private int seqCount;

	public TaxonomyLazyTreeNode getParent() {
		return parent;
	}

	public void setParent(TaxonomyLazyTreeNode parent) {
		this.parent = parent;
	}

	public TaxonomyLazyTreeNode[] getChildren() {
		return children;
	}

	public void setChildren(TaxonomyLazyTreeNode[] children) {
		this.children = children;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getTaxonomyID() {
		return taxonomyID;
	}

	public void setTaxonomyID(int taxonomyID) {
		this.taxonomyID = taxonomyID;
	}

	public int getSeqCount() {
		return seqCount;
	}

	public void setSeqCount(int seqCount) {
		this.seqCount = seqCount;
	}

	/**
	 * Adds the <code>child</code> node to this container making this its
	 * parent.
	 * 
	 * @param child
	 *            is the node to add to the tree as a child of <code>this</code>
	 * 
	 * @param index
	 *            is the position within the children list to add the child. It
	 *            must be between 0 (the first child) and the total number of
	 *            current children (the last child). If it is negative the child
	 *            will become the last child.
	 */

	public void add(TaxonomyLazyTreeNode child, int index) {
		// Add the child to the list of children.
		if (index < 0 || index == children.length) // then append
		{
			TaxonomyLazyTreeNode[] newChildren = new TaxonomyLazyTreeNode[children.length + 1];
			System.arraycopy(children, 0, newChildren, 0, children.length);
			newChildren[children.length] = child;
			children = newChildren;
		} else if (index > children.length) {
			throw new IllegalArgumentException("Cannot add child to index "
					+ index + ".  There are only " + children.length
					+ " children.");
		} else // insert
		{
			TaxonomyLazyTreeNode[] newChildren = new TaxonomyLazyTreeNode[children.length + 1];
			if (index > 0) {
				System.arraycopy(children, 0, newChildren, 0, index);
			}
			newChildren[index] = child;
			System.arraycopy(children, index, newChildren, index + 1,
					children.length - index);
			children = newChildren;
		}

		// Set the parent of the child.
		child.parent = this;
	}

	/**
	 * Adds the <code>child</code> node to this container making this its
	 * parent. The child is appended to the list of children as the last child.
	 */
	public void add(TaxonomyLazyTreeNode child) {
		add(child, -1);
		//this.seqCount += child.getSeqCount();
	}

	
	/**
	 * Removes the child at position <code>index</code> from the tree.
	 * 
	 * @param index
	 *            is the position of the child. It should be between 0 (the
	 *            first child) and the total number of children minus 1 (the
	 *            last child).
	 * @return The removed child node. This will be <code>null</code> if no
	 *         child exists at the specified <code>index</code>.
	 */

	public TaxonomyLazyTreeNode remove(int index) {
		if (index < 0 || index >= children.length)
			throw new IllegalArgumentException(
					"Cannot remove element with index " + index
							+ " when there are " + children.length
							+ " elements.");

		// Get a handle to the node being removed.
		TaxonomyLazyTreeNode node = children[index];
		node.parent = null;

		// Remove the child from this node.
		TaxonomyLazyTreeNode[] newChildren = new TaxonomyLazyTreeNode[children.length - 1];
		if (index > 0) {
			System.arraycopy(children, 0, newChildren, 0, index);
		}
		if (index != children.length - 1) {
			System.arraycopy(children, index + 1, newChildren, index,
					children.length - index - 1);
		}
		children = newChildren;

		return node;
	}

	/**
	 * Removes this node from its parent. This node becomes the root of a
	 * subtree where all of its children become first level nodes.
	 * <p>
	 * Calling this on the root node has no effect.
	 */
	public void removeFromParent() {
		if (parent != null) {
			int position = this.index();
			parent.remove(position);
			parent = null;
		}
	}

	/**
	 * Returns if this node is the root node in the tree or not.
	 * 
	 * @return <code>true</code> if this node is the root of the tree;
	 *         <code>false</code> if it has a parent.
	 */
	public boolean isRoot() {
		if (parent == null) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Gets a list of all the child nodes of this node.
	 * 
	 * @return An array of all the child nodes. The array will be the size of
	 *         the number of children. A leaf node will return an empty array,
	 *         not <code>null</code>.
	 */
	public TaxonomyLazyTreeNode[] children() {
		return children;
	}

	/**
	 * Returns if this node has children or if it is a leaf node.
	 * 
	 * @return <code>true</code> if this node has children; <code>false</code>
	 *         if it does not have any children.
	 */
	public boolean hasChildren() {
		if (children.length == 0) {
			return false;
		} else {
			return true;
		}
	}

	public boolean hasChildren(TaxonomyLazyTreeNode child) {
		//System.out.println("I am in");
		if (children.length == 0) {
			return false;
		} else {
			for(int i =0 ; i < children.length; i++) {
				//System.out.println("I am here");
				//System.out.println(children[i].getName()+ " <> "+ child.getName());
				if(children[i].getName().equals(child.getName())) {
					
					return true;
				}
				
			}
			return false;
		}
	}
	/**
	 * Gets the position of this node in the list of siblings managed by the
	 * parent node. This node can be obtained by
	 * <code>this = parent.children[this.index()]</code>.
	 * 
	 * @return The index of the child array of this node's parent. If this is
	 *         the root node it will return -1.
	 */
	public int index() {
		if (parent != null) {
			for (int i = 0;; i++) {
				Object node = parent.children[i];

				if (this == node) {
					return i;
				}
			}
		}

		// Only ever make it here if this is the root node.
		return -1;
	}

	/**
	 * Gets this node's depth in the tree. The root node will have a depth of 0,
	 * first-level nodes will have a depth of 1, and so on.
	 * 
	 * @return The depth of this node in the tree.
	 */
	public int depth() {
		int depth = recurseDepth(parent, 0);
		return depth;
	}

	/**
	 * Recursive helper method to calculate the depth of a node. The caller
	 * should pass its parent and an initial depth of 0.
	 * <p>
	 * A recursive approach is used so that when a node that is part of a tree
	 * is removed from that tree, we do not need to recalculate the depth of
	 * every node in that subtree.
	 * 
	 * @param node
	 *            is the node to recursively check for its depth. This should be
	 *            set to <code>parent</code> by the caller.
	 * @param depth
	 *            is the depth of the current node (i.e. the child of
	 *            <code>node</code>). This should be set to 0 by the caller.
	 */
	private int recurseDepth(TaxonomyLazyTreeNode node, int depth) {
		if (node == null) // reached top of tree
		{
			return depth;
		} else {
			return recurseDepth(node.parent, depth + 1);
		}
	}

	public String toString() {
		printLevelList();
		return "";
	}

	private static final int indent = 2;
/*
	private String printTree() {
		String s = this.getName() + "(";

		for (int i = 0; i < children.length; i++) {
			TaxonomyLazyTreeNode child = children[i];
			s += "\n" + child.printTree();
		}
		for (int i = 0; i < children.length; i++) {
			TaxonomyLazyTreeNode child = children[i];
			s += child.getName() + ", ";

		}
		s += ")\n";
		return s;

	}
	*/

	public String printTree(int increment) {
		String s = "";
		String inc = "";
		for (int i = 0; i < increment; ++i) {
			inc = inc + " ";
		}
		s = inc;
		s = inc + this.getName();
		for (int i = 0; i < children.length; i++) {

			TaxonomyLazyTreeNode child = children[i];
			System.out.println(child.getName() + "!!!");
			s += "\n" + child.printTree(increment + indent);
		}
		return s;
	}

	 public String printTree() {
		String lst = "";
		if(this.getName().equals("Organism")) {
			lst += "<li>" + this.getName();
		}
		else {
			lst +="<li><a href=\"http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+ this.taxonomyID+"\" target=\"_blank\">" +this.getName() + "</a>";
		}
		if(!this.getType().equals("") && !this.getType().equals("no rank")) {
			lst +=" [<font color=red>" + this.getType()+"</font>]";
		}
			lst += " (" + this.getSeqCount()+")";
		
		if(this.children.length > 0) {
			lst +="<ul>\n";
			Arrays.sort(children, TaxonomyLazyTreeNode.TaxonomyLazyTreeNodeNameComparator);
			//for(int i=0; i < this.children.length; i++) {
			for(TaxonomyLazyTreeNode temp: children) {
				//lst += this.children[i].printTree();
				lst += temp.printTree();
				
			}
			lst += "</ul>\n";
		}
		lst +="</li>\n";
		return lst;
	}

	public String printLineage() {
		String lst = "";
		if(this.getName().equals("Organism")) {
			//lst += "<li>" + this.getName();
		}
		else {
			lst +="<a href=\"http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?lvl=0&id="+ this.taxonomyID+"\">" +this.getName() + "</a>";
		}
		if(!this.getType().equals("")) {
			lst +=" [<font color=red>" + this.getType()+"</font>] ";
		}
			//lst += "(" + this.getSeqCount()+")";
		
		if(this.children.length > 0) {
			//lst +="<ul>\n";
			Arrays.sort(children, TaxonomyLazyTreeNode.TaxonomyLazyTreeNodeNameComparator);
			//for(int i=0; i < this.children.length; i++) {
			for(TaxonomyLazyTreeNode temp: children) {
				//lst += this.children[i].printTree();
				lst += temp.printLineage();
				
			}
			//lst += "</ul>\n";
		}
		return lst;
	}

	 Queue<TaxonomyLazyTreeNode> one = new LinkedList<TaxonomyLazyTreeNode>();
	Queue<TaxonomyLazyTreeNode> two = new LinkedList<TaxonomyLazyTreeNode>();

	//static void printLevelList(TaxonomyLazyTreeNode root) {
 void printLevelList() {

		if (this == null) {
			System.out.println("Empty tree");
			return;
		}
		System.out.println(this.getName() + "[" + this.getTaxonomyID()+", "+this.getSeqCount()+"]");
		System.out.println("--------------------------");
		if (!this.hasChildren()) {
			System.out.println("No Children");
			return;
		}

		addToQueue(this.children());
		copyQueue();
		while(true) {
			while(!one.isEmpty()) {
				TaxonomyLazyTreeNode node = one.remove();
				System.out.print(node.getName()+" [" + node.getTaxonomyID()+", "+node.getSeqCount()+"] " );
				addToQueue(node.children());
			}
			System.out.println("");
			System.out.println("--------------------------");
			copyQueue();
			if(one.isEmpty() && two.isEmpty()) {
				return;
			}
		}
	}
 
 void printLineage1() {

		if (this == null) {
			System.out.println("Empty tree");
			return;
		}
		System.out.print(this.getName() + "[" + this.getTaxonomyID()+"]; ");
		//System.out.println("--------------------------");
		if (!this.hasChildren()) {
			System.out.println("No Children");
			return;
		}

		addToQueue(this.children());
		copyQueue();
		while(true) {
			while(!one.isEmpty()) {
				TaxonomyLazyTreeNode node = one.remove();
				System.out.print(node.getName()+" [" + node.getTaxonomyID()+"]; " );
				addToQueue(node.children());
			}
			//System.out.println("");
			//System.out.println("--------------------------");
			copyQueue();
			if(one.isEmpty() && two.isEmpty()) {
				System.out.println();
				return;
			}
		}
	}
 
	private  void addToQueue(TaxonomyLazyTreeNode[] children) {
		if (children.length == 0) {
			return;
		}
		for (int i = 0; i < children.length; i++) {
			two.add((TaxonomyLazyTreeNode) children[i]);
		}
	}

	private  void copyQueue() {
		while (!two.isEmpty()) {
			one.add(two.remove());
		}
	}

	public int compareTo(TaxonomyLazyTreeNode compareTaxonomyLazyTreeNode) {
			return this.name.compareTo(compareTaxonomyLazyTreeNode.getName());
	}
	
	public static Comparator<TaxonomyLazyTreeNode> TaxonomyLazyTreeNodeNameComparator = new Comparator<TaxonomyLazyTreeNode>() {
		public int compare(TaxonomyLazyTreeNode node1, TaxonomyLazyTreeNode node2) {
			String nodeName1 = node1.getName().toUpperCase();
			String nodeName2 = node2.getName().toUpperCase();
		return nodeName1.compareTo(nodeName2);

		}	
	};
}
