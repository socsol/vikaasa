% output gap= 0 
% 1-st condition for steady state 
%[imin, imax]: interest rate bounds

% building a wall starting at imin up to imax
% at y= 0; width [-.01 .06] 
%hight= [imin:.005:imax];

pimin=0.01;
pimax=0.03;

imin=0;
imax=0.07;


width =  [pimin:.005: pimax];
lypi= length(width);
xy= zeros(1,lypi);
[Xy,Ypi]= meshgrid(xy,width);
Zi= ones(lypi);
for k= 1:lypi
Zi(k,:)= (k-1)/(lypi-1)*(imax-imin)*ones(1,lypi);
end
mesh(Xy,Ypi,Zi', 'FaceColor', [1,1,1], 'FaceAlpha', 0.7)