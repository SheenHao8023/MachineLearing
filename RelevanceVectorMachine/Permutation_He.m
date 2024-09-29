%parfor numPerm=1:5000
    
%    RandIdx=randperm(length(y));
    
 %   for net=1:4 %脑网络，你四个这里就是1：4
  %      for Cov=1:5 %因子，你5个因子，这里就是1：5
   %         nowCov=y(:,Cov);
    %        PermCov = nowCov(RandIdx);
     %       NEWPermFourFactorALL10000{numPerm}.Res{net,Cov} = RVM_kFold(MixedSocialNet{net}, PermCov, cvarg, Confound, CovCateIdx, CovSiteIdx) % SCZ_EN_ 替换成你自己的代码，()括号内输入根据你的代码来，就是把原来真实的Cov替换成PermCov
      %          fprintf(1,'%s\n',['Cov ' int2str(Cov) ' done'])
   %     end
   %     fprintf(1,'%s\n',['net ' int2str(net) ' done'])
  %  end
  %  fprintf(1,'%s\n',['numPerm ' int2str(numPerm) ' done'])
%end

% test specific parcels
parfor numPerm=1:1000
    
    RandIdx=randperm(length(y));
    PermConfound=Confound(RandIdx',:);
    
    for net=1:size(id,1) % specific match
        
        nowCov=y(:,id(net,2));
        PermCov = nowCov(RandIdx);
        NEWPermFourFactorALL10000{numPerm}.Res{id(net,1),id(net,2)} = RVM_kFold(MixedSocialNet{id(net,1)}, PermCov, cvarg, PermConfound, CovCateIdx, CovSiteIdx) % SCZ_EN_ 替换成你自己的代码，()括号内输入根据你的代码来，就是把原来真实的Cov替换成PermCov
        fprintf(1,'%s\n',[int2str(net) 'parcel done'])
    end
    fprintf(1,'%s\n',['numPerm ' int2str(numPerm) ' done'])
end