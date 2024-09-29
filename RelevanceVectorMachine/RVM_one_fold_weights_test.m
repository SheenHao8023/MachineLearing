function [perf,ypred_val,y_val,weights] = RVM_one_fold_weights_test(x, y, cv_ind, fold, confounds, CovCateIdx)
% 
% This function runs RVM for one cross-validation fold. The
% relationship between features and targets is assumed to be 
% y = x * weights + b.

% INPUT:
%       - x       : NxF matrix containing F features from N subjects
%       - y       : Nx1 matrix containing the target values from N subjects
%       - cv_ind  : Nx1 matrix containing cross-validation fold assignment
%                   for N subjects. Values should range from 1 to 10 for a
%                   10-fold cross-validation                
%       - fold    : Fold to be used as validation set   
%       - confounds: NxD matrix containing D confounds for N subjects.

% OUTPUT:
%       - r_val  :Pearson correlation between predicted target values and
%                 actual target values in validation set              
%       - weights:Fx1 matrix containing weights of the F features                
%
% ------  Ji Chen, last edited on 24-Aug-2020

x_val = x(cv_ind == fold, :);
y_val = y(cv_ind == fold);
x_train=x(cv_ind~=fold,:);
y_train=y(cv_ind~=fold);

%% z score：test 1
x_mean = mean(x_train);
x_std = std(x_train);
y_mean = mean(y_train);
y_std = std(y_train);

x_train = zscore(x_train);
y_train = zscore(y_train);

x_dev = x_val-x_mean;
for i = 1:length(x_mean)
    x_val(:,i) = x_dev(:,i)/x_std(i);
end
y_val = (y_val-y_mean)/y_std;

confounds_val = confounds(cv_ind == fold,:);
confounds_train = confounds(cv_ind ~= fold,:);

confounds_mean = mean(confounds_train(:,2:3));
confounds_std = std(confounds_train(:,2:3));

confounds_train = [confounds_train(:,1), zscore(confounds_train(:,2:3)), confounds_train(:,4)];
confounds_val = [confounds_val(:,1), (confounds_val(:,2)-confounds_mean(1))/confounds_std(1) (confounds_val(:,3)-confounds_mean(2))/confounds_std(2),confounds_val(:,4)];
DesignMatrix_train = x2fx(confounds_train,'linear',CovCateIdx);
DesignMatrix_val = x2fx(confounds_val,'linear',CovCateIdx);

[y_train, reg_y] = regress_confounds(y_train, ...
    DesignMatrix_train);
[y_val,~] = regress_confounds(y_val, DesignMatrix_val, reg_y);

[x_train, reg_x] = regress_confounds(x_train, ...
    DesignMatrix_train);
x_val = regress_confounds(x_val, DesignMatrix_val, reg_x);


%%

[nn,d]=size(x_train);

[model.rvm, model.hyperparams, model.diagnostics] = SparseBayes('Gaussian', [x_train, ones(nn,1)], y_train);

   model.weights = zeros(d,1);

   model.b = 0;
   if model.rvm.Relevant(end)==(d+1) 
     model.b = model.rvm.Value(end);
     model.weights(model.rvm.Relevant(1:end-1)) = model.rvm.Value(1:end-1);
   else
     model.weights(model.rvm.Relevant) = model.rvm.Value;
   end 
   weights=model.weights;
  
   ypred_val = x_val*model.weights + model.b;  
   
   
perf.r_val = corr(y_val, ypred_val, 'type', 'Pearson', 'Rows', 'complete');





