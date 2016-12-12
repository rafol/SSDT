function output = quadricImg(im,w)

im = padarray(im,[floor(w/2) floor(w/2)],'symmetric');

output = im;

[lin col prof] = size(im);
for x=1+floor(w/2):lin-floor(w/2)
    for y=1+floor(w/2):col-floor(w/2)
        im_l = im(x-floor(w/2):x+floor(w/2),y-floor(w/2):y+floor(w/2));
        v = quadricFitLocalLsq2(im_l);
        if (v >= 0) output(x,y) = v; end;
    end;
end;
output = output(1+floor(w/2):end-floor(w/2),1+floor(w/2):end-floor(w/2));