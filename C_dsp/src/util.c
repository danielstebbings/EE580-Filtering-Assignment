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


