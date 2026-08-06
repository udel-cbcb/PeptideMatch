package query;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

public class TaxonomyLazyTreeNodeTest {

	@Test
	public void testConstructor() {
		TaxonomyLazyTreeNode node = new TaxonomyLazyTreeNode("Eukaryota", 2759, "no rank", "id1");
		assertEquals("Eukaryota", node.getName());
		assertEquals(2759, node.getTaxonomyID());
		assertEquals("no rank", node.getType());
		assertEquals("id1", node.getId());
		assertEquals(0, node.getSeqCount());
	}

	@Test
	public void testConstructorWithSeqCount() {
		TaxonomyLazyTreeNode node = new TaxonomyLazyTreeNode("Homo sapiens", 9606, "species", "id2", 10);
		assertEquals(10, node.getSeqCount());
	}

	@Test
	public void testAddAndRemoveChild() {
		TaxonomyLazyTreeNode root = new TaxonomyLazyTreeNode("root", 1, "", "r");
		TaxonomyLazyTreeNode a = new TaxonomyLazyTreeNode("a", 2, "", "a");
		TaxonomyLazyTreeNode b = new TaxonomyLazyTreeNode("b", 3, "", "b");
		root.add(a);
		root.add(b, 0);
		assertEquals(2, root.getChildren().length);
		assertEquals("b", root.getChildren()[0].getName());
		assertEquals("a", root.getChildren()[1].getName());
		assertEquals("r", a.getParent().getId());
		root.remove(0);
		assertEquals(1, root.getChildren().length);
	}

	@Test
	public void testIndexDepthAndIsRoot() {
		TaxonomyLazyTreeNode root = new TaxonomyLazyTreeNode("root", 1, "", "r");
		TaxonomyLazyTreeNode level1 = new TaxonomyLazyTreeNode("l1", 2, "", "l1");
		TaxonomyLazyTreeNode level2 = new TaxonomyLazyTreeNode("l2", 3, "", "l2");
		root.add(level1);
		level1.add(level2);
		assertTrue(root.isRoot());
		assertFalse(level2.isRoot());
		assertEquals(-1, root.index());
		assertEquals(0, root.depth());
		assertEquals(2, level2.depth());
		assertEquals(0, level1.index());
	}

	@Test
	public void testHasChildren() {
		TaxonomyLazyTreeNode root = new TaxonomyLazyTreeNode("root", 1, "", "r");
		assertFalse(root.hasChildren());
		root.add(new TaxonomyLazyTreeNode("a", 2, "", "a"));
		assertTrue(root.hasChildren());
	}

	@Test
	public void testCompareToAndComparator() {
		TaxonomyLazyTreeNode a = new TaxonomyLazyTreeNode("apple", 1, "", "a");
		TaxonomyLazyTreeNode b = new TaxonomyLazyTreeNode("banana", 2, "", "b");
		assertTrue(a.compareTo(b) < 0);
		assertTrue(TaxonomyLazyTreeNode.TaxonomyLazyTreeNodeNameComparator.compare(a, b) < 0);
	}
}
