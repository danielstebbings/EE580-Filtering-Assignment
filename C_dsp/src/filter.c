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



