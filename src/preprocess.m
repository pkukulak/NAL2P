function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 

  global CSC401_A2_DEFNS
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down 
  inSentence = regexprep( inSentence, '\s+', ' '); 

  % initialize outSentence
  outSentence = inSentence;
  
  % perform language-agnostic changes
  space_left = ' $0';
  space_right = '$0 ';
  
  right_punc_rgx = '([.!?]+|[,;:]|\*|\&|\$|\%|/)';
  outSentence = regexprep(outSentence, right_punc_rgx, space_left);
  
  left_punc_rgx = '([.!?]+|[,:;]|\*|\&|\$|\%|/)';
  outSentence = regexprep(outSentence, left_punc_rgx, space_right);
  
  left_math_rgx = '\<\d+[+-<>=]';
  outSentence = regexprep(outSentence, left_math_rgx, space_right);
  
  right_math_rgx = '[+-<>=]\d+\>';
  outSentence = regexprep(outSentence, right_math_rgx, space_left);
  
  left_special_rgx = '[\[\]{}()`"]';
  outSentence = regexprep(outSentence, left_special_rgx, space_right);
  
  right_special_rgx = '[\[\]{}()"`]';
  outSentence = regexprep(outSentence, right_special_rgx, space_left);
  
  % splitting dashes; has to be fixed to only split dashes that are
  % between parenthesized words
  outSentence = regexprep(outSentence, '-', ' $0 ');
  
  switch language
   case 'e'
    outSentence = regexprep(outSentence, '(\w''t|''s?\>)', ' $0');
   case 'f'
    outSentence = regexprep(outSentence, '(qu|\<[tcjml])''', '$0 ');

  end

  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = regexprep( outSentence, '\s+', ' '); 
  outSentence = convertSymbols( outSentence );