function [b, v] = boxplotting(data, varargin)

xVar = [];
yVar = [];
midline_method = 'MEDIAN';
units = "";
titleString = inputname(1);
betweenVariable = [];
p_table = struct();
p_table.unpaired = [];
p_table.paired = [];
p_table.mixed = [];
p_table.stratified = [];
design = [];
separateColors = false;
isAngle = false;
ax = [];
plotType = {'box'};
groupBy = "";
sameAx = false;
            
if istable(data)
    xVarNames = [];
else
    xVarNames = string(1:width(data));
end

for i = 1:2:nargin - 1
    varName = lower(varargin{i});
    varValue = varargin{i + 1};
    switch varName
        case "xvarnames"
            xVarNames = varValue;
        case "midlinemethod"
            midline_method = upper(varValue);
        case "units"
            units = varValue;
        case "title"
            titleString = varValue;
        case {'x', 'withinvar'}
            xVar = string(varValue);
            if contains(lower(inputname(i + 2)), 'between')  % input 1 is data, input 1+(1:2:end) is varName, input 2+(1:2:end) is varValue, we need varValue's original name. 
                separateColors = true;
            end
        case "groupby"
            groupBy = varValue;
        case "y"
            yVar = string(varValue);
        case {'groupby', 'betweenvar'}
            betweenVariable = varValue;
            if (istable(data) && ~ismember(varValue, data.Properties.VariableNames)) || (~istable(data) && (uint64(varValue) < 0 || uint64(varValue) < width(data)))
                warning('Invalid group variable: %s', varValue);
                betweenVariable = [];
            end
        case {'ptable', 'punpaired'}
            p_table.unpaired = varValue;
            separateColors = true;
        case {'pttest', 'pstratified'}
            p_table.stratified = varValue;
        case 'pmixed'
            p_table.mixed = varValue;
            % if strcmp(varName, 'punpaired')
            %     design = 'unpaired';
            % elseif strcmp(varName, 'pmixed')
            %     design = 'mixed';
            % end
        case {'ppaired'}
            p_table.paired = varValue;
        case {'isangle'}
            isAngle = varValue;
        case {'axes'}
            ax = varValue;
        case {'plottype'}
            plotType = varValue;
        case {'sameax'}
            sameAx = true;
    end
end
if isempty(ax)
    figure;
    ax = gca();
end
if isempty(plotType)
    plotType = {'box'};
end
if isempty(xVarNames) && ~isempty(betweenVariable)
    xVarNames = rmmissing(string(unique(data.(betweenVariable))))';
elseif isempty(xVarNames) && ~isempty(xVar) && istable(data)
    xVarNames = rmmissing(string(unique(data.(xVar)))');
end


if istable(data)
    if ~isempty(betweenVariable) && ~isempty(intersect(string(data.Properties.VariableNames), xVarNames))
        % table is not stacked
        dataTemp = rmmissing(stack(data, xVarNames, 'NewDataVariableName', 'yData', 'indexVariableName', 'xData'));
        betweenData = dataTemp.(betweenVariable);
    elseif ~isempty(betweenVariable)
        dataTemp = rmmissing(table(data.(betweenVariable), data.(xVar), data.(yVar), 'variablenames', {char(betweenVariable), 'xData', 'yData'}));
        betweenData = dataTemp.(betweenVariable);
        xVarNames = string(unique(dataTemp.xData))';
    elseif ~isempty(xVar) && ~isempty(yVar)
        betweenData = [];
        dataTemp = table(data.(xVar), data.(yVar), 'VariableNames', {'xData', 'yData'});
    end
else
    if ~isempty(betweenVariable)
        betweenData = data(:, betweenVariable);
    else
        betweenData = [];
    end
    data = array2table(data, 'VariableNames', xVarNames);
    dataTemp = stack(data, xVarNames, 'NewDataVariableName', 'yData', 'indexVariableName', 'xData');
end

dataTemp = rmmissing(dataTemp);
xData = dataTemp.xData;
if iscategorical(xData)
    xData = removecats(xData);
    if sameAx
        xData = double(xData);
    end
end
yData = dataTemp.yData;

clearvars dataTemp

if ~isempty(betweenVariable)
    betweenConditions = unique(betweenData);
    nBetweenConditions = length(betweenConditions);
else
    nBetweenConditions = 1;
end

midLine = struct();

betweenvars = {'xData', 'betweenData'};
datavars = 'yData';
if ~isAngle
    midline_method = string(lower(midline_method));
else
    midline_method = @(x) wrapToPi(angle_mean(x));
end
midline_method = midline_method(:)';

if ~strcmp(groupBy, "")
    if ~iscategorical(data.(groupBy))
        data.(groupBy) = categorical(data.(groupBy));
    end
    groups = double(data.(groupBy));
else
    groups = ones(size(yData));
end


if ~isAngle
if isempty(betweenData)
    for method = midline_method
        try
            midLine.(method) = groupsummary(table(xData, yData), 'xData', method);
            midLine.(method) = sortrows(removevars(midLine.(method), 'GroupCount'), 'xData', 'ascend');
            midLine.(method) = renamevars(midLine.(method), midLine.(method).Properties.VariableNames(end), yVar);
            midLine.(method).Properties.RowNames = string(midLine.(method).xData);
            midLine.(method) = removevars(midLine.(method), 'xData');%
        catch ME
        end
    end
else
    for method = midline_method
        midLine.(method) = groupsummary(table(xData, yData, betweenData), betweenvars, method, datavars);
        midLine.(method) = sortrows(unstack(removevars(midLine.(method), 'GroupCount'), midLine.(method).Properties.VariableNames(end), 'xData', 'VariableNamingRule','preserve'), 'betweenData', 'ascend');
        % try
        midLine.(method).Properties.RowNames = string(midLine.(method).betweenData);
        % catch
        %     midLine.(method).Properties.RowNames = string
        midLine.(method) = removevars(midLine.(method), 'betweenData');%
    end
end
end
% clf;
% cla(ax);
hold(ax, 'on');
if isempty(betweenData)
    % b = boxchart(xData, yData);
    xPosX = unique(findgroups(categorical(xData)));
    if separateColors
        if any(contains(plotType, 'box'))
            b = boxchart(ax, xData, yData, 'GroupByColor', xData, 'ColorGroupLayout','overlaid');
        end
        if any(contains(plotType, 'violin'))
            v = violinplot(ax, xData, yData, 'GroupByColor', xData, 'ColorGroupLayout','overlaid', 'EdgeColor', 'none', 'handlevisibility', 'callback', 'DensityScale', 'count');
            arrayfun(@(x, y) set(x, 'facecolor', y), v(:), rgb2hex(lines(numunique(xData))));
        end
        betweenCounts = groupsummary(groupsummary(data, setdiff(data.Properties.VariableNames, [yVar, "ID"]),'IncludeMissingGroups',false), xVar, @max, 'GroupCount');
        xLabels = string(betweenCounts.(xVar)) + " (N = " + string(betweenCounts.fun1_GroupCount) + ")";
    else
        c = "#808080";
        if any(contains(plotType, 'box'))
            b = boxchart(ax, xData, yData, 'BoxFaceColor', c, 'BoxEdgeColor', c, 'BoxMedianLineColor', c, 'MarkerColor', c, 'handlevisibility', 'callback');
        end
        if any(contains(plotType, 'violin'))
            v = violinplot(ax, xData, yData, 'FaceColor', c, 'EdgeColor', 'none', 'handlevisibility', 'callback', 'DensityScale', 'count');
            if numunique(groups) > 1
                v.DensityDirection = "positive";
                for group = unique(groups(:)')
                   v2(group) = violinplot(ax, xData(groups == group), yData(groups == group), 'EdgeColor', 'none', 'handlevisibility', 'off', 'DensityDirection', 'negative', 'DensityScale', 'count');
                   v2(group).DensityWidth = v.DensityWidth * sum(groups == group) / numel(groups);
                end
                arrayfun(@(x, y) set(x, 'facecolor', y), v2(:), rgb2hex(lines(numunique(groups))))
            end
        end
            % xLabels = strcat(xVar, " ", string(unique(xData)));
        xLabels = string(unique(xData));
    end
else
    if any(contains(plotType, 'box'))
        b = boxchart(ax, xData, yData, 'GroupByColor', betweenData);
    end
    if any(contains(plotType, 'violin'))
        v = violinplot(ax, xData, yData, 'GroupByColor', betweenData, 'EdgeColor', 'none', 'handlevisibility', 'callback', 'DensityScale', 'count');
    end
    betweenCounts = groupsummary(groupsummary(data, {char(xVar), char(betweenVariable)}), betweenVariable, @max, 'GroupCount', 'IncludeMissingGroups',false);
    legend(ax, betweenVariable + ": " + string(betweenCounts.(betweenVariable)) + " (N = " + string(betweenCounts.fun1_GroupCount) + ")")
    xPosX = findgroups(categorical(xVarNames, xVarNames, 'ordinal', true));
    if any(contains(plotType, 'box'))
        arrayfun(@(x, y) set(x, 'boxfacecolor', y), b, rgb2hex(lines(numunique(betweenData))));
    end
    if any(contains(plotType, 'violin'))
        arrayfun(@(x, y) set(x, 'facecolor', y), v(:), rgb2hex(lines(numunique(betweenData))));
    end
    % xLabels = strcat(xVar, " ", string(unique(xData)));
    xLabels = string(unique(xData));
end
if ~exist('b', 'var')
    b = [];
    for n = 1:nBetweenConditions
        b(n).MarkerColor = v(n).FaceColor;
        b(n).MarkerSize = 4;
    end
end
xPosX = xPosX(:)';
% ax = gca();
ax.XAxis.TickLabelInterpreter = 'none';
xticklabels(ax, xLabels);
xlabel(ax, xVar, 'Interpreter', 'none');
title(ax, titleString, 'interpreter', 'none');

if nBetweenConditions > 1
    offset = ax.Children(1).ColorGroupWidth/(nBetweenConditions);
else
    offset = 0;
end

linestyleorder(ax, 'mixedstyles')
for nBetweenCondition = 1:nBetweenConditions
    xPos(nBetweenCondition, :) = xPosX(:)' + offset*(nBetweenCondition - mean(1:nBetweenConditions));
    for method = midline_method
        if ~isempty(midLine.(method))
            if ~isempty(betweenVariable)
                yVal =  table2array(midLine.(method)(nBetweenCondition, xVarNames));
            else
                yVal =  table2array(midLine.(method)(:, yVar));
            end
            if nBetweenConditions > 1
                plot(ax, xPos(nBetweenCondition, :), yVal, 'marker', 'x', 'MarkerSize', b(nBetweenCondition).MarkerSize, 'LineWidth', 2, 'color', b(nBetweenCondition).MarkerColor, 'displayname', method + " - " + string(betweenConditions(nBetweenCondition)));
            else
                plot(ax, xPos(nBetweenCondition, :), yVal, 'marker', 'x', 'MarkerSize', b(nBetweenCondition).MarkerSize, 'LineWidth', 2, 'color', b(nBetweenCondition).MarkerColor, 'displayname', method);
            end
        end
    end
end

ylabel(ax, units)
fontsize(ax, 15, 'points')
legend(ax)
try
    boxchart_limits('x', xData, 'y', yData, 'ax', ax);
catch ME

end

% if nBetweenConditions == 1
%     if ~isempty(p_unpaired)
%         p_unpaired(p_unpaired.p >= 0.05, :) = [];
%         pValueLines(p_unpaired, data, xVar, yVar, ax, 'up')
%     end
% else
for design = ["paired", "unpaired", "mixed", "stratified"]
    if ~isempty(p_table.(design))
        switch design
            case 'paired'
                withinVar = xVar;
                betweenVar = [];
            case 'stratified'
                withinVar = xVar;
                betweenVar = betweenVariable;
            case 'unpaired'
                betweenVar = xVar;
                withinVar = [];
            case 'mixed'
                withinVar = xVar;
                betweenVar = betweenVariable;
        end

        try
            pValueLines(p_table.(design), data, ...
                withinVar = withinVar, ...
                responseVar = yVar, ...
                ax = ax, ...
                design = design, ...
                offset = offset, ...
                betweenVar = betweenVar);
            
        catch ME
            disp(getReport(ME))
        end
    end



end
% try
%     pValueLines(p_ttest, data, ...
%         withinVar = xVar, ...
%         responseVar = yVar, ...
%         ax = ax, ...
%         design = 'stratified', ...
%         offset = offset, ...
%         betweenVar = betweenVariable);
% catch ME
% end
% try
%     pValueLines(p_paired, data, ...
%         withinVar = xVar, ...
%         responseVar = yVar, ...
%         ax = ax, ...
%         design = 'paired', ...
%         offset = offset, ...
%         betweenVar = betweenVariable);
% catch ME
% end
% try
%     pValueLines(p_mixed, data, ...
%         withinVar = xVar, ...
%         responseVar = yVar, ...
%         ax = ax, ...
%         design = 'mixed', ...
%         offset = offset, ...
%         betweenVar = betweenVariable);
% catch ME
% end
% end

ax.LineWidth = 2;

for j = 1:height(ax.Children)
    ax.Children(j).LineWidth = 2;
end

ax.Box = 'on';
ax.Title.FontWeight = 'Bold';

end



function aa = angle_interpol(a1, w1, a2, w2)

    diff = a2 - a1;       
    if diff > 180
        a1 = a1 + 360;
    elseif diff < -180
        a1 = 360;
    end

    aa = (w1 * a1 + w2 * a2) / (w1 + w2);

    if aa > 360
        aa = aa - 360;
    elseif aa < 0
        aa = aa + 360;
    end
end

function aa = angle_mean(angle)

    angle = rmmissing(angle);
    aa = 0.0;
    ww = 0.0;

    for a = angle(:)'
        aa = angle_interpol(aa, ww, a, 1);
        ww = ww + 1;
    end
end
