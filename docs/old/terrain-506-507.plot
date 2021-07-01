# usage: 'gnuplot terrain-506-507.plot'
set title "f506/f507 terrain"
set xrange [0:2*pi]
set yrange [0:2*pi]
set isosamples 50,50
set xlabel "X axis" -3,-2
set ylabel "Y axis" 3,-2
set zlabel "Z axis" 0, 0
# fn 506
#plot sin(x)-sin(1.5*x)+sin(2.5*x)+0.5*sin(3.5*x)
# fn 507
#plot sin(x)-sin(1.5*x)+sin(2.5*x)-0.5*sin(3.5*x)
# plot 506, 507
#plot sin(x)-sin(1.5*x)+sin(2.5*x)+0.5*sin(3.5*x),\
#sin(x)-sin(1.5*x)+sin(2.5*x)-0.5*sin(3.5*x)
# 3D plot 506*507
splot (sin(x)-sin(1.5*x)+sin(2.5*x)+0.5*sin(3.5*x))*(sin(y)-sin(1.5*y)+sin(2.5*y)-0.5*sin(3.5*y))
pause -1
reset
