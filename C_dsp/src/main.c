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

