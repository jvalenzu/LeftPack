#!/bin/perl -w

use strict;

open(my $fh, '>', "CodeGen/SplitMasksMapped.h") or die $!;
print $fh "#include <stdint.h>\n\n";
print $fh "#include <immintrin.h>\n\n";
print $fh "extern const unsigned char g_BeMasksMapped[256][8];\n";
print $fh "extern const unsigned char g_LeMasksMapped[9][256][16];\n";
close($fh);

open($fh, '>', "CodeGen/SplitMasksMapped.cpp") or die $!;
print $fh "#include \"CodeGen/SplitMasksMapped.h\"\n\n";
print $fh "#include <stdint.h>\n\n";

## big endian masks
print $fh "const unsigned char g_BeMasksMapped[256][8] __attribute((aligned(16))) =\n";
print $fh "{\n";

for (my $iu=0; $iu<256; ++$iu)
{
  # my $i = ( 0,1,2,4,8,16,32,64,128,3,5,6,9,10,12,17,18,20,24,33,34,36,40,48,65,66,68,72,80,96,129,130,132,136,144,160,192,7,11,13,14,19,21,22,25,26,28,35,37,38,41,42,44,49,50,52,56,67,69,70,73,74,76,81,82,84,88,97,98,100,104,112,131,133,134,137,138,140,145,146,148,152,161,162,164,168,176,193,194,196,200,208,224,15,23,27,29,30,39,43,45,46,51,53,54,57,58,60,71,75,77,78,83,85,86,89,90,92,99,101,102,105,106,108,113,114,116,120,135,139,141,142,147,149,150,153,154,156,163,165,166,169,170,172,177,178,180,184,195,197,198,201,202,204,209,210,212,216,225,226,228,232,240,31,47,55,59,61,62,79,87,91,93,94,103,107,109,110,115,117,118,121,122,124,143,151,155,157,158,167,171,173,174,179,181,182,185,186,188,199,203,205,206,211,213,214,217,218,220,227,229,230,233,234,236,241,242,244,248,63,95,111,119,123,125,126,159,175,183,187,189,190,207,215,219,221,222,231,235,237,238,243,245,246,249,250,252,127,191,223,239,247,251,253,254,255)[$iu];
  my $i = (
       0,     8,     6,     4,     1,     2,     3,     5,
       7,    48,    29,    58,    22,    26,    69,    11,
      18,    25,    59,    17,    10,    13,    27,    72,
      21,    14,     9,    15,    28,    62,    23,    20,
      16,    12,    19,    32,    49,    70,   177,   178,
     179,   180,   181,   182,   183,   184,   185,    71,
      46,   186,    40,    78,   187,    65,   188,   189,
     190,    77,    43,    67,    33,    45,   191,    38,
      37,   192,   193,   194,   195,   196,   197,    74,
     198,    34,    73,    24,    41,   199,    30,    31,
      44,   200,    36,    39,    35,   201,   202,   203,
      63,   204,   205,   206,    50,    55,   207,   208,
     209,   210,   211,   212,   213,   214,   215,   216,
     217,   218,   219,   220,    64,   221,   222,   223,
     224,   225,   226,   227,   228,   229,   230,   231,
     232,   233,   234,   235,   236,   237,   238,   239,
      66,   240,   241,   242,    76,   243,   244,   245,
     246,   247,   248,    61,   249,   250,   251,   252,
     253,   254,   255,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    92,
      93,    75,    51,    52,    94,    95,    96,    97,
      98,    99,   100,   101,   102,   103,   104,   105,
     106,   107,   108,   109,   110,   111,   112,    68,
     113,   114,   115,   116,   117,   118,   119,   120,
     121,   122,   123,   124,   125,   126,   127,   128,
     129,   130,   131,   132,   133,   134,   135,   136,
     137,   138,   139,   140,   141,   142,   143,    79,
     144,   145,    47,    56,   146,   147,   148,   176,
     149,   150,    60,   151,   152,   153,   154,   155,
     156,   157,   158,   159,   160,   161,   162,   163,
     164,   165,   166,   167,   168,   169,    57,    53,
     170,   171,   172,   173,   174,   175,    54,    42 )[$iu];
  
  my @d0;
  my $joffset = 0;
  for (my $j=0; $j<8; ++$j)
  {
    if ((($i & (1<<$j)) == 0))
    {
      $d0[$joffset++] = sprintf("0x%02x", $j);
    }
  }
  
  {
    my $skipped = 8 - $joffset;
    while ($#d0 < 7)
    {
      push @d0, "0x80";
    }
  }
  
  my @d1 = @d0;
  
  my $is = sprintf("%5s", sprintf("%d", $iu));
  print $fh "    /* $is */ { ".join(',', @d1)."}".(($iu!=255)?",":" ")."\n";
}

print $fh "};\n\n";

## little endian masks
print $fh "const unsigned char g_LeMasksMapped[9][256][16]  __attribute((aligned(16))) =\n";
print $fh "{\n";

for (my $k=0; $k<9; ++$k)
{
  print $fh "  {\n";
  print $fh "     // $k\n";
  
  for (my $iu=0; $iu<256; ++$iu)
  {
    my @d0 = ();

    # my $i = (0,1,2,9,3,10,11,37,4,12,13,38,14,39,40,93,5,15,16,41,17,42,43,94,18,44,45,95,46,96,97,163,6,19,20,47,21,48,49,98,22,50,51,99,52,100,101,164,23,53,54,102,55,103,104,165,56,105,106,166,107,167,168,219,7,24,25,57,26,58,59,108,27,60,61,109,62,110,111,169,28,63,64,112,65,113,114,170,66,115,116,171,117,172,173,220,29,67,68,118,69,119,120,174,70,121,122,175,123,176,177,221,71,124,125,178,126,179,180,222,127,181,182,223,183,224,225,247,8,30,31,72,32,73,74,128,33,75,76,129,77,130,131,184,34,78,79,132,80,133,134,185,81,135,136,186,137,187,188,226,35,82,83,138,84,139,140,189,85,141,142,190,143,191,192,227,86,144,145,193,146,194,195,228,147,196,197,229,198,230,231,248,36,87,88,148,89,149,150,199,90,151,152,200,153,201,202,232,91,154,155,203,156,204,205,233,157,206,207,234,208,235,236,249,92,158,159,209,160,210,211,237,161,212,213,238,214,239,240,250,162,215,216,241,217,242,243,251,218,244,245,252,246,253,254,255)[$iu];
    # my $i = ( 0,1,2,4,8,16,32,64,128,3,5,6,9,10,12,17,18,20,24,33,34,36,40,48,65,66,68,72,80,96,129,130,132,136,144,160,192,7,11,13,14,19,21,22,25,26,28,35,37,38,41,42,44,49,50,52,56,67,69,70,73,74,76,81,82,84,88,97,98,100,104,112,131,133,134,137,138,140,145,146,148,152,161,162,164,168,176,193,194,196,200,208,224,15,23,27,29,30,39,43,45,46,51,53,54,57,58,60,71,75,77,78,83,85,86,89,90,92,99,101,102,105,106,108,113,114,116,120,135,139,141,142,147,149,150,153,154,156,163,165,166,169,170,172,177,178,180,184,195,197,198,201,202,204,209,210,212,216,225,226,228,232,240,31,47,55,59,61,62,79,87,91,93,94,103,107,109,110,115,117,118,121,122,124,143,151,155,157,158,167,171,173,174,179,181,182,185,186,188,199,203,205,206,211,213,214,217,218,220,227,229,230,233,234,236,241,242,244,248,63,95,111,119,123,125,126,159,175,183,187,189,190,207,215,219,221,222,231,235,237,238,243,245,246,249,250,252,127,191,223,239,247,251,253,254,255)[$iu];
    my $i = (
       0,     8,     6,     4,     1,     2,     3,     5,
       7,    48,    29,    58,    22,    26,    69,    11,
      18,    25,    59,    17,    10,    13,    27,    72,
      21,    14,     9,    15,    28,    62,    23,    20,
      16,    12,    19,    32,    49,    70,   177,   178,
     179,   180,   181,   182,   183,   184,   185,    71,
      46,   186,    40,    78,   187,    65,   188,   189,
     190,    77,    43,    67,    33,    45,   191,    38,
      37,   192,   193,   194,   195,   196,   197,    74,
     198,    34,    73,    24,    41,   199,    30,    31,
      44,   200,    36,    39,    35,   201,   202,   203,
      63,   204,   205,   206,    50,    55,   207,   208,
     209,   210,   211,   212,   213,   214,   215,   216,
     217,   218,   219,   220,    64,   221,   222,   223,
     224,   225,   226,   227,   228,   229,   230,   231,
     232,   233,   234,   235,   236,   237,   238,   239,
      66,   240,   241,   242,    76,   243,   244,   245,
     246,   247,   248,    61,   249,   250,   251,   252,
     253,   254,   255,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    92,
      93,    75,    51,    52,    94,    95,    96,    97,
      98,    99,   100,   101,   102,   103,   104,   105,
     106,   107,   108,   109,   110,   111,   112,    68,
     113,   114,   115,   116,   117,   118,   119,   120,
     121,   122,   123,   124,   125,   126,   127,   128,
     129,   130,   131,   132,   133,   134,   135,   136,
     137,   138,   139,   140,   141,   142,   143,    79,
     144,   145,    47,    56,   146,   147,   148,   176,
     149,   150,    60,   151,   152,   153,   154,   155,
     156,   157,   158,   159,   160,   161,   162,   163,
     164,   165,   166,   167,   168,   169,    57,    53,
     170,   171,   172,   173,   174,   175,    54,    42
        )[$iu];

    while ($#d0 < 7-$k)
    {
      push @d0, "0x80";
    }
    
    for (my $j=0; $j<8; ++$j)
    {
      if ((($i & (1<<$j)) == 0))
      {
        push @d0, sprintf("0x%02x", $j + 8);
      }
    }

    while ($#d0 < 15)
    {
      push @d0, "0x80";
    }

    my @d1 = @d0;

    my $iks = sprintf("%5s", sprintf("%d %d", $iu, $k));
    print $fh "    /* $iks */ { ".join(',', @d1)."}".(($iu!=255)?",":" ")."\n";
  }

  print $fh "  }".($k == 8 ? "" : ",")."\n";
}
print $fh "};\n\n";