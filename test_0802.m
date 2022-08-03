%% 测试新旧设备的信号质量
clc;clear; close all;

%% 测试项目：
% 1）原始脑电数据；
% 2）对数据进行去除线性趋势；
% 3）滤波后的脑电数据；（50hz、100hz）
% 4) 眨眼检测预处理（0.1hz高通、降采样到64hz、中值滤波）
% 5）眨眼检测
% 6）频域分析



%% 导入数据
filename_old = 'Frank Gu_2022_08_02_01_54.csv';   % 硅胶头环
filename_new = 'Frank Gu_2022_08_02_03_31.csv';   % 单通道产品
filename_newclamp = 'Frank Gu_2022_08_02_02_50.csv';   % 单通道+电极贴产品

%% 测试原始数据
% 硅胶头环
T_old = readtable(filename_old,'HeaderLines',4); % for non_numeric array
eeg1_old = T_old{:,2};
eeg2_old = T_old{:,3};

% delete Nan values if any
eeg1_old(isnan(eeg1_old)) = [];
eeg2_old(isnan(eeg2_old)) = [];
% two channels dimension equivalence check
if ~isequal(length(eeg1_old),length(eeg2_old))
    eeg1_old = eeg1_old(1:min(length(eeg1_old),length(eeg2_old)));
    eeg2_old = eeg2_old(1:min(length(eeg1_old),length(eeg2_old)));
end

% 单通道
T_new = readtable(filename_new,'HeaderLines',4); % for non_numeric array
eeg1_new = T_new{:,2};
eeg2_new = T_new{:,3};

% delete Nan values if any
eeg1_new(isnan(eeg1_new)) = [];
eeg2_new(isnan(eeg2_new)) = [];
% two channels dimension equivalence check
if ~isequal(length(eeg1_new),length(eeg2_new))
    eeg1_new = eeg1_new(1:min(length(eeg1_new),length(eeg2_new)));
    eeg2_new = eeg2_new(1:min(length(eeg1_new),length(eeg2_new)));
end

% 单通道+电极贴
T_newclamp = readtable(filename_newclamp,'HeaderLines',4); % for non_numeric array
eeg1_newclamp = T_newclamp{:,2};
eeg2_newclamp = T_newclamp{:,3};

% delete Nan values if any
eeg1_newclamp(isnan(eeg1_newclamp)) = [];
eeg2_newclamp(isnan(eeg2_newclamp)) = [];
% two channels dimension equivalence check
if ~isequal(length(eeg1_newclamp),length(eeg2_newclamp))
    eeg1_newclamp = eeg1_newclamp(1:min(length(eeg1_newclamp),length(eeg2_newclamp)));
    eeg2_newclamp = eeg2_newclamp(1:min(length(eeg1_newclamp),length(eeg2_newclamp)));
end

%% filtering the raw data for further process
fs = 250; % sampling frequency
T = 1/fs;  
data_len = length(eeg1_old); % length of selected signal
time_vector = (0:data_len-1)/fs; % time vector
data_dur = data_len/fs; % recording duration, in seconds

% 开始、结束时间戳
start_sample = 61001;  % 75001
end_sample = 81500;    % 82501

figure(1)
subplot(311);plot(eeg2_old(start_sample:end_sample,:));title("硅胶头环AF7的原始脑电信号");
subplot(312);plot(eeg2_new(start_sample:end_sample,:));title("单通道的原始脑电信号");
subplot(313);plot(eeg2_newclamp(start_sample:end_sample,:));title("单通道+电极贴的原始脑电信号");

%% 测试去除基线效果
data_old = detrend(eeg2_old);
data_new = detrend(eeg2_new);
data_newclamp = detrend(eeg2_newclamp);

figure(2)
subplot(311);plot(data_old(start_sample:end_sample,:));title("硅胶头环AF7的去除线性趋势");
subplot(312);plot(data_new(start_sample:end_sample,:));title("单通道的去除线性趋势");
subplot(313);plot(data_newclamp(start_sample:end_sample,:));title("单通道+电极贴的去除线性趋势");

%% 测试去除50hz、100hz的干扰
% 去除50hz干扰
datafilter1_old = bandstop_simple(data_old, 1, [49 51], fs);
datafilter1_new = bandstop_simple(data_new, 1, [49 51], fs);
datafilter1_newclamp = bandstop_simple(data_newclamp, 1, [49 51], fs);

figure(3)
subplot(311);plot(datafilter1_old(start_sample:end_sample,:));title("硅胶头环AF7的去除50hz干扰");
subplot(312);plot(datafilter1_new(start_sample:end_sample,:));title("单通道的去除50hz干扰");
subplot(313);plot(datafilter1_newclamp(start_sample:end_sample,:));title("单通道+电极贴的去除50hz干扰");

% 去除100hz干扰
datafilter2_old = bandstop_simple(datafilter1_old, 1, [99 101], fs);
datafilter2_new = bandstop_simple(datafilter1_new, 1, [99 101], fs);
datafilter2_newclamp = bandstop_simple(datafilter1_newclamp, 1, [99 101], fs);

figure(4)
subplot(311);plot(datafilter2_old(start_sample:end_sample,:));title("硅胶头环AF7的去除100hz干扰");
subplot(312);plot(datafilter2_new(start_sample:end_sample,:));title("单通道的去除100hz干扰");
subplot(313);plot(datafilter2_newclamp(start_sample:end_sample,:));title("单通道+电极贴的去除100hz干扰");


%% 检测眨眼效果
%basic parameter setup
epoch_duration = 1;
epoch_overlaptime = 0.1;
artifact_process_mode = 0;

channel_id_2use = 1;  %channel ID to use
samplingrate_original = 250; % sampling rates of original  data
%preprocessing
samplingFrequency2Use = 64;  % 降采样
datarange_2use = start_sample:end_sample;   % 检测的数据段范围

% 检测眨眼检测的脑电数据
dataold_detection = datafilter2_old(datarange_2use,:);
datanew_detection = datafilter2_new(datarange_2use,:);
datanewclamp_detection = datafilter2_newclamp(datarange_2use,:);

% 眨眼检测的预处理（0.1hz的高通，降采样的64hz，5点中值滤波）
dataold = Preprocessing(dataold_detection,samplingrate_original,samplingFrequency2Use);   % 预处理
datanew = Preprocessing(datanew_detection,samplingrate_original,samplingFrequency2Use);   % 预处理
datanewclamp = Preprocessing(datanewclamp_detection,samplingrate_original,samplingFrequency2Use);   % 预处理
figure(5)
subplot(311);plot(dataold);title("硅胶头环AF7的眨眼检测预处理");
subplot(312);plot(datanew);title("单通道的眨眼检测预处理");
subplot(313);plot(datanewclamp);title("单通道+电极贴的眨眼检测预处理");

%EOG Detection
threshold = 140;
threshold_newclamp = 20;
min_window_width = 30;  %6 = 6/64  = about 93.8 ms
max_window_width = 50;  %14 = 14/64  = 448/2048 = about 220 ms

[artifact_range_old, window_acc_v_old] = eogdetection_accdiff(dataold(:,1), min_window_width, max_window_width, threshold);
[artifact_range_new, window_acc_v_new] = eogdetection_accdiff(datanew(:,1), min_window_width, max_window_width, threshold);
[artifact_range_newclamp, window_acc_v_newclamp] = eogdetection_accdiff(datanewclamp(:,1), min_window_width, max_window_width, threshold_newclamp);

figure(6)
subplot(311);plot(window_acc_v_old);title("硅胶头环AF7的MSDW");
subplot(312);plot(window_acc_v_new);title("单通道的MSDW");
subplot(313);plot(window_acc_v_newclamp);title("单通道+电极贴的MSDW");

%% 标记眨眼
num_artifact_old = size(artifact_range_old,1);
num_artifact_new = size(artifact_range_new,1);
num_artifact_newclamp = size(artifact_range_newclamp,1);

for i = 1:1:num_artifact_old
    temp = artifact_range_old(i,:);
    temp2 = dataold(temp(1):temp(2),:);
    artifact_max = max(temp2);
    index_old(i) = max(find(artifact_max == dataold(temp(1):temp(2),:)))+temp(1)-1;
end

for i = 1:1:num_artifact_new
    temp = artifact_range_new(i,:);
    temp2 = datanew(temp(1):temp(2),:);
    artifact_max = max(temp2);
    index_new(i) = max(find(artifact_max == datanew(temp(1):temp(2),:)))+temp(1)-1;
end

for i = 1:1:num_artifact_newclamp
    temp = artifact_range_newclamp(i,:);
    temp2 = datanewclamp(temp(1):temp(2),:);
    artifact_max = max(temp2);
    index_newclamp(i) = max(find(artifact_max == datanewclamp(temp(1):temp(2),:)))+temp(1)-1;
end


figure(7)
subplot(311);plot(dataold);hold on; plot(index_old,dataold(index_old),'or');title("硅胶头环AF7的标记眨眼");
subplot(312);plot(datanew);hold on; plot(index_new,datanew(index_new),'or');title("单通道的标记眨眼");
subplot(313);plot(datanewclamp);hold on; plot(index_newclamp,datanewclamp(index_newclamp),'or');title("单通道+电极贴的标记眨眼");






