
PermResult = cell(4,5,1000);
CorrectedP_rall = zeros(4,5);
CorrectedP_medYRall = zeros(4,5);

networkDimensionPairs = [3 ,1; 4 ,1; 3 ,3; 2 ,4; 2 ,5];
for i = 1:length(networkDimensionPairs)
    net=networkDimensionPairs(i,1);
    dim=networkDimensionPairs(i,2);
    parfor numPerm=1:1000

    RandIdx=randperm(length(y)); 
    PermConfound=Confound(RandIdx',:); 
  
    PermCov = y(RandIdx',dim); % 置换
        
    
    PermResult{net,dim,numPerm} = RVM_kFold(MixedSocialNet{1,net}, PermCov, cvarg, PermConfound, CovCateIdx, CovSiteIdx);
        
        
    PermResult_rall(net,dim,numPerm) = mean(mean(PermResult{net,dim,numPerm}.RAll));
        %
        %             PermResult_psqiAll{net,dim,numPerm} = R;
        %             PermResult_Rall_psqi(net,dim,numPerm) = mean(PermResult_psqiAll{net,dim,numPerm});
    PermResult_medYRall(net,dim,numPerm) = corr(median(PermResult{net,dim,numPerm}.YPredAll,2), median(PermResult{net,dim,numPerm}.YTrueAll,2));

    end
    CorrectedP_rall(net,dim)=(length(find(PermResult_rall(net,dim,:)>=TrueResult_rall(net,dim)))+1)/1001;
    CorrectedP_medYRall(net,dim) = (length(find(PermResult_medYRall(net,dim,:)>=TrueResult_medYRall(net,dim)))+1)/1001;
    fprintf('pair: %d p: %d\n',i,CorrectedP_rall(net,dim));

end