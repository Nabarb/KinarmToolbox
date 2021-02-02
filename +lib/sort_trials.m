%SORT_TRIALS given a set of trials loaded from zip_load this will sort the
%   trials based on the criteria you specify.
%
%   sorted = sort_trials(zip_load()) Will sort the trials based on the
%   execution order.
%
%   sorted = sort_trials(zip_loads(), [type], [method]). Type is one of:
%   'execution' - execution order sort
%   'tp' - sort by trial protocol number (and run order when tp's match).
%   'custom' - use the supplied method argument as the sorting method.
%   method - a pointer to a method with the signature sortMethod(c3d1,
%   c3d2). The method should return true when c3d1 > c3d2, false otherwise.
%
function exam = sort_trials(exam, varargin)
    % This method implements a simple bubble sort for the trials in an exam
    % loaded using zip_load.
    n = length(exam.c3d);
    Props = struct('method','execution'...
    );
Props = getopt(Props,varargin{:});

    if strcmpi('execution', Props.method)
        sortMethod = @sortByRunOrder;
    elseif strcmpi('tp', Props.method)
        sortMethod = @sortByTP;
    elseif strcmpi('custom', Props.method)
        sortMethod = varargin{1};
    end
    
    
    while (n > 0)
        % Iterate through c3d
        nnew = 0;
        for i = 2:n
            % Swap elements in wrong order
            if sortMethod(exam.c3d(i - 1), exam.c3d(i))
                swap(i,i - 1);
                nnew = i;
            end
        end
        n = nnew;
    end
    
    function swap(i,j)
        val = exam.c3d(i);
        exam.c3d(i) = exam.c3d(j);
        exam.c3d(j) = val;
    end    
end

function ret = sortByRunOrder(c3d1, c3d2)
    ret = c3d1.TRIAL.TRIAL_NUM > c3d2.TRIAL.TRIAL_NUM;  
end

function ret = sortByTP(c3d1, c3d2)
    if c3d1.TRIAL.TP == c3d2.TRIAL.TP
        ret = sortByRunOrder(c3d1, c3d2);
    else
        ret = c3d1.TRIAL.TP > c3d2.TRIAL.TP;  
    end
end

function properties = getopt(properties,varargin)
%GETOPT - Process paired optional arguments as 'prop1',val1,'prop2',val2,...
%
%   getopt(properties,varargin) returns a modified properties structure,
%   given an initial properties structure, and a list of paired arguments.
%   Each argumnet pair should be of the form property_name,val where
%   property_name is the name of one of the field in properties, and val is
%   the value to be assigned to that structure field.
%
%   No validation of the values is performed.
%%
% EXAMPLE:
%   properties = struct('zoom',1.0,'aspect',1.0,'gamma',1.0,'file',[],'bg',[]);
%   properties = getopt(properties,'aspect',0.76,'file','mydata.dat')
% would return:
%   properties =
%         zoom: 1
%       aspect: 0.7600
%        gamma: 1
%         file: 'mydata.dat'
%           bg: []
%
% Typical usage in a function:
%   properties = getopt(properties,varargin{:})

% Function from
% http://mathforum.org/epigone/comp.soft-sys.matlab/sloasmirsmon/bp0ndp$crq5@cui1.lmms.lmco.com

% dgleich
% 2003-11-19
% Added ability to pass a cell array of properties

if ~isempty(varargin) && (iscell(varargin{1}))
   varargin = varargin{1};
end;

% Process the properties (optional input arguments)
prop_names = fieldnames(properties);
TargetField = [];
for ii=1:length(varargin)
   arg = varargin{ii};
   if isempty(TargetField)
      if ~ischar(arg)
         error('Property names must be character strings');
      end
      %f = find(strcmp(prop_names, arg));
      if isempty(find(strcmp(prop_names, arg),1)) %length(f) == 0
         error('%s ',['invalid property ''',arg,'''; must be one of:'],prop_names{:});
      end
      TargetField = arg;
   else
      properties.(TargetField) = arg;
      TargetField = '';
   end
end
if ~isempty(TargetField)
   error('Property names and values must be specified in pairs.');
end
end