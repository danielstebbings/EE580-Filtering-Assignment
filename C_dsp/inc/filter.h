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
