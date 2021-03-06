function [tot_explore, cur_soc_explore, cur_nonsoc_explore, pre_soc_explore, pre_nonsoc_explore, win_explore, nowin_explore] = make_3col_files_m05(subject)

%{

OUTPUTs:
tot_explore = mean(isexplore(:,1));
cur_soc_explore = mean(isexplore(isexplore(:,3)==1),1);
cur_nonsoc_explore = mean(isexplore(isexplore(:,3)==0),1);
pre_soc_explore = mean(isexplore(isexplore(:,4)==1),1);
pre_nonsoc_explore = mean(isexplore(isexplore(:,4)==0),1);
win_explore = mean(isexplore(isexplore(:,5)==1),1);
nowin_explore = mean(isexplore(isexplore(:,5)==0),1);

%}

maindir = pwd;
datadir = fullfile(maindir,'data',num2str(subject));
outputdir = fullfile(maindir,'evfiles_m05',num2str(subject));
if ~exist(outputdir,'dir')
    mkdir(outputdir);
end
addpath(fullfile(maindir,'rw'));


alpha = 0.30;
beta = 2;
clear out dec miss ishuman iswin
% have practice trials for 1007 and beyond
if subject < 1007
    for r = 1:4
        load(fullfile(datadir,sprintf('%s_feedback_%d.mat',num2str(subject),r)))
        choicedata = [data.Npoints; data.deckchoice]';
        ishumans = [data.partner]';
        iswins = [data.soc_win]';
        tmpdec = [data.deckchoice]';
        tmpdec(tmpdec<10) = 0;
        tmpdec(tmpdec>10) = 1;
        misses = [data.lapse1]';
        misses = misses + tmpdec;
        if exist('out','var')
            out = [out; choicedata(:,1)];
            dec = [dec; choicedata(:,2)];
            miss = [miss; misses];
            ishumans = [data.partner]';
            ishuman = [ishuman; ishumans];
            iswins = [data.soc_win]';
            iswin = [iswin; iswins];
        else
            out = choicedata(:,1);
            dec = choicedata(:,2);
            miss = misses;
            ishuman = ishumans;
            iswin = iswins;
        end
    end
    [~, ~, ~, pe_e] = runRW_noPrac(dec, out, alpha, beta);
    miss(1:7,1) = 1;
else
    load(fullfile(datadir,sprintf('%s_feedback_prac.mat',num2str(subject))))
    choicedata = [data.Npoints; data.deckchoice]';
    misses = [data.lapse1]';
    out = choicedata(:,1);
    dec = choicedata(:,2);
    miss = misses;
    ishuman = [data.partner]';
    iswin = [data.soc_win]';
    for r = 1:4
        load(fullfile(datadir,sprintf('%s_feedback_%d.mat',num2str(subject),r)))
        choicedata = [data.Npoints; data.deckchoice]';
        tmpdec = [data.deckchoice]';
        tmpdec(tmpdec<10) = 0;
        tmpdec(tmpdec>10) = 1;
        misses = [data.lapse1]';
        misses = misses + tmpdec;
        out = [out; choicedata(:,1)];
        dec = [dec; choicedata(:,2)];
        miss = [miss; misses];
        
        ishumans = [data.partner]';
        ishuman = [ishuman; ishumans];
        iswins = [data.soc_win]';
        iswin = [iswin; iswins];
    end
    [~, ~, ~, pe_e] = runRW_wPrac(dec, out, alpha, beta);
end
hit = (miss-1).*-1;
bins = prctile(pe_e(hit==1),[20 40 60 80]);
normedPE = zeros(length(miss),4); %lin, quad, miss, raw
for x = 1:length(normedPE)
    if hit(x)
        normedPE(x,4) = pe_e(x);
        if pe_e(x) < bins(1) %bin 1
            normedPE(x,1) = -2;
            normedPE(x,2) = 4;
        elseif pe_e(x) >= bins(1) && pe_e(x) < bins(2) %bin 2
            normedPE(x,1) = -1;
            normedPE(x,2) = 1;
        elseif pe_e(x) >= bins(2) && pe_e(x) < bins(3) %bin 3
            normedPE(x,1) = 0;
            normedPE(x,2) = 0;
        elseif pe_e(x) >= bins(3) && pe_e(x) < bins(4) %bin 4
            normedPE(x,1) = 1;
            normedPE(x,2) = 1;
        elseif pe_e(x) >= bins(4) %bin 5
            normedPE(x,1) = 2;
            normedPE(x,2) = 4;
        end
    else
        normedPE(x,1) = 0;
        normedPE(x,2) = 0;
        normedPE(x,3) = 1; %miss
    end
end
if subject > 1006
    normedPE(1:20,:) = [];
end
%figure,plot(normedPE(:,4))
%keyboard
% figure,plot(normedPE(:,1))
% hold on
% plot(normedPE(:,2),'r')
% keyboard
% linear -> [-2 -1 0 1 2]
% quad -> [4 1 0 1 4]
dec(dec>2) = 0;
dec_idx = 1:length(dec);
all_dec = [dec dec_idx' ishuman iswin];
all_dec(all_dec(:,1)==0,:) = [];
isexplore = zeros(length(all_dec),5); % explore, idx, soc_t, soc_t-1, win_t-1
for d = 1:length(all_dec)
    if d < 2
        isexplore(d,1) = 1;
        isexplore(d,2) = all_dec(d,2);
        isexplore(d,3) = all_dec(d,3);
        isexplore(d,4) = 0;
        isexplore(d,5) = 0;
    else
        if all_dec(d,1) == all_dec(d-1,1)
            isexplore(d,1) = 0;
            isexplore(d,2) = all_dec(d,2);
            isexplore(d,3) = all_dec(d,3);
            isexplore(d,4) = all_dec(d-1,3);
            isexplore(d,5) = all_dec(d-1,4);
        else
            isexplore(d,1) = 1;
            isexplore(d,2) = all_dec(d,2);
            isexplore(d,3) = all_dec(d,3);
            isexplore(d,4) = all_dec(d-1,3);
            isexplore(d,5) = all_dec(d-1,4);
        end
    end
end
tot_explore = mean(isexplore(:,1));

cur_soc_explore = mean(isexplore(isexplore(:,3)==1),1);
cur_nonsoc_explore = mean(isexplore(isexplore(:,3)==0),1);

pre_soc_explore = mean(isexplore(isexplore(:,4)==1),1);
pre_nonsoc_explore = mean(isexplore(isexplore(:,4)==0),1);

win_explore = mean(isexplore(isexplore(:,5)==1),1);
nowin_explore = mean(isexplore(isexplore(:,5)==0),1);


tcount = 0;
blocks = 1:4;
for r = 1:length(blocks)
    load(fullfile(datadir,sprintf('%s_feedback_%d.mat',num2str(subject),r)))
    
    ntrials = length(data);
    
    %make empty mats (for *_par, will make *_con last)
    selfchoice = zeros(ntrials,3);
    inf_con = zeros(ntrials,3);
    uinf_par = zeros(ntrials,3);
    sinf_par = zeros(ntrials,3);
    aff_gain = zeros(ntrials,3);
    aff_loss = zeros(ntrials,3);
    partnerchoice = zeros(ntrials,3);
    
    cselfchoice = zeros(ntrials,3);
    cinf_con = zeros(ntrials,3);
    cuinf_par = zeros(ntrials,3);
    csinf_par = zeros(ntrials,3);
    caff_gain = zeros(ntrials,3);
    caff_loss = zeros(ntrials,3);
    cpartnerchoice = zeros(ntrials,3);
    
    lapse1 = zeros(ntrials,3);
    lapse2 = zeros(ntrials,3);
    dummy = zeros(ntrials,3);
    
    for t = 1:ntrials
        tcount = tcount + 1;
        %if data(t).is_catch
        %    continue
        %end
        
        if data(t).lapse1
            lapse1(t,1) = data(t).choice_onset;
            lapse1(t,2) = 3;
            lapse1(t,3) = 1;
        else
            if data(t).partner
                if data(t).deckchoice < 10
                    selfchoice(t,1) = data(t).choice_onset;
                    selfchoice(t,2) = data(t).RT1 + .5;
                    selfchoice(t,3) = 1;
                    if subject < 1007 && t < 8 && r == 1
                        dummy(t,1) = data(t).info_onset;
                        dummy(t,2) = 1.75;
                        dummy(t,3) = 1;
                    else
                        inf_con(t,1) = data(t).info_onset;
                        inf_con(t,2) = 1.75;
                        inf_con(t,3) = 1;
                        uinf_par(t,1) = data(t).info_onset;
                        uinf_par(t,2) = 1.75;
                        uinf_par(t,3) = normedPE(tcount,2);
                        sinf_par(t,1) = data(t).info_onset;
                        sinf_par(t,2) = 1.75;
                        sinf_par(t,3) = normedPE(tcount,1);
                    end
                end
                if data(t).lapse2
                    lapse2(t,1) = data(t).partner_onset;
                    lapse2(t,2) = 3;
                    lapse2(t,3) = 1;
                else
                    if ~data(t).is_catch == 1
                        partnerchoice(t,1) = data(t).partner_onset;
                        partnerchoice(t,2) = data(t).RT2 + 1.25; % 0.75 before and 0.5 after
                        partnerchoice(t,3) = 1;
                        if data(t).soc_win
                            aff_gain(t,1) = data(t).aff_onset;
                            aff_gain(t,2) = 1.75;
                            aff_gain(t,3) = 1;
                        else
                            aff_loss(t,1) = data(t).aff_onset;
                            aff_loss(t,2) = 1.75;
                            aff_loss(t,3) = 1;
                        end
                    end
                end
            else
                if data(t).deckchoice < 10
                    cselfchoice(t,1) = data(t).choice_onset;
                    cselfchoice(t,2) = data(t).RT1 + .5;
                    cselfchoice(t,3) = 1;
                    if subject < 1007 && t < 8 && r == 1
                        dummy(t,1) = data(t).info_onset;
                        dummy(t,2) = 1.75;
                        dummy(t,3) = 1;
                    else
                        cinf_con(t,1) = data(t).info_onset;
                        cinf_con(t,2) = 1.75;
                        cinf_con(t,3) = 1;
                        cuinf_par(t,1) = data(t).info_onset;
                        cuinf_par(t,2) = 1.75;
                        cuinf_par(t,3) = normedPE(tcount,2);
                        csinf_par(t,1) = data(t).info_onset;
                        csinf_par(t,2) = 1.75;
                        csinf_par(t,3) = normedPE(tcount,1);
                    end
                end
                if data(t).lapse2
                    lapse2(t,1) = data(t).partner_onset;
                    lapse2(t,2) = 3;
                    lapse2(t,3) = 1;
                else
                    if ~data(t).is_catch == 1
                        cpartnerchoice(t,1) = data(t).partner_onset;
                        cpartnerchoice(t,2) = data(t).RT2 + 1.25; % 0.75 before and 0.5 after
                        cpartnerchoice(t,3) = 1;
                        if data(t).soc_win
                            caff_gain(t,1) = data(t).aff_onset;
                            caff_gain(t,2) = 1.75;
                            caff_gain(t,3) = 1;
                        else
                            caff_loss(t,1) = data(t).aff_onset;
                            caff_loss(t,2) = 1.75;
                            caff_loss(t,3) = 1;
                        end
                    end
                end
            end
        end
    end
    
    dummy(~dummy(:,1),:) = [];
    lapse2(~lapse2(:,1),:) = [];
    lapse1(~lapse1(:,1),:) = [];
    
    %social
    inf_con(~inf_con(:,1),:) = [];
    aff_loss(~aff_loss(:,1),:) = [];
    aff_gain(~aff_gain(:,1),:) = [];
    partnerchoice(~partnerchoice(:,1),:) = [];
    selfchoice(~selfchoice(:,1),:) = [];
    sinf_par(~sinf_par(:,1),:) = [];
    sinf_par(:,3) = sinf_par(:,3)-mean(sinf_par(:,3));
    uinf_par(~uinf_par(:,1),:) = [];
    uinf_par(:,3) = uinf_par(:,3)-mean(uinf_par(:,3));
    
    
    %computer
    cinf_con(~cinf_con(:,1),:) = [];
    caff_loss(~caff_loss(:,1),:) = [];
    caff_gain(~caff_gain(:,1),:) = [];
    cpartnerchoice(~cpartnerchoice(:,1),:) = [];
    cselfchoice(~cselfchoice(:,1),:) = [];
    csinf_par(~csinf_par(:,1),:) = [];
    csinf_par(:,3) = csinf_par(:,3)-mean(csinf_par(:,3));
    cuinf_par(~cuinf_par(:,1),:) = [];
    cuinf_par(:,3) = cuinf_par(:,3)-mean(cuinf_par(:,3));
    
    
    
    
    cd(outputdir);
    if ~isempty(dummy)
        dlmwrite(sprintf('dummy%d.txt',r),dummy,'delimiter','\t','precision','%.6f')
    end
    if ~isempty(lapse1)
        dlmwrite(sprintf('lapseA%d.txt',r),lapse1,'delimiter','\t','precision','%.6f')
    end
    if ~isempty(lapse2)
        dlmwrite(sprintf('lapseB%d.txt',r),lapse2,'delimiter','\t','precision','%.6f')
    end
    
    %social
    dlmwrite(sprintf('inf_con%d.txt',r),inf_con,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('sinf_par%d.txt',r),sinf_par,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('uinf_par%d.txt',r),uinf_par,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('aff_gain%d.txt',r),aff_gain,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('aff_loss%d.txt',r),aff_loss,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('partnerchoice%d.txt',r),partnerchoice,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('selfchoice%d.txt',r),selfchoice,'delimiter','\t','precision','%.6f')
    
    %computer
    dlmwrite(sprintf('cinf_con%d.txt',r),cinf_con,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('csinf_par%d.txt',r),csinf_par,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('cuinf_par%d.txt',r),cuinf_par,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('caff_gain%d.txt',r),caff_gain,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('caff_loss%d.txt',r),caff_loss,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('cpartnerchoice%d.txt',r),cpartnerchoice,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('cselfchoice%d.txt',r),cselfchoice,'delimiter','\t','precision','%.6f')
    
    cd(maindir);
end

