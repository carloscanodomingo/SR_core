function plot_chirpz(y)
fs = 187

cf1 =0; cf2 =187/2; %in Hz
m=256; %number of contour points
%ratio between contour points:
w=exp(-j*(2* pi*(cf2 -cf1 ))/(m*fs));
a=exp(j*(2* pi*cf1)/fs); %contour starting point
chy=czt(y,m,w,a); %the chirp -z transform
fhiv =(cf2 -cf1)/m; %frequency interval
fhy=cf1:fhiv :(cf2 -fhiv );
plot(fhy ,abs(chy),'k');
end

