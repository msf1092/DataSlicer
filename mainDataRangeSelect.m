clear all; close all; format compact; clc;
%% Data reader
% This tiny code takes data, draw a chart, and the user selects the range
% of data to be kept/removed.
% It is used to select the B-value and hydraulic permeability tests, from
% the long-time saturation-permeability tests.
data_dir_in = "C:\Users\qdmofa\OneDrive - TUNI.fi\Fincone II-adjunct\Asli\FINCONE II - Analytical tools\Codes\Lab data Analysis\Triaxial\Data_range_selector\data_dir_in";
data_dir_out = "C:\Users\qdmofa\OneDrive - TUNI.fi\Fincone II-adjunct\Asli\FINCONE II - Analytical tools\Codes\Lab data Analysis\Triaxial\Data_range_selector\data_dir_out";

[Sr, k, time_start, time_end, strt_ind, end_ind, out_table] = fncBarvo()

