clear all
close all

cd \\mbneufy3-srv.science.ru.nl\mbneufy3\Data_ME\source_standard\sub-21\motion
 addpath C:\Users\helen\Documents\MATLAB\matlab_toolboxes\fieldtrip\external\xdf

% load data
cfg=[];
cfg.datafile= 'sub-21_task-footnonauto_motion.mvnx';
data_motion=ft_preprocessing(cfg);

% select vertical acceleration of right foot
cfg=[];
cfg.channel={'sen_RightFoot_sensorFreeAcceleration_Z'};
data_accel=ft_selectdata(cfg, data_motion);

 % find trials based on events
streams=load_xdf('\\mbneufy3-srv.science.ru.nl\mbneufy3\Data_ME\source_standard\sub-21\stim\sub-21_task-automaticity_rec-01_triggerslabrecorder.xdf');
% find lsldert04
for i=1:length(streams)
  if strcmp(streams{i}.info.hostname, 'lsldert04')
    stream=streams{i}; 
  else
    continue
  end
end
events=table(stream.time_series', stream.time_stamps', 'VariableNames', {'value', 'timestamp'});
% find the relevant events
idx_begin=find(strcmp(events.value, 'foot_nonauto'));
idx_end=idx_begin+1; % 'rest'
% find the start of the recording of this datafile
idx_start_rec=idx_begin(1)-2; % this is usually 2 events before the first task event
if ~strcmp(events.value(idx_start_rec), 'start_rec')
  error('wrong start_rec event was selected')
end
% find relative begin and end times based on the start rec
begin_time=events.timestamp(idx_begin)-events.timestamp(idx_start_rec);
end_time=events.timestamp(idx_end)-events.timestamp(idx_start_rec);
% in samples
trials_begin=floor((begin_time-2)*data_accel.fsample); % 2 second margin
trials_end=ceil((end_time+2)*data_accel.fsample);

 % split trials
 cfg=[];
 cfg.trl=[trials_begin trials_end zeros(length(trials_begin), 1)];
 data_trl=ft_redefinetrial(cfg, data_accel);
 
 %% loop over trials and substract the intervals 
 for i=1:length(data_trl.trial)
   figure; plot(data_trl.trial{i}(1,:)); title(sprintf('trial %.0d', i))
   % remark: we could also first smooth the data (movmedian) and then find the local
   % maxima
   peaks=find(islocalmax(data_trl.trial{i}(1,:), 'MaxNumExtrema', 13, 'MinSeparation', 0.3*data_trl.fsample, 'MinProminence', 10));
   hold on; plot(peaks, 20*ones(1,length(peaks)), 'ro')
   legend({'vertical acceleration of the right foot', 'detected foot stomps'})
   if length(peaks)>=12
     stomps=peaks(1:12); % only select the first 12
   else 
     warning('Not all 12 foot stomps were detected for trial %.0d', i)
     stomps=peaks;
   end
   intervals=diff(stomps)/data_trl.fsample
 end



