function [ improb ] = fnColorTest( im, clModel, options )
    
    imSize = size(im);
    if isequal(options.useCroma,'LabScale')
        im2 = im(:,:,2:3,:);
        cl =  im2(:,:,:);
    elseif isequal(options.useCroma,'Lab')
        imL = lab2double(applycform(im, makecform('srgb2lab')));
        cl = imL(:,:,[1 3]);
    elseif isequal(options.useCroma,'LabRg') % with lab and rg chromaticity
        imL = lab2double(applycform(im, makecform('srgb2lab')));
        cl = imL(:,:,[1 3]);
        cl(:,:,3) = im(:,:,1) ./ sum(im, 3);
        cl(:,:,4) = im(:,:,3) ./ sum(im, 3);
    else % with rg chromaticity
        cl = im(:,:,1) ./ sum(im, 3);
        cl(:,:,2) = im(:,:,3) ./ sum(im, 3);
    end
    cl =  permute(cl, [3 1 2]);
        
    if isequal(clModel.EstMtd, 'fast')
        prob = pdf_mvgm(cl(:,:), clModel.Mest, clModel.Sest, clModel.Pest);
    else
        prob = pdf(clModel.param, cl(:,:)');
    end
    improb = reshape(prob, imSize(1:2)) ./ max(prob);
    
    
end

