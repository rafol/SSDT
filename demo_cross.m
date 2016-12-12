%% Stochstic skin detector - v1.0
% tests by 10-fold cross validation
addpath('auxlib');
addpath('BiSS');
addpath('em_mvgm');
addpath('skinLib');
addpath('yael_matlab_linux64_v300');

% source path - where the skin sample images are
ps = 'img_train/';
% destination path - where the results will be saved
pd = 'Resultados/';
% data path - where the temporary data files will be stored
dd = 'data/';

mkdir(pd);
mkdir(dd);
% change the image format below if needed
arqs = dir([ps '*.color.ppm']);

% options setup
options = [];
% directory options
options.ps = ps;
options.pd = pd;
options.dd = dd;
options.ftype = '.color.ppm';
options.gtype = '.gt.pgm';
% texture options
options.w = 2;
options.clNum = 30;
options.rpNum = 10;
options.factor = 1; % image resize factor
options.crop = true; % crop skin regions (for hi res images)
%biss options
options.scale = false;
options.lambda = 10;
options.quadmode = 2;
options.bissIter = 7;
% SRM options
options.Q = 400;
options.wg = [2 1 1];
options.nIt = 1;
% color options
options.gNum = 4;
options.useCroma = 'rgCroma';
options.scatter = false;
% skin detection options
options.wg2 = [1 1 1];
options.skinTexTh = 0.2;
options.skinColorTh = 0.54;
% output options
options.alpha = 0.4;
% validation options
options.fold = 10;
done = 1;
% cross validation setup
crossSet = cvpartition(1:length(arqs),'k',10);
%% run tests
for t = 1:crossSet.NumTestSets
    trainSet = crossSet.training(t);
    testSet = crossSet.test(t);
    
    %% Get Skin Textons & color model
    fprintf('get target textons...\n')
    w     = options.w;
    clNum = options.clNum;
    rpNum = options.rpNum;
    [ textonsUniv, model ] = fnSkinTextons( w, clNum, rpNum, trainSet, options );

    fprintf('get target color model...\n')
    neta = options.gNum;
    [ clModel ] = fnSkinColor( neta, trainSet, options );

    %% skin segmentation
    for i=find(testSet)'
        fullname = [ps arqs(i).name];
        fname = arqs(i).name(1:end-3);
        fprintf('%2i: %s\n', done, arqs(i).name);
        outName = [dd arqs(i).name(1:end-10) '_seg'];
        im = imresize(imread(fullname), options.factor);
        im2 = lab2double(applycform(im, makecform('srgb2lab')));
            %% get image textons
            fprintf('get image textons...\n')
            [ MRep, cng, ~, textonsIm ] = fnDicGen( im, w, clNum, rpNum, options );
            %% join dictionaries
            dic = [textonsUniv; textonsIm];
            [ p2d ] = fnTexNN(cng, dic, rpNum);
            imSize = size(MRep(:,:,:));
            p2im = reshape(p2d, imSize);         
            %% region map generation
            fprintf('mapping...\n')
            [map] = fnPixMap(double(im)/255);
            fprintf('featuring...\n')
            [ feat ] = fnTexureFeatures( map, p2im, size(dic,1) );
            baseMap = map;
            %% Region Merging
            Q = options.Q;
            map = baseMap;
            wg2 = repmat(options.wg, size(MRep,4), 1);
            wg = wg2(:)';
            Qmin = 200; 
            Qi = Q - Qmin;
            k=1;
            fprintf('merging...');
            for k=1:options.nIt
                %%
                fprintf(' %i |', k);
                [ map, feat ] = fnMerge( MRep, map, feat, p2im, Q, wg );
                Q = Qi*exp(-k)+Qmin;
            end
            fprintf('\n');
            [~, m, map(:)] = unique(map);
            feat = feat(:,:,m);
            % save segmentation output
            fprintf('saveing...\n');
            im3 = segImage(im2double(im), map);
            imwrite(im3, [pd fname 'seg.ppm']);
            save([outName '.mat'], 'map', 'feat');
            % figure, imshow(im3);
        %% color skin detection
        [ avgcl ] = fnMeanColor( im2double(im), map );
        [ improb ] = fnColorTest( avgcl, clModel, options );
        %% texture skin detection
        skinMapMin = zeros(size(map));
        wg2 = repmat(options.wg2, size(MRep,4), 1);
        wg2 = wg2(:)';
        for r=unique(map)'
            roi = map==r;
            rmodel = feat(1:end/2,:,r);
            [ dc1 ] = fnChi2( rmodel, model, wg2 );
            skinMapMin(roi) =  min(dc1);
        end
        save([dd fname 'prob.mat'], 'skinMapMin', 'improb');
        %% final skin probability map
        clrClass = improb     > options.skinColorTh;
        texClass = skinMapMin > options.skinTexTh;
        jointClass = clrClass & texClass;
        %% save results
        imwrite(jointClass, [pd fname 'Prob.png']);
        a = alphaBend( im, ~jointClass, options.alpha );
        b = segImage(im2double(a), double(jointClass));
        imwrite(b, [pd fname 'skin.png'])
        
        c = alphaBend( im3, ~jointClass, options.alpha );
        d = segImageCl(c, double(jointClass), [0 1 0]);
        imwrite(d, [pd fname 'skinByRegion.png'])
        done = done+1;
    end
end