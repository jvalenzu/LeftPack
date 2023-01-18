#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

#include <immintrin.h>
#include <emmintrin.h>
#include <x86intrin.h>

#if  __APPLE__
#include <mach/mach.h>
#include <mach/mach_time.h>
#endif

#include <limits.h>

#include <sys/stat.h>
#include <time.h>

#include "CodeGen/BigMasks.h"

#define ALIGN16(x) (((x) + 15) & ~15)
#define MIN(a,b)   ((a)<(b)?(a):(b))
#define MAX(a,b)   ((a)>(b)?(a):(b))

void indices8(int histogram[256]);
void indices16();

char* binary(int x)
{
    static char buf[33];
    buf[sizeof buf - 1] = '\0';

    for (int i=0; i<8; ++i, x >>= 1)
        buf[31-i] = x&1 ? '1' : '0';
    
    return &buf[24];
}

int dist(int x, int y)
{
    return abs(x-y);
}

void dump(const char* label, __m128i x)
{
    char value8[16];
    uint64_t value64[2];

    _mm_storeu_si128((__m128i*)value8, x);
    _mm_storeu_si128((__m128i*)value64, x);

    printf("%s\n", label);

    printf("    %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
           value8[0]&15, value8[1]&15, value8[2]&15, value8[3]&15, value8[4]&15, value8[5]&15, value8[6]&15, value8[7]&15, 
           value8[8]&15, value8[9]&15, value8[10]&15, value8[11]&15, value8[12]&15, value8[13]&15, value8[14]&15, value8[15]&15);

#if __linux__
    printf("    %016lx %016lx\n", value64[0], value64[1]);
#else
    printf("    %016llx %016llx\n", value64[0], value64[1]);
#endif
}

void test0()
{
    const __m128i c0 = _mm_set_epi8(0x0f,0x0e,0x0d,0x0c,0x0b,0x0a,0x09,0x08,0x07,0x06,0x05,0x04,0x03,0x02,0x01,0x00);
    const __m128i c1 = _mm_set_epi8(0x80,0x80,0x80,0x0f,0x0e,0x0d,0x0c,0x0a,0x09,0x07,0x06,0x05,0x04,0x03,0x01,0x00);
    
    dump("_mm_set_epi8(0x0f,0x0e,0x0d,0x0c,0x0b,0x0a,0x09,0x08,0x07,0x06,0x05,0x04,0x03,0x02,0x01,0x00)", c0);
    dump("_mm_set_epi8(0x80,0x80,0x80,0x0f,0x0e,0x0d,0x0c,0x0a,0x09,0x07,0x06,0x05,0x04,0x03,0x01,0x00)", c1);

    const __m64 k0 = _mm_set_pi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
    const __m64 k1 = _mm_set_pi8(0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00);
    const __m128i k2 = _mm_set_epi64(k0, k1);

    dump("_mm_set_epi64(_mm_set_pi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff),_mm_set_pi8(0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00))", k2);
}

int main(int argc, char* argv[])
{
#if false
    const unsigned char f[] = { 0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f };
    const __m128i       m   = _mm_set_epi8(0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f);

    dump("f", _mm_load_si128((const __m128i*)&f[0]));
    dump("m", _mm_load_si128(&m));

    return 0;
#endif

    const char* fname = (argc > 1) ? argv[1] : "CountOfMonteCristo.txt";

    struct stat buf;
    if (stat(fname, &buf) < 0)
        return 1;
    
    const int buffer_size = ALIGN16(buf.st_size+1);
    
    char* buffer = (char*) malloc(buffer_size);
    memset(buffer, 0, buffer_size);
    assert((((uint64_t)buffer) & 15) == 0);
    
    {
        FILE* fh = fopen(fname, "rb");
        fread(buffer, buf.st_size, 1, fh);
        fclose(fh);
    }

    {
        const __m128i spaces = _mm_set1_epi8(' ');

        const size_t count = buf.st_size;
        const char* in = buffer;
        const char* in_first = in;
        const char* in_last = (char*) ((uint64_t)(in + count) & ~15);

        const unsigned char map[] = { 0,1,2,9,3,10,11,37,4,12,13,38,14,39,40,93,5,15,16,41,17,42,43,94,18,44,45,95,46,96,97,163,6,19,20,47,21,48,49,98,22,50,51,99,52,100,101,164,23,53,54,102,55,103,104,165,56,105,106,166,107,167,168,219,7,24,25,57,26,58,59,108,27,60,61,109,62,110,111,169,28,63,64,112,65,113,114,170,66,115,116,171,117,172,173,220,29,67,68,118,69,119,120,174,70,121,122,175,123,176,177,221,71,124,125,178,126,179,180,222,127,181,182,223,183,224,225,247,8,30,31,72,32,73,74,128,33,75,76,129,77,130,131,184,34,78,79,132,80,133,134,185,81,135,136,186,137,187,188,226,35,82,83,138,84,139,140,189,85,141,142,190,143,191,192,227,86,144,145,193,146,194,195,228,147,196,197,229,198,230,231,248,36,87,88,148,89,149,150,199,90,151,152,200,153,201,202,232,91,154,155,203,156,204,205,233,157,206,207,234,208,235,236,249,92,158,159,209,160,210,211,237,161,212,213,238,214,239,240,250,162,215,216,241,217,242,243,251,218,244,245,252,246,253,254,255};        
        
        int histogram[256];
        memset(histogram, 0, sizeof histogram);
        
        while (in != in_last)
        {
            const __m128i c0 = _mm_load_si128((__m128i*) in);
            const __m128i m0 = _mm_cmpeq_epi8(c0, spaces);
            const uint16_t mm = (uint16_t)_mm_movemask_epi8(m0);
            const int mm_right = mm&255;
            const int mm_left = mm>>8;
            
            histogram[map[mm_right]]++;
            histogram[map[mm_left]]++;
            
            in += 16;
        }

        // k-means clustering
        {
            int clusters[256];
            int centroids[3];
            
            {
                int min = INT_MAX, max = INT_MIN;
                for (int i=0; i<256; ++i)
                {
                    min = MIN(min, histogram[i]);
                    max = MAX(max, histogram[i]);
                }
                int avg = (max+min)/2;
                centroids[0] = min;
                centroids[1] = avg;
                centroids[2] = max;
            }

            // printf("initial cluster %d %d %d\n", centroids[0], centroids[1], centroids[2]);
            
            for (int i=0; i<256; ++i)
            {
                const float d0 = dist(histogram[i], centroids[0]);
                const float d1 = dist(histogram[i], centroids[1]);
                const float d2 = dist(histogram[i], centroids[2]);
                
                if (d0 < d1 && d0 < d2)
                    clusters[i] = 0;
                else if (d1 < d0 && d1 < d2)
                    clusters[i] = 1;
                else if (d2 < d0 && d2 < d1)
                    clusters[i] = 2;
                else
                    clusters[i] = 1;
            }

            for (int i=0; i<256; ++i)            
                printf("initial clusters %d\n", clusters[i]);
            
            for (int k=0; k<16; ++k)
            {
                // recalculate centroids
                {
                    float values[3] = { 0.0f, 0.0f, 0.0f };
                    float counts[3] = { 0.0f, 0.0f, 0.0f };
                    
                    for (int i=0; i<256; ++i)
                        counts[clusters[i]] += 1.0f;
                    
                    for (int i=0; i<256; ++i)
                    {
                        if (counts[clusters[i]] == 0.0f)
                            goto done;
                        
                        values[clusters[i]] += histogram[i] / counts[clusters[i]];
                    }
                    
                    for (int i=0; i<3; ++i)
                        centroids[i] = (int) values[i];
                }
                
                for (int i=0; i<256; ++i)            
                    printf("%d step clusters %d\n", k, clusters[i]);
                
                for (int i=0; i<256; ++i)
                {
                    const float d0 = dist(histogram[i], centroids[0]);
                    const float d1 = dist(histogram[i], centroids[1]);
                    const float d2 = dist(histogram[i], centroids[2]);
                    
                    if (d0 < d1 && d0 < d2)
                        clusters[i] = 0;
                    else if (d1 < d0 && d1 < d2)
                        clusters[i] = 1;
                    else if (d2 < d0 && d2 < d1)
                        clusters[i] = 2;
                    else
                        clusters[i] = 1;
                }
            }

            FILE* fh = fopen("histogram_k.txt", "wb");
            int priority[256];
            for (int i=0; i<256; ++i)
            {
                fprintf(fh, "%d %d\n", i, centroids[clusters[i]]);
            }
            fclose(fh);

            if (false)
            {
                int priority[256];
                for (int i=0; i<256; ++i)                
                    priority[i] = centroids[clusters[i]];
                indices8(priority);
            }
        }
      done:

        if (true)
        {
            int priority[256];
            for (int i=0; i<256; ++i)                
                priority[i] = histogram[i];
            indices8(priority);
        }
        
        FILE* fh = fopen("histogram.txt", "wb");
        for (int i=0; i<256; ++i)
            fprintf(fh, "%d %d\n", i, histogram[i]);
        fclose(fh);
    }

    return 0;
}

int sort_lzcnt(const void* a, const void* b)
{
    const int* ap = (const int *)a;
    const int* bp = (const int *)b;

    return ((_popcnt32(*ap)<<16)|*ap) - ((_popcnt32(*bp)<<16)|*bp);
}

#if __APPLE__
int sort_by_histogram(void* thunk, const void* a, const void* b)
#else
int sort_by_histogram(const void* a, const void* b, void* thunk)
#endif
{
    int *priority = (int*)thunk;
    
    const int* ap = (const int *)a;
    const int* bp = (const int *)b;

    return priority[*bp] - priority[*ap];
}

void indices8(int histogram[256])
{
    int indices[256];
    for (int i=0; i<256; ++i)
        indices[i] = i;

#if __APPLE__
    qsort_r(indices, 256, sizeof(int), histogram, sort_by_histogram);
#else
    qsort_r(indices, 256, sizeof(int), sort_by_histogram, histogram);
#endif

    int rev_indices[256];
    for (int i=0; i<256; ++i)
        rev_indices[indices[i]] = i;


    printf("// by priority \n");    
    printf("{\n");
    
    for (int i=0; i<256; i += 8)
    {
        printf("  ");
        
        for (int j=0; j<8; ++j)
            printf("%6d%s", indices[j+i], (j+i)==255?"" :",");
        
        puts("");
    }

    printf("}\n");

    printf("// by inverse priority\n");
    printf("(\n");
    
    for (int i=0; i<256; i += 8)
    {
        printf("  ");
        
        for (int j=0; j<8; ++j)
            printf("%6d%s", rev_indices[j+i], (j+i)==255?"" :",");
        
        puts("");
    }

    printf(")\n");
}
