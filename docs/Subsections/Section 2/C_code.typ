

=== filter.h
```C
/**
 * @file filter.h
 * @brief FIR filter structure definitions and functions. 
 */

#ifndef FILTER_H
#define FILTER_H

#include <stdint.h>
#include <stdbool.h>

typedef float float32_t;
#define BUFF_SIZE          900U
#define BUFF_ZERO_SIZE     BUFF_SIZE + BUFF_SIZE / 2

typedef struct {
    uint8_t symmetric;
    uint32_t  coeff_b_len;
    uint32_t  coeff_a_len;
    float32_t *coeff_a_ptr;
    float32_t *coeff_b_ptr;
} filter_t;


/**
 * @brief Applies a FIR (Finite Impulse Response) filter to an input signal.
 *
 * @param[in] p_input Pointer to the input signal array
 * @param[in] p_input_len Length of the input signal
 * @param[in] p_filter Pointer to the FIR filter structure containing coefficients
 * @param[out] p_output Pointer to the output signal array where filtered results are stored
 *
 * @note The filter coefficients are accessed from p_filter->coeff_b_ptr with length p_filter->coeff_b_len.
 * @note Filter coefficients p_filter->coeff_a are assumed = [ 1 ].
 *
 * @return void
 */
void filter_signal(const float32_t *p_input, uint32_t p_input_len, const filter_t *p_filter, float32_t *p_output);

/**
 * @brief Performs linear convolution of two integer arrays.
 * @note Output length will be (p_input1_len + p_input2_len - 1).
 *
 * @return void
 */
void convolution(const int32_t *p_input1, uint32_t p_input1_len, const int32_t *p_input2, uint32_t p_input2_len, int32_t *p_output, uint32_t *p_output_len);

/**
 * @brief Applies a symmetric FIR filter to an input signal.
 * 
 * This function implements a symmetric finite impulse response (FIR) filter,
 * taking advantage of coefficient symmetry to process the input signal.
 * For each output sample, the filter computes a weighted sum using symmetric
 * tap pairs.
 * 
 * @param[in] p_input Pointer to the input signal array.
 * @param[in] p_input_len Length of the input signal.
 * @param[in] p_filter Pointer to the FIR filter structure containing coefficients
 *                      and filter length information.
 * @param[out] p_output Pointer to the output signal array where filtered results
 *                       are stored.
 * 
 * @return void
 *
 * @note Filter coefficients must exhibit symmetry: h[k] = h[N-1-k].
 * @note Filter coefficients p_filter->coeff_a are assumed = [ 1 ].
 * @note Assumes odd length of filter coefficients
 */
void symm_filter_signal(const float32_t *p_input, uint32_t p_input_len, const filter_t *p_filter, float32_t *p_output);

/**
 * @brief Converts an input signal to fixed-point and applies a symmetric FIR filter to it.
 *
 * This function implements a scales and converts a floating-point input signal to fixed-point integer.
 * Applies a symmetric FIR filter to it.
 * Converts the output signal back to floating-point.
 *
 * @param[in] p_input Pointer to the input signal array.
 * @param[in] p_input_len Length of the input signal.
 * @param[in] p_filter Pointer to the FIR filter structure containing coefficients
 *                      and filter length information.
 * @param[out] p_output Pointer to the output signal array where filtered results
 *                       are stored.
 *
 * @return void
 *
 * @note Filter coefficients must exhibit symmetry: h[k] = h[N-1-k].
 * @note Filter coefficients p_filter->coeff_a are assumed = [ 1 ].
 * @note Assumes odd length of filter coefficients
 */
void symm_filter_signal_short(const float32_t *p_input, const uint32_t p_input_len, const filter_t *p_filter, float32_t *p_output, const float32_t p_coeff_norm);

/**
 * @brief Applies a symmetric FIR filter to an integer input signal.
 *
 * This function implements a symmetric finite impulse response (FIR) filter,
 * taking advantage of coefficient symmetry to process the input signal.
 * For each output sample, the filter computes a weighted sum using symmetric
 * tap pairs.
 *
 * @param[in] x Pointer to the input signal array.
 * @param[in] p_input_len Length of the input signal.
 * @param[in] N Number of filter coefficients
 * @param[in] h Pointer to the filter coefficient array.
 * @param[in] p_coeff_norm shift factor.
 *
 * @param[out] y Pointer to the output signal array where filtered results
 *                       are stored.
 *
 * @return void
 *
 * @note Filter coefficients must exhibit symmetry: h[k] = h[N-1-k].
 * @note Filter coefficients p_filter->coeff_a are assumed = [ 1 ].
 * @note Assumes odd length of filter coefficients
 */
void symm_filter_signal_short_nconv(const int16_t *x, const uint32_t p_input_len, const uint32_t N, const int16_t *h, int32_t *y, const int16_t p_coeff_norm);

/**
 * @brief Converts an input signal to fixed-point and applies an FIR filter to it using SIMD intrinsics.
 *
 * @param[in] p_input Pointer to the input signal array.
 * @param[in] p_input_len Length of the input signal.
 * @param[in] p_filter Pointer to the FIR filter structure containing coefficients
 *                      and filter length information.
 * @param[in] p_coeff_norm scaling and normalisation factor
 * @param[out] p_output Pointer to the output signal array where filtered results
 *                       are stored.
 *
 * @return void
 *
 * @note Filter coefficients must exhibit symmetry: h[k] = h[N-1-k].
 * @note Filter coefficients p_filter->coeff_a are assumed = [ 1 ].
 * @note Assumes odd length of filter coefficients
 */
void fir2_set_run(const float32_t *p_input, const uint32_t p_input_len, const filter_t *p_filter, float32_t *p_output, const float32_t p_coeff_norm);

/**
 * @brief Applies an FIR filter to an integer input signal using SIMD intrinsics.
 *
 * @param[in] x Pointer to the input signal array.
 * @param[in] h Pointer to the reversed filter coefficient array.
 * @param[out] y Pointer to the output signal array where filtered results
 *                       are stored.
 * @param[in] n Length of the input signal.
 * @param[in] m Number of filter coefficients
 * @param[in] s shift factor.
 *
 *
 * @return void
 *
 * @note Filter coefficients must exhibit symmetry: h[k] = h[N-1-k].
 * @note Filter coefficients p_filter->coeff_a are assumed = [ 1 ].
 * @note Assumes odd length of filter coefficients
 */
void fir2(const int x[], const int h[], short y[], int n, int m, int s);

#endif  /* FILTER_H */
```
=== filter.c
```C
#include "filter.h"
#include "util.h"
#include <stdio.h>


void filter_signal(const float32_t *p_input, uint32_t p_input_len, const filter_t *p_filter, float32_t *p_output)
{
    const uint32_t N = p_filter->coeff_b_len;
    const float32_t *h = p_filter->coeff_b_ptr;

    // filter loop
    uint32_t n, k;
    for (n = 0; n < p_input_len; n++)
    {
        float32_t l_acc = 0.0f;

        // calculate tap-sums
        for (k = 0; k < N; k++) {
            if (n >= k) {
                l_acc += p_input[n - k] * h[k];
            }
            else break;
        }
        p_output[n] = l_acc;
    }
}


void convolution(const int32_t *p_input1, uint32_t p_input1_len, const int32_t *p_input2, uint32_t p_input2_len, int32_t *p_output, uint32_t *p_output_len)
{
    *p_output_len = p_input1_len + p_input2_len - 1;

    // convolution loop
    uint32_t n, k;
    for (n = 0; n < *p_output_len; n++)
    {
        uint32_t l_acc = 0;

        // calculate tap-sums
        for (k = 0; k < p_input1_len; k++)
        {
            if (n >= k && (n - k) < p_input2_len)
            {
                l_acc += p_input1[k] * p_input2[n - k];
            }
        }
        p_output[n] = l_acc;
    }
}


void symm_filter_signal(const float32_t *p_input, uint32_t p_input_len, const filter_t *p_filter, float32_t *p_output) 
{
    const uint32_t N = p_filter->coeff_b_len;
    const float32_t *h = p_filter->coeff_b_ptr;

    const uint32_t l_half_len = (N / 2);
    
    // filter loop
    uint32_t n, k;
    for (n = 0; n < p_input_len; n++)
    {
        float32_t l_acc = 0.0f;
        
        // loop through the first half of coefficients
        for (k = 0; k < l_half_len; k++) {

            // add symmetric taps before multiplying
            float32_t tap_sum = 0.0f;
            if (n >= k) 
            {
                tap_sum += p_input[n - k];
            }
            if (n >= (N - 1 - k))
            {
                tap_sum += p_input[n - (N - 1 - k)];
            }
            // calculate tap-sums
            l_acc += tap_sum * h[k];
        }
        
        // handle the middle tap if N is odd (assumed filter has odd length)
        if (n >= l_half_len)
        {
            l_acc += p_input[n - l_half_len] * h[l_half_len];
        }
        p_output[n] = l_acc;
    }
}


static void symm_filter_signal_short_nconv(const int16_t *x, const uint32_t p_input_len, const uint32_t N, const int16_t *h, int32_t *y, const int16_t p_coeff_norm)
{
    const uint32_t l_half_len = (N / 2);

    // filter loop
    uint32_t n, k;
    for (n = 0; n < p_input_len; n++)
    {
        int32_t l_acc = 0;

        // loop through the first half of coefficients
        for (k = 0; k < l_half_len; k++) {

            // add symmetric taps before multiplying
            int32_t tap_sum = 0;
            if (n >= k)
            {
                tap_sum += x[n - k];
            }
            if (n >= (N - 1 - k))
            {
                tap_sum += x[n - (N - 1 - k)];
            }
            // calculate tap-sums
            l_acc += tap_sum * h[k];
        }

        // handle the middle tap if N is odd (assumed filter has odd length)
        if (n >= l_half_len) {
            l_acc += (int32_t)x[n - l_half_len] * h[l_half_len];
        }

        // rounding
        // add half-LSB (1 << (s - 1)) to round to nearest integer during shift
        l_acc += (1 << (p_coeff_norm - 1));

        // re-normalization
        l_acc >>= p_coeff_norm;

        y[n] = l_acc;
    }
}


void symm_filter_signal_short(const float32_t *p_input, const uint32_t p_input_len, const filter_t *p_filter, float32_t *p_output, const float32_t p_coeff_norm)
{
    const uint32_t N = p_filter->coeff_b_len;

    // convert coefficients to int
    static int16_t h_q[BUFF_SIZE] = { 0 };
    float_to_int16_normalized(p_filter->coeff_b_ptr, N, h_q, p_coeff_norm);

    // convert input to int
    static int16_t x_q[BUFF_SIZE] = { 0 };
    float_to_int16_normalized(p_input, p_input_len, x_q, p_coeff_norm);

    static int32_t y_q[BUFF_SIZE] = { 0 };
    // filter loop
    symm_filter_signal_short_nconv(x_q, p_input_len, N, h_q, y_q, 1);

    // convert output to float
    int32_to_float(y_q, p_input_len, p_output, 1, p_coeff_norm);
}



void fir2_set_run(const float32_t *p_input, const uint32_t p_input_len, const filter_t *p_filter, float32_t *p_output, const float32_t p_coeff_norm)
{
    const uint32_t N = p_filter->coeff_b_len;
    const uint32_t M = p_input_len;
    const uint32_t L_even = (N % 2U == 0U) ? N : (N + 1U);
    const uint32_t M_even = (M % 2U == 0U) ? M : (M + 1U);

    // right-shift used by fir2() before storing to int16.
    //      Q15xQ15 -> Q30 accumulation -> Q15 output.
    const int s = 15;

    // convert coefficients
    static int16_t h_q[BUFF_SIZE] = { 0 };
    float_to_int16_normalized(p_filter->coeff_b_ptr, N, h_q, p_coeff_norm);

    // convert input
    static int16_t x_q[BUFF_SIZE] = { 0 };
    float_to_int16_normalized(p_input, M, x_q, p_coeff_norm);

    // build padded input of length (L_even + M_even) samples
    const uint32_t x_pad_len = L_even + M_even ;
    static int16_t x_pad[BUFF_ZERO_SIZE] = { 0 };

    uint32_t i;
    for(i = 0; i < (L_even - 1U); i++)
    {
        x_pad[i] = 0;
    }
    for(i = 0; i < M; i++)
    {
        x_pad[(L_even - 1U) + i] = x_q[i];
    }
    for(i = (L_even - 1U) + M; i < x_pad_len; i++)
    {
        x_pad[i] = 0;
    }

    // build padded and reversed coefficient array
    static int16_t h_pad[BUFF_ZERO_SIZE] = { 0 };
    for(i = 0; i < N; i++)
    {
        h_pad[(L_even - 1U) - i] = h_q[i];
    }
    for(i = N; i < L_even; i++)
    {
        h_pad[(L_even - 1U) - i] = 0;
    }

    static int16_t y_q[BUFF_ZERO_SIZE + 300] = { 0 };

    // ensure 4-byte word alignment
    _nassert(((int)(x_pad) & 0x3) == 0);
    _nassert(((int)(h_pad) & 0x3) == 0);
    _nassert(((int)(y_q) & 0x3) == 0);

    // filter loop
    fir2((const int *)x_pad, (const int *)h_pad, y_q, (int)L_even, (int)M_even, s);


    // x and h were both scaled by p_coeff_norm => scaled by p_coeff_norm^2.
    // fir2 stores (acc >> s) => reconstruct by multiplying by 2^s.
    const float32_t inv_scale = (float32_t)(1U << s) / (p_coeff_norm * p_coeff_norm);

    for(i = 0; i < M; i++)
    {
        p_output[i] = (float32_t)y_q[i] * inv_scale;
    }
}

// extracted from Example 3–14. FIR Filter— Optimized Form in C6x programmer's guide(198d)
void fir2(const int x[], const int h[], short y[], int n, int m, int s)
{
    int i, j;
    long y0, y1;
    long round = 1L << (s - 1);

    #pragma MUST_ITERATE (,,2);
    for (j = 0; j < (m >> 1); j++)
    {
        y0 = y1 = round;
        #pragma MUST_ITERATE (,,2);
        for (i = 0; i < (n >> 1); i++)
        {
            y0 += _mpy (x[i + j], h[i]);
            y0 += _mpyh (x[i + j], h[i]);
            y1 += _mpyhl(x[i + j], h[i]);
            y1 += _mpylh(x[i + j + 1], h[i]);
        }
        *y++ = (int)(y0 >> s);
        *y++ = (int)(y1 >> s);
    }
}
```

=== util.h
```C
/**
 * @file util.h
 * @brief utility functions for FIR filter implementations.
 */

#ifndef UTIL_H
#define UTIL_H

#include <stdint.h>
#include <time.h>

typedef float float32_t;

// profiling definitions
#undef CLOCKS_PER_SEC
#define CLOCKS_PER_SEC (300000000)
extern cregister volatile unsigned int TSCL;
extern cregister volatile unsigned int TSCH;


/**
 * @brief Returns current clock cycle.
 *
 * @return clock_t
 *
 */
clock_t clock(void);

/**
 * @brief Calculates the mean (average) of an array of unsigned integers.
 *
 * @param[in] p_input Pointer to an array of uint32_t values to be averaged.
 * @param[in] p_input_len The number of elements in the input array.
 * @param[out] p_output Pointer to a float32_t variable where the calculated mean will be stored.
 *
 * @return void
 *
 */
void calculate_mean(const uint32_t *p_input, uint32_t p_input_len, float32_t *p_output);

/**
 * @brief Generates a signal by repeating and mean-centering an input array.
 *
 * @param p_input Pointer to the input array of uint32_t values.
 * @param p_input_len Length of the input array.
 * @param p_output Pointer to the output array of float32_t values where
 *                 the generated signal will be stored.
 * @param p_output_len Length of the output array. Should be a multiple of
 *                      p_input_len.
 *
 * @return void
 *
 */
void generate_signal(const uint32_t *p_input, uint32_t p_input_len, float32_t *p_output, uint32_t p_output_len);


/**
 * @brief Normalises an array of floats to an array of signed 16-bit fixed-point integers.
 * @param input: The IEEE 754 single precision float.
 * @param scale: The scaling factor (e.g., 32767.0f for full range).
 * @return: A saturated 16-bit signed integer.
 */
void float_to_int16_normalized(const float32_t *p_input, const uint32_t p_input_len, int16_t *p_output, const float32_t p_scale);

/**
 * @brief Converts an array of scaled 16-bit signed integers back to an array of 32-bit floats.
 * @param input The int16_t value to convert.
 * @param scale The factor the float was multiplied by (e.g., 100.0f).
 * @return float The reconstructed float value.
 */
void int16_to_float(const int16_t *p_input, const uint32_t p_input_len, float32_t *p_output, const int16_t s, const float32_t p_scale);

/**
 * @brief Converts an array of scaled 32-bit signed integers back to an array of 32-bit floats.
 * @param input The int32_t value to convert.
 * @param scale The factor the float was multiplied by (e.g., 100.0f).
 * @return float The reconstructed float value.
 */
void int32_to_float(const int32_t *p_input, const uint32_t p_input_len, float32_t *p_output, const int16_t s, const float32_t p_scale);

/**
 * @brief Prints a formatted table of two float arrays with their differences and statistical summary.
 *
 * @param p_output1 Pointer to the first float32_t array
 * @param p_output2 Pointer to the second float32_t array
 * @param p_output_len Total length of both arrays
 * @param p_print_start Starting index for the table output (inclusive)
 * @param p_print_n Number of elements to print in the table
 *
 * @details
 * This function displays:
 * - A formatted table with columns for Index, y1, y2, and their absolute difference
 *   for elements from p_print_start to min(p_print_start + p_print_n, p_output_len)
 * - A statistics summary including:
 *   - Mean value of y1 (calculated over entire array)
 *   - Mean value of y2 (calculated over entire array)
 *   - Mean absolute difference between arrays
 *   - Total absolute difference across all elements
 */
void print_statistics(const float32_t *p_output1, const float32_t *p_output2, uint32_t p_output_len, uint32_t p_print_start, uint32_t p_print_end);

/**
 * @brief Prints a set of array samples from index 0
 *
 * @param x Pointer to the array of float32_t values to be written.
 * @param n The number of elements to print.
 *
 * @return void
 *
 */
void print_results(const float32_t *x, const uint32_t n);

/**
 * @brief Records an array of floating-point values to a CSV file.
 *
 * @param p_output Pointer to the array of float32_t values to be written.
 * @param p_output_len The number of elements in the p_output array.
 * @param p_filename The path to the output file. The file will be created or overwritten.
 *
 * @return void
 *
 * @note If the file cannot be opened, an error message is printed to stdout and the
 *       function returns without writing any data.
 */
void record_output(const float32_t *p_output, uint32_t p_output_len, const char *p_filename);

#endif  /* UTIL_H */
```

=== util.c
```C
#include "util.h"
#include <stdio.h>
#include <math.h>
#include <string.h>

clock_t clock(void)
{
    unsigned int low  = TSCL;
    unsigned int high = TSCH;
    if(high) return (clock_t)-1;
    return low;
}

void calculate_mean(const uint32_t *p_input, uint32_t p_input_len, float32_t *p_output)
{
    uint32_t l_sum = 0;

    uint32_t i;
    for(i = 0; i < p_input_len; i++)
    {
        l_sum += p_input[i];
    }

    *p_output = (float32_t) l_sum / p_input_len;
}


void generate_signal(const uint32_t *p_input, uint32_t p_input_len, float32_t *p_output, uint32_t p_output_len)
{
    float32_t l_mean = 0;
    calculate_mean(p_input, p_input_len, &l_mean);

    // generate the first block
    uint32_t i;
    for(i = 0; i < p_input_len; i++)
    {
        p_output[i] = (float32_t) p_input[i] - l_mean;
    }

    const uint32_t l_repetitions = p_output_len / p_input_len;
    const size_t l_block_size = p_input_len * sizeof(float32_t);

    // copy the first block across the rest of the array
    for (i = 1; i < l_repetitions; i++)
    {
        // Copy the first block into the current repetition's offset
        memcpy(&p_output[i * p_input_len], p_output, l_block_size);
    }
}


void float_to_int16_normalized(const float32_t *p_input, const uint32_t p_input_len, int16_t *p_output, const float32_t p_scale)
{
    uint16_t i;
    for(i = 0; i < p_input_len; i++)
    {
        // scale sample
        float32_t scaled_val = p_input[i] * p_scale;

        // round to nearest integer
        scaled_val = roundf(scaled_val);

        // saturate to prevent overflow
        if (scaled_val >= 32767.0f) {
            p_output[i] = 32767;
            continue;
        } else if (scaled_val <= -32768.0f) {
            p_output[i] = -32768;
            continue;
        }

        p_output[i] = (int16_t)scaled_val;
    }
}


void int16_to_float(const int16_t *p_input, const uint32_t p_input_len, float32_t *p_output, const int16_t s, const float32_t p_scale)
{
    const float32_t l_inv_scale = (float32_t)(1U << s) / (p_scale * p_scale);

    uint16_t i;
    for(i = 0; i < p_input_len; i++)
    {
        p_output[i] = (float32_t)p_input[i] * l_inv_scale;
    }
}


void int32_to_float(const int32_t *p_input, const uint32_t p_input_len, float32_t *p_output, const int16_t s, const float32_t p_scale)
{
    const float32_t l_inv_scale = (float32_t)(1U << s) / (p_scale * p_scale);

    uint16_t i;
    for(i = 0; i < p_input_len; i++)
    {
        p_output[i] = (float32_t)p_input[i] * l_inv_scale;
    }
}


void print_statistics(const float32_t *p_output1, const float32_t *p_output2, uint32_t p_output_len, uint32_t p_print_start, uint32_t p_print_n)
{
    const uint32_t p_print_end = (p_print_start + p_print_n < p_output_len) ? (p_print_start + p_print_n) : p_output_len;

    printf("| Index |      y1      |      y2      |   Difference  |\n");
    printf("|-------|--------------|--------------|----------------|\n");
    uint32_t i;
    for(i = p_print_start; i < p_print_end; i++)
    {
        printf("| %3d | %12.6f | %12.6f | %12.6f |\n", i, p_output1[i], p_output2[i], fabsf(p_output1[i] - p_output2[i]));
    }

    // Statistics summary
    float32_t mean_y1 = 0, mean_y2 = 0, mean_diff = 0, total_diff = 0;
    for(i = 0; i < p_output_len; i++)
    {
        mean_y1 += p_output1[i];
        mean_y2 += p_output2[i];
        total_diff += fabsf(p_output1[i] - p_output2[i]);
    }
    mean_y1 /= p_output_len;
    mean_y2 /= p_output_len;
    mean_diff = total_diff / p_output_len;
    printf("Statistics Summary:\n");
    printf("Mean of y1: %f\n", mean_y1);
    printf("Mean of y2: %f\n", mean_y2);
    printf("Mean of Differences: %f\n", mean_diff);
    printf("Total of Differences: %f\n", total_diff);

}

void print_results(const float32_t *x, const uint32_t n)
{
    printf("\nresult");
    uint8_t i;
    for(i = 0; i<10; i++)
    {
        printf("[%d] = %f ", i, x[i]);
    }
}


void record_output(const float32_t *p_output, uint32_t p_output_len, const char *p_filename)
{
    FILE *l_file = fopen(p_filename, "w");

    if (l_file == NULL)
    {
        printf("Error. Not able to open file %s for writing.\n", p_filename);
        return;
    }

    uint32_t i;
    for (i = 0; i < p_output_len; i++)
    {
        fprintf(l_file, "%f,", p_output[i]);
    }

    // remove trailing comma (functions not supported on C67x device)
//    fseek(l_file, -1, SEEK_END);
//    ftruncate(fileno(l_file), ftell(l_file));
    printf("\nData saved in file: %s", p_filename);

    fclose(l_file);
}
```

=== main.c
```C
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "util.h"
#include "filter.h"
#include "data.h"
#include "data_1_fixed.h"
#include "data_2_fixed.h"


/* DEFINES */
// file paths for data outputs
#define DATA_DIR "/home/preben/Documents/ee580_dsp/EE580-Filtering-Assignment/C_dsp/data/"
#define DATA_FILE_1 DATA_DIR "data1.txt"
#define DATA_FILE_2 DATA_DIR "data2.txt"

// signal generation declarations
#define REG_LENGTH    9U
#define REG1_LAST4    8874U
#define REG2_LAST4    4642U

// convolution buffer
#define SAMPLE_LEN 4


/* GLOBAL DECLARATIONS */
static uint32_t g_reg1[REG_LENGTH] = { 2, 0, 2, 1, 1, 8, 8, 7, 4 }; // 202118874
static uint32_t g_reg2[REG_LENGTH] = { 2, 0, 2, 1, 1, 4, 6, 4, 2 }; // 202114642

// buffers for data input and output
#pragma DATA_ALIGN(g_x, 8); // Align to 8-byte (64-bit) boundary
static float32_t g_x[BUFF_ZERO_SIZE] = { 0 }; // stack overflow if not static
#pragma DATA_ALIGN(g_y, 8); // Align to 8-byte (64-bit) boundary
static float32_t g_y[BUFF_ZERO_SIZE] = { 0 };


/* STATIC DECLARATIONS */
static void profile_filter_implementations(const float32_t *p_input, const uint32_t p_input_len, const filter_t *p_filter, float32_t *p_output);

static double ticks_to_seconds(clock_t p_start, clock_t p_end)
{
    return (double) (p_end - p_start) / CLOCKS_PER_SEC;
}


/**
 * main.c
 * - declare FIR filter structs
 * - filter signal x1
 * - filter signal x2
 * - profile various FIR filter implementations
 */
int main(void)
{
    TSCL = 0;   // this starts the clock

    filter_t l_FIR_1;
    l_FIR_1.symmetric = true;
    l_FIR_1.coeff_b_len = Filter_1_Fixed_N_FIR_B;
    l_FIR_1.coeff_a_len = Filter_1_Fixed_N_FIR_A;
    l_FIR_1.coeff_a_ptr = Filter_1_Fixed_a_fir;
    l_FIR_1.coeff_b_ptr = Filter_1_Fixed_b_fir;

    filter_t l_FIR_2;
    l_FIR_2.symmetric = true;
    l_FIR_2.coeff_b_len = Filter_2_Fixed_N_FIR_B;
    l_FIR_2.coeff_a_len = Filter_2_Fixed_N_FIR_A;
    l_FIR_2.coeff_a_ptr = Filter_2_Fixed_a_fir;
    l_FIR_2.coeff_b_ptr = Filter_2_Fixed_b_fir;

    // filter signal x1
    generate_signal(g_reg1, REG_LENGTH, g_x, BUFF_SIZE);
    filter_signal(g_x, BUFF_SIZE, &l_FIR_1, g_y);
    record_output(g_y, BUFF_SIZE, DATA_FILE_1);


    // filter signal x2
    generate_signal(g_reg2, REG_LENGTH, g_x, BUFF_SIZE);
    filter_signal(g_x, BUFF_SIZE, &l_FIR_2, g_y);
    record_output(g_y, BUFF_SIZE, DATA_FILE_2);

    // profile FIR implementations
    profile_filter_implementations(g_x, BUFF_SIZE, &l_FIR_1, g_y);

    // convolution of 4 integer samples signals
    int32_t l_sample_signal1[SAMPLE_LEN] = { 1, 1, 1, 1};
    int32_t l_sample_signal2[SAMPLE_LEN] = { 1, 2, 1, 2};
    int32_t l_conv_output[SAMPLE_LEN * 2] = { 0 };
    uint32_t l_conv_len = 0;

    convolution(l_sample_signal1, SAMPLE_LEN, l_sample_signal2, SAMPLE_LEN, l_conv_output, &l_conv_len);

    return 0;
}

static void profile_filter_implementations(const float32_t *p_input, const uint32_t p_input_len, const filter_t *p_filter, float32_t *p_output)
{
    // CPU cycle profiling
    clock_t start, stop, overhead;
    start = clock();
    stop = clock();
    overhead = stop - start;

    // number of output samples to print
    const uint32_t l_samples_to_print = 10;

    // calculation of scaling norm for fixed-point integer conversions
    float32_t l_max = 0;
    uint16_t i;
    // find max sample value
    for(i = 0; i < p_input_len; i++)
    {
        float32_t l_sample = abs(p_input[i]);
        if(l_sample > l_max) l_max = l_sample;
    }
    // find max coefficient value
    for(i = 0; i < p_filter->coeff_b_len; i++)
    {
        float32_t l_sample = abs(p_filter->coeff_b_ptr[i]);
        if(l_sample > l_max) l_max = l_sample;
    }
    const float32_t l_scaled_norm = 32767.0f / (l_max);
    printf("\nscaled norm = %f \n", l_scaled_norm);

    // standard filter
    start = clock();
    filter_signal(p_input, p_input_len, p_filter, p_output);
    stop = clock();
    printf("\nfilter cycles: %d, seconds: %f", stop - start - overhead, ticks_to_seconds(start, stop - overhead ));
    record_output(p_output, p_input_len, DATA_DIR "data_standard.txt");
    print_results(p_output, l_samples_to_print);

    // symmetric filter
    start = clock();
    symm_filter_signal(p_input, p_input_len, p_filter, p_output);
    stop = clock();
    printf("\nsymm cycles: %d, seconds: %f", stop - start - overhead, ticks_to_seconds(start, stop - overhead ));
    record_output(p_output, p_input_len, DATA_DIR "data_symmetric.txt");
    print_results(p_output, l_samples_to_print);

    // symmetric filter with fixed-point
    start = clock();
    symm_filter_signal_short(p_input, p_input_len, p_filter, p_output, l_scaled_norm);
    stop = clock();
    printf("\nsymm short cycles: %d, seconds: %f", stop - start - overhead, ticks_to_seconds(start, stop - overhead ));
    record_output(p_output, p_input_len, DATA_DIR "data_symmetric_fixed.txt");
    print_results(p_output, l_samples_to_print);

    // SIMD filter with fixed-point
    start = clock();
    fir2_set_run(p_input, p_input_len, p_filter, p_output, l_scaled_norm);
    stop = clock();
    printf("\nfir2 cycles: %d, seconds: %f", stop - start - overhead, ticks_to_seconds(start, stop - overhead ));
    record_output(p_output, p_input_len, DATA_DIR "data_fixed_simd.txt");
    print_results(p_output, l_samples_to_print);

}

```