package query;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

public class TaxonomyTreeNodeTest {

	@Test
	public void testConstructor() {
		TaxonomyTreeNode node = new TaxonomyTreeNode("Eukaryota", 2759, "no rank");
		assertEquals("Eukaryota", node.getName());
		assertEquals(2759, node.getTaxonomyID());
		assertEquals("no rank", node.getType());
		assertEquals(0, node.getSeqCount());
	}

	@Test
	public void testConstructorWithSeqCount() {
		TaxonomyTreeNode node = new TaxonomyTreeNode("Homo sapiens", 9606, "species", 10);
		assertEquals(10, node.getSeqCount());
	}

	@Test
	public void testAddAppendsChild() {
		TaxonomyTreeNode root = new TaxonomyTreeNode("root", 1, "");
		TaxonomyTreeNode child = new TaxonomyTreeNode("child", 2, "");
		root.add(child);
		assertEquals(1, root.getChildren().length);
		assertEquals("child", root.getChildren()[0].getName());
		assertEquals(root, child.getParent());
		assertTrue(child.isRoot() == false);
		assertTrue(root.isRoot());
	}

	@Test
	public void testAddChildAtIndex() {
		TaxonomyTreeNode root = new TaxonomyTreeNode("root", 1, "");
		TaxonomyTreeNode a = new TaxonomyTreeNode("a", 2, "");
		TaxonomyTreeNode b = new TaxonomyTreeNode("b", 3, "");
		TaxonomyTreeNode c = new TaxonomyTreeNode("c", 4, "");
		root.add(a);
		root.add(c);
		root.add(b, 1);
		assertEquals(3, root.getChildren().length);
		assertEquals("a", root.getChildren()[0].getName());
		assertEquals("b", root.getChildren()[1].getName());
		assertEquals("c", root.getChildren()[2].getName());
	}

	@Test
	public void testAddWithNegativeIndexAppends() {
		TaxonomyTreeNode root = new TaxonomyTreeNode("root", 1, "");
		TaxonomyTreeNode a = new TaxonomyTreeNode("a", 2, "");
		TaxonomyTreeNode b = new TaxonomyTreeNode("b", 3, "");
		root.add(a);
		root.add(b, -1);
		assertEquals(2, root.getChildren().length);
		assertEquals("b", root.getChildren()[1].getName());
	}

	@Test(expected = IllegalArgumentException.class)
	public void testAddWithTooLargeIndexThrows() {
		TaxonomyTreeNode root = new TaxonomyTreeNode("root", 1, "");
		root.add(new TaxonomyTreeNode("a", 2, ""), 5);
	}

	@Test
	public void testRemoveChild() {
		TaxonomyTreeNode root = new TaxonomyTreeNode("root", 1, "");
		TaxonomyTreeNode a = new TaxonomyTreeNode("a", 2, "");
		TaxonomyTreeNode b = new TaxonomyTreeNode("b", 3, "");
		root.add(a);
		root.add(b);
		TaxonomyTreeNode removed = root.remove(0);
		assertEquals("a", removed.getName());
		assertEquals(1, root.getChildren().length);
		assertEquals("b", root.getChildren()[0].getName());
	}

	@Test(expected = IllegalArgumentException.class)
	public void testRemoveInvalidIndexThrows() {
		TaxonomyTreeNode root = new TaxonomyTreeNode("root", 1, "");
		root.remove(3);
	}

	@Test
	public void testRemoveFromParent() {
		TaxonomyTreeNode root = new TaxonomyTreeNode("root", 1, "");
		TaxonomyTreeNode child = new TaxonomyTreeNode("child", 2, "");
		root.add(child);
		child.removeFromParent();
		assertEquals(0, root.getChildren().length);
		assertTrue(child.isRoot());
	}

	@Test
	public void testRemoveFromParentOnRootNoop() {
		TaxonomyTreeNode root = new TaxonomyTreeNode("root", 1, "");
		root.removeFromParent();
		assertTrue(root.isRoot());
	}

	@Test
	public void testIsRoot() {
		TaxonomyTreeNode node = new TaxonomyTreeNode("node", 1, "");
		assertTrue(node.isRoot());
	}

	@Test
	public void testChildrenAndHasChildren() {
		TaxonomyTreeNode root = new TaxonomyTreeNode("root", 1, "");
		assertFalse(root.hasChildren());
		assertEquals(0, root.children().length);
		root.add(new TaxonomyTreeNode("a", 2, ""));
		assertTrue(root.hasChildren());
		assertEquals(1, root.children().length);
	}

	@Test
	public void testHasChildrenWithChild() {
		TaxonomyTreeNode root = new TaxonomyTreeNode("root", 1, "");
		TaxonomyTreeNode a = new TaxonomyTreeNode("a", 2, "");
		TaxonomyTreeNode b = new TaxonomyTreeNode("b", 3, "");
		root.add(a);
		assertTrue(root.hasChildren(a));
		assertFalse(root.hasChildren(b));
	}

	@Test
	public void testIndex() {
		TaxonomyTreeNode root = new TaxonomyTreeNode("root", 1, "");
		TaxonomyTreeNode a = new TaxonomyTreeNode("a", 2, "");
		TaxonomyTreeNode b = new TaxonomyTreeNode("b", 3, "");
		root.add(a);
		root.add(b);
		assertEquals(0, a.index());
		assertEquals(1, b.index());
		assertEquals(-1, root.index());
	}

	@Test
	public void testDepth() {
		TaxonomyTreeNode root = new TaxonomyTreeNode("root", 1, "");
		TaxonomyTreeNode level1 = new TaxonomyTreeNode("l1", 2, "");
		TaxonomyTreeNode level2 = new TaxonomyTreeNode("l2", 3, "");
		root.add(level1);
		level1.add(level2);
		assertEquals(0, root.depth());
		assertEquals(1, level1.depth());
		assertEquals(2, level2.depth());
	}

	@Test
	public void testCompareToByName() {
		TaxonomyTreeNode a = new TaxonomyTreeNode("apple", 1, "");
		TaxonomyTreeNode b = new TaxonomyTreeNode("banana", 2, "");
		assertTrue(a.compareTo(b) < 0);
		assertTrue(b.compareTo(a) > 0);
		assertEquals(0, a.compareTo(new TaxonomyTreeNode("apple", 3, "")));
	}

	@Test
	public void testNameComparatorIsCaseInsensitive() {
		TaxonomyTreeNode a = new TaxonomyTreeNode("apple", 1, "");
		TaxonomyTreeNode b = new TaxonomyTreeNode("Banana", 2, "");
		assertTrue(TaxonomyTreeNode.TaxonomyTreeNodeNameComparator.compare(a, b) < 0);
	}
}
