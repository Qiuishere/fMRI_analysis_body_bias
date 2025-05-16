%% NOTES
%%%%%%%% code to loop the t-test on the contrast creaded for phase 1 and 2 %%%%%%%%
%%%%%%%% to be runned for phase=1 and pahse=2 %%%%%%%%
%% SUBJ INFO
%number=[113;117;170;175;189;220;225;239;260;264;268;279;...
%    283;287;301;306;310;343;361;388;391;395;403;407;410];

% to be fixed: 113,117 => problems in 1st level!

% no phase1: 113,170,175
% no phase2: 117
% no tot: 260,124,194

%% CODE INFO
%seclev_SUSW_120219(subj,cont,phase,pm)

% cont= 'SWconf';        % name of the contrast to be runned
% pm = 2;    % ph1: 0,1,2 - ph2: 0,1,2,3

phase = 1; % 1 or 2

if phase==1
    subj = [189;220;225;239;264;268;279;...
            283;287;301;306;310;343;361;388;391;395;403;407;410];

    seclev_SUSW_120219(subj,'SU75vsSU25cue',phase,0)    %1
    seclev_SUSW_120219(subj,'50vs7525cue',phase,0)      %2
    seclev_SUSW_120219(subj,'SU75vsSU25taste',phase,0)  %3
    seclev_SUSW_120219(subj,'SU50vsSU25taste',phase,0)  %4
    seclev_SUSW_120219(subj,'SU75vsSU50taste',phase,0)  %5
    seclev_SUSW_120219(subj,'SW75vsSW25taste',phase,0)  %6
    seclev_SUSW_120219(subj,'SW50vsSW25',phase,0)       %7
    seclev_SUSW_120219(subj,'SW75vsSW50_taste',phase,0) %8
    seclev_SUSW_120219(subj,'SU75vsSU25vsSW75vsSW25_taste',phase,0) %9
    seclev_SUSW_120219(subj,'certain_vs_uncertain_taste',phase,0)   %10
    seclev_SUSW_120219(subj,'likely_vs_notlikely_taste',phase,0)    %11
    seclev_SUSW_120219(subj,'SU_taste',phase,0)         %12
    seclev_SUSW_120219(subj,'SW_taste',phase,0)         %13
    seclev_SUSW_120219(subj,'SUvsSW_taste',phase,0)     %14
    seclev_SUSW_120219(subj,'SU50vsSW50_taste',phase,0)     %15
    seclev_SUSW_120219(subj,'Interaction',phase,0)     %16
    seclev_SUSW_120219(subj,'exp_vs_unexp_SW',phase,0)     %17
    seclev_SUSW_120219(subj,'exp_vs_unexp_SU',phase,0)     %18
    
    seclev_SUSW_120219(subj,'SUvsSW_taste',phase,1)    %3
    seclev_SUSW_120219(subj,'SUconf',phase,1)          %4
    seclev_SUSW_120219(subj,'SWconf',phase,1)          %5
    seclev_SUSW_120219(subj,'average_conf',phase,1)    %6
    seclev_SUSW_120219(subj,'SUvsSWconf',phase,1)      %7

    seclev_SUSW_120219(subj,'SUvsSW_taste',phase,2)    %3
    seclev_SUSW_120219(subj,'SUconf',phase,2)          %4
    seclev_SUSW_120219(subj,'SWconf',phase,2)          %5
    seclev_SUSW_120219(subj,'average_conf',phase,2)    %6
    seclev_SUSW_120219(subj,'SUvsSWconf',phase,2)      %7

elseif phase==2
    subj = [170;175;189;220;225;239;264;268;279;...
            283;287;301;306;310;343;361;388;391;395;403;407;410];

    seclev_SUSW_120219(subj,'SUandSWcue',phase,0)      %1
    seclev_SUSW_120219(subj,'SUvsNcue',phase,0)        %2
    seclev_SUSW_120219(subj,'SWvsNcue',phase,0)        %3
    seclev_SUSW_120219(subj,'SUtaste',phase,0)         %4
    seclev_SUSW_120219(subj,'SWtaste',phase,0)         %5
    seclev_SUSW_120219(subj,'exp_vs_unexp_SU',phase,0) %6
    seclev_SUSW_120219(subj,'exp_vs_unexp_SW',phase,0) %7
    seclev_SUSW_120219(subj,'exp',phase,0)             %8
    seclev_SUSW_120219(subj,'unexp',phase,0)           %9
    seclev_SUSW_120219(subj,'SUvsSWtaste',phase,0)     %10
    seclev_SUSW_120219(subj,'exp_vs_unexp',phase,0)    %11
    seclev_SUSW_120219(subj,'SUvsN',phase,0)           %12
    seclev_SUSW_120219(subj,'SWvsN',phase,0)           %13
    seclev_SUSW_120219(subj,'SUexp_vs_N',phase,0)      %14
    seclev_SUSW_120219(subj,'SWexp_vs_N',phase,0)      %15
    seclev_SUSW_120219(subj,'SUexp_vs_SWexp',phase,0)  %16
    seclev_SUSW_120219(subj,'SUunexp_vs_SWunexp',phase,0) %17
    seclev_SUSW_120219(subj,'SUvsSWcue',phase,0)       %18
    seclev_SUSW_120219(subj,'Interaction',phase,0)       %19

    seclev_SUSW_120219(subj,'Pleas_taste',phase,1)     %4

    seclev_SUSW_120219(subj,'Pleas_SUexp',phase,2)     %4
    seclev_SUSW_120219(subj,'Pleas_SUunexp',phase,2)   %5
    seclev_SUSW_120219(subj,'Pleas_SWexp',phase,2)     %6
    seclev_SUSW_120219(subj,'Pleas_SWunexp',phase,2)   %7

    seclev_SUSW_120219(subj,'Pleas_whenSUcue',phase,3) %4
    seclev_SUSW_120219(subj,'Pleas_whenSWcue',phase,3) %5
end