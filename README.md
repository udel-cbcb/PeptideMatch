# A fast Peptide Match Service for UniProt Knowledgebase

Locating occurrences of a specific peptide in a protein sequence database is important for protein identification in proteomics studies as well as for sequence-based protein retrieval. Although exact peptide matching is algorithmically simple, quickly locating a peptide in a large protein sequence database has become challenging, as the number of protein sequences exponentially increases. We have developed a new web application for peptide matching using Apache Lucene-based search engine. The Peptide Match service is designed to quickly retrieve all occurrences of a given query peptide from UniProt Knowledgebase (UniProtKB) with isoforms. The matched proteins are shown in summary tables with rich annotations and are grouped by taxonomy and can be browsed by organism, taxonomic group or taxonomy tree. The service supports queries where isobaric leucine and isoleucine are treated equivalent, and an option for searching UniRef100 representative sequences, as well as dynamic queries to major proteomic databases. In addition to the web interface, we also provide RESTful web services.

This repository contains the source code for Peptide Match related project.

- [peptidematch_web](./peptidematch_web)
This project contains the source code for Java web application at https://research.bioinformatics.udel.edu/peptidematch/index.jsp. It is the original web interface we developed for accessing our Peptide Match service.


## Publication

Chuming Chen; Zhiwen Li; Hongzhan Huang; Baris E. Suzek; Cathy H. Wu; UniProt Consortium.
[A fast Peptide Match Service for UniProt Knowledgebase](https://bioinformatics.oxfordjournals.org/content/29/21/2808).
Bioinformatics 2013; doi: 10.1093/bioinformatics/btt484.
