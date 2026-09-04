package org.proteininformationresource.peptidematch;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class OrganismTest {

    @Test
    void testDefaultConstructor() {
        Organism org = new Organism();
        assertNull(org.getName());
        assertEquals(0, org.getTaxonId());
    }

    @Test
    void testParameterizedConstructor() {
        Organism org = new Organism("Homo sapiens", 9606);
        assertEquals("Homo sapiens", org.getName());
        assertEquals(9606, org.getTaxonId());
    }

    @Test
    void testSetters() {
        Organism org = new Organism();
        org.setName("Mus musculus");
        org.setTaxonId(10090);

        assertEquals("Mus musculus", org.getName());
        assertEquals(10090, org.getTaxonId());
    }
}
