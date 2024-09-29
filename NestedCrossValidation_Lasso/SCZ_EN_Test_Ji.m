function results = SCZ_EN_Test_Ji(X, y, cvarg, group, Confound, CovCateIdx, CovSiteIdx)

%%INPUT
% X          : A matrix with n rows (observations/subjects) and d columns (features)
% y          : A vector with the dependent (continuous) variable to be predicted, or a matrix
%              with n rows and t columns
% cvarg      : A structure defines number of folds and repelications; default:numRep=500; numFold=10 
% group      : A vector with d rows/columes, representing grouping information of all features 
% Confound   : A matrix with confounding variables that would like to be adjusted, here both the
%              dependent variable and the predictors are adjusted according to the current
%              recommendations in Pervaiz et al. (2020)
%              Numbering the site column, if there is only one site, just put ones 
% CovCateIdx : A vector indicates which columns in your confound matrix are categorical variables, 
%              Example: CovCatIdx=[1,2]
% CovSiteIdx  :Numeric,indicating which column encodes the site in your confound matrix
%              Example: CovSiteIdx=[2]
% 
%
% OUTPUT (a structure with results including performance measures)
% results.
%          RAll: Pearson correlation between predicted target values and
%                actual target values in outer-loop validation set
%          RinvalAll: Pearson correlation between predicted target values and
%                     actual target values in inner-loop validation set
%
%EXAMPLE USAGE
% iris = load('fisheriris.mat');
% X = iris.meas(:,1:2);
% y = iris.meas(:,3);
% group = [1,2];
% Confound = iris.meas(:,4);
% Add the site index column to Confound: Confound(:,2)=ones; 
% cvarg = [];
% cvarg.NumFolds = 100;
% cvarg.NumRepeats = 10;
% CovCateIdx = [2];
% CovSiteIdx = [2];
% results = SCZ_EN_Test_Ji(X, y, cvarg, group, Confound, CovCateIdx, CovSiteIdx)


if ~isempty(cvarg.NumRepeats)   
    numRep=cvarg.NumRepeats;
else
    numRep=500;
end

if ~isempty(cvarg.NumFolds)     
    numFold=cvarg.NumFolds;
else
    numFold=10;
end

%if multiple sites, the folds are stritified by site  
if length(unique(Confound(:,CovSiteIdx)))~=1
    CVindices=nan(size(y,1),numRep);
    CV=Confound(:,CovSiteIdx);
    sites = unique(CV); 
    indices = {};
    for i=1:length(sites)
        indices{i} = find(CV==sites(i));
    end

    for ith_repeat = 1:numRep
        for i=1:length(sites)
            ind = indices{i};
            ith_partition = cvpartition(length(ind),'KFold',numFold);
            for ith_fold=1:numFold
                j = ith_partition.test(ith_fold);
                CVindices(ind(j),ith_repeat) = ith_fold;
            end
        end
     end

% else
%     CVindices = cross_validation_partition(y, numFold, numRep);
end
group_info.pheno_group_idx = group;

% covariate regression and z-scores normalization of X and y
DesignMatrixAll=x2fx(Confound, 'linear',CovCateIdx);
y = regress_confounds_y(y, DesignMatrixAll);
X = regress_confounds_x(X, DesignMatrixAll);

y = getNormalization(y);
X = getNormalization(X);

%% True accuracy 
% for ith_repeat=1:numRep
% % YRes=nan(146,1);
% % Yhat=nan(146,1);
%  nowCV=CVindices(:,ith_repeat);
%    for ith_fold=1:10 
for ith_repeat=1:numRep
    YPred=nan(size(X,1),1);
    YTrue=nan(size(X,1),1);
    nowCV=CVindices(:,ith_repeat);
    for ith_fold=1:numFold
        [r_val, r_inval, weights, para, ypred_val,y_val] = EN_one_fold_Ji(X, y, nowCV, ith_fold, numFold, Confound, group_info,CovCateIdx);
        
        results.RAll(ith_fold,ith_repeat)=r_val;
        results.ParaAll{ith_fold,ith_repeat}=para;
        results.RinvalAll(ith_fold,ith_repeat)=r_inval;
        results.WeigAll{ith_fold, ith_repeat}=weights;
        YRes(find(nowCV==ith_fold),1)=ypred_val;
        %  Yhat(find(nowCV==ith_fold),1)=yhat;
        YVal(find(nowCV==ith_fold),1)=y_val;
        %  results.YResAll(ith_fold,ith_repeat)=ypred_val;
        %  results.YhatAll(ith_fold,ith_repeat)= yhat;
        fprintf(1,'%s\n',[int2str(ith_fold) ' done'])
    end
    %    results.Corr(ith_repeat)=corr(nowCV,y);
    results.YResAll(:,ith_repeat)=YRes;
    % results.YhatAll(:,ith_repeat)=Yhat;
    results.YValAll(:,ith_repeat)=YVal;
    fprintf(1,'%s\n',['Repeat' int2str(ith_repeat) 'completed'])
end