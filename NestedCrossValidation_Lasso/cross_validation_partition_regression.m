% generate cross validation partition(s),重复m次的k-折分配折编号矩阵（n * m）
% y : labels vector
% k : number of folds
% m : number of repeats
% check_test_set: flag that checks if test set has all class labels
% stratified : flag that sets stratified partitioning
% returns a maatrix with partitions, each column is one CV
% with each entry as id of the fold
% Kaustubh Patil, 15 Feb 2018, Research Center Juelich

function CVindices = cross_validation_partition_regression(y, k, m)

n = length(y);
CVindices = nan(n,m);
% get the corss-validation indices
for ith_repeat = 1:m
  ith_partition = cvpartition(n,'KFold',k);
  for ith_fold=1:k
    j = ith_partition.test(ith_fold);
    CVindices(j,ith_repeat) = ith_fold;
  end
end % ith_repeat

