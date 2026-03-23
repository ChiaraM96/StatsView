function [limits, varargout] = boxchart_limits(varargin)

yData = [];
xData = [];
ax = [];
currLims = [nan nan];

for i = 1:2:nargin - 1
    var = char(lower(varargin{i}));
    val = varargin{i + 1};
    switch var
        case {'xdata', 'x'}
            xData = val(:);
        case {'ydata', 'y'}
            yData = val(:);
        case {'ax', 'axis'}
            ax = val;
        case {'currlim', 'limits', 'currentlimits', 'lim'}
            currLims = var;
    end
end



if isempty(yData) && ~isempty(ax)
    if ~isempty(ax)
        yData = findobj(ax, '-property', 'YData').YData;
    end
end
if isempty(xData)
    if ~isempty(ax)
        xData = findobj(ax, '-property', 'YData').XData;
    else
        xData = ones(size(yData));
    end
end


limFun = @(x) [ max([nan, min(x(x > - 1.5*diff(quantile(x, [.25 .75])) + quantile(x, .25)), [], 'omitnan')]),...
                max([nan, max(x(x < 1.5*diff(quantile(x, [.25 .75])) + quantile(x, .75)), [], 'omitnan')])];
% minLimFun = @(x) max([nan, min(x(x > - 1.5*diff(quantile(x, [.25 .75])) + quantile(x, .25)), [], 'omitnan')]);


% xCats = unique(xData);

xData = xData(:);
yData = yData(:);

limits = splitapply(limFun, yData, findgroups(xData));

limits = [1 - .1*sign(min(limits(:, 1)) - 1e-10) 1 + .1*sign(max(limits(:, 2)) + 1e-10)].*[min(limits(:, 1)), max(limits(:, 2))];

nulLims = find(limits == 0);
limits(nulLims) = limits(nulLims) + sign(nulLims - 1.5)*range(limits)/15;


% for xCat = xCats(:)'
%     boxLimits(xCat, :) = quantile(yData(xData == xCat), [.25 .75], 1);
%     IQR(xCat) = diff(boxLimits(xCat, :));
%     upperLimit(xCat) = boxLimits(xCat, 2) + 1.5*IQR(xCat);
%     lowerLimit(xCat) = boxLimits(xCat, 1) - 1.5*IQR(xCat);
%     upperLimit(xCat) = max(yData(xData == xCat & yData <= upperLimit(xCat)));
%     lowerLimit(xCat) = min(yData(xData == xCat & yData >= lowerLimit(xCat)));
%     % medianLine(xCat, 1) = median(yData(xData == xCat), 'omitnan');
% end

% boxLimits = quantile(yData, [.25 .75], 1);
% IQR = diff(boxLimits, 1, 2);
% upperLimit = boxLimits(:, 2) + IQR*1.5;        % a bit higher than the upper whisker
% lowerLimit = boxLimits(:, 1) - IQR*1.5;        % a bit lower than the lower whisker


% upperLimit = medianLine + IQR*2.5;        % a bit higher than the upper whisker
% lowerLimit = medianLine - IQR*1.75;        % a bit lower than the lower whisker
limits = [max(min(limits(:, 1)), currLims(1)), min(max(limits(:, 2)), currLims(2))];

if ~isempty(ax)
    ax.YLim = limits;
    varargout{1} = ax;
end

% lim_temp = nan(size(boxLimits));
% % index_min = data_to_plot > temp(1, :) - IQR*1.5; index_max =
% % data_to_plot < temp(2, :) + IQR*1.5;
% index_inside = xData > boxLimits(1, :) - IQR*1.5 & xData < boxLimits(2, :) + IQR*1.5;
% for i = 1 : width(index_inside)
%     lim_temp(1, i) = min(xData(index_inside(:, i), i));
%     lim_temp(2, i) = max(xData(index_inside(:, i), i));
% end
% % temp_min = median(data_to_plot, 'omitnan') - 1.57 * IQR ./
% % sqrt(sum(~isnan(data_to_plot))); temp_max = median(data_to_plot,
% % 'omitnan') + 1.57 * IQR ./ sqrt(sum(~isnan(data_to_plot)));
% lim = [min(lim_temp(1, :)), max(lim_temp(2, :))];
end