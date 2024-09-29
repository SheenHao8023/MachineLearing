
YPredMedians = median(TrueResult{2,5}.YPredAll, 2);
YTrueMedians = median(TrueResult{2,5}.YTrueAll, 2);


lm = fitlm(YPredMedians, YTrueMedians);


figure;
scatter(YPredMedians, YTrueMedians, 'filled');
xlabel('Predicted Scores');
ylabel('True Scores');
title('intermediate-Factor5');
grid on;
hold on;

x1 = linspace(min(YPredMedians), max(YPredMedians), 100)';
[y_pred, ci] = predict(lm, x1);


plot(x1, y_pred, 'b-', 'LineWidth', 2);


x2 = [x1; flipud(x1)];
inBetween = [ci(:,1); flipud(ci(:,2))];
fill(x2, inBetween, 'b', 'FaceAlpha', 0.1, 'EdgeColor', 'none');


R = corr(YPredMedians, YTrueMedians);
text(mean(x1), max(ci(:,2)), sprintf('R = %.2f', R(1,2)), 'FontSize', 12, 'Color', 'b');


yticks(-2:1:4);

hold off;
