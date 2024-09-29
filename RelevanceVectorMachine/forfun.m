% organizae data
%addpath '/home/dell/桌面/hezhiqiu/RVM/inputs';
%load('dirs.mat');
%for i = 1:13
%    load(parcels{i});
%    Allpar{i} = X;
%end
% RVM run
TrueResult = cell(4,5);
parfor net = 1:4
    for dim = 1:5       

        TrueResult{net,dim} = RVM_kFold(MixedSocialNet{net},y(:,dim), cvarg, Confound, CovCateIdx, CovSiteIdx);
        TrueResult_rall(net,dim) = mean(mean(TrueResult{net,dim}.RAll));
        TrueResult_medYRall(net,dim) = corr(median(TrueResult{net,dim}.YPredAll,2), median(TrueResult{net,dim}.YTrueAll,2));
        fprintf('net %d, dim %d\n',net,dim);

    end
end
% RVM run1
%parfor i = 1:4
%    for j = 1:5       
%        resultsRVM2{i,j} = RVM_kFold(X(:,idx(i,1):idx(i,2)), y(:,j), cvarg, Confound, CovCateIdx, CovSiteIdx);
%    end
%end

