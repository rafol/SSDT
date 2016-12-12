clc,clear, close all hidden
disp('First example : a simple EM .... (pause)')
% pause

d                                   = 2;                % dimension
m                                   = 3;                % number of conpounds
Ntrain                              = 1000;             % number of training data
Ntest                               = 1000;             % number of testing data
nbite                               = 100;              % number of EM iterations


%%% True model %%%%

P                                   = cat(3 , [0.4] , [0.6]);
M                                   = cat(3 , [-1 ; -1] , [1 ; 1]);
S                                   = cat(3 , [1 0.3 ; 0.3 0.8] , [0.7 0.6; 0.6 1]);
[Ztrain ,  Xtrain]                  = sample_mvgm(Ntrain , M , S , P);
Xtrain                              = Xtrain - 1;
[Ztest ,  Xtest]                    = sample_mvgm(Ntest , M , S , P);
Xtest                               = Xtest - 1;
[x , y]                             = ndellipse(M , S);

%%% Initial model %%%%
P0                                  = rand(m , 1 , d );
sumP                                = sum(P0 , 3);
P0                                  = P0./sumP(: , : , ones(d , 1));

M0                                  = randn(m , 1 , d);
S0                                  = [2 0 ; 0 2];
% S0                                  = cat(3 , [2 0 ; 0 2] , [3 0; 0 2]);
[x0 , y0]                           = ndellipse(M0 , S0);

%% % Run EM on training data %%%%

[logl , Mest , Sest , Pest]         = em_mvgm(Ztrain , M0 , S0 , P0 , nbite);
[xtrain_est , ytrain_est]           = ndellipse(Mest , Sest);

%% % Performance on training data %%%%

L                                   = likelihood_mvgm(Ztrain , Mest , Sest , Pest);
[val , Xtrain_est]                  = max(L);
Xtrain_est                          = Xtrain_est - 1;
Err_train                           = min(sum(Xtrain ~= Xtrain_est , 2)/Ntrain , sum(Xtrain ~= ~Xtrain_est , 2)/Ntrain);

figure(1)
h                                   = plot(Ztrain(1 , :) , Ztrain(2 , :) , 'k+' , x , y , 'b' , x0 , y0 , 'r' , xtrain_est , ytrain_est , 'g' , 'linewidth' , 2);
legend([h(1) ; h(2:m:end)] , 'Train data' , 'True' , 'Initial' , 'Estimated' , 'location' , 'best')
title(sprintf('Train data, Error rate = %4.2f%%' , Err_train*100))

%%% Performance on testing data %%%%

Ltest                               = likelihood_mvgm(Ztest , Mest , Sest , Pest);
[val , Xtest_est]                   = max(Ltest);
Xtest_est                           = Xtest_est - 1;
Err_test                            = min(sum(Xtest ~= Xtest_est , 2)/Ntest , sum(Xtest ~= ~Xtest_est , 2)/Ntest);

figure(2)
h                                   = plot(Ztest(1 , :) , Ztest(2 , :) , 'k+' , x , y , 'b' , xtrain_est , ytrain_est , 'g' , 'linewidth' , 2);
legend([h(1) ; h(2:m:end)] , 'Test data' , 'True'  , 'Estimated' , 'location' , 'best')
title(sprintf('Test data, Error rate = %4.2f%%' , Err_test*100))


clc,clear, 
disp('Second example : EM with multiple initial parameters .... (pause)')
pause
close all hidden,drawnow

d                                   = 2;                % dimension
m                                   = 2;                % number of conpounds
R                                   = 50;               % number of initial parameters
Ntrain                              = 1000;             % number of training data
Ntest                               = 1000;             % number of testing data
nbite                               = 100;              % number of EM iterations


%%% True model %%%%

P                                   = cat(3 , [0.4] , [0.6]);
M                                   = cat(3 , [-1 ; -1] , [1 ; 1]);
S                                   = cat(3 , [1 0.3 ; 0.3 0.8] , [0.7 0.6; 0.6 1]);
[Ztrain ,  Xtrain]                  = sample_mvgm(Ntrain , M , S , P);
Xtrain                              = Xtrain - 1;
[Ztest ,  Xtest]                    = sample_mvgm(Ntest , M , S , P);
Xtest                               = Xtest - 1;
[x , y]                             = ndellipse(M , S);

%%% Initial model %%%%
P0                                  = rand(1 , 1 , d , R);
sumP                                = sum(P0 , 3);
P0                                  = P0./sumP(: , : , ones(d , 1) , :);

M0                                  = 2*randn(m , 1 , d , R);
S0                                  = repmat(cat(3 , [2 0 ; 0 2] , [3 0; 0 2]) , [1 , 1 , 1, R]) ;
[x0 , y0]                           = ndellipse(M0 , S0);

%%% Run EM on training data %%%%

[logl , Mest , Sest , Pest]         = em_mvgm(Ztrain , M0 , S0 , P0 , nbite);
[xtrain_est , ytrain_est]           = ndellipse(Mest , Sest);

%%% Performance on training data %%%%

L                                   = likelihood_mvgm(Ztrain , Mest , Sest , Pest);
[val , Xtrain_est]                  = max(L , [] , 1);
Xtrain_est                          = Xtrain_est - 1;
Err_train                           = reshape(min(sum(Xtrain(: , : , ones(1 , R)) ~= Xtrain_est , 2)/Ntrain , sum(Xtrain(: , : , ones(1 , R)) ~= ~Xtrain_est , 2)/Ntrain) , 1 , R);


figure(1)
plot(Err_train , 'linewidth' , 2)
xlabel('# initial parameter');
title(sprintf('Error rate Train data'))


%%% Performance on testing data %%%%

Ltest                               = likelihood_mvgm(Ztest , Mest , Sest , Pest);
[val , Xtest_est]                   = max(Ltest , [] , 1);
Xtest_est                           = Xtest_est - 1;
Err_test                            = reshape(min(sum(Xtest(: , : , ones(1 , R)) ~= Xtest_est , 2)/Ntest , sum(Xtest(: , : , ones(1 , R)) ~= ~Xtest_est , 2)/Ntest) , 1 , R);

figure(2)
plot(Err_test , 'linewidth' , 2)
xlabel('# initial parameter');
title(sprintf('Error rate  Test data'))
