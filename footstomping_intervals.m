cd \\mbneufy3-srv.science.ru.nl\mbneufy3\Data_ME\source_standard\sub-06\motion

% load data
cfg=[];
cfg.datafile= 'sub-06_task-footnonauto_motion.mvnx';
data_motion=ft_preprocessing(cfg);

% select foot contacts right foot
cfg=[];
cfg.channel={'fc_RightFoot_Heel_footContacts', 'fc_RightFoot_Toe_footContacts'};
data_FC=ft_selectdata(cfg, data_motion);

% plot
figure; plot(data_FC.time{1}, data_FC.trial{1}(1,:))
ylim([-1 2])
hold on; plot(data_FC.time{1}, data_FC.trial{1}(2,:))

% find blocks
 blocks=findchangepts(data_FC.trial{1}(1,:), 'MaxNumChanges', 22)
 figure; plot(data_FC.trial{1}(1,:)); ylim([-1 2])
 hold on; plot(blocks, zeros(1, length(blocks)), 'ro')
 blocks_begin=blocks([1:2:21])-1*data_FC.fsample;% use 3-second margins
 blocks_end=blocks([2:2:22])+1*data_FC.fsample;% use 3-second margins
 
 % split trials
 cfg=[];
 cfg.trl=[blocks_begin' blocks_end' zeros(length(blocks_begin), 1)];
 data_trl=ft_redefinetrial(cfg, data_FC);
 
 % loop over trials and substract the intervals 
 for i=1:length(data_trl.trial)
   figure; plot(data_trl.trial{i}(2,:)); ylim([-1 2]); title(sprintf('trial %.0d', i))
   x=findchangepts(data_trl.trial{i}(2,:), 'MaxNumChanges', 24);
%    hold on; plot(x, ones(1,length(x)), 'ro')
   stomps=x(2:2:24);
   hold on; plot(stomps, ones(1,length(stomps)), 'go')
   intervals=diff(stomps)/data_trl.fsample
 end