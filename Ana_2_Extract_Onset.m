clear
Set_Up;


for thesub = Subs
    subId = ['sub-' sprintf('%03d', thesub)];
    Dirs = get_directories_for_thesub(thesub);
    
    
    if exist(Dirs.behav, 'dir')
        for thetype = 1%:length(Task)
            taskType  = Task(thetype).Type;
            fileThisType = dir(fullfile(Dirs.behav, Task(thetype).nameInBehav, '*.mat'));
            
            for i = 1:length(fileThisType)
                
                therun = str2num(fileThisType(i).name(end-4));
                
                %% extract motion regressor from confound files
                
                if exist(Dirs.brain, 'dir')
                    regreFile = ['sub-' sprintf('%03d', thesub) '_task-' Task(thetype).nameInBids  '_run-' num2str(therun) '_desc-confounds_timeseries.tsv'];
                    s = tdfread(fullfile(Dirs.brain,regreFile));
                    R = [s.trans_x, s.trans_y, s.trans_z, s.rot_x, s.rot_y, s.rot_z];
                    regre_names = {'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z'};
                end
                
                %% extract onsets of conditions
                behavFile = fullfile(Dirs.behav, Task(thetype).nameInBehav, [subId '_' Task(thetype).nameInBehav '_' num2str(therun) '.mat']);
                load(behavFile)
                
                switch taskType
                    
                    case 'RS'
                        if theexp==1
                            %  For RS, use RS trials as conditions, use MVPA trials as nuisance
                            Table = T(~isnan(T.angle2),:);
                            mvpaTrial = T(isnan(T.angle2)&~isnan(T.angle1), :);
                            
                            
                            % get the RS trials for the tested conditions
                            [names, onsets, durations] = deal(cell(1,4));
                            thecondi = 1;
                            for thedir = 1:length(directions)
                                for themovingDir = movingDirs'
                                    trialId = strcmp(Table.direction,  directions(thedir)) & Table.movingDir==themovingDir;
                                    if themovingDir < 0
                                        names{thecondi} = strcat(directions{thedir}, '-Up');
                                    else
                                        names{thecondi} = strcat(directions{thedir}, '-Down');
                                    end
                                    
                                    onsets{thecondi} = Table.img1Onset(trialId); % in second
                                    durations{thecondi} = (dur.image1 + dur.blank + dur.image2)/1000; % in second
                                    thecondi = thecondi+1;
                                end
                            end
                            
                             % put MVPA trial as a regressor, too
                            names{end+1}  = 'single-posture';
                            onsets{end+1} = mvpaTrial.img1Onset;
                            durations{end+1} = (dur.image1 + dur.blank + dur.image2)/1000;
                            
                            % put nontrials as a regressor for baseline.
                            names{end+1}  = 'nonTrials';
                            onsets{end+1} = T(isnan(T.angle1),:).img1Onset;
                            durations{end+1} = (dur.image1 + dur.blank + dur.image2)/1000;
                            
                            
%                             % get the MVPA trials and put in the regreFile as a nuisance regressor
%                             NTR = size(R,1);
%                             convSeries = convolve_events(mvpaTrial.img1Onset, dur.image1/1000, TR, NTR);
%                             
%                             R(:,end+1) = convSeries;
%                             regre_names{end+1} = 'mvpaTrials';
                            
                            %                         % another way of defining: use the image2 onset as regressor.
                            %                         for thedir = 1:length(directions)
                            %                             for themovingDir = movingDirs'
                            %                                 trialId = strcmp(Table.direction,  directions(thedir)) & Table.movingDir==themovingDir;
                            %                                 if themovingDir < 0
                            %                                     names{thecondi} = strcat(directions{thedir}, '-Up');
                            %                                 else
                            %                                     names{thecondi} = strcat(directions{thedir}, '-Down');
                            %                                 end
                            %                                 onsets{thecondi} = Table.img2Onset(trialId); % in second
                            %                                 durations{thecondi} = (dur.image2)/1000; % in second
                            %                                 thecondi = thecondi+1;
                            %                             end
                            %                         end
                            %
                            %                         % put image1 as a regressor regardless of the
                            %                         % conditions, even for MVPA trials
                            %                         names{end+1}         = 'image1';
                            %                         onsets{end+1}        = T.img1Onset;
                            %                         durations{thecondi}  = (dur.image1)/1000; % in second
                            
                            
                        elseif theexp==2
                            Table = T(~isnan(T.angle2),:);
                            
                            
                            % get the RS trials for the tested conditions
                            [names, onsets, durations] = deal(cell(1,6));
                            thecondi = 1;
                            for thedir = 1:length(directions)
                                for themovingDir = movingDirs'
                                    trialId = strcmp(Table.direction,  directions(thedir)) & Table.movingDir==themovingDir;
                                    if themovingDir == -changeAng
                                        names{thecondi} = strcat(directions{thedir}, '-Up');
                                    elseif themovingDir == changeAng
                                        names{thecondi} = strcat(directions{thedir}, '-Down');
                                    else
                                        names{thecondi} = strcat(directions{thedir}, '-OtherSide');
                                    end
                                    
                                    onsets{thecondi} = Table.img1Onset(trialId); % in second
                                    durations{thecondi} = (dur.image1 + dur.blank + dur.image2)/1000; % in second
                                    thecondi = thecondi+1;
                                end
                            end
                            % put nontrials as a regressor for baseline.
                            names{end+1}  = 'nonTrials';
                            onsets{end+1} = T(isnan(T.angle1),:).img1Onset;
                            durations{end+1} = durations{end};
                            
                        end
                        
                    case "Test"
                        if theexp ==1
                            %% for test trials, use MVPA trials as conditions, use RS trials as nuisance
                            % get conditions of MVPA trials
                            Table = T(~isnan(T.angle2),:);
                            mvpaTrial = T(isnan(T.angle2)&~isnan(T.angle1), :);
                            
                            [names, onsets, durations] = deal(cell(1,4));
                            thecondi = 1;
                            for thedir = 1:length(directions)
                                for theview = 1:length(views)
                                    names{thecondi} = [directions{thedir} '-' views{theview}];
                                    onsets{thecondi} = mvpaTrial.img1Onset(strcmp(mvpaTrial.direction,directions{thedir}) &  strcmp(mvpaTrial.view,views{theview}));
                                    durations{thecondi} = dur.image1/1000;
                                    thecondi = thecondi +1;
                                end
                            end
                            
                            
                            % get the RS trials and put in the regreFile as a nuisance regressor
                            NTR = size(R,1);
                            convSeries = convolve_events(Table.img1Onset, (dur.image1+dur.blank+dur.image2)/1000, TR, NTR);
                            
                            R(:,end+1) = convSeries;
                            regre_names{end+1} = 'RSTrials';
                            
                        elseif theexp==3 % for the decoding of direction and view
                            Table = T(~isnan(T.angle2) & T.movingDir~=90,:);
                            
                            % get the RS trials
                            
                            [names, onsets, durations] = deal(cell(1,4));
                            thecondi = 1;
                            for thedir = 1:length(directions)
                                for theview = 1:length(views)
                                    names{thecondi} = [directions{thedir} '-' views{theview}];
                                    onsets{thecondi} = Table.img1Onset(strcmp(Table.direction,directions{thedir}) &  strcmp(Table.view,views{theview}));
                                    durations{thecondi} = dur.image1/1000;
                                    thecondi = thecondi +1;
                                end
                            end
                            
                            
                            % put nontrials as a regressor for baseline.
                            names{end+1}  = 'nonTrials';
                            onsets{end+1} = T(isnan(T.angle1),:).img1Onset;
                            durations{end+1} = durations{end};
                        end
                        
                    case 'Test-angle'
                            Table = T(~isnan(T.angle2) & T.movingDir~=90,:);
                            angles = unique(Table.angle1);                            
                            [names, onsets, durations] = deal(cell(1,4));
                            thecondi = 1;
                            for thedir = 1:length(directions)
                                for theview = 1:length(views)
                                    for theangle = 1:length(angles)
                                    names{thecondi} = [directions{thedir} '-' views{theview} '-' num2str(angles(theangle))];
                                    onsets{thecondi} = Table.img1Onset(strcmp(Table.direction,directions{thedir}) ...
                                        &  strcmp(Table.view,views{theview})...
                                        & Table.angle1 == angles(theangle));
                                    durations{thecondi} = dur.image1/1000;
                                    thecondi = thecondi +1;
                                    end
                                end
                            end
                        
                    case 'Train' % this we do block-wise beta for training the classifier
                        Table = T(1:NTrialPerBlock:end,:);
                        dur.block = (dur.image* NTrialPerBlock + dur.wait * (NTrialPerBlock-1))/1000;
                        
                        [names, onsets, durations] = deal(cell(1,length(spatialAngs)));
                        
                        for thecondi = 1:height(Table)
                            names{thecondi} = ['retinalAng(' num2str(Table.retinalAng(thecondi)) ')'];
                            onsets{thecondi} = Table.img1Onset(thecondi);
                            durations{thecondi} = dur.block;
                        end
                        
                    case 'Localizer_Obj'
                        Table = T(1:NTrialPerBlock:end,:);
                        dur.block = (dur.image* NTrialPerBlock + dur.wait * (NTrialPerBlock-1))/1000;
                        
                        [names, onsets, durations] = deal(cell(1,length(categories)));
                        
                        for thecondi = 1:length(categories)
                            names{thecondi} = categories{thecondi};
                            onsets{thecondi} = Table.img1Onset(strcmp(Table.category, categories(thecondi)));
                            durations{thecondi} = dur.block;
                        end
                        
                    case 'Localizer_BM'
                        Table = [T.condition, T.img1Onset];
                        
                        Table = Table(1:NTrialPerBlock:end,:);
                        
                        dur.block = (dur.image* NTrialPerBlock + dur.wait * (NTrialPerBlock-1))/1000;
                        
                        Ncondi = 2;
                        [names, onsets, durations] = deal(cell(1,Ncondi));
                        names{1} = 'Intact';
                        names{2} = 'Scramb';
                        
                        for thecondi = 1:Ncondi
                            onsets{thecondi} = Table(Table(:,1)==thecondi, 2);
                            durations{thecondi} = dur.block;
                        end
                        
                end
                
                %% save
                
                save(fullfile(Dirs.onsets, ['onset_' taskType '_run-' num2str(therun)]), 'names' ,'onsets', 'durations');
                
                names = regre_names; % to avoid overwritting
                save(fullfile(Dirs.nuisances, ['nuisance_' taskType '_run-' num2str(therun)] ),'R', 'names');
            end
            
            
        end
    end
end