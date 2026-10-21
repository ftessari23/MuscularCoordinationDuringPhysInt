%% Main script to reproduce the Main and Supporting Figures of the paper
%  "A Shared Command with Individualized Preferences Explains Muscle
%   Coordination During Physical Interaction"
%  DOI:
%
%  Code created by: Federico Tessari, PhD
%  Latest update:   10/20/2026
%  Run-time:        ~20 seconds
%
%  NOTE: all code lines that save figures to file are commented out.
%        Uncomment them (and create the "PaperFigures" folder) to export.

clear; clc;

addpath(genpath(fullfile(pwd, 'DIEM-main')));

musc = {'FCR','ECU','BIC','TRI','DA','DP','PM','TP'};   % muscle names
dirz = {'+x','+y','-x','-y'};                           % force directions

%% Loading Data
% Representative subject data
load('rep_subj_data.mat','t_rep_tr','EMG_rep_tr','t_rep_avg','EMG_rep_avg');

% Synergy analysis results (cVAF, EMG_time_tot, EMG_weight_tot)
load('EMG_syn_res_norm_max.mat');

% DIEM statistics (pre-computed)
load('DIEM_stats_8h_4315w.mat');
reqVars = {'exp_center_h','vard_h','min_DIEM_h','exp_center_w','vard_w','min_DIEM_w'};
for q = 1:numel(reqVars)
    assert(exist(reqVars{q},'var')==1, ...
        'Variable %s not found in DIEM_stats_8h_4315w.mat', reqVars{q});
end

% Force-hold and position-hold data
load('results_EMG_phases.mat');

%% Analysis constants
subjIDs = 7:20;            % Subjects used for synergy analysis (subjects 1-6 have no trapezius recording)
S       = numel(subjIDs);  % Number of subjects (14)
C       = 9;               % Number of conditions
nDirs   = 4;               % Number of force directions

%% Representative Subject Data
% Post-processed EMG of one representative subject (no. 17).
% Signal: flexor carpi radialis, direction +Y, condition F = 25 N, d = 50 mm.

triplet_f = [0 0.4470 0.7410];   % color of the single repetitions

fig = figure('Color','w','Units','inches','Position',[5 2 3.5 3.5]);

% Single repetitions, each with a dashed line at t = 0
for tr = 1:numel(t_rep_tr)
    plot(t_rep_tr{tr},EMG_rep_tr{tr},'Color',triplet_f,'LineWidth',1), hold on
    plot([0 0],[0 max(EMG_rep_tr{tr})],'k--','LineWidth',1)
end

% Average over repetitions
plot(t_rep_avg,EMG_rep_avg,'r','LineWidth',2)
ylim([0 30])
xlim([-0.5 1.5])
ylabel('EMG [\%]');
xlabel('Time [s]');

% Uncomment below to save figure (into existing subfolder "PaperFigures")
% outDir  = fullfile(pwd, 'PaperFigures');
% figFile = fullfile(outDir, 'rep_subj_data_plot.fig');
% svgFile = fullfile(outDir, 'rep_subj_data_plot.svg');
%
% drawnow;
% savefig(fig, figFile);
% exportgraphics(fig, svgFile, 'ContentType', 'vector');

%% Global figure defaults (applied to all figures created from here on)
set(groot,'DefaultLineLineWidth',2);
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultfigurecolor',[1 1 1]);             % white figure background
set(groot,'defaultAxesBox','on');
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultTextInterpreter','latex');

%% Synergy Temporal Evolution for 1, 2 and 3 extracted synergies
% For each number of extracted synergies (n_syn), collect cVAF and the
% mean-subtracted temporal evolution of every synergy across all
% directions x subjects x conditions, then compute mean and std.

nSamples = 4000;                  % samples kept per trace (2 s at 2 kHz)
t_syn    = 0:0.0005:(2-0.0005);   % time vector [s], length 4000

for n_syn = 1:3
    idx = 1;
    clear cVAF_tot
    EMG_syn = cell(1,n_syn);      % EMG_syn{s}: (traces x samples) for synergy s

    for iDir = 1:nDirs
        for s = 1:S
            for k = 1:C
                cVAF_tot(idx,:) = cVAF{subjIDs(s),iDir}(k,:);
                for syn_i = 1:n_syn
                    syn = EMG_time_tot{subjIDs(s),iDir,k}{n_syn}(:,syn_i);
                    syn = syn - mean(syn);
                    EMG_syn{syn_i}(idx,1:nSamples) = syn(1:nSamples);
                end
                idx = idx + 1;
            end
        end
    end

    synRes(n_syn).cVAF_tot = cVAF_tot;
    for syn_i = 1:n_syn
        synRes(n_syn).avg{syn_i} = mean(EMG_syn{syn_i});
        synRes(n_syn).std{syn_i} = std(EMG_syn{syn_i});
    end
end

%% Cumulative Variance-Accounted-For and First Synergy Temporal Evolution
cVAF_tot = synRes(1).cVAF_tot;
avg      = synRes(1).avg{1};
sd       = synRes(1).std{1};

fig2 = figure('Units','inches','Position',[3 3 7 3.5]);
tiledlayout(1,2)

% Left: cumulative VAF vs. number of synergies (90% threshold in red)
nexttile(1)
errorbar(1:8,mean(100*cVAF_tot),std(100*cVAF_tot),'o-k'), hold on
plot([1 8],[90 90],'--r')
ylim([0 100])
xticks(1:8)
xlabel('Number of Synergies')
ylabel('cVAF [\%]')

% Right: first synergy, mean +/- std (time 0 = force perturbation onset)
nexttile(2)
plot(t_syn-0.5,avg,'r','LineWidth',3), hold on
fill([t_syn, fliplr(t_syn)]-0.5, [avg+sd, fliplr(avg-sd)], ...
     'r','FaceAlpha',0.3,'EdgeColor','none');
plot([0 0],[-10 20],'k--')
xlabel('Time [s]')
ylabel('EMG-$\mu(EMG)$ [\%]')
title('$1^{st}$ Synergy')

% Uncomment below to save figure (into existing subfolder "PaperFigures")
% outDir  = fullfile(pwd, 'PaperFigures');
% figFile = fullfile(outDir, 'cVAF_1syn.fig');
% svgFile = fullfile(outDir, 'cVAF_1syn.svg');
%
% drawnow;
% savefig(fig2, figFile);
% exportgraphics(fig2, svgFile, 'ContentType', 'vector');

%% Synergy Temporal Evolution for 1, 2 and 3 extracted synergies - Figure
% Row r = solution with r synergies; column s = s-th synergy of that solution
fig3 = figure('Units','inches','Position',[1 1 7 6]);
tiledlayout(3,3,'TileSpacing','compact','Padding','compact');

for n_syn = 1:3
    for s = 1:n_syn
        nexttile(3*(n_syn-1) + s);

        avg = synRes(n_syn).avg{s};
        sd  = synRes(n_syn).std{s};

        plot(t_syn-0.5,avg,'r','LineWidth',2); hold on;
        fill([t_syn, fliplr(t_syn)]-0.5, [avg+sd, fliplr(avg-sd)], ...
             'r','FaceAlpha',0.3,'EdgeColor','none');
        plot([0 0],[-10 20],'k--');
        xticks(-0.5:0.25:1.5);
        ylim([-10 20]);

        if n_syn == 3
            xlabel('Time [s]');
        end
        if s == 1
            ylabel('EMG-$\mu(EMG)$ [\%]');
        end
        title(strcat('Extracted Synergies:',num2str(n_syn)))
        hold off;
    end
end

% Uncomment below to save figure (into existing subfolder "PaperFigures")
% outDir  = fullfile(pwd, 'PaperFigures');
% figFile = fullfile(outDir, '123_syn_te.fig');
% svgFile = fullfile(outDir, '123_syn_te.svg');
%
% drawnow;
% savefig(fig3, figFile);
% exportgraphics(fig3, svgFile, 'ContentType', 'vector');

%% Similarity Analysis (DIEM and Cosine Similarity) on H1-W1 - Data preparation
% W1 = 1st synergy temporal evolution, H1 = 1st synergy activation coefficients
% (unit length). Indices: {subject, direction, condition}.

% Collect W1/H1 and the length of each temporal-evolution vector
idx = 1;
for s = 1:S
    for j = 1:nDirs
        for k = 1:C
            w1{s,j,k}    = EMG_time_tot{subjIDs(s),j,k}{1};
            h1{s,j,k}    = EMG_weight_tot{subjIDs(s),j,k}{1};
            w1_length(idx) = length(w1{s,j,k});
            idx = idx + 1;
        end
    end
end
w1_min_length = min(w1_length);   % shortest temporal evolution

% Trim W1 to a common length and rescale:
%   W1 -> unit arithmetic mean;  H1 -> multiplied by the same mean
%   (so that the product H1*W1 is preserved)
idx = 1;
for s = 1:S
    for j = 1:nDirs
        for k = 1:C
            w1_nl{s,j,k} = w1{s,j,k}(1:w1_min_length);

            mean_temp(idx) = mean(w1_nl{s,j,k});

            w1_nl_zm{s,j,k}     = w1_nl{s,j,k}/mean_temp(idx);   % W1: equal length, unit mean
            w1_matrix_zm(:,idx) = w1_nl_zm{s,j,k};

            h1_sc{s,j,k} = h1{s,j,k}*mean_temp(idx);             % H1: amplitude rescaled by mean
            idx = idx + 1;
        end
    end
end

% Maximum values passed to DIEM for H1 and W1
maxH = max(mean_temp);
maxW = max(w1_matrix_zm(:));

%% Analyzing Similarity Using Cosine Similarity and DIEM
%  Statistic  : Delta = mean(within-subject sim) - mean(between-subject sim)
%               (Cosine: Delta > 0 => within more similar; DIEM: Delta < 0 => within more similar)
%  Inference  : (1) permutation test (subject labels shuffled within each condition)
%               (2) subject-level delete-one jackknife -> SE and approximate 95% CI
%               (3) Holm correction across the 16 tests
%  Descriptive: medians and rank-biserial correlation (not used for inference)

% --- Figure export settings (only needed if the export lines below are enabled) ---
% figWidth_in  = 7.5;   % max width in inches
% figHeight_in = 6;
% figDir = fullfile(pwd, 'PaperFigures');
% if ~exist(figDir, 'dir')
%     mkdir(figDir);
% end

% --- Analysis settings ---
nPerm    = 10000;     % permutations (smallest two-sided p = 2/(nPerm+1))
alphaLvl = 0.05;
tCrit    = tinv(1 - alphaLvl/2, S-1);
rng(1);

metricName = ["Cosine","Cosine","DIEM","DIEM"];   % order of the 4 similarity sets
compName   = ["H1","W1","H1","W1"];               % 1:cs_h  2:cs_w  3:diem_h  4:diem_w

triS  = triu(true(S),1);       % unique subject pairs (91)
triC  = triu(true(C),1);       % unique condition pairs (36)
triS1 = triu(true(S-1),1);     % same after deleting one subject
[ra, cb] = find(triC);         % condition pairs (a<b), same order as the within-subject columns
nPairsC = numel(ra);

% --- Permutation index table ---------------------------------------------
% One permutation = independent random relabelling of subjects in each condition.
% After permuting, the "within-subject" value for subject s and condition pair (a,b)
% is X_ab( pi_a(s), pi_b(s) ), where X_ab is the SxS cross-condition similarity block.
% Between-subject comparisons (same condition) are unchanged by this relabelling.
pairOffset = S*S*(0:nPairsC-1);                       % offset of block p in Xc(:)
off = repmat(pairOffset,S,1);                         % S x 36
permLin = zeros(nPerm, S*nPairsC, 'uint32');
for p = 1:nPerm
    Pm = zeros(S,C);
    for c = 1:C
        Pm(:,c) = randperm(S)';
    end
    ia = Pm(:,ra);  ib = Pm(:,cb);                    % S x 36
    permLin(p,:) = uint32(ia(:) + (ib(:)-1)*S + off(:))';
end

resultRows = cell(16,1);
ridx = 0;

% Plot settings shared by all similarity histograms
histColor = {'blue','red'};                           % 1: H1, 2: W1
compIdx   = [1 2 1 2];                                % component shown in each of the 4 tiles
figTitle  = {'Cosine Similarity - Dir: ','DIEM - Dir: '};
tileTitle = { ...
    'Between Subjects (same Condition) - $H_1$', ...
    'Between Subjects (same Condition) - $W_1$ (t)', ...
    'Within Subject (across Conditions) - $H_1$', ...
    'Within Subject (across Conditions) - $W_1 (t)$'; ...
    'Between Subjects (same Condition) - $H_1$', ...
    'Between Subjects (same Condition) - $W_1$ (t)', ...
    'Within Subject (across Conditions) - $H_1$', ...
    'Within Subject (across Conditions) - $W_1$ (t)'};

for iDir = 1:nDirs
    Bfull = cell(1,4);   % full SxSxC between-subject matrices, one per similarity set

    % ---- Between subjects: same condition, fixed direction (trial-averaged data) ----
    % H/W must be cleared: their number of columns differs between the
    % between-subject (S) and within-subject (C) parts.
    clearvars H W cs_tot_h cs_tot_w diem_tot_h diem_tot_w
    for k = 1:C
        for s = 1:S
            H(:,s) = h1_sc{s,iDir,k};
            W(:,s) = w1_nl_zm{s,iDir,k};
        end
        cs_h   = getCosineSimilarity(H,H,'Plot','off');
        cs_w   = getCosineSimilarity(W,W,'Plot','off');
        diem_h = getDIEM(H,H,maxH,0,exp_center_h,vard_h,'Plot','off');
        diem_w = getDIEM(W,W,maxW,0,exp_center_w,vard_w,'Plot','off');

        % unique subject pairs (upper triangle)
        cs_tot_h(:,k)   = cs_h(triS);
        cs_tot_w(:,k)   = cs_w(triS);
        diem_tot_h(:,k) = diem_h(triS);
        diem_tot_w(:,k) = diem_w(triS);

        % keep the full matrices (needed for the subject-level jackknife)
        Bfull{1}(:,:,k) = cs_h;    Bfull{2}(:,:,k) = cs_w;
        Bfull{3}(:,:,k) = diem_h;  Bfull{4}(:,:,k) = diem_w;
    end
    bsData = {cs_tot_h(:), cs_tot_w(:), diem_tot_h(:), diem_tot_w(:)};

    % ---- Within subject: different conditions, fixed direction (trial-averaged data) ----
    clearvars H W cs_tot_h cs_tot_w diem_tot_h diem_tot_w
    for s = 1:S
        for k = 1:C
            H(:,k) = h1_sc{s,iDir,k};
            W(:,k) = w1_nl_zm{s,iDir,k};
        end
        cs_h   = getCosineSimilarity(H,H,'Plot','off');
        cs_w   = getCosineSimilarity(W,W,'Plot','off');
        diem_h = getDIEM(H,H,maxH,0,exp_center_h,vard_h,'Plot','off');
        diem_w = getDIEM(W,W,maxW,0,exp_center_w,vard_w,'Plot','off');

        % unique condition pairs (upper triangle)
        cs_tot_h(:,s)   = cs_h(triC);
        cs_tot_w(:,s)   = cs_w(triC);
        diem_tot_h(:,s) = diem_h(triC);
        diem_tot_w(:,s) = diem_w(triC);
    end
    % per-subject within-subject values (36 x S), one array per similarity set
    Wcols  = {cs_tot_h, cs_tot_w, diem_tot_h, diem_tot_w};
    wsData = {cs_tot_h(:), cs_tot_w(:), diem_tot_h(:), diem_tot_w(:)};

    % ---- Histograms: between vs. within subject (dashed line = median) ----
    % x-axis limits per similarity type (row) and component (column: H1, W1)
    xl = {[0.7 1], [0.7 1]; ...
          [min_DIEM_h max(bsData{3})], [min_DIEM_w max(bsData{4})]};

    simFigs = gobjects(1,2);
    for sim = 1:2                                     % 1: Cosine, 2: DIEM
        mH = 2*sim-1;  mW = 2*sim;                    % indices of the H1 / W1 sets
        simFigs(sim) = figure(2*iDir+1+sim);          % figure numbers 4..11
        tl = tiledlayout(2,2);
        % (strcat is kept on purpose: it trims the trailing blank of the title string)
        title(tl,strcat(figTitle{sim},dirz{iDir}),'FontName','Times New Roman')

        plotData = {bsData{mH}, bsData{mW}, wsData{mH}, wsData{mW}};
        for q = 1:4
            x = plotData{q};
            nexttile(q)
            h = histogram(x,'FaceColor',histColor{compIdx(q)},'EdgeColor','none'); hold on
            plot([median(x) median(x)],[0 max(h.Values)],'k--'), box off
            xlim(xl{sim,compIdx(q)})
            title(tileTitle{sim,q})
        end
        ylabel(tl,'Frequency','FontName','Times New Roman')
    end

    % Uncomment below to format and save the Cosine and DIEM figures
    % simTag = {'Cosine','DIEM'};
    % for e = 1:2
    %     set(simFigs(e), 'Units','inches', 'Position',[1 1 figWidth_in figHeight_in])
    %     set(simFigs(e), 'PaperUnits','inches', 'PaperPosition',[0 0 figWidth_in figHeight_in])
    %     set(simFigs(e), 'PaperSize',[figWidth_in figHeight_in])
    %
    %     fname = sprintf('Similarity_%s_Dir_%s', simTag{e}, dirz{iDir});
    %     savefig(simFigs(e), fullfile(figDir, [fname '.fig']));
    %     print(simFigs(e), fullfile(figDir, fname), '-dsvg', '-painters');
    % end

    % ---- Cross-condition similarity blocks (needed only by the permutation test) ----
    % Xc{m}(s,t,p) = similarity between subject s in condition ra(p) and subject t in
    % condition cb(p). Its diagonal is the original within-subject value.
    Xc = repmat({zeros(S,S,nPairsC)},1,4);
    for p = 1:nPairsC
        for s = 1:S
            Ha(:,s) = h1_sc{s,iDir,ra(p)};    Hb(:,s) = h1_sc{s,iDir,cb(p)};
            Wa(:,s) = w1_nl_zm{s,iDir,ra(p)}; Wb(:,s) = w1_nl_zm{s,iDir,cb(p)};
        end
        Xc{1}(:,:,p) = getCosineSimilarity(Ha,Hb,'Plot','off');
        Xc{2}(:,:,p) = getCosineSimilarity(Wa,Wb,'Plot','off');
        Xc{3}(:,:,p) = getDIEM(Ha,Hb,maxH,0,exp_center_h,vard_h,'Plot','off');
        Xc{4}(:,:,p) = getDIEM(Wa,Wb,maxW,0,exp_center_w,vard_w,'Plot','off');
    end

    % Consistency check: block diagonals must reproduce the original within-subject values
    for m = 1:4
        dg = zeros(nPairsC,S);
        for p = 1:nPairsC
            dg(p,:) = diag(Xc{m}(:,:,p))';
        end
        fprintf('Dir %s, set %d: max |diag - original within| = %.2e\n', ...
            dirz{iDir}, m, max(abs(dg(:) - wsData{m})));
    end

    % ---- Statistics: permutation test + subject-level jackknife ----
    for m = 1:4
        x_bs = bsData{m};
        x_ws = wsData{m};
        a    = mean(Wcols{m},1)';              % S x 1: per-subject mean within-subject similarity
        B    = mean(Bfull{m},3);               % S x S: per-subject-pair mean between-subject similarity

        meanWithin  = mean(a);
        meanBetween = mean(B(triS));
        D = meanWithin - meanBetween;

        % (1) Permutation test. The between-subject mean is invariant under
        %     within-condition relabelling, so only the within-subject term changes.
        Xflat      = Xc{m}(:);
        nullWithin = mean(Xflat(permLin),2);   % nPerm x 1
        nullDelta  = nullWithin - meanBetween;
        pUp   = (1 + sum(nullDelta >= D)) / (nPerm + 1);
        pLo   = (1 + sum(nullDelta <= D)) / (nPerm + 1);
        pPerm = min(1, 2*min(pUp,pLo));        % two-sided

        % (2) Subject-level delete-one jackknife
        dLOO = zeros(S,1);
        for i = 1:S
            keep = setdiff(1:S,i);
            Bk = B(keep,keep);
            dLOO(i) = mean(a(keep)) - mean(Bk(triS1));
        end
        SE_J  = sqrt((S-1)/S * sum((dLOO - mean(dLOO)).^2));
        CI_lo = D - tCrit*SE_J;
        CI_hi = D + tCrit*SE_J;
        pJack = 2*tcdf(-abs(D/SE_J), S-1);

        % Influence diagnostics (flag: one subject > 50% of jackknife variance)
        dev2 = (dLOO - mean(dLOO)).^2;
        [maxDev, iMax] = max(dev2);
        infShare = maxDev/sum(dev2);
        signChg  = any(sign(dLOO) ~= sign(D));

        % Descriptive: rank-biserial correlation (between vs. within)
        n1 = numel(x_bs);  n2 = numel(x_ws);
        rk  = tiedrank([x_bs; x_ws]);
        U1  = sum(rk(1:n1)) - n1*(n1+1)/2;
        rbs = 1 - 2*U1/(n1*n2);

        % Cosine: higher = more similar; DIEM: lower = more similar
        if metricName(m) == "Cosine"
            withinHigher = D > 0;
        else
            withinHigher = D < 0;
        end

        ridx = ridx + 1;
        resultRows{ridx} = struct( ...
            'Direction', string(dirz{iDir}), ...
            'Metric', metricName(m), ...
            'Component', compName(m), ...
            'N_Subjects', S, ...
            'N_Within', n2, ...
            'N_Between', n1, ...
            'Mean_Within', meanWithin, ...
            'Mean_Between', meanBetween, ...
            'Delta_WithinMinusBetween', D, ...
            'WithinMoreSimilar', withinHigher, ...
            'Perm_NullMeanDelta', mean(nullDelta), ...
            'p_Perm', pPerm, ...
            'Jack_SE', SE_J, ...
            'Jack_CI95_Lower', CI_lo, ...
            'Jack_CI95_Upper', CI_hi, ...
            'p_Jack', pJack, ...
            'LOO_Delta_Min', min(dLOO), ...
            'LOO_Delta_Max', max(dLOO), ...
            'LOO_SignChange', signChg, ...
            'MostInfluentialSubject', subjIDs(iMax), ...
            'MaxInfluenceShare', infShare, ...
            'InfluenceFlag', infShare > 0.5, ...
            'Median_Between', median(x_bs), ...
            'Median_Within', median(x_ws), ...
            'RankBiserial_BetweenVsWithin', rbs );
    end
    fprintf('Direction %s done\n', dirz{iDir});
end

%% Holm correction across the 16 tests and results table
resultsTbl = struct2table(vertcat(resultRows{:}));
mTests     = height(resultsTbl);

pRaw  = {'p_Perm',      'p_Jack'};        % primary: permutation; sensitivity: jackknife t(S-1)
pHolm = {'p_Perm_Holm', 'p_Jack_Holm'};
pSig  = {'Sig_Perm_Holm','Sig_Jack_Holm'};
for q = 1:2
    [ps,ord] = sort(resultsTbl.(pRaw{q}));
    adj = min(1, cummax((mTests - (1:mTests)' + 1) .* ps));
    pH = zeros(mTests,1);
    pH(ord) = adj;
    resultsTbl.(pHolm{q}) = pH;
    resultsTbl.(pSig{q})  = pH < alphaLvl;
end

disp(resultsTbl(:,{'Direction','Metric','Component','Delta_WithinMinusBetween', ...
    'Jack_CI95_Lower','Jack_CI95_Upper','p_Perm','p_Perm_Holm','p_Jack_Holm', ...
    'RankBiserial_BetweenVsWithin','MaxInfluenceShare','InfluenceFlag'}))
fprintf('Smallest attainable two-sided permutation p = %.2e (nPerm = %d)\n', 2/(nPerm+1), nPerm);

% writetable(resultsTbl, 'SimilarityStats_PermJackknife.csv');
% save('SimilarityStats_PermJackknife.mat','resultsTbl','nPerm');

%% Sanity Check
% Off-diagonal check: block entry vs. explicit calculation (-x, first condition pair)
dirSel = 3;  pairSel = 1;  sSel = 2;  tSel = 5;
for q = 1:S
    Ha(:,q) = h1_sc{q,dirSel,ra(pairSel)};
    Hb(:,q) = h1_sc{q,dirSel,cb(pairSel)};
end
va = Ha(:,sSel);  vb = Hb(:,tSel);

% Cosine: explicit formula
Xc1 = getCosineSimilarity(Ha,Hb,'Plot','off');
fprintf('Cosine: block(s,t) = %.12f | manual = %.12f | block(t,s) = %.12f\n', ...
        Xc1(sSel,tSel), (va'*vb)/(norm(va)*norm(vb)), Xc1(tSel,sSel));

% DIEM: use a 2-column input so the function sees a matrix, not a vector
Xd = getDIEM(Ha,Hb,maxH,0,exp_center_h,vard_h,'Plot','off');
d2 = getDIEM([va va],[vb vb],maxH,0,exp_center_h,vard_h,'Plot','off');
fprintf('DIEM:   block(s,t) = %.12f | direct = %.12f | block(t,s) = %.12f\n', ...
        Xd(sSel,tSel), d2(1,1), Xd(tSel,sSel));

%% Force Hold vs Position Hold - Between Subjects - Bar Plot per Muscle
phSubjIDs  = 5:18;                            % indices of the 14 subjects in results_EMG_avg
subj_names = "S" + string(1:S);               % x-axis labels S1 ... S14

FH_color = [0 0 1];                           % force hold
PH_color = [1 0 0];                           % position hold

for mus = 1:8
    fig = figure('Units','inches','Position',[1 0.5 8 5]);
    tl = tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
    sgtitle(['Muscle: ' musc{mus}], 'FontName','Times New Roman', 'FontSize', 14)

    for iDir = 1:nDirs
        ax = nexttile;
        hold(ax,'on')

        % Mean and std (over the 9 conditions) of the muscle EMG, per subject
        FH_mean = zeros(1,S); PH_mean = zeros(1,S);
        FH_std  = zeros(1,S); PH_std  = zeros(1,S);
        for s = 1:S
            fh_vec = results_EMG_avg.fh{phSubjIDs(s), iDir}.mean(:,mus);
            ph_vec = results_EMG_avg.ph{phSubjIDs(s), iDir}.mean(:,mus);
            FH_mean(s) = mean(fh_vec, 'omitnan');
            PH_mean(s) = mean(ph_vec, 'omitnan');
            FH_std(s)  = std(fh_vec, 'omitnan');
            PH_std(s)  = std(ph_vec, 'omitnan');
        end

        % Grouped bars (semi-transparent, no edge)
        b = bar(ax, 1:S, [FH_mean; PH_mean]', 'grouped', 'BarWidth', 1);
        b(1).FaceColor = FH_color; b(1).FaceAlpha = 0.6; b(1).EdgeColor = 'none';
        b(2).FaceColor = PH_color; b(2).FaceAlpha = 0.6; b(2).EdgeColor = 'none';

        % Error bars: color-matched, no caps
        xtips = zeros(S,2);
        for k = 1:numel(b)
            xtips(:,k) = b(k).XEndPoints;
        end
        er1 = errorbar(ax, xtips(:,1), FH_mean, FH_std, 'LineStyle','none', 'LineWidth',1.2, 'CapSize',0);
        er1.Color = FH_color;
        er2 = errorbar(ax, xtips(:,2), PH_mean, PH_std, 'LineStyle','none', 'LineWidth',1.2, 'CapSize',0);
        er2.Color = PH_color;

        if iDir == 1
            hLegendElements = b;              % handles used for the shared legend
        end

        % Axis formatting
        ax.XTick = 1:S;
        ax.XTickLabel = subj_names;
        ax.XTickLabelRotation = 45;
        ax.FontSize = 12;
        ax.FontName = 'Times New Roman';
        if iDir == 1 || iDir == 3
            ylabel(ax, 'EMG %', 'FontName','Times New Roman');
        end
        ylim(ax, [0 20]);
        title(ax, dirz{iDir}, 'FontName','Times New Roman', 'FontSize', 12)
        box(ax,'off')
        hold(ax,'off')
    end

    % Shared legend, manually positioned relative to the tiledlayout
    lgd = legend(hLegendElements, {'FH','PH'}, ...
        'Orientation','horizontal', 'Box','off', ...
        'FontSize',10, 'FontName','Times New Roman');

    tp   = tl.InnerPosition;                  % [x y w h], normalized
    lg_w = 0.5;
    lg_h = 0.03;
    lg_x = tp(1) + 0.70*(tp(3) - lg_w);
    lg_y = tp(2) - lg_h + 0.37;
    lgd.Units    = 'normalized';
    lgd.Position = [lg_x lg_y lg_w lg_h];

    % Uncomment below to save figure
    % folder = 'PaperFigures';
    % if ~exist(folder,'dir'), mkdir(folder); end
    % filename = fullfile(folder, ['ma_bet_sub_' musc{mus} '_alldir']);
    %
    % savefig(fig, [filename '.fig']);
    % exportgraphics(fig, [filename '.svg'], 'ContentType','vector');
end

%% 2-way ANOVA: effect of subject (columns) and phase, FH vs PH (rows)
% anova2 output p = [p_columns (subject), p_rows (phase), p_interaction]
p_res = zeros(8,3,nDirs);          % (muscle, effect, direction)
for mus = 1:8
    for iDir = 1:nDirs
        mus_act = [];
        for s = 1:S
            temp = [results_EMG_avg.fh{phSubjIDs(s), iDir}.mean(:,mus); ...
                    results_EMG_avg.ph{phSubjIDs(s), iDir}.mean(:,mus)];
            mus_act = [mus_act, temp];
        end
        p_res(mus,:,iDir) = anova2(mus_act,9,'off');   % 9 replicates per cell
    end
end

%% DIEM Statistics for the between-subjects FH / PH comparison
% Maximum EMG over all subjects, directions, phases and muscles
maxEMG = zeros(18,nDirs);
for subj = 1:18
    for iDir = 1:nDirs
        maxEMG(subj,iDir) = max( ...
            max(results_EMG_avg.fh{subj,iDir}.mean(:,1:8),[],'all'), ...
            max(results_EMG_avg.ph{subj,iDir}.mean(:,1:8),[],'all'));
    end
end
maxV = max(maxEMG(:));
minV = 0;

% Pre-computed DIEM statistics (exp_center_bs, vard_bs, min_DIEM_bs, ...)
load('DIEM_stat_N8_bs.mat')
% To re-compute them, uncomment the lines below. Because of the stochastic
% nature of DIEM, this slightly changes some numbers. To reproduce the exact
% results of the paper, use the load command above.
% N = 8;
% fig_flag = 0;
% [exp_center_bs,vard_bs,std_one_bs,orth_med_bs,min_DIEM_bs,max_DIEM_bs] = DIEM_Stat(N,maxV,minV,fig_flag);

%% Between-Subjects DIEM on mean EMG - Force Hold and Position Hold figures
% For each direction and each phase: histogram of the DIEM over all subject
% pairs + bar plots of the subject pairs with minimum / median / maximum DIEM.

statNames  = {'min','med','max'};
phaseField = {'force','position'};
phaseTitle = {'Force Hold: ','Position Hold: '};
histClr    = {'blue','red'};
barClr     = {[0.2 0.4 0.8],  [0.6 0.8 1.0]; ...     % FH: darker / lighter blue
              [0.85 0.3 0.3], [1.0 0.6 0.6]};         % PH: darker / lighter red
% exportTag  = {'FH_DIEM_bs_','PH_DIEM_bs_'};

diem_stats = struct();
for iDir = 1:nDirs
    % Mean EMG of each muscle (8 x S), per subject and phase
    for s = 1:S
        fh_v(:,s) = mean(results_EMG_avg.fh{phSubjIDs(s), iDir}.mean(:,1:8),1);
        ph_v(:,s) = mean(results_EMG_avg.ph{phSubjIDs(s), iDir}.mean(:,1:8),1);
    end
    meanEMG = {fh_v, ph_v};

    for ph = 1:2                                      % 1: force hold, 2: position hold
        v = meanEMG{ph};

        % DIEM between all subject pairs (upper triangle only)
        DIEMmat = getDIEM(v,v,maxV,minV,exp_center_bs,vard_bs,'Plot','off');
        DIEMmat = triu(DIEMmat,1);
        DIEMmat(DIEMmat == 0) = NaN;
        diemVec = DIEMmat(~isnan(DIEMmat));

        % Min / median / max DIEM and the subject pair [row col] that produced each
        st = struct('min',min(diemVec), 'med',median(diemVec), 'max',max(diemVec));
        for q = 1:3
            [r,c] = find(DIEMmat == st.(statNames{q}));
            st.([statNames{q} '_idx']) = [r c];
        end
        diem_stats(iDir).(phaseField{ph}) = st;

        % --- Figure ---
        figDIEM = figure('Color','white','Units','inches','Position',[1 1 8 3.5]);
        tl = tiledlayout(1,5);
        title(tl,strcat(phaseTitle{ph},dirz{iDir}),'FontName','Times New Roman')

        % DIEM histogram (dashed lines: DIEM minimum and zero)
        nexttile(1,[1 2])
        hDIEM = histogram(DIEMmat(:),'BinWidth',1.5,'EdgeColor','none','FaceColor',histClr{ph}); hold on
        plot([min_DIEM_bs min_DIEM_bs],[0 max(hDIEM.Values)],'--k','LineWidth',0.5)
        plot([0 0],[0 max(hDIEM.Values)],'--k','LineWidth',0.5)
        box off
        xlim([1.1*min_DIEM_bs 0])
        ylabel('Frequency','FontName','Times New Roman')
        xlabel('DIEM','FontName','Times New Roman')

        % EMG profiles of the min / median / max DIEM subject pairs
        for q = 1:3
            nm   = statNames{q};
            pair = st.([nm '_idx']);

            nexttile
            b = barh(1:8,[v(:,pair(1))'; v(:,pair(2))']);
            b(1).FaceColor = barClr{ph,1};
            b(2).FaceColor = barClr{ph,2};
            yticklabels(musc);
            set(gca,'TickLabelInterpreter','tex','FontName','Times New Roman')
            title(strcat('DIEM_{',nm,'}=',num2str(round(st.(nm),2))),'Interpreter','tex','FontSize',8)
            subtitle(strcat('Subj. ',num2str(pair(1)),' vs. Subj. ',num2str(pair(2))),'FontSize',7)
            if q == 1
                ylabel('Muscles')
            elseif q == 2
                xlabel('Average EMG Activation [\%]')
            end
            box off
            xlim([0 20])
        end

        % Uncomment below to save figure
        % folder = 'PaperFigures';
        % if ~exist(folder,'dir'), mkdir(folder); end
        % filename = fullfile(folder, [exportTag{ph} dirz{iDir}]);
        %
        % savefig(figDIEM, [filename '.fig']);
        % exportgraphics(figDIEM, [filename '.svg'], 'ContentType','vector');
    end
end