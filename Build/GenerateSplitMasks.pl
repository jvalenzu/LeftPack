#!/bin/perl -w

use strict;

open(my $fh, '>', "CodeGen/SplitMasks.h") or die $!;
print $fh "#include <stdint.h>\n\n";
print $fh "#include <immintrin.h>\n\n";
print $fh "extern const __m64   g_BeMasks[256];\n";
print $fh "extern const __m128i g_LeMasks[9][256];\n";
close($fh);

open($fh, '>', "CodeGen/SplitMasks.cpp") or die $!;
print $fh "#include \"CodeGen/SplitMasks.h\"\n\n";
print $fh "#include <stdint.h>\n\n";

## big endian masks
print $fh "const __m64 g_BeMasks[256] __attribute((aligned(16))) =\n";
print $fh "{\n";

for (my $i=0; $i<256; ++$i)
{
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
  
  my @d1 = reverse @d0;
  
  my $is = sprintf("%5s", sprintf("%d", $i));
  print $fh "    /* $is */ _mm_set_pi8(".join(',', @d1).")".(($i!=255)?",":" ")."\n";
}

print $fh "};\n\n";

## little endian masks
print $fh "const __m128i g_LeMasks[9][256]  __attribute((aligned(16))) =\n";
print $fh "{\n";

for (my $k=0; $k<9; ++$k)
{
  print $fh "  {\n";
  print $fh "     // $k\n";
  
  for (my $i=0; $i<256; ++$i)
  {
    my @d0 = ();

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

    my @d1 = reverse @d0;

    my $iks = sprintf("%5s", sprintf("%d %d", $i, $k));
    print $fh "    /* $iks */ _mm_set_epi8(".join(',', @d1).")".(($i!=255)?",":" ")."\n";
  }

  print $fh "  }".($k == 8 ? "" : ",")."\n";
}
print $fh "};\n\n";
