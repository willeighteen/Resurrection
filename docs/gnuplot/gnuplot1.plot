# usage: 'gnuplot <path>/gnuplot1.plot'

# 1) plotting file data contents

#set key outside below
#plot 'f502.data'
#<'more.files'>,\

# 2) 3D plot
set xrange [0:1]
set yrange [0:1]
set isosamples 50,50
# plot fn 501
#plot sin(2.5*x)+sin(x)
# fn 503
#plot sin(3.5*x)-cos(3*x)
# fn 506
#plot sin(x)-sin(1.5*x)+sin(2.5*x)+0.5*sin(3.5*x)
# fn 507
#plot sin(x)-sin(1.5*x)+sin(2.5*x)-0.5*sin(3.5*x)
#plot sin(x*x)-2*sin(x)+0.5*sin(0.5*x)
#plot sin(x)-0.2*sin(0.5*x*x), cos(x)-0.5*cos(0.2*x*x)

#splot (sin(x)-0.2*sin(0.5*x*x))*(cos(y)-0.5*cos(0.2*y*y))
#plot sin(x*x)

#plot sin(x)
# 3D plot 506*507
splot (sin(x)-sin(1.5*x)+sin(2.5*x)+0.5*sin(3.5*x))*(sin(y)-sin(1.5*y)+sin(2.5*y)-0.5*sin(3.5*y))

splot x*y

pause -1
reset
