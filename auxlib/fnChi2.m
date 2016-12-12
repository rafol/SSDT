function [ dv ] = fnChi2( rmodel2, skinModel, wg2 )

    dv = zeros(size(skinModel,3),1);
    dT = zeros(size(rmodel2,2), 1);
    for k=1:size(skinModel,3)
        chi2 = (rmodel2 - skinModel(:,:,k)).^2 ./ (rmodel2 + skinModel(:,:,k));
        for j=1:size(rmodel2,2)
            dT(j) = 1/2 * sum(chi2(~isnan(chi2(:,j)), j));
        end
        dT2= (dT.*wg2' ./ sum(wg2));
        dv(k) = sum(dT2(~isnan(dT2)));
    end


end

