function LM = lm_train(dataDir, language, fn_LM)
%
%  lm_train
% 
%  This function reads data from dataDir, computes unigram and bigram counts,
%  and writes the result to fn_LM
%
%  INPUTS:
%
%       dataDir     : (directory name) The top-level directory containing 
%                                      data from which to train or decode
%                                      e.g., '/u/cs401/A2_SMT/data/Toy/'
%       language    : (string) either 'e' for English or 'f' for French
%       fn_LM       : (filename) the location to save the language model,
%                                once trained
%  OUTPUT:
%
%       LM          : (variable) a specialized language model structure  
%
%  The file fn_LM must contain the data structure called 'LM', 
%  which is a structure having two fields: 'uni' and 'bi', each of which holds
%  sub-structures which incorporate unigram or bigram COUNTS,
%
%       e.g., LM.uni.word = 5       % the word 'word' appears 5 times
%             LM.bi.word.bird = 2   % the bigram 'word bird' appears twice
% 
% Template (c) 2011 Frank Rudzicz

global CSC401_A2_DEFNS

LM=struct();
LM.uni = struct();
LM.bi = struct();

SENTSTARTMARK = 'SENTSTART'; 
SENTENDMARK = 'SENTEND';

DD = dir( [ dataDir, filesep, '*', language] );

disp([ dataDir, filesep, '.*', language] );

for iFile=1:length(DD)

  lines = textread([dataDir, filesep, DD(iFile).name], '%s','delimiter','\n');

  for l=1:length(lines)

    processedLine =  preprocess(lines{l}, language);
    % We append 'EOL' to each sentence to ensure we hit
    % the marker SENTEND.
    words = [strsplit(' ', processedLine), 'EOL'];
    
    for i=1:length(words)-1
        
        if (isempty(words{i}) || isempty(words{i+1})) 
            continue 
        end 
        
        % Check if the unigram does not occur in the unigram substruct.
        if ( ~isfield(LM.uni, (words{i})) ) 
            LM.uni.(words{i}) = 1;
        % Otherwise, increment it's unigram count.
        else
            LM.uni.(words{i}) = LM.uni.(words{i}) + 1;
        end

        % Check if the first word in the 
        % bigram does not occur in the bigram substruct.
        if ( ~isfield(LM.bi, (words{i})) )
            LM.bi.(words{i}) = struct((words{i+1}), 1);
        % Otherwise, check if the bigram word occurs as a field
        % in the bigram substruct's substruct corresponding to the
        % unigram word.
        elseif ( ~isfield(LM.bi.(words{i}), (words{i+1})) )
            LM.bi.(words{i}).(words{i+1}) = 1;
        % Otherwise, the entire bigram has been seen before and currently
        % holds a value in the bigram substruct.
        else
            LM.bi.(words{i}).(words{i+1}) = ...
                             LM.bi.(words{i}).(words{i+1}) + 1;
        end
        
    end
    
  end
  
end

save( fn_LM, 'LM', '-mat'); 