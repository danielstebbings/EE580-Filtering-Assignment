/**
 * @file util.h
 * @brief utility function for FIR filter implementations.
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
