function [r_val, r_inval, weights, para,ypred_val1,y_val] = EN_one_fold_Ji(x, y, cv_ind, fold, n_fold, confounds, group_info,CovCateIdx)
%% Adapted from previous code
% [r_val, r_train, weights, b] = EN_one_fold(x, y, cv_ind, fold, n_fold, confounds)
% This function runs Elastic nets for one cross-validation fold. The
% relationship between features and targets is assumed to be 
% y = x * weights + b.
%
% New input:
%       - x:
%                  NxP matrix containing P features from N subjects
%       - y:
%                  NxT matrix containing T target values from N subjects
%       - cv_ind:
%                  Nx1 matrix containing cross-validation fold assignment
%                  for N subjects. Values should range from 1 to 10 for a
%                  10-fold cross-validation
%       - fold:
%                  Fold to be used as validation set 
%       - n_fold:
%                  Total number of folds
%       - confounds:
%                   NxD matrix containing D confounds for N subjects. For
%                   the default confounds now, D = 9.
%       - group_info:
%                   A vector with d rows/columes, representing grouping information of all features
%       - CovCateIdx: 
%                   A vector indicates which columns in your confound matrix are categorical variables, 
%                   Example: CovCatIdx=[1,2]
%
% New output:
%       - r_val:
%                 Pearson correlation between predicted target values and
%                 actual target values in outer-loop validation set
%       - r_inval:
%                 Pearson correlation between predicted target values and
%                 actual target values in inner-loop validation set
%       - weights:
%                 Px1 matrix containing weights of the P features
%       - para:
%                 The best lambda combination within inner-loop training
%       - ypred_val1:
%                 Predicted values of outer-loop validation set
%       - y_val:
%                 Confound-adjusted true scores of outer-loop validation
%                 set
%
% Example:
% [r_val, r_train, weights, para] = EN_one_fold(x, y, cv_ind, 1, 10, confounds, group_info, CovCateIdx)
% This command runs EN using fold 1 as validation set, and the rest as training set
% Jianxiao Wu, last edited on 28-Mar-2019

% usage
if nargin ~= 8
    disp('Usage: [r_val, r_train, weights] = EN_one_fold(x, y, cv_ind, fold, n_fold, confounds)');
end

% add glmnet library to path
%lib_path = fileparts(fileparts(fileparts(mfilename('fullpath'))));
% addpath(fullfile(lib_path, 'lib', 'glmnet_matlab'));

% set-up
% n_fold_lambda = 10; % 10-fold inner CV loop to tune lambda
% options = [];
% options.nlambda = 10;
% options.standardize = false;
[~, d] = size(x);
weights = zeros(d, 1);

% inner-loop validation set
if fold == n_fold
    fold_inner = 1;
else
    fold_inner = fold + 1;
end
x_val_inner = x(cv_ind == fold_inner, :); 
y_val_inner = y(cv_ind == fold_inner, :);

% inner-loop training set
train_ind_inner = (cv_ind ~= fold) .* (cv_ind ~= fold_inner); 
x_train_inner = x(train_ind_inner==1, :);
y_train_inner = y(train_ind_inner==1, :);

% outer-loop validation set
x_val = x(cv_ind == fold, :);
y_val = y(cv_ind == fold);

% DesignMatrixAll=x2fx(confounds, 'linear',CovCateIdx);
% confound regression
% [y_train_inner,~, reg_y] = regress_confounds_y(y_train_inner, ...
%     DesignMatrixAll(train_ind_inner==1, :));
% y_val_inner = regress_confounds_y(y_val_inner, ...
%     DesignMatrixAll(cv_ind==fold_inner, :), reg_y); 
% [y_val,yhat] = regress_confounds_y(y_val, DesignMatrixAll(cv_ind==fold, :), reg_y); 
% 
% [x_train_inner, reg_x] = regress_confounds_x(x_train_inner, ...
%     DesignMatrixAll(train_ind_inner==1, :));
% x_val_inner = regress_confounds_x(x_val_inner, ...
%     DesignMatrixAll(cv_ind==fold_inner, :), reg_x);
% x_val = regress_confounds_x(x_val, DesignMatrixAll(cv_ind==fold, :), reg_x);

% preparation for abc_regression
train_inner.Y = x_train_inner;
train_inner.z = y_train_inner;
test_inner.Y = x_val_inner;
test_inner.z = y_val_inner;

% select best alpha value with inner-loop cross-validation
% see sklearn.linear_model.ElasticNetCV for list of alpha values
% an alpha value of 0.01 is added based on Dubois et al. 2018
parameters = [0.0001 0.001 0.01 0.1 1 10 100 1000];
[lambda1, lambda2] = ndgrid(parameters);
Index = [lambda1(:) lambda2(:)];

parfor para_com = 1:size(Index,1) % [0.01 0.1 0.5 0.7 0.9 0.95 0.99 1]
    lambda1 = Index(para_com, 1);
    lambda2 = Index(para_com, 2);
%    lambda3 = Index(para_com, 3);
    
    % train model and fetch parameters
    [V_Reg,~,~,~] = abc_regression(train_inner, lambda1, lambda2, group_info);
    V_Regall{para_com, 1} = V_Reg;
end

for para_com1 = 1:size(Index,1)
    % inner-loop validation
    tr1_Reg(para_com1,1) = get_corr(train_inner, V_Regall{para_com1,1});
    te1_Reg(para_com1,1) = get_corr(test_inner, V_Regall{para_com1,1});
    
    % initialise best model
    if para_com1 ==1
        r_inval = te1_Reg(1,1);
        weights = V_Regall{1,1};
        para_best = Index(1,:);
    end
    %     if alpha == 0.0001 % 0.01
    %         r_train = r_curr;
    %         weights = fit.glmnet_fit.beta(:, ind);
    %         b = fit.glmnet_fit.a0(ind);
    %         alpha_best = alpha;
    %     end
    
    % update best model if needed
    if te1_Reg(para_com1,1) > r_inval
        r_inval = te1_Reg(para_com1,1);
        weights = V_Regall{para_com1,1};
        para_best = Index(para_com1,:);
    end
end
para = para_best;

% outer-loop validation
ypred_val1 = x_val * weights;
%ypred_val = ypred_val1 + yhat;
r_val = corr(y_val, ypred_val1, 'type', 'Pearson', 'Rows', 'complete');
% ypred_val1 = x_val * weights + b;
% ypred_val= ypred_val1+yhat;
% r_val = corr(y_val+yhat, ypred_val, 'type', 'Pearson', 'Rows', 'complete');
