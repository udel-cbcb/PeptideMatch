


_menuCloseDelay=0           // The time delay for menus to remain visible on mouse out
_menuOpenDelay=0            // The time delay before menus open on mouse over
_followSpeed=5                // Follow scrolling speed
_followRate=50                // Follow scrolling Rate
_subOffsetTop=5               // Sub menu top offset
_subOffsetLeft=-10            // Sub menu left offset
_scrollAmount=3               // Only needed for Netscape 4.x
_scrollDelay=20               // Only needed for Netcsape 4.x



with(menuStyle=new mm_style()){
onbgcolor="#E4F2BC";
oncolor="#000000";
offbgcolor="#ffffff";
offcolor="#000000";
bordercolor="#296488";
borderstyle="solid";
borderwidth=0;
separatorcolor="#ffffff";
separatorsize="0";
padding=5;
fontsize="9";
fontstyle="normal";
fontfamily="Verdana, Tahoma, Arial";
}

with(submenuStyle=new mm_style()){
onbgcolor="#C7D5EC";
oncolor="#000000";
offbgcolor="#ffffff";
offcolor="#003366";
bordercolor="#296488";
borderstyle="solid";
borderwidth=1;
separatorcolor="#E5E5E5";
separatorsize="1";
imagepadding=5;
padding=5;
fontsize="11";
fontstyle="normal";
fontweight="bold";
fontfamily="Verdana, Tahoma, Arial";
overfilter="Fade(duration=0.2);Alpha(opacity=100);Shadow(color='#003366', Direction=135, Strength=5)";
}

with(milonic=new menuname("Main Menu")){
style=menuStyle;
top=80;
left=94;
alwaysvisible=1;
orientation="horizontal";
hidediv="myiframe";
aI("image=https://pir.georgetown.edu/pirwww/menu/b_about_off.png;overimage=https://pir.georgetown.edu/pirwww/menu/b_about_on.png;showmenu=About PIR;url=https://pir.georgetown.edu/pirwww/about/;");
aI("image=https://pir.georgetown.edu/pirwww/menu/b_databases_off.png;overimage=https://pir.georgetown.edu/pirwww/menu/b_databases_on.png;showmenu=Databases;url=https://pir.georgetown.edu/pirwww/dbinfo/;");
aI("image=https://pir.georgetown.edu/pirwww/menu/b_search_analy_off.png;overimage=https://pir.georgetown.edu/pirwww/menu/b_search_analy_on.png;showmenu=Search/Analysis;url=https://pir.georgetown.edu/pirwww/search/;");
aI("image=https://pir.georgetown.edu/pirwww/menu/b_download_off.png;overimage=https://pir.georgetown.edu/pirwww/menu/b_download_on.png;showmenu=Download;url=https://pir.georgetown.edu/pirwww/download/;");
aI("image=https://pir.georgetown.edu/pirwww/menu/b_support_off.png;overimage=https://pir.georgetown.edu/pirwww/menu/b_support_on.png;showmenu=Support;url=https://pir.georgetown.edu/pirwww/support/;");

}

with(milonic=new menuname("About PIR")){
style=submenuStyle;
overflow="scroll";
hidediv="myiframe";
aI("text=History;url=https://pir.georgetown.edu/pirwww/about/aboutpir.shtml;");
aI("text=PIR Brochure;url=https://pir.georgetown.edu/pirwww/about/brochure.pdf;");
aI("text=Funding & Sponsors;url=https://pir.georgetown.edu/pirwww/about/sponsor.shtml;");
aI("text=Publications;url=https://pir.georgetown.edu/pirwww/about/publication.shtml;");
aI("text=Presentations/Abstracts;url=https://pir.georgetown.edu/pirwww/about/presentations.shtml;");
aI("text=Staff;url=https://pir.georgetown.edu/pirwww/about/staff.shtml;");

aI("text=Use/Link to PIR;url=https://pir.georgetown.edu/pirwww/about/linkpir.shtml;");

aI("text=Employment;url=https://pir.georgetown.edu/pirwww/about/employment.shtml;");

aI("text=Contact;url=https://pir.georgetown.edu/pirwww/support/contact.shtml;");

}

with(milonic=new menuname("Databases")){
style=submenuStyle;
overflow="scroll";
hidediv="myiframe";
aI("text=<font color=red><i>i</i></font>ProClass;url=https://pir.georgetown.edu/pirwww/dbinfo/iproclass.shtml;");
aI("text=PIRSF;url=https://pir.georgetown.edu/pirwww/dbinfo/pirsf.shtml;");
aI("text=PIR-PSD;url=https://pir.georgetown.edu/pirwww/dbinfo/pir_psd.shtml;");
aI("text=PIR-NREF;url=https://pir.georgetown.edu/pirwww/dbinfo/nref.shtml;");
aI("text=UniProt&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;;url=https://pir.georgetown.edu/pirwww/dbinfo/uniprot.shtml;");

}


with(milonic=new menuname("Search/Analysis")){
style=submenuStyle;
overflow="scroll";
hidediv="myiframe";

aI("text=Search & Analysis Tools;url=https://pir.georgetown.edu/pirwww/search/searchtools.shtml;");
aI("text=Text Search;url=https://pir.georgetown.edu/pirwww/search/textsearch.shtml;");
aI("text=Batch Retrieval;url=https://pir.georgetown.edu/pirwww/search/batch.shtml;");
//aI("text=BLAST Search;url=https://pir.georgetown.edu/pirwww/search/blast.shtml;onfunction=showtip;");

//aI("text=FASTA Search;url=https://pir.georgetown.edu/pirwww/search/fasta.shtml;");
aI("text=Peptide Match;url=https://research.bioinformatics.udel.edu/peptidematch/index.htm;");
//aI("text=Pattern Search;url=https://pir.georgetown.edu/pirwww/search/pattern.shtml;");
aI("text=Pairwise Alignment;url=https://pir.georgetown.edu/pirwww/search/pairwise.shtml;");
aI("text=Multiple Alignment;url=https://pir.georgetown.edu/pirwww/search/multialn.shtml;");
aI("text=ID Mapping;url=https://pir.georgetown.edu/pirwww/search/idmapping.shtml;");
//aI("text=PIRSF Scan;url=https://pir.georgetown.edu/pirwww/search/pirsfscan.shtml;");
aI("text=Composition/Mol Weight;url=https://pir.georgetown.edu/pirwww/search/comp_mw.shtml;");

}

with(milonic=new menuname("Download")){
style=submenuStyle;
overflow="scroll";
hidediv="myiframe";

aI("text=FTP Center;url=https://pir.georgetown.edu/pirwww/download/ftpcenter.shtml;");
aI("text=PIRSF;url=ftp://ftp.pir.georgetown.edu/databases/pirsf/;");
aI("text=<font color=red><i>i</i></font>ProClass;url=ftp://ftp.pir.georgetown.edu/databases/iproclass/;");

}

with(milonic=new menuname("Support")){
style=submenuStyle;
overflow="scroll";
hidediv="myiframe";

aI("text=Help;url=https://pir.georgetown.edu/pirwww/support/help.shtml;");
aI("text=FAQ;url=https://pir.georgetown.edu/pirwww/support/faq.shtml;");
aI("text=Site Search;url=https://pir.georgetown.edu/pirwww/support/sitesearch.shtml;");
aI("text=Contact;url=https://pir.georgetown.edu/pirwww/support/contact.shtml;");
aI("text=Useful Links&nbsp;&nbsp;&nbsp;&nbsp;;url=https://pir.georgetown.edu/pirwww/support/usefullinks.shtml;");
}




drawMenus();

