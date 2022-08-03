%% �����¾��豸���ź�����
clc;clear; close all;

%% ������Ŀ��
% 1��ԭʼ�Ե����ݣ�
% 2�������ݽ���ȥ���������ƣ�
% 3���˲�����Ե����ݣ���50hz��100hz��
% 4) գ�ۼ��Ԥ����0.1hz��ͨ����������64hz����ֵ�˲���
% 5��գ�ۼ��
% 6��Ƶ�����



%% ��������
filename_old = 'Frank Gu_2022_08_02_01_54.csv';   % �轺ͷ��
filename_new = 'Frank Gu_2022_08_02_03_31.csv';   % ��ͨ����Ʒ
filename_newclamp = 'Frank Gu_2022_08_02_02_50.csv';   % ��ͨ��+�缫����Ʒ

%% ����ԭʼ����
% �轺ͷ��
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

% ��ͨ��
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

% ��ͨ��+�缫��
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

% ��ʼ������ʱ���
start_sample = 61001;  % 75001
end_sample = 81500;    % 82501

figure(1)
subplot(311);plot(eeg2_old(start_sample:end_sample,:));title("�轺ͷ��AF7��ԭʼ�Ե��ź�");
subplot(312);plot(eeg2_new(start_sample:end_sample,:));title("��ͨ����ԭʼ�Ե��ź�");
subplot(313);plot(eeg2_newclamp(start_sample:end_sample,:));title("��ͨ��+�缫����ԭʼ�Ե��ź�");

%% ����ȥ������Ч��
data_old = detrend(eeg2_old);
data_new = detrend(eeg2_new);
data_newclamp = detrend(eeg2_newclamp);

figure(2)
subplot(311);plot(data_old(start_sample:end_sample,:));title("�轺ͷ��AF7��ȥ����������");
subplot(312);plot(data_new(start_sample:end_sample,:));title("��ͨ����ȥ����������");
subplot(313);plot(data_newclamp(start_sample:end_sample,:));title("��ͨ��+�缫����ȥ����������");

%% ����ȥ��50hz��100hz�ĸ���
% ȥ��50hz����
datafilter1_old = bandstop_simple(data_old, 1, [49 51], fs);
datafilter1_new = bandstop_simple(data_new, 1, [49 51], fs);
datafilter1_newclamp = bandstop_simple(data_newclamp, 1, [49 51], fs);

figure(3)
subplot(311);plot(datafilter1_old(start_sample:end_sample,:));title("�轺ͷ��AF7��ȥ��50hz����");
subplot(312);plot(datafilter1_new(start_sample:end_sample,:));title("��ͨ����ȥ��50hz����");
subplot(313);plot(datafilter1_newclamp(start_sample:end_sample,:));title("��ͨ��+�缫����ȥ��50hz����");

% ȥ��100hz����
datafilter2_old = bandstop_simple(datafilter1_old, 1, [99 101], fs);
datafilter2_new = bandstop_simple(datafilter1_new, 1, [99 101], fs);
datafilter2_newclamp = bandstop_simple(datafilter1_newclamp, 1, [99 101], fs);

figure(4)
subplot(311);plot(datafilter2_old(start_sample:end_sample,:));title("�轺ͷ��AF7��ȥ��100hz����");
subplot(312);plot(datafilter2_new(start_sample:end_sample,:));title("��ͨ����ȥ��100hz����");
subplot(313);plot(datafilter2_newclamp(start_sample:end_sample,:));title("��ͨ��+�缫����ȥ��100hz����");


%% ���գ��Ч��
%basic parameter setup
epoch_duration = 1;
epoch_overlaptime = 0.1;
artifact_process_mode = 0;

channel_id_2use = 1;  %channel ID to use
samplingrate_original = 250; % sampling rates of original  data
%preprocessing
samplingFrequency2Use = 64;  % ������
datarange_2use = start_sample:end_sample;   % �������ݶη�Χ

% ���գ�ۼ����Ե�����
dataold_detection = datafilter2_old(datarange_2use,:);
datanew_detection = datafilter2_new(datarange_2use,:);
datanewclamp_detection = datafilter2_newclamp(datarange_2use,:);

% գ�ۼ���Ԥ����0.1hz�ĸ�ͨ����������64hz��5����ֵ�˲���
dataold = Preprocessing(dataold_detection,samplingrate_original,samplingFrequency2Use);   % Ԥ����
datanew = Preprocessing(datanew_detection,samplingrate_original,samplingFrequency2Use);   % Ԥ����
datanewclamp = Preprocessing(datanewclamp_detection,samplingrate_original,samplingFrequency2Use);   % Ԥ����
figure(5)
subplot(311);plot(dataold);title("�轺ͷ��AF7��գ�ۼ��Ԥ����");
subplot(312);plot(datanew);title("��ͨ����գ�ۼ��Ԥ����");
subplot(313);plot(datanewclamp);title("��ͨ��+�缫����գ�ۼ��Ԥ����");

%EOG Detection
threshold = 140;
threshold_newclamp = 20;
min_window_width = 30;  %6 = 6/64  = about 93.8 ms
max_window_width = 50;  %14 = 14/64  = 448/2048 = about 220 ms

[artifact_range_old, window_acc_v_old] = eogdetection_accdiff(dataold(:,1), min_window_width, max_window_width, threshold);
[artifact_range_new, window_acc_v_new] = eogdetection_accdiff(datanew(:,1), min_window_width, max_window_width, threshold);
[artifact_range_newclamp, window_acc_v_newclamp] = eogdetection_accdiff(datanewclamp(:,1), min_window_width, max_window_width, threshold_newclamp);

figure(6)
subplot(311);plot(window_acc_v_old);title("�轺ͷ��AF7��MSDW");
subplot(312);plot(window_acc_v_new);title("��ͨ����MSDW");
subplot(313);plot(window_acc_v_newclamp);title("��ͨ��+�缫����MSDW");

%% ���գ��
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
subplot(311);plot(dataold);hold on; plot(index_old,dataold(index_old),'or');title("�轺ͷ��AF7�ı��գ��");
subplot(312);plot(datanew);hold on; plot(index_new,datanew(index_new),'or');title("��ͨ���ı��գ��");
subplot(313);plot(datanewclamp);hold on; plot(index_newclamp,datanewclamp(index_newclamp),'or');title("��ͨ��+�缫���ı��գ��");






