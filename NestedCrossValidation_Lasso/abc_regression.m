function [V,v1,v2,obj] = abc_regression(trainData, lambda1, lambda2, group_info)
% --------------------------------------------------------------------
% reg using L1 grouplasso ggl penalty
% --------------------------------------------------------------------
% --------------------------------------------------------------------

Y = trainData.Y; % 病人×总特征数
Z = trainData.z; % 病人认知得分
% Y = getNormalization(Y);
% Z = getNormalization(Z);
p = size(Y,2);
% Initialization
v0 = ones(p, 1);
v1 = v0;
v2 = v0;

% set group information
pheno_group_idx = group_info.pheno_group_idx;
pheno_group_set = unique(pheno_group_idx);
pheno_group_num = length(pheno_group_set);

% set parameters
% lambda1 = lambda1; 
% lambda2 = lambda2; 
% lambda3 = lambda3; 

% set stopping criteria
max_Iter = 30;
t = 0;
tol = 1e-5;
obj = [];
tv = inf;

% set group information

while (t<max_Iter && tv>tol) % default 100 times of iteration
    t = t+1;
    % update v
    % -------------------------------------  
    D1 = updateD(v1); 
    % update the structure
%     D3 = updateD(v3,'GGL');
    
    % update Dgroup
    for pheno_c = 1:pheno_group_num
        pheno_idx = find(pheno_group_idx == pheno_group_set(pheno_c));
        wc2 = v2(pheno_idx, :);
        pheno_di = sqrt(sum(sum(wc2.*wc2))+eps);
        pheno_wi(pheno_idx) = pheno_di;
    end
    d2 = 0.5 ./ pheno_wi;
    D2 = diag(d2);   
 
    % solve v1
    v1_old = v1;
    F1 = 2*Y'*Y+lambda1*D1;
    b1 = Y'*Z-Y'*Y*v2;
%     b1 = Y'*Z-Y'*Y*v2-Y'*Y*v3;
    v1 = F1\b1;
    
    % solve v2
    v2_old = v2;
    F2 = 2*Y'*Y+lambda2*D2;
    b2 = Y'*Z-Y'*Y*v1;
%     b2 = Y'*Z-Y'*Y*v1-Y'*Y*v3;
    v2 = F2\b2;
   
    % solve v3
%     v3_old = v3;
%     F3 = 2*Y'*Y+lambda3*D3;
%     b3 = Y'*Z-Y'*Y*v1-Y'*Y*v2;
%     v3 = F3\b3;
    
 % stopping condition
    if t > 1
        tv1 = max(abs(v1-v1_old));
        tv2 = max(abs(v2-v2_old));
%         tv3 = max(abs(v3-v3_old));
    else
        tv1 = tol*10;
        tv2 = tol*10;
%         tv3 = tol*10;
    end
end
V = v1+ v2;
end