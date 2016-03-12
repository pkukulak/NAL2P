%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% Directories.
trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training/';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing/';

% The English language model.
LME = load('hansard_e', '-mat');

% A special formatting string for nice output.
line_break = '--------------';

% All of our pre-built alignment models.
AMFE_1 = load('am', '-mat');
AMFE_10 = load('am_10', '-mat');
AMFE_15 = load('am_15', '-mat');
AMFE_30 = load('am_30', '-mat');

% Cell arrays to track scores.
scores_1 = {};
scores_10 = {};
scores_15 = {};
scores_30 = {};

% Open up our test files.
lines_e = textread([testDir, filesep, 'Task5.e'], '%s','delimiter','\n');
lines_f = textread([testDir, filesep, 'Task5.f'], '%s','delimiter','\n');
lines_e_google = textread([testDir, filesep, 'Task5.google.e'], '%s','delimiter','\n');

% Evaluate each training sentence.
for i=1:length(lines_e)
    % Preprocess the French sentence.
    fre = preprocess(lines_f{i}, 'f');
    
    command = strcat('env LD_LIBRARY_PATH='''' curl -u "7bc64b77-c00e-4b67-a916-de85af3d552b":"GmiB37fBLiSe" -X POST -F "text=', ...
        fre, '" -F "source=fr" -F "target=en" "https://gateway.watsonplatform.net/language-translation/api/v2/translate"');
    [resp, text] = unix(command);
    
    % Bluemix translation is already preprocessed.
    % However, Bluemix doesn't follow our convention and
    % it yields words like " don't ", which breaks
    % everything. So, we re-preprocess it.
    consts = fieldnames(CSC401_A2_DEFNS);
    eng_bluemix_ref = preprocess(text, 'e');
    for k=1:numel(consts)
        lower_c = lower(CSC401_A2_DEFNS.(consts{k}));
        upper_c = upper(CSC401_A2_DEFNS.(consts{k}));
        eng_bluemix_ref = regexprep(eng_bluemix_ref, lower_c, upper_c); 
    end
    
    % Our reference sentences.
    eng_bluemix_ref = strsplit(' ', eng_bluemix_ref);
    eng_bluemix_ref = strjoin(eng_bluemix_ref(2:end-1));
    eng_hansard_ref =  preprocess(lines_e{i}, 'e');
    eng_google_ref  = preprocess(lines_e_google{i}, 'e');
    
    % As given, decode2.m is BROKEN. We have made some changes to fix
    % the problem where PERIOD_ appears almost randomly after decoding.
    % The only remaining problem is that SENTSTART also seems to appear
    % randomly in an otherwise reasonable decoding. bleuscore.m contains
    % a hacky fix on the input candidate to fix that.
    eng_1  = decode2( fre, LME.LM, AMFE_1.AM,  '', 0.01, 0 );
    eng_10 = decode2( fre, LME.LM, AMFE_10.AM, '', 0.01, 0 );
    eng_15 = decode2( fre, LME.LM, AMFE_15.AM, '', 0.01, 0 );
    eng_30 = decode2( fre, LME.LM, AMFE_30.AM, '', 0.01, 0 );
    
    % Track our scores.
    scores_1{i} = bleuscore({eng_bluemix_ref, eng_hansard_ref, eng_google_ref}, eng_1);
    scores_10{i} = bleuscore({eng_bluemix_ref, eng_hansard_ref, eng_google_ref}, eng_10);
    scores_15{i} = bleuscore({eng_bluemix_ref, eng_hansard_ref, eng_google_ref}, eng_15);
    scores_30{i} = bleuscore({eng_bluemix_ref, eng_hansard_ref, eng_google_ref}, eng_30);
    
    % Display the scores for this sentences.
    disp(scores_1{i});
    disp(scores_10{i});
    disp(scores_15{i});
    disp(scores_30{i});
    disp(line_break);
end

% Save our scores.
save('scores_1', 'scores_1', '-mat');
save('scores_10', 'scores_10', '-mat');
save('scores_15', 'scores_15', '-mat');
save('scores_30', 'scores_30', '-mat');
