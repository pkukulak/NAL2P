%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training/';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing/';
%fn_LME       = TODO;
%fn_LMF       = TODO;
%lm_type      = TODO;
%delta        = TODO;
% vocabSize    = TODO; 
% numSentences = TODO;

% Train your language models. This is task 2 which makes use of task 1
%LME = lm_train( trainDir, 'e', fn_LME );
%LMF = lm_train( trainDir, 'f', fn_LMF );
LME = load('hansard_e', '-mat');
%LMF = load('hansard_f', '-mat');

% Train your alignment model of French, given English 
%AMFE = align_ibm1( trainDir, numSentences );
% ... TODO: more 
AMFE_1 = load('am', '-mat');
AMFE_10 = load('am_10', '-mat');
AMFE_15 = load('am_15', '-mat');
AMFE_30 = load('am_30', '-mat');

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this  
lines_e = textread([testDir, filesep, 'Task5.e'], '%s','delimiter','\n');
lines_f = textread([testDir, filesep, 'Task5.f'], '%s','delimiter','\n');
lines_e_google = textread([testDir, filesep, 'Task5.google.e'], '%s','delimiter','\n');
% Decode the test sentence 'fre'
for i=1:2 %length(lines_e)
    fre = preprocess(lines_f{i}, 'f');
    
    command = strcat('env LD_LIBRARY_PATH='''' curl -u "7bc64b77-c00e-4b67-a916-de85af3d552b":"GmiB37fBLiSe" -X POST -F "text=', ...
        fre, '" -F "source=fr" -F "target=en" "https://gateway.watsonplatform.net/language-translation/api/v2/translate"');
    [resp, text] = unix(command);
    
    eng_bluemix_ref = preprocess(text, 'e');
    eng_hansard_ref =  preprocess(lines_e{i}, 'e');
    eng_google_ref  = preprocess(lines_e_google{i}, 'e');
    
    % Decode fre using our 4 trained models.
    % Uncomment these when you want to run the code.
    %eng_1  = decode( fre, LME.LM, AMFE_1.AM,  '', 0.01, 0 );
    %eng_10 = decode( fre, LME.LM, AMFE_10.AM, '', 0.01, 0 );
    %eng_15 = decode( fre, LME.LM, AMFE_15.AM, '', 0.01, 0 );
    %eng_30 = decode( fre, LME.LM, AMFE_30.AM, '', 0.01, 0 );
    
    %for n=1:3
        % Get the blue scores!
        % Note: this loop might be redundant now (hi phil)
    %end
    
end

% TODO: perform some analysis
% add BlueMix code here 

[status, result] = unix('')
