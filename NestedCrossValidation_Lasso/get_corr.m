% calculate corr
function [corr1] = get_corr(idata, V)

z = idata.z;
Y = idata.Y;
corr1 = corr(z, Y * V);%

