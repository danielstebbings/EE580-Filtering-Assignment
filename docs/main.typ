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
  "FFT": "Fast Fourier Transform",
  "SIMD": "Single Instruction Multiple Data",
  "MSE": "Mean Squared Error",
  "MAC": "Multiply-Accumulate",
  "CCS": "Code Composer Studio",
  "DSP": "Digital Signal Processing",
 
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
The task provided centered around the implementation of #acr("FIR") filters for time domain signals. The signals to be used were derived from the student numbers of the students completing the task. Filters were created for each signal using MATLAB Filter Designer and tested within MATLAB. These filter coefficients were then exported as C header files and code for time domain filtering using the OMAP-L148 #acr("DSP") development boards was developed and optimised using #acr("CCS"). The results of this were then compared against the MATLAB implementation to find the error.

Multiple optimisation methods were investigated, including both fixed point representation and leveraging #acr("SIMD") instructions.

= MATLAB Implementation

== Filter Design <matlab_filter>
The input signal was constructed by repeating each student's registration number one hundred times. The student numbers used are shown in @Student_Numbers and the resulting signal vectors are shown in @input_signals. The mean of each vector was subtracted to ensure they had no DC offset. The resulting signals are shown in @input_time_domain.


$ S_1 = [2, 0, 2, 1, 1, 8, 8, 7, 4] \
  S_2 = [2, 0, 2, 1, 1, 4, 6, 4, 2] $ <Student_Numbers>

$ x_1 = [2, 0, 2, 1, 1, 8, 8, 7, 4, 2, 0, 2, ... , 8, 7, 4] \
  x_2 = [2, 0, 2, 1, 1, 4, 6, 4, 2, 2, 0, 2, ... , 4, 6, 4] $ <input_signals>

The sampling rate was calculated by rounding the average of the final four digits of each student number as shown in @student_2_fs. The resulting time domain plots are shown in @input_time_domain. An 1024 point #acr("FFT") of each signal was computed, as shown in @input_freq_domain. It was found that both signals had a peak at 1504 Hz, and a second peak at 752 Hz. In accordance to the provided brief, the 1504 Hz peak in $x_1$ was selected for suppression, and the 752 Hz peak in $x_2$. A zoomed plot of the relevant peaks is shown in @input_freq_zoomed.

$ f_s = round( (S_1 [5:8] + S_2 [5:8]) /2 ) = 6758 $ <student_2_fs>

For each signal an FIR bandstop filter was developed using MATLAB Filter Designer with a stop band limited to 100Hz. For $x_1$, the peak had a skew towards higher frequencies, so the stop band was defined from -50 Hz to +20 Hz of the 752 Hz. The implemented filter, $h_1$ , had an attenuation of over 70 dB in the stop band with an order of 358.

For $x_2$, the peak was slightly skewed as well, and the stop band defined from -40 Hz to +20 Hz of the 1504 Hz peak. The implemented filter $h_2$ had an attenuation of over 60dB in the stop band and an order of 314, although it had quite a high ripple in the stop band.

Although the filters had high cofficient counts, there was no real time requirement imposed by this project. Further, this provided a good benchmark to optimise against.

The filter coefficients / impulse response of the filters are shown in @filter_coeffs. Both filters were symmetric with a large central coefficient and much smaller ripples to either side. The magnitude and phase response of $h_1$ and $h_2$ are shown in @filter1_magphase and @filter2_magphase respectively. Both filters had minimal pass band ripple. They both also have linear phase, although with a nonlinearity in the stop band. As these were both #acr("FIR") filters the pole zero diagrams, as shown in @filter1_pz and @filter2_pz / @filter2_pz_zoom, had all poles at the root and several zeros in complex conjugate pairs around the unit circle. The zeroes associate with the stop band are arrayed at a correspondingly lower frequency for $h_1$ than $h_2$.

== Filter Results

The signals were filtered using @eq:filt_conv to create $y_1$ and $y_2$.

$ y_k = h_k * _k $ <eq:filt_conv>

= Embedded Implementation
== Signal Generation
// generate the signals x1[n] and x2[n]
The input signals $x_1$ and $x_2$ were constructed using a methodology similar to @matlab_filter, and stored in arrays for subsequent processing.

The generation process involved calculating the mean of the student's registration number shown in @Student_Numbers. Each digit of the registration number was then offset by the mean and assigned to the signal array. This sequence was then copied across the signal array until the target signal length was reached. 

// in CCS, plot time graphs of 3 cycles of the signals generated, and plot frequency graphs of the entire signals. 
In #acr("CCS"), time domain plots were generated for three cycles of the signals, see @emb_input1_time_domain and @emb_input2_time_domain, and frequency domain plots of the full signals, see @emb_input1_freq_domain and @emb_input2_freq_domain. 


== FIR Filter <emb_fir>
// In CCS, implement an FIR filter, to remove the unwanted frequencies from the two signals, based on your filter designs in Part 1 (i.e. using the filter coefficients stored in the header file “data.h”). 
The filter coefficients were derived as described in @matlab_filter and stored in data_1_fixed.h and data_2_fixed.h. The filter specifications were encapsulated in a structure definition containing the number of coefficients, a pointer to the coefficient array, and its symmetric properties.

// provide a critical description of your code.  
The #acr("FIR") filter implementation employs a tapped delay line architecture. In this architecture, each input sample is multiplied by its corresponding filter coefficient and added to an accumulator. Once all taps are processed, the accumulator value is stored in the output array as the filtered sample.
After all input samples have been passed through the delay line, the output array contains the filtered signal.

The tapped delay line implementation uses a nested for-loop:
- *Outer-loop*: Iterates through the length of the input signal.
- *Inner-loop*: Iterates throguh the delay line samples, and performs a #acr("MAC") operation to process the tap and accumulator.

To improve efficiency, the inner loop was optimised to only iterate through the samples currently present in the delay line. This avoids redundant #acr("MAC") operations with the initial zero values.

Further optimisations was achieved by implementing the following measures:
- *Symmetry:* By "folding" the tapped delay line for symmetric filter coefficents, the number of multiplications was halved.
- *Fixed-Point Integer Arithmetic:* Converting the signals and filter coefficients to integers accelerates arithmetic operations by reducing the required CPU cycles. This measure increases the error of the output.   
- *Loop Unrolling & Intrinsics:* Utilising compiler intrinsics for parallellisation, pipelining, and reducing memory accesses. This reduces the required CPU cycles to run the filter.

The implementations can be seen in @emb_impl.

== FIR Filter Results <emb_fir_results>
// Plot time (3 cycles) and frequency (using all 900 points) graphs of the filtered signals. Include clear screenshots of the appropriately labelled graphs in your report. 
The filtered signal time domain plots can be seen in @emb_input1_time_domain and @emb_input2_time_domain, and frequency domain plots can be seen in @emb_input1_freq_domain and @emb_input2_freq_domain.  

// Provide critical comments to the graphs and results, to demonstrate your understanding and the correctness of your implementation
The following observations confirms the correctness of the implementation: // comparing the results to the MATLAB implementation results in  and @input_freq_domain.
- The time domain plots in MATLAB and CCS are visually similar, see @input_time_domain and @emb_input1_time_domain respectively. 
- The frequency domain plots confirm that the targeted frequencies have been attenuated, matching the intended filter response, see @emb_input1_freq_domain and @emb_input2_freq_domain.

== Convolution
// provide a step-by-step demonstration of the code in action with two new signals of 4 integer samples each, with screenshots of the DSP memory and CCS console. show how these 7 values are computed and stored in memory, one by one, alongside all other indices and temporary variables used in your convolution/filter code.)
While the standard #acr("FIR") filter implementation stops after the last input sample is passed into the tapped delay line, a full convolution requires the entire tapped delay line to be flushed before the result is produced. 

To demonstrate the convolution, two 4 sample integers were convolved. The input signals contain the values in @emb_convolution_input, and the resulting convolution is given in @emb_convolution_output. 

$ x_1 = [1, 1, 1, 1] \
  x_2 = [1, 2, 1, 2] $ <emb_convolution_input>

$ "Convolution" = [1, 3, 4, 6, 5, 3, 2] $ <emb_convolution_output>

The step-by-step process with a visual of the #acr("DSP") memory state can be seen in @emb_convolution1 and the following figures. 

== Profiling of C implementations

The various C implementations mentioned in @emb_fir were profiled using the number of clock cycles and #acr("MSE") compared to MATLAB. 
The standard #acr("FIR") filter implementation was used as a baseline for evaluating improvements in speed and trade-offs in accuracy.
The results can be seen in @profiling_implementations below.

#figure(
table(
  columns: 4,
  align: (left + horizon, right + horizon, right + horizon, left + horizon),
  stroke: 0.4pt,
  [*Implementation*],
  [*Number of CPU cycles*],
  [*Comparison (\%)*],
  [*MSE*],
  [Standard],
  [15315458],
  [100.0],
  // [0],
  [#text(fill: rgb("#212121"))[1.254e-07]],
  [Symmetric],
  [15393043],
  [100.5],
  // [-0.507],
  [#text(fill: rgb("#212121"))[1.253e-07]],
  [Symmetric Fixed point],
  [14427900],
  [94.20],
  // [5.80],
  [#text(fill: rgb("#212121"))[1.217e-02]],
  [#acr("SIMD") Fixed point],
  [7219817],
  [47.10],
  // [52.9],
  [#text(fill: rgb("#212121"))[1.218e-02]],
),
caption: "Performance comparison of FIR filter C implementations",
) <profiling_implementations>

From the results, it can be observed that converting to fixed point reduces signal integrity significantly. However, by applying #acr("SIMD") intrinsics a large efficiency increase in run time of 50% can be achieved.

= Comparison
== MATLAB versus C implementation
// Load these signals from the text file into Matlab, and compare the signals filtered in C and Matlab: 

// plot appropriately labelled time (3 cycles) domain and frequency (using all 900 points) domain graphs of both C filtered signals loaded in Matlab, and critically discuss any differences and/or similarities between the C and Matlab filter outputs.
The C filtered signals were recorded to a .csv file and loaded into MATLAB for error analysis. 

The time domain and error per sample of the C signals can be seen in @res_time and @res_time_error. It can be observed that there is a small fluctuating deviation between the signals.

The frequency domain and frequency response error of the C signals can be seen in @res_freq and @res_freq_error. It can be observed that there is a small deviation between the signals near the frequency peaks of the original signal.

To quantify the time domain deviation between MATLAB and the C implementation, the #acr("MSE") of the filtered signals was calculated over the full length. The results are given in @MSE_result below. 

$ "MSE"_1 = 1.254e-07 \
  "MSE"_2 = 5.654e-08 $ <MSE_result>

// $ "MSE"_1 = 8.018e-09 \
//   "MSE"_2 = 2.386e-09 $ <MSE_result> // valid for 3 cycles


== Discussion
// critically discuss any differences and/or similarities between the C and Matlab filter outputs.
The primary driver of the observed time and frequency domain error is the difference in numerical precision, see @res_time_error and @res_freq_error. 
MATLAB defaults to 64-bit double-precision floating-point, whereas the C67x #acr("DSP") hardware uses 32-bit single-precision floating-point. 
This results in the arithmetic operations in the tapped delay line introducing a small quantisation error that accumulates over the 300+ taps of the filter. 
However, for most practical applications, an #acr("MSE") in the magnitude of 10-7 is considered negligible.

= Conclusion

This project successfully demonstrated the transition of a digital filter design from MATLAB to an embedded hardware platform (OMAP-L138) optimised for #acr("DSP"). The implementation confirmed that:
- FIR filters can be implemented in C for effective attenuation of targeted frequencies.
- Numerical precision trade-offs are inherent in embedded DSP. However, single-precision floating-point arithmetic provides sufficient accuracy for most applications.
- Hardware-specific optimisations, particularly #acr("SIMD"), can reduce run time by over 50%, but with significant loss of signal integrity.

#pagebreak()

= Figures and Tables
== Part 1 

=== Input Signals
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
) <input_freq_zoomed>

=== Filter Design

#figure(
  image("Subsections/Section 1/figs/filter_coeffs.svg"),
  caption: "Coefficients of each filter"
) <filter_coeffs>

#figure(
  image("Subsections/Section 1/figs/filter1_polezero.svg"),
  caption: [Poles and Zeros of $H_1$]
) <filter1_pz>
#figure(
  image("Subsections/Section 1/figs/filter_1_magphase.svg"),
  caption: [Magnitude and Phase response of $H_1$]
) <filter1_magphase>

#figure(
  image("Subsections/Section 1/figs/filter2_polezero.svg"),
  caption: [Poles and Zeros of $H_2$]
) <filter2_pz>
#figure(
  image("Subsections/Section 1/figs/filter2_polezero_zoomed.svg"),
  caption: [Zoomed Poles and Zeros of $H_2$]  
) <filter2_pz_zoom>
#figure(
  image("Subsections/Section 1/figs/filter2_magphase.svg"),
  caption: [Magnitude and Phase response of $H_2$]
) <filter2_magphase>

=== Filter Results

#figure(
  image("Subsections/Section 1/figs/filtered_time.svg"),
  caption: [Time domain representation of $y_1$ and $y_2$],
)
#figure(
  image("Subsections/Section 1/figs/filtered_freq.svg"),
  caption: [Frequency representations, $Y_1$ and $Y_2$],
)

#figure(
  image("Subsections/Section 1/figs/filtered_freq_zoomed.svg"),
  caption: [Zoomed frequency representations, $Y_1$ and $Y_2$],
)

== Part 2 
=== Input Signals

#figure(
  image("Subsections/Section 2/figs/x1_time.png"),
  caption: "Student 1 input signal in time domain from CCS",
) <emb_input1_time_domain>
#figure(
  image("Subsections/Section 2/figs/x2_time.png"),
  caption: "Student 2 input signal in time domain from CCS",
) <emb_input2_time_domain>

#figure(
  image("Subsections/Section 2/figs/x1_freq.png"),
  caption: "Student 1 input signal in frequency domain from CCS",
) <emb_input1_freq_domain>
#figure(
  image("Subsections/Section 2/figs/x2_freq.png"),
  caption: "Student 2 input signal in frequency domain from CCS",
) <emb_input2_freq_domain>


=== Filter Results

#figure(
  image("Subsections/Section 2/figs/y1_time.png"),
  caption: "Student 1 output signal in time domain from CCS",
) <emb_output1_time_domain>
#figure(
  image("Subsections/Section 2/figs/y2_time.png"),
  caption: "Student 2 output signal in time domain from CCS",
) <emb_output2_time_domain>

#figure(
  image("Subsections/Section 2/figs/y1_freq.png"),
  caption: "Student 1 output signal in frequency domain from CCS",
) <emb_output1_freq_domain>
#figure(
  image("Subsections/Section 2/figs/y2_freq.png"),
  caption: "Student 2 output signal in frequency domain from CCS",
) <emb_output2_freq_domain>


=== Convolution
#figure(
  image("Subsections/Section 2/figs/convolution_debug1.png"),
  caption: "Convolution - start state in CCS",
) <emb_convolution1>

#figure(
  image("Subsections/Section 2/figs/convolution_debug2.png"),
  caption: "Convolution - first output sample in CCS",
) <emb_convolution2>

#figure(
  image("Subsections/Section 2/figs/convolution_debug3.png"),
  caption: "Convolution - second output sample in CCS",
) <emb_convolution3>

#figure(
  image("Subsections/Section 2/figs/convolution_debug4.png"),
  caption: "Convolution - last output sample in CCS",
) <emb_convolution4>

== Part 3

=== Filtered Signals Time Domain
#figure(
  image("Subsections/Section 3/figs/filtered_time_c.svg"),
) <res_time>

#figure(
  image("Subsections/Section 3/figs/filtered_time_error.svg"),
) <res_time_error>

=== Filtered Signals Frequency Domain
#figure(
  image("Subsections/Section 3/figs/filtered_freq_c.svg"),
)<res_freq>
#figure(
  image("Subsections/Section 3/figs/filtered_freq_error.svg"),
)<res_freq_error>

#pagebreak()

= Code Listings
== MATLAB Implementation
#include("./Subsections/Section 1/MATLAB_code.typ")

== C Implementation <emb_impl>

#include("./Subsections/Section 2/C_code.typ")

== MATLAB Comparison

#include("./Subsections/Section 3/MATLAB_code.typ")


#pagebreak()

#show bibliography: set heading(numbering: "1")
#bibliography(
  ( 

  ),
)
//#pagebreak()

= Contributions

Student, Daniel Stebbings:
- Responsible for the filter design and MATLAB code.
- Contribution: 50%

Student, Preben Rasamanickam:
- Responsible for the C code.
- Contribution: 50%
