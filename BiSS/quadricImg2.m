function output = quadricImg2(im,w)

im = padarray(im,[floor(w/2) floor(w/2)],'symmetric');

output = im;

[lin col prof] = size(im);
for x=1+floor(w/2):lin-floor(w/2)
    for y=1+floor(w/2):col-floor(w/2)
        im_l = im(x-floor(w/2):x+floor(w/2),y-floor(w/2):y+floor(w/2));
        
%         v = quadricFitLocalLsq2(im_l);
        %% quadricFitLocalLsq2
        V = im_l;
        V(V<0) = 0;
        [lin col] = size(V);
        
        xind=zeros(col,lin); 
        yind=zeros(col,lin); 
        for i=1:col 
            for j=1:lin 
                xind(i,j) = i; 
                yind(i,j) = j; 
            end; 
        end;
        xr = xind(:); 
        yr = yind(:);
        
        X = ones(6,col*lin); 
        X(1,:) = xr.^2;
        X(2,:) = yr.^2;
        X(3,:) = xr.*yr;
        X(4,:) = xr;
        X(5,:) = yr;

        X=X';
        P = double((X'*X)^(-1)*X'*double(V(:)));
        
        xp = double(round(col/2)); 
        yp = double(round(lin/2));
        v = [xp^2 yp^2 xp*yp xp yp 1] * P;
        %%
        if (v >= 0) output(x,y) = v; end;
    end;
end;
output = output(1+floor(w/2):end-floor(w/2),1+floor(w/2):end-floor(w/2));