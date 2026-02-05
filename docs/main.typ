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
  "FIR":"Finite Impulse Response",

  
 
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

// TODO: Reference filter designer
// TODO: Reference board
The task provided centered around the implementation of #acr("FIR") filters for time domain signals. The signals to be used were derived from the student numbers of the students completing the task. Filters were created for each signal using MATLAB Filter Designer and tested within MATLAB. These filter coefficients were then exported as C header files and code for time domain filtering using the OMAP-L148 development boards was developed and optimised. The results of this were then compared against the MATLAB implementation to find the error.

= MATLAB Implementation

The input signal was constructed by repeating each student's registration number one hundred times. The student numbers used are shown in @Student_Numbers and the resulting signal vectors are shown in @input_signals. Each mean of each vector was subtracted such that they were zero mean. The resulting signals are shown in @input_time_domain.


$ S_1 = [2, 0, 2, 1, 1, 8, 8, 7, 4] \
  S_2 = [2, 0, 2, 1, 1, 4, 6, 4, 2] $ <Student_Numbers>

$ x_1 = [2, 0, 2, 1, 1, 8, 8, 7, 4, 2, 0, 2, ... , 8, 7, 4] \
  x_2 = [2, 0, 2, 1, 1, 4, 6, 4, 2, 2, 0, 2, ... , 4, 6, 4] $ <input_signals>

The sampling rate was derived from the average of the final four digits of each student number as shown in @student_2_fs.
$ f_s = round( (S_1 [5:8] + S_2 [5:8]) /2 ) $ <student_2_fs>




= Embedded Implementation


= Comparison

= Conclusion

= Figures and Tables
== Part 1 

== Input Signals
#figure(
  image("Subsections/Section 1/figs/Input_time.svg"),
  caption: "Input signals in time domain",
) <input_time_domain>

#figure(
  image("Subsections/Section 1/figs/input_freq.svg"),
  caption: "Input signals in frequency domain. The first peak of both signals is at 752 Hz, and the second peak of the second signal is at 1504 Hz.",
) <input_freq_domain>

#figure(
 image("Subsections/Section 1/figs/input_freq_zoomed.svg"),
 caption: "Frequency domain plots of input signals zoomed to relevant peaks"
)

== Filter Design

#figure(
  image("Subsections/Section 1/figs/filter_coeffs.svg")
)

#figure(
  image("Subsections/Section 1/figs/filter1_polezero.svg")

)
#figure(
  image("Subsections/Section 1/figs/filter_1_magphase.svg")
)


#figure(
  image("Subsections/Section 1/figs/filter2_polezero.svg")
  
)
#figure(
  image("Subsections/Section 1/figs/filter2_polezero_zoomed.svg")
  
)
#figure(
  image("Subsections/Section 1/figs/filter2_magphase.svg")
  
)

== Filter Results

#figure(
  image("Subsections/Section 1/figs/filtered_time.svg")
)
#figure(
  image("Subsections/Section 1/figs/filtered_freq.svg")
)

#figure(
  image("Subsections/Section 1/figs/filtered_freq_zoomed.svg")
)

== Part 2 

== Part 3

#figure(
  image("Subsections/Section 3/figs/filtered_time_c.svg")
)
#figure(
  image("Subsections/Section 3/figs/filtered_time_error.svg")
)


#figure(
  image("Subsections/Section 3/figs/filtered_freq_c.svg")
)
#figure(
  image("Subsections/Section 3/figs/filtered_freq_error.svg")
)

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