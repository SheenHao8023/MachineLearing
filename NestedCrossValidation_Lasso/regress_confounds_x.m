function [x, reg_x] = regress_confounds_x(x, DesignMatrix, existing_reg)
% [y, reg_y] = regress_confounds_y(y, confounds, existing_reg)
%
% This function regresses out confounds from prediction targets y. For
% training data, pass in y and the confounds to perform regression,
% obtaining the new y and regression coefficients reg_y. For validation
% data, also pass in the regression coefficients obtained from the training
% data. Basically, regression coefficients should be estimated using only
% training data, and applied to both training and validation data.
%
% Inputs:
%       - y           :
%                      NxT matrix containing T target values from N subjects
%       - confounds   :
%                      NxD matrix containing D confounds for N subjects.
%       - existing_reg:
%                      (Optional) Existing regression coefficients to use
%                      for regressing out confounds in validation set.
%
% Output:
%        - y    :
%                NxT matrix containing the target values with
%                confounds removed
%        - reg_y:
%                (D+1)xT array containing the regression coefficient for
%                each confound. The last element correspond to the offset,
%                i.e. a confound of constant 1.
%
% Example:
% 1) [y_train, reg_y] = regress_confounds_y(y_train, confounds)
%    This command regresses out confounds from the training targets, also
%    returning the regression coefficients
% 2) y_val = regress_confounds_y(y_val, confounds, reg_y)
%    This command regresses out confounds from the validation targets,
%    using the regression coefficients previously determined based on
%    training data
%
% Jianxiao Wu, last edited on 18-Mar-2018

% set up
t = size(x, 2);
n = size(x, 1);
d = size(DesignMatrix, 2);
reg_x=cell(t);xhat=nan(n,t);
% perform regression
if nargin < 3
    % for training set
    %reg_x = zeros(d+1, t);
    reg_x=cell(t,1);
    for target = 1:t
        [reg_x{target}, ~, x(:, target)] = regress(x(:,target), DesignMatrix);
    end
else
    % for validation set
%     y = y - [confounds, ones(n, 1)] * existing_reg;
%     reg_y = existing_reg;
    
    for ith_col=1:t
    for nn=1:n
     xhat(nn,ith_col) =  sum(existing_reg{ith_col}'.*DesignMatrix(nn,:));
    end
    end
     x=x-xhat;
end
   
    
end
