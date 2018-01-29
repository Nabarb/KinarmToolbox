function ParseBlockList( tsk )
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% TP Useful indexes
%
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generates some useful lists, as the index of a block change,
% the number of the block the trial is currently into, and the amount
% of trials in each block

% creates a vector the same length as the experiment with, for each trial,
% the number of the block we are currently in
BlocksUsed = size(tsk.BlockTable,1);
ChangeBlockIndex=zeros(1,BlocksUsed+1);
isCatchTrial=false(1,tsk.NTrials);

for k=1:BlocksUsed
    
    %%%%%%%%%%%%
    % Parsing Catch trial list
    String=tsk.BlockTable.CATCH_TP_LIST{k};
    tsk.BlockTable.CATCH_TP_LIST{k}=str2num(strrep(String,'-',':'));
    
    %%%%%%%%%%%%
    % Parsing trial protocol list
    String=tsk.BlockTable.TP_LIST{k};
    tsk.BlockTable.TP_LIST{k}=str2num(strrep(String,'-',':'));
    
        NumTrailsInBlocks(k)= tsk.BlockTable.LIST_REPS{k}*length(tsk.BlockTable.TP_LIST{k});
    
%     tmp=ones(NumTrailsInBlocks(k),1)*...
%         [1:tsk.BlockTable.LIST_REPS{k}]+k-1;
%     tmp=reshape(tmp,numel(tmp),[]);
    
    
%     BlockInExperiment = [BlockInExperiment ;tmp];
    ChangeBlockIndex(k+1) = ChangeBlockIndex(k) +...
        NumTrailsInBlocks(k) .* tsk.BlockTable.BLOCK_REPS{k}';
    
%      INDEX=ChangeBlockIndex(k)+1:ChangeBlockIndex(k+1);
end
tsk.ChangeBlockIndex=ChangeBlockIndex;



end

function [c, matches] = strsplit(str, aDelim, varargin)
%STRSPLIT  Split string at delimiter
%   C = STRSPLIT(STR) splits the character vector or string scalar STR at
%   whitespace into C.
%
%   C = STRSPLIT(STR, DELIMITER) splits STR at DELIMITER into C. If
%   DELIMITER is a cell array of character vectors, STRSPLIT splits STR
%   along the elements in DELIMITER, in the order in which they appear in
%   the cell array.
%
%   C = STRSPLIT(STR, DELIMITER, PARAM1, VALUE1, ... PARAMN, VALUEN)
%   modifies the way in which STR is split at DELIMITER.
%
%     Valid parameters are:
%
%     'CollapseDelimiters' - If true (default), consecutive delimiters in
%         STR are treated as one. If false, consecutive delimiters are
%         treated as separate delimiters, resulting in text with no
%         characters between matched delimiters.
%     'DelimiterType' - DelimiterType can have the following values:
%         'Simple' (default) - Except for escape sequences, STRSPLIT treats
%             DELIMITER as a literal.
%         'RegularExpression' - STRSPLIT treats DELIMITER as a regular
%             expression.
%         In both cases, DELIMITER can include the following escape
%         sequences:
%             \\   Backslash             \n   New line
%             \0   Null                  \r   Carriage return
%             \a   Alarm                 \t   Horizontal tab
%             \b   Backspace             \v   Vertical tab
%             \f   Form feed
%
%   [C, MATCHES] = STRSPLIT(...) also returns the cell array of character
%   vectors MATCHES containing the DELIMITERs upon which STR was split.
%   Note that MATCHES always contains one fewer element than C.
%
%   NOTE: STR can be a string array or character vector. DELIMITER can be
%   a string array, character vector, or cell array of character vectors.
%   When STR is a string array, outputs C and MATCHES are string arrays.
%   Otherwise, C and MATCHES are cell arrays of character vectors.
%
%   Examples:
%
%       str = 'The rain in Spain stays mainly in the plain.';
%
%       % Split on all whitespace.
%       strsplit(str)
%       % {'The', 'rain', 'in', 'Spain', 'stays',
%       %  'mainly', 'in', 'the', 'plain.'}
%
%       % Split on 'ain'.
%       strsplit(str, 'ain')
%       % {'The r', ' in Sp', ' stays m', 'ly in the pl', '.'}
%
%       % Split on ' ' and on 'ain' (treating multiple delimiters as one).
%       strsplit(str, {' ', 'ain'})
%       % ('The', 'r', 'in', 'Sp', 'stays',
%       %  'm', 'ly', 'in', 'the', 'pl', '.'}
%
%       % Split on all whitespace and on 'ain', and treat multiple
%       % delimiters separately.
%       strsplit(str, {'\s', 'ain'}, 'CollapseDelimiters', false, ...
%                     'DelimiterType', 'RegularExpression')
%       % {'The', 'r', '', 'in', 'Sp', '', 'stays',
%       %  'm', 'ly', 'in', 'the', 'pl', '.'}
%
%   See also SPLIT, JOIN, STRJOIN, REGEXP, CONTAINS, COUNT, EXTRACTBETWEEN,
%   STRFIND

%   Copyright 2012-2016 The MathWorks, Inc.

% Initialize default values.
collapseDelimiters = true;
delimiterType = 'Simple';

% Check input arguments.
if nargin < 1
    narginchk(1, Inf);
elseif ~ischar(str) && ~(isstring(str) && isscalar(str))
    error(message('MATLAB:strsplit:InvalidStringType'));
end
if nargin < 2
    delimiterType = 'RegularExpression';
    aDelim = {'\s'};
elseif ischar(aDelim)
    aDelim = {aDelim};
elseif isstring(aDelim)
    aDelim(ismissing(aDelim)) = [];
    aDelim = cellstr(aDelim);
elseif ~iscellstr(aDelim)
    error(message('MATLAB:strsplit:InvalidDelimiterType'));
end
if nargin > 2
    funcName = mfilename;
    p = inputParser;
    p.FunctionName = funcName;
    p.addParameter('CollapseDelimiters', collapseDelimiters);
    p.addParameter('DelimiterType', delimiterType);
    p.parse(varargin{:});
    collapseDelimiters = verifyScalarLogical(p.Results.CollapseDelimiters, ...
        funcName, 'CollapseDelimiters');
    delimiterType = validatestring(p.Results.DelimiterType, ...
        {'RegularExpression', 'Simple'}, funcName, 'DelimiterType');
end

% Handle DelimiterType.
if strcmp(delimiterType, 'Simple')
    % Handle escape sequences and translate.
    aDelim = strescape(aDelim);
    aDelim = regexptranslate('escape', aDelim);
else
    % Check delimiter for regexp warnings.
    regexp('', aDelim, 'warnings');
end

% Handle multiple delimiters.
aDelim = strjoin(aDelim, '|');

% Handle CollapseDelimiters.
if collapseDelimiters
    aDelim = ['(?:', aDelim, ')+'];
end

% Split.
[c, matches] = regexp(str, aDelim, 'split', 'match');

end
%--------------------------------------------------------------------------
function tf = verifyScalarLogical(tf, funcName, parameterName)

if isscalar(tf) && (islogical(tf) || (isnumeric(tf) && any(tf == [0, 1])))
    tf = logical(tf);
else
    validateattributes(tf, {'logical'}, {'scalar'}, funcName, parameterName);
end

end

function str = strescape(str)
%STRESCAPE  Escape control character sequences in a string.
%   STRESCAPE(STR) converts the escape sequences in a string to the values
%   they represent.
%
%   Example:
%
%       strescape('Hello World\n')
%
%   See also SPRINTF.

%   Copyright 2012-2015 The MathWorks, Inc.

if iscell(str)
    str = cellfun(@(c)strescape(c), str, 'UniformOutput', false);
else
    idx = 1;
    % Note that only [1:end-1] of the string is checked,
    % since unescaped trailing backslashes are ignored.
    while idx < length(str)
        if str(idx) == '\'
            str(idx) = [];  % Remove the '\' escape character itself.
            str(idx) = escapeChar(str(idx));
        end
        idx = idx + 1;
    end
end

end
%--------------------------------------------------------------------------
function c = escapeChar(c)
switch c
    case '0'  % Null.
        c = char(0);
    case 'a'  % Alarm.
        c = char(7);
    case 'b'  % Backspace.
        c = char(8);
    case 'f'  % Form feed.
        c = char(12);
    case 'n'  % New line.
        c = char(10);
    case 'r'  % Carriage return.
        c = char(13);
    case 't'  % Horizontal tab.
        c = char(9);
    case 'v'  % Vertical tab.
        c = char(11);
    case '\'  % Backslash.
        c = '\';
    otherwise
        warning(message('MATLAB:strescape:InvalidEscapeSequence', c, c));
end
end


