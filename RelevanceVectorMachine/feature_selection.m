for i = 1:4
    for j = 1:5
        tmp = [];
        for k = 1:100 % RepNum 
            tmp = [tmp TrueResult{i,j}.AllWei{1,k}];
        end
        checkweig{i,j} = tmp;
        clear tmp;
    end
end

for i = 1:5
    tmp = [];
    for j = 1:4
        tmp = [tmp; checkweig{j,i}];
        Alldim{i} = tmp;
    end
    clear tmp;
end

for i = 1:4
    checkfeature{i} = sum(Alldim{i},2);
    selectfeature{i} = find(checkfeature{i} > 560);
end

% for LOSO
%for i = 1:4
 %   tmp = [];
  %  for j = 1:13
   %     tmp = [tmp; resultsRVM_LOSO{j,i}.AllWei];
    %    Alldim_LOSO{i} = tmp;
   % end
   % clear tmp;
%end

%for i = 1:4
 %   checkfeature_LOSO{i} = sum(Alldim_LOSO{i},2);
  %  selectfeature_LOSO{i} = find(checkfeature_LOSO{i} > 5);
%end

%for i = 1:4
 %   finalselection{i} = intersect(selectfeature{i},selectfeature_LOSO{i});
%end