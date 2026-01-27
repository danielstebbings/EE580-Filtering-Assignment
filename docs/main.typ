#import "./Template/template.typ": *

#import "@preview/codelst:2.0.2": sourcecode
#import "@preview/acrostiche:0.5.1": *
#import "@preview/wordometer:0.1.4" : word-count, total-words
#import "@preview/subpar:0.2.1"
#import "@preview/numbly:0.1.0": numbly

#set text(size: 10pt, region: "GB")
#set page(margin:2.5cm)
#set list(indent: 2em)

// Acronym List
#init-acronyms((

  
 
))

#show: strathy.with(
  // Make this shorterer
  title: "EE580 Mini Project",

  //takes in a list of dicts (name: full_name, reg: registration_number)
  authors: (
    (name: "Daniel Stebbings",    reg: "202118874"),

    (name: "Preben Rasamanickam", reg: "202114642"),
    
  ),
  
  declaration: [
  We confirm and declare that this report and the project work is entirely the product of our own efforts and we have not used or presented the work of others herein without acknowledgement
  ],

  //abstract: [

  //],
  
  subtitle: [
  Department of Electronic and Electrical Engineering \
  University of Strathclyde, Glasgow
  ],
  
  // date: [your custom date]
  //default is datetime.today().display("[day] [month repr:long] [year]")
  
  // whether to gen a list of figs
  figures: false,
  
  // special space for the glossary, if using a glossary manager
  //glossary: [#print-index(title: "Definitions", sorted: "up")],
  
  // whether to generate the typst ack at the bottom
  ack: false,

  // compact layeout for assignments, set to false for more "grandeur"
  compact: true
)
// table titles at the top if you like it that way
#show figure.where(
  kind: table
): set figure.caption(position: top)


//The report is required to be in PDF format, and it should have the following structure:
//• Introduction
//• Part 1
//• Part 2
//• Part 3
//• Conclusion
//o Figures and tables (appropriately labelled)
//o Code (compulsory, in text format, and exhaustively commented)
//o References
//o Contributions
//A maximum of 5 pages is allowed for Introduction, Part1-3 and Conclusion sections
//combined; pages in excess will not be assessed. There is no page limit for figures, tables,
//code, references and contributions. A4 format, typical margins (~2.50cm) and font size
//(10-12pt) should be used.


= Introduction


= Part 1
= Part 2
= Part 3

= Conclusion

= Figures and Tables

= Code Listings
== MATLAB Implementation
== C Implementation
== Comparison




#pagebreak()

#show bibliography: set heading(numbering: "1")
#bibliography(
  ( 

  ),
)
#pagebreak()

= Contributions