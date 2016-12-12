function I_s = segImageCl(I,S,cl)
    [cx,cy] = gradient(S);
    ccc = (abs(cx)+abs(cy))~=0;
    I_s = rgbMaskValue( I, ccc, cl );
        
end
    
function [ out ] = rgbMaskValue( iRGB, mask, v )
    m1 = iRGB(:,:,1);
    m2 = iRGB(:,:,2);
    m3 = iRGB(:,:,3);
    m1(mask) = v(1);
    m2(mask) = v(2);
    m3(mask) = v(3);

    out(:,:,1) = m1;
    out(:,:,2) = m2;
    out(:,:,3) = m3;
end
