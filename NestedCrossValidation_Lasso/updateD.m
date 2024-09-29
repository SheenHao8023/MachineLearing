function D = updateD(w, type)

%%对每个输入特征执行权重预测
% w: v;
% type: L1-norm, GGL-norm;

if nargin == 1
    % for L1-norm
    d = 1 ./ sqrt(w .^ 2 + eps);
elseif strcmpi(type, 'GGL')
    % for GGL-norm
    [n_features, ~] = size(w);
    structure = updateGraph(n_features, 'GGL');
    Gp = 1 ./ sqrt(structure * (w .^ 2) + eps);
    d = sum(reshape(Gp, n_features - 1, []));
else
    error('Error type.');
end

D = diag(d);

function E = updateGraph(n, type)

if strcmpi(type, 'GGL')
    num = 0;
    E = zeros(n * (n - 1), n);
    for i = 1 : n
        for j = 1 : n
            if i ~= j
                num = num + 1;
                E(num, i) = 1;
                E(num, j) = 1;
            end
        end
    end
else
    error('Error type.');
end
