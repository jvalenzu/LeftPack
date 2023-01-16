## Layout

const unsigned char f[] = { 0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f };
const __m128i       m   = _mm_set_epi8(0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f);

f
char [16]    00 00 00 00 00 00 00 00 08 09 0a 0b 0c 0d 0e 0f
uint64_t [2] 8080808080808080 0f0e0d0c0b0a0908

m
char [16]    0f 0e 0d 0c 0b 0a 09 08 00 00 00 00 00 00 00 00
uint64_t [2] 08090a0b0c0d0e0f 8080808080808080

## Numbers

CountOfMonteCristo.txt

| baseline    | LUT         | Mapped LUT | 2LUT        | Mapped 2LUT |
|:------------|:------------|:-----------|:------------|:------------|
| 3.470136    | 0.265491    | 0.279223   | 0.382727    | 0.421061    |
| 3.463995    | 0.2824      | 0.277845   | 0.384558    | 0.390641    |
| 3.49266     | 0.273872    | 0.301346   | 0.409116    | 0.408362    |
| 3.471359    | 0.268867    | 0.290308   | 0.386828    | 0.412893    |
| 3.569373    | 0.297064    | 0.289218   | 0.408985    | 0.414847    |
| *3.4935046* | *0.2775388* | *0.287588* | *0.3944428* | *0.409560*  |

## Mapped
Tried to improve cache efficiency by remapping entries to group together the most popular entries.  It didn't work, but the current mechanism employs an LUT, need to try an alternative that just colvolves the bits.
