set terminal png size 1024,768
set output "histogram.png"
plot "histogram.txt" using 1:2 with boxes 
