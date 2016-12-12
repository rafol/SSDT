function [ out ] = alphaBend( im, mask, alpha )

    out = permute(im, [3 1 2]);
    out(:,mask) = out(:,mask)*alpha;
    out = permute(out, [2 3 1]);

end

