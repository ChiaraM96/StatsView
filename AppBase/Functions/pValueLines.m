function pValueLines(p_table, data, varargin)

% arguments
%     p_table table
%     data
%     % responseVar
%     % ax = gca()
%     % design = 'paired'
%     % offset = 0
%     % betweenVar = 'betweenVar'
%     % withinVar = 'withinVar'
%     % location = 'above'
%     % nGroup = 1
% end
try
p = inputParser;
expectedDesign = {'stratified', 'paired', 'unpaired', 'mixed'};

addRequired(p, 'p_table', @istable)
addRequired(p, 'data')
addParameter(p, 'responseVar', @isvarname)
addParameter(p, 'ax', @isobject)
addParameter(p, 'offset', 0, @isscalar)
addParameter(p, 'betweenVar', 'betweenVar')
addParameter(p, 'withinVar', 'withinVar')
addParameter(p, 'design', 'paired', @(x) any(validatestring(x, expectedDesign)))

parse(p, p_table, data, varargin{:})
% addParameter(p, 'location', 'above')
ax = p.Results.ax;
design = p.Results.design;
if ~isempty(p.Results.withinVar)
    withinVar = p.Results.withinVar;
    v_temp = contains(p_table.Properties.VariableNames, 'Condition');
    if ~all(strcmp(p_table.Properties.VariableTypes(v_temp), 'categorical'))
        cats = unique(reshape(p_table(:, v_temp).Variables, 1, []));
        for v = find(v_temp)
            p_table.(v) = categorical(p_table.(v), cats);
        end
    end
else
    withinVar = 'withinVar';
end
if ~isempty(p.Results.betweenVar)
    betweenVar = p.Results.betweenVar;
    v_temp = contains(p_table.Properties.VariableNames, 'Condition');
    if ~all(strcmp(p_table.Properties.VariableTypes(v_temp), 'categorical'))
        cats = unique(reshape(p_table(:, v_temp).Variables, 1, []));
        for v = find(v_temp)
            p_table.(v) = categorical(p_table.(v), cats);
        end
    end
else
    betweenVar = 'betweenVar';
end
offset = p.Results.offset;
responseVar = p.Results.responseVar;


% if isempty(betweenVar)
%     betweenVar = 'betweenVar';
% end

try
    p_table = p_table(p_table.p < 0.05, :);
catch
    vars = string(p_table.Properties.VariableNames);
    p_table = renamevars(p_table, vars(contains(lower(vars), {'pvalue', 'pval'}) & ~contains(lower(vars), 'raw')), 'p');
    p_table = p_table(p_table.p < 0.05, :);
end

if ~height(p_table)
    return
end



yFun75 = @(x) max([nan, max(x(x < 1.5*diff(quantile(x, [.25 .75])) + quantile(x, .75)), [], 'omitnan')]);
yFun25 = @(x) max([nan, min(x(x > - 1.5*diff(quantile(x, [.25 .75])) + quantile(x, .25)), [], 'omitnan')]);

switch design
    case 'paired'
        % table should have withinCondition1, withinCondition2, p
        nConditions = 1;
        Conditions = ones(height(p_table), 1);
        data.(betweenVar) = categorical(ones(height(data), 1));
        p_table.betweenCondition = Conditions;
        try
            lineColors = repmat(rgb2hex(findobj(ax, 'type', 'BoxChart').BoxFaceColor), size(Conditions));
        catch
            lineColors = repmat('k', size(Conditions));
        end
        % lineColors = rgb2hex(lines(nConditions));
    case 'unpaired'
        % table should have betweenCondition1, betweenCondition2, p
        nConditions = 1;
        Conditions = ones(height(p_table), 1);
        data.(withinVar) = categorical(ones(height(data), 1));
        p_table.withinCondition = Conditions;
        lineColors = repmat('k', nConditions);
    case 'mixed'
        % table should have betweenCondition, withinCondition1, withinCondition2, p
        Conditions = double(p_table.betweenCondition);
        nConditions = numel(categories(p_table.betweenCondition));
        lineColors = rgb2hex(lines(nConditions)); % Generate distinct colors for each betweenCondition
    case 'stratified'
        % table should have withinCondition, betweenCondition2, betweenCondition2
        Conditions = double(p_table.withinCondition);
        nConditions = numel(categories(p_table.withinCondition));
        lineColors = repmat('k', nConditions);
        % lineColors = repmat(rgb2hex(findobj(gca(), 'type', 'BoxChart').BoxFaceColor), size(Conditions));  
end

Y = removevars(rmmissing(groupsummary(data, {char(withinVar), char(betweenVar)}, {yFun25, yFun75}, responseVar)), "GroupCount");
Y.Properties.RowNames = string(string(Y.(betweenVar)) + string(Y.(withinVar)));
Y.Properties.VariableNames(3:4) = [{'quantile25'}, {'quantile75'}];

switch design
    case 'stratified'
        x = string([p_table.betweenCondition1 p_table.betweenCondition1 p_table.betweenCondition2 p_table.betweenCondition2]) + string(p_table.withinCondition);
        y = reshape(Y(x, 'quantile25').Variables, [], 4);
        x = repmat(double(p_table.withinCondition), 1, 4);
        x(:, 1:2) = x(:, 1:2) + offset*(double(p_table.betweenCondition1) - median(1:numunique(categories(p_table.betweenCondition1))));
        x(:, 3:4) = x(:, 3:4) + offset*(double(p_table.betweenCondition2) - median(1:numunique(categories(p_table.betweenCondition2))));
        up = -1;
        text_offset = 0;
        step_var = range(Y(:, 'quantile25').Variables)/8;

    case 'unpaired' % between
        x = string([p_table.betweenCondition1 p_table.betweenCondition1 p_table.betweenCondition2 p_table.betweenCondition2]) + string(p_table.withinCondition);
        y = reshape(Y(x, 'quantile25').Variables, [], 4);
        x = double([p_table.betweenCondition1 p_table.betweenCondition1 p_table.betweenCondition2 p_table.betweenCondition2]);
        x(:, 1:2) = x(:, 1:2) + offset*(double(p_table.betweenCondition1) - median(1:numunique(categories(p_table.betweenCondition2))));
        x(:, 3:4) = x(:, 3:4) + offset*(double(p_table.betweenCondition1) - median(1:numunique(categories(p_table.betweenCondition2))));
        up = -1;
        text_offset = 0;
        step_var = range(Y(:, 'quantile25').Variables)/8;

    case 'mixed'
        x = string(p_table.betweenCondition) + string([p_table.withinCondition1 p_table.withinCondition1 p_table.withinCondition2 p_table.withinCondition2]);
        y = reshape(Y(x, 'quantile75').Variables, [], 4);
        x = [p_table.withinCondition1 p_table.withinCondition1 p_table.withinCondition2 p_table.withinCondition2];
        x = double(x) + offset*(Conditions - mean(1:nConditions));
        up = 1;
        text_offset = median(diff(double(ax.XTick)))/10;
        step_var = range(Y(:, 'quantile75').Variables)/8;

    case 'paired'
        x = [p_table.withinCondition1 p_table.withinCondition1 p_table.withinCondition2 p_table.withinCondition2];
        y = reshape(Y(string(p_table.betweenCondition) + string(x), 'quantile75').Variables, [], 4);
        x = double(x) + offset*(Conditions - mean(1:nConditions));
        up = 1;
        text_offset = median(diff(double(ax.XTick)))/10;
        % step_var = range(Y(:, 'quantile75').Variables)/8;
        step_var =  mean(Y(:, 'quantile75').Variables - Y(:, 'quantile25').Variables) / 8;

end

lso = {'--', ':', '-.'};
linestyleorder(ax, lso);
% if ismember(design, ["paired", "mixed"])
%     up = 1;
%     text_offset = median(diff(double(ax.XTick)))/10;
% else
%     up = -1;
%     text_offset = 0;
% end
% if ismember('betweenCondition', p_table.Properties.VariableNames)
%     betweenConditions = findgroups(p_table.betweenCondition);
%     nBetweenConditions = numel(categories(p_table.betweenCondition));
     % Generate distinct colors for each betweenCondition
% else
%     nBetweenConditions = 1;
%     betweenConditions = ones(height(data), 1);
%     data.betweenVar = betweenConditions;
%     p_table.betweenCondition = ones(height(p_table), 1);
% end
% if ismember('withinCondition1', p_table.Properties.VariableNames)
%     withinConditions = categories(p_table.withinCondition1);
% else
%     p_table.withinCondition1 = ones(height(p_table), 1);
%     p_table.withinCondition2 = ones(height(p_table), 1);
% end
%
% Y = removevars(rmmissing(groupsummary(data, {char(withinVar), char(betweenVar)}, {yFun25, yFun75}, responseVar)), "GroupCount");
% Y.Scenario = findgroups(string(Y.(betweenVar)) + string(Y.(withinVar)));
% % Y_between.Properties.RowNames = string(Y_between.Scenario)
% Y.Properties.RowNames = string(string(Y.(betweenVar)) + string(Y.(withinVar)));
% Y.Properties.VariableNames(3:4) = [{'quantile25'}, {'quantile75'}];
% Y_between.Scenario =
% switch design
%     case 'paired'
%         x = [p_table.withinCondition1 p_table.withinCondition1 p_table.withinCondition2 p_table.withinCondition2];
%     case 'unpaired'
%
%     case 'mixed'
%         if strcmp(design, 'paired')
%             x = [p_table.withinCondition1 p_table.withinCondition1 p_table.withinCondition2 p_table.withinCondition2];
%             y = reshape(Y(string(x) + string(p_table.betweenCondition), 'quantile75').Variables, [], 4);
%             x = double(x) + offset*(betweenConditions - mean(1:nBetweenConditions));
%         elseif strcmp(design, 'unpaired')
%             try
%                 x = string([p_table.withinCondition1 p_table.withinCondition1 p_table.withinCondition2 p_table.withinCondition2]) + string(p_table.betweenCondition);
%                 y = reshape(Y(x, 'quantile25').Variables, [], 4);
%             catch
%                 x = string(p_table.betweenCondition) + string([p_table.withinCondition1 p_table.withinCondition1 p_table.withinCondition2 p_table.withinCondition2]);
%                 y = reshape(Y(x, 'quantile25').Variables, [], 4);
%             end
%             if nBetweenConditions > 1
%                 x = repmat(double(p_table.betweenCondition), 1, 4);
%             else
%                 x = findgroups([p_table.withinCondition1 p_table.withinCondition1 p_table.withinCondition2 p_table.withinCondition2]);
%             end
%
%             x(:, 1:2) = x(:, 1:2) + offset*(double(p_table.withinCondition1) - median(1:numunique(categories(p_table.withinCondition1))));
%             x(:, 3:4) = x(:, 3:4) + offset*(double(p_table.withinCondition2) - median(1:numunique(categories(p_table.withinCondition2))));
%         elseif strcmp(design, 'mixed')
%             x = string(p_table.betweenCondition) + string([p_table.withinCondition1 p_table.withinCondition1 p_table.withinCondition2 p_table.withinCondition2]);
%             y = reshape(Y(x, 'quantile75').Variables, [], 4);
%             x = [p_table.withinCondition1 p_table.withinCondition1 p_table.withinCondition2 p_table.withinCondition2];
%             x = double(x) + offset*(betweenConditions - mean(1:nBetweenConditions));
%         end
%
%
%
%         linestyleorder(ax, lso);
%         step_var = range(Y(:, 'quantile75').Variables)/8;
%         if ismember(design, ["paired", "mixed"])
%             up = 1;
%             text_offset = median(diff(double(ax.XTick)))/10;
%         else
%             up = -1;
%             text_offset = 0;
%         end
% end

for k = 1:height(p_table)
    x_temp = x(k, :);
    y_temp(k, :) = y(k, :) + up * step_var;
    if ismember(design, ["paired", "mixed"])
        y_temp(k, 2:3) = max(max(y, [], 'omitnan'), [], 'omitnan');
        y_temp(k, 2:3) = y_temp(k, 2:3) .*  (1 + sign(y_temp(k, 2:3))* .1) + up * step_var * k;
        y_text = max(y_temp(k, :));
    else
        if any(y_temp(k, 2:3) <= 0)
            y_temp(k, 2:3) =  min([ - step_var, min(min(y(Conditions == Conditions(k), :), [], 'omitnan'), [], 'omitnan')]);
        else
            y_temp(k, 2:3) =  min(min(y(Conditions == Conditions(k), :), [], 'omitnan'));
        end
        group_count = sum(Conditions(1:k) == Conditions(k));
        y_temp(k, 2:3) = y_temp(k, 2:3) .* (1 - sign(y_temp(k, 2:3))* .1) + up * step_var * group_count;
        y_text = min(y_temp(k, :));
    end
    hold(ax, 'on');

    if strcmp(design, 'unpaired')
        lineColor = 'k';
        va = 'bottom';
        ha = 'center';
        x_text = mean(x_temp);
    else
        lineColor = lineColors(Conditions(k));
        x_text = min(x_temp) + text_offset;
        va = 'top';
        ha = 'left';
    end

    plot(ax, x_temp, y_temp(k, :), 'color', lineColor, 'linewidth', 2, 'HandleVisibility', 'off')
    text(ax, x_text, ...
        y_text, ...
        sprintf('p = %.2e', p_table.p(k)), ...
        'HorizontalAlignment', ha, ...
        'VerticalAlignment', va, ...
        'Color', lineColor);

end
ylim = ax.YLim;
if ismember(design, ["paired", "mixed"])
    ylim(2) = max([ylim(2), max(max(y_temp)) + 2*step_var]);
else
    ylim(1) = min([ylim(1), min(min(y_temp)) - 2*step_var]);
end
ax.YLim = ylim;

catch ME
    disp(getReport(ME))
end

end
