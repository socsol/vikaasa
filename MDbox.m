%% add box K for Macro Dynamics 

ymin= -.04;
ymax= .04;
pimin= .01;
pimax= .03;
yy= [ymin:.01:ymax];
ly =  length(yy);
pi_b= pimin*ones(1,ly);
%plot(yy,pi_b,'k-')
pi_u= pimax*ones(1,ly);
%plot(yy,pi_u,'k-')
hpi= [pimin:.005:pimax];
lpi =  length(hpi);
%plot(ymin*ones(1,lpi),hpi,'k-')
%plot(ymax*ones(1,lpi),hpi,'k-')
yym= [ymax:-.01:ymin];
%fill([yy, ymax*ones(1,lpi), yym,ymin*ones(1,lpi)], [pi_b, hpi, pi_u,hpi],'y')
yminlim= ymin-.01;
ymaxlim= ymax+.01;
piminlim= pimin-.01;
pimaxlim= pimax+.01;

imin= 0;
iminlim= imin;
imax= .07;
imaxlim= imax+.01;
axis([yminlim, ymaxlim, piminlim, pimaxlim, iminlim, imaxlim])
xlabel('output gap')
ylabel('inflation')
zlabel('interes rate')
%base
plot(yy,pi_b,'k-')
plot(yy,pi_u,'k-')
plot(ymin*ones(1,lpi),hpi,'k-')
plot(ymax*ones(1,lpi),hpi,'k-')
%fill([yy, ymax*ones(1,lpi), yym,ymin*ones(1,lpi)], [pi_b, hpi, pi_u, hpi],'y')
%ly =  length(yy);
%lpi =  length(hpi);

%ceiling
plot3(yy,pi_b,imax*ones(1,ly),'k-')
plot3(yy,pi_u,imax*ones(1,ly),'k-')
plot3(ymin*ones(1,lpi),hpi,imax*ones(1,lpi),'k-')
plot3(ymax*ones(1,lpi),hpi,imax*ones(1,lpi),'k-')

%walls
plot3(yy(1)*ones(1,ly+1),pi_b(1)*ones(1,ly+1),imax*[0:1/ly:1],'k-')
plot3(yy(1)*ones(1,ly+1),pi_u(1)*ones(1,ly+1),imax*[0:1/ly:1],'k-')
plot3(yy(ly)*ones(1,ly+1),pi_u(1)*ones(1,ly+1),imax*[0:1/ly:1],'k-')
plot3(yy(ly)*ones(1,ly+1),pi_b(1)*ones(1,ly+1),imax*[0:1/ly:1],'k-')