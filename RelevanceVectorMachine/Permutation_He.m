%parfor numPerm=1:5000
    
%    RandIdx=randperm(length(y));
    
 %   for net=1:4 %�����磬���ĸ��������1��4
  %      for Cov=1:5 %���ӣ���5�����ӣ��������1��5
   %         nowCov=y(:,Cov);
    %        PermCov = nowCov(RandIdx);
     %       NEWPermFourFactorALL10000{numPerm}.Res{net,Cov} = RVM_kFold(MixedSocialNet{net}, PermCov, cvarg, Confound, CovCateIdx, CovSiteIdx) % SCZ_EN_ �滻�����Լ��Ĵ��룬()���������������Ĵ����������ǰ�ԭ����ʵ��Cov�滻��PermCov
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
        NEWPermFourFactorALL10000{numPerm}.Res{id(net,1),id(net,2)} = RVM_kFold(MixedSocialNet{id(net,1)}, PermCov, cvarg, PermConfound, CovCateIdx, CovSiteIdx) % SCZ_EN_ �滻�����Լ��Ĵ��룬()���������������Ĵ����������ǰ�ԭ����ʵ��Cov�滻��PermCov
        fprintf(1,'%s\n',[int2str(net) 'parcel done'])
    end
    fprintf(1,'%s\n',['numPerm ' int2str(numPerm) ' done'])
end