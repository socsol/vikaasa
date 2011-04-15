% 45 degree plane
%[Xy45,Ypi45]= meshgrid(width,width);
lengthy= [ymin: .005:ymax];
[Xy45,Ypi45]= meshgrid(lengthy,width);
mesh(Xy45,Ypi45,Ypi45)