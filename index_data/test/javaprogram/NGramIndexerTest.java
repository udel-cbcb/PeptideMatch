package javaprogram;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

public class NGramIndexerTest {

	@Rule
	public TemporaryFolder tempFolder = new TemporaryFolder();

	@Test
	public void testDeleteDirRemovesNestedDirectories() throws IOException {
		File dir = tempFolder.newFolder("todelete");
		File subDir = new File(dir, "sub");
		subDir.mkdir();
		File nestedFile = new File(subDir, "file.txt");
		nestedFile.createNewFile();
		File topFile = new File(dir, "top.txt");
		topFile.createNewFile();

		assertTrue(dir.exists());
		assertTrue(NGramIndexer.deleteDir(dir));
		assertFalse(dir.exists());
	}

	@Test
	public void testDeleteDirOnSingleFile() throws IOException {
		File file = tempFolder.newFile("single.txt");
		assertTrue(file.exists());
		assertTrue(NGramIndexer.deleteDir(file));
		assertFalse(file.exists());
	}

	@Test
	public void testDeleteDirOnNonExistentPath() {
		File missing = new File(tempFolder.getRoot(), "does-not-exist");
		assertFalse(NGramIndexer.deleteDir(missing));
	}

	@Test
	public void testIndexCreatesIndexFiles() throws IOException {
		File dataFile = tempFolder.newFile("data.fasta");
		FileWriter w = new FileWriter(dataFile);
		w.write(">P12345 P12345_9ARCH^|^P12345_9ARCH^|^^|^a test protein^|^^|^^|^org^|^123^|^group^|^456^|^X^|^X^|^X^|^^|^1, 131567^|^1, 131567^|^UniRef100_P12345\n");
		w.write("MKTAYIAKQRQISFVKSHFSRQ\n");
		w.write(">Q67890 Q67890_9ARCH^|^Q67890_9ARCH^|^^|^another protein^|^^|^^|^org2^|^124^|^group^|^457^|^X^|^X^|^X^|^^|^1, 131567^|^1, 131567^|^UniRef100_Q67890\n");
		w.write("ACDEFGHIKLMNPQRSTVWY\n");
		w.close();

		File indexDir = tempFolder.newFolder("indexdir");
		NGramIndexer.index(indexDir, dataFile, 3, 3);

		String[] files = indexDir.list();
		assertTrue("expected index files in " + indexDir + ": " + java.util.Arrays.toString(files),
				files != null && files.length > 0);
	}

	@Test
	public void testIndexThrowsOnMissingDataFile() throws IOException {
		File indexDir = tempFolder.newFolder("indexdir2");
		File missing = new File(tempFolder.getRoot(), "missing.fasta");
		boolean threw = false;
		try {
			NGramIndexer.index(indexDir, missing, 3, 3);
		} catch (IOException e) {
			threw = true;
		}
		assertTrue(threw);
	}

	@Test
	public void testIndexOverwritesExistingIndexDir() throws IOException {
		File dataFile = tempFolder.newFile("data2.fasta");
		FileWriter w = new FileWriter(dataFile);
		w.write(">P12345 P12345_9ARCH^|^P12345_9ARCH^|^^|^a test protein^|^^|^^|^org^|^123^|^group^|^456^|^X^|^X^|^X^|^^|^1, 131567^|^1, 131567^|^UniRef100_P12345\n");
		w.write("MKTAYIAKQRQISFVKSHFSRQ\n");
		w.close();

		File indexDir = tempFolder.newFolder("indexdir3");
		File stale = new File(indexDir, "stale.txt");
		stale.createNewFile();

		NGramIndexer.index(indexDir, dataFile, 3, 3);

		assertFalse("stale file should be removed by overwrite", stale.exists());
		String[] files = indexDir.list();
		assertTrue("expected index files after overwrite: " + java.util.Arrays.toString(files),
				files != null && files.length > 0);
	}
}
