function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);


  % Iterate between E and M steps
  for iter=1:maxIter,
    disp(iter);
    AM = em_step(AM, eng, fre);
  end

  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
  %eng = {};
  %fre = {};

  % TODO: your code goes here.
  
  % 
  eng = {};
  fre = {};
  
  dir_e = dir([mydir, filesep, '*', 'e']);
  dir_f = dir([mydir, filesep, '*', 'f']);
  count = 0;
  for iFile=1:length(dir_e) % because we are assuming equal number of files.
      % read line i from the .e and .f files, and put into correct
      % structure.
      lines_e = textread([mydir, filesep, dir_e(iFile).name], '%s','delimiter','\n');
      lines_f = textread([mydir, filesep, dir_f(iFile).name], '%s','delimiter','\n');
      
      % Out of bounds check
      %if length(lines_e) < numSentences
      %    numSentences = length(lines_e);
      %end
      % Read numSentences lines from each file
      for iter=1:length(lines_e)
          count = count + 1;
          english_sentence = lines_e{iter};
          french_sentence = lines_f{iter};
          
          eng{count} = strsplit(' ',  preprocess(english_sentence, 'e'));
          fre{count} = strsplit(' ',  preprocess(french_sentence, 'f'));
          if (count == numSentences)
              return
          end
      end
  end
end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)
    % First loop over sentences
    for i=1:length(eng)
        % Loop over words in the sentence, not counting initial.
        for j=1:length(eng{i})       
            % Check if the english word has been encountered already
            % If not, create a field for it.
            if (~isfield(AM, eng{i}{j}))
                AM.(eng{i}{j}) = struct();
            end
            
            % For each word, loop over the words in the corresponding
            % french sentence.
            for k=1:length(fre{i})
                % Check if it's an existing word pair
                if ~isfield(AM.(eng{i}{j}), fre{i}{k})
                    AM.(eng{i}{j}).(fre{i}{k}) = 1;
                end
            end
        end
    end
    
    % Next, for each existing pair, need to normalize the value.
    english_words = fieldnames(AM);
    for i=1:length(english_words)
        % Get the associated french words.
        french_words = fieldnames(AM.(english_words{i}));
        normalized_value = 1/length(french_words);
        
        % loop over corresponding french words
        for j=1:length(french_words)
            AM.(english_words{i}).(french_words{j}) = normalized_value;
        end
    end
    
    % Force these constants.
    AM.SENTSTART.SENTSTART = 1;
    AM.SENTEND.SENTEND = 1;
end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
  
  % TODO: your code goes here
  
  % okay so t is our current AM model
  % eng and fre are cell-arrays of cell-arrays.
  % We adjust the current model and return it.
  
  tcount = struct(); % assume non-existant field -> field is zero.
  total = struct();
  % First loop over sentence pairs
  for i=1:length(eng)
      
      unique_words_e = unique(eng{i});
      unique_words_f = unique(fre{i});
      
      for j=1:length(unique_words_f)
          denom_c = 0;
          for k=1:length(unique_words_e)
              Fcountf = cellfun(@(x) sum(ismember((unique_words_f{j}),x)), fre(i));

              %if (strcmp(evalc(['disp(t.(unique_words_e{k}))']), 'SENTEND'))
              %    fieldnames(t.(unique_words_e{k}))
              %    Pfe = 0;
              %else
              Pfe = t.(unique_words_e{k}).(unique_words_f{j});
              %end
              % Count occurences of the word in the sentence.
              denom_c = denom_c + (Fcountf * Pfe);         
          end
          for k=1:length(unique_words_e)
              Pfe = t.(unique_words_e{k}).(unique_words_f{j});
              Ecounte = cellfun(@(x) sum(ismember((unique_words_e{k}),x)), eng(i));
              Fcountf = cellfun(@(x) sum(ismember((unique_words_f{j}),x)), fre(i));
              
              % Existence checks
              if ~isfield(tcount, (unique_words_e{k}))
                  tcount.(unique_words_e{k}) = struct((unique_words_f{j}), 0);
              end
              if ~isfield(tcount.(unique_words_e{k}), (unique_words_f{j}))
                  tcount.(unique_words_e{k}).(unique_words_f{j}) = 0;
              end
              
              % Increment tcount at position.
              tcount.(unique_words_e{k}).(unique_words_f{j}) = ...
                  tcount.(unique_words_e{k}).(unique_words_f{j}) + ...
                  Pfe * Ecounte * Fcountf / denom_c;
              
              
              % Existence check on total
              if ~isfield(total, (unique_words_e{k}))
                  total.(unique_words_e{k}) = 0;
              end
              
              % Increment total
              total.(unique_words_e{k}) = ...
                  total.(unique_words_e{k}) + ...
                  Pfe * Ecounte * Fcountf / denom_c;
              
          end
      end
      
      
  end
  english_words = fieldnames(total);
  for i=1:length(english_words)
      english_word = (english_words{i});
      associated_french_words = fieldnames(tcount.(english_word));
      
      for j=1:length(associated_french_words)
          french_word = (associated_french_words{j});
          t.(english_word).(french_word) = ...
              tcount.(english_word).(french_word) / total.(english_word);
      end
      
  end
end


