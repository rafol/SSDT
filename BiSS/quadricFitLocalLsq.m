function [new_LocalValue] = quadricFitLocalLsq(img)
%V = rgb2gray(img);
V = img;
mask = ones(size(V));

V(V<0) = 0;
[lin col] = size(V);

xind=zeros(col,lin); yind=zeros(col,lin); for i=1:col for j=1:lin xind(i,j) = i; yind(i,j) = j; end; end;
xr = reshape(xind,col*lin,1); yr = reshape(yind,col*lin,1);

Im = reshape(V,col*lin,1);
X = zeros(6,col*lin); for i=1:col*lin X(:,i) = double([xr(i)^2 yr(i)^2 xr(i)*yr(i) xr(i) yr(i) 1]); end;
X=X';
%X,Im,(X'*X),(X'*X)^(-1)*X',pause,
P = double((X'*X)^(-1)*X'*double(Im));
%pause,
xp = double(round(col/2)); yp = double(round(lin/2));
new_LocalValue = P(1)*xp^2 + P(2)*yp^2 + P(3)*xp*yp + P(4)*xp + P(5)*yp + P(6);

end





% weights ???  (1-w)*Estim + w*MonteCarlo