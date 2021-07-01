# usage: 'gnuplot terrain-508-509.plot'
set title "f508/f509 terrain"
set xrange [0:2*pi]
set yrange [0:2*pi]
set isosamples 50,50
set xlabel "X axis" -3,-2
set ylabel "Y axis" 3,-2
set zlabel "Z axis" 0, 0
# fn 508/509
#plot sin(x)-sin(1.5*x)+sin(2.5*x)+0.5*sin(3.5*x),\
#sin(x)+sin(1.5*x)-sin(2.5*x)-0.5*sin(3.5*x)+0.5*sin(4.5*x)
# 3D plot f508/509
splot (sin(x)-sin(1.5*x)+sin(2.5*x)+0.5*sin(3.5*x))*(sin(y)+sin(1.5*y)-sin(2.5*y)-0.5*sin(3.5*y)+0.5*sin(4.5*y))
pause -1
reset
