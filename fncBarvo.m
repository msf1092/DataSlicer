function [Sr, k, time_start, time_end, strt_ind, end_ind, out_table] = fncBarvo()
% The function computes the saturation ratio of the sample!
% The Sr is calculated based on the pore pressure measurements, within
% 95-98% range of pore pressure measurements.

[file, path] = uigetfile({'*.txt', 'B-value (*.txt)';'*.*','All Files (*.*)'}, 'Select B-arvo file');
file_path_name = fullfile(path, file);
T = readtable(file_path_name, "Encoding","UTF-8","FileType","text", "Delimiter","\t","ReadVariableNames",false);
n = size(T,2);
if n == 3 % For the B-value setup
    T.Properties.VariableNames = {'Time Day-hr.min.sec,_','Increased pore pressure (kPa)','Increased cell pressure (kPa)'};
    B_pore_pressure = str2double(strrep(T{:,2}, ',','.'));
    B_inc_cell_pressure = str2double(strrep(T{:,3}, ',','.'));
    % time
    newStr = strrep(T{:,1},"-",".");
    newStr = strrep(newStr, ',','.');
    [Y, M, D, H, MN, S] = datevec(char(newStr{:,1}), 'yyyy.mm.dd.HH.MM.SS.FFF');
    month_days = [31; 28; 31; 30; 31; 30; 31; 31; 30; 31; 30; 31];
    month = zeros(12,1);
    time_min = zeros(numel(S),1);
    time_sec = zeros(numel(S),1);
    for i = 1:numel(S) %change of year is not considered in time!
        month_i = M(i,1) - 1; %number of the current month
        month(1:month_i) = 1; %ones till the current month
        time_min(i,1) = (sum(month.*month_days) + (D(i,1)-1)) * 1440 + ...
            H(i,1)*60 + MN(i,1) + S(i,1)/60;
        time_sec(i,1) = (sum(month.*month_days) + (D(i,1)-1)) * 86400 + ...
            H(i,1)*3600 + MN(i,1)*60 + S(i,1);
    end
    time_sec = time_sec - time_sec(1); %datum to zero; i.e. start of test
    time_min = time_min - time_min(1);
else
    drain = str2double(T.Var13); % for the new TX setups, no. 2 & 3
    B_pore_pressure = str2double(T.Var12);
    B_inc_cell_pressure = str2double(strrep(T.Var12,",","."));
    time_sec = str2double(strrep(T.Var7,",","."));
end



% To be improved (it should be changed to old and new TX files! Then, if the new file is used, I need to develop the code to consider the B-value tests also.):
BK = input("Is it a B-value check or k measurement ('B' or 'k'): ");

if BK == 'B'
    [time_start, time_end, strt_ind, end_ind, time_downs, pore_downs, ind_downs] = fncRangeSelector(time_sec,B_pore_pressure);

    % section of time n pore
    time_section = time_sec(strt_ind:end_ind,1);
    pore_section = B_pore_pressure(strt_ind:end_ind,1);
    cell_pressure_section = B_inc_cell_pressure(strt_ind:end_ind,1);

    k = 'NA';
    % Saturation check
    n = end_ind - strt_ind + 1;
    lowInd = round(n * 0.95);
    upInd = round(n * 0.98);
    cell_press9095 = mean(cell_pressure_section(lowInd:upInd,1));
    pore_press9095 = mean(pore_section(lowInd:upInd,1));
    Sr = (pore_press9095 / cell_press9095) * 100;

    out_table = table(time_section,cell_pressure_section,pore_section);
    out_table.Properties.VariableNames = {'time','cell pressure','pore'};
    
elseif BK == 'k'
    [time_start, time_end, strt_ind, end_ind, time_downs, pore_downs, ind_downs] = fncRangeSelector(time_sec,drain);

    % section of time n drain
    time_section = time_sec(strt_ind:end_ind,1);
    drain_section = drain(strt_ind:end_ind,1);
    pore_section = B_inc_cell_pressure(strt_ind:end_ind,1);

    Sr = 'NA';
    time_k_diff = time_section(end)-time_section(1);
    drain_k_diff = mean(drain((round(0.97*(length(drain_section)))):end,1)) - mean(drain(1:(round(0.03*(length(drain_section)))),1)); % the avg of 3% of initial and ending drainage values are regarded as drainage
    k = (drain_k_diff / time_k_diff) * 1e-9;

    out_table = table(time_section,drain_section,pore_section);
    out_table.Properties.VariableNames = {'time','drain','pore'};
end

end


