function varargout = process_entropy_NM( varargin )
% PROCESS_ENTROPY_NM: Return the entropy values for the input files.

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
    % Description the process
    sProcess.Comment     = 'Entropy_NM';
    sProcess.FileTag     = 'Custom';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = 'Custom';
    sProcess.Index       = 72;
    sProcess.Description = '';
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'data', 'results', 'timefreq', 'raw', 'matrix'};
    sProcess.OutputTypes = {'data', 'results', 'timefreq', 'raw', 'matrix'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;
    % Default values for some options
    sProcess.isSourceAbsolute = -1;
    sProcess.processDim  = 2;     % Process time by time
    % === Sensor types
    sProcess.options.sensortypes.Comment = 'Sensor types or names (empty=all): ';
    sProcess.options.sensortypes.Type    = 'text';
    sProcess.options.sensortypes.Value   = 'MEG, EEG';
    sProcess.options.sensortypes.InputTypes = {'data', 'raw'};

  
end


%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
    Comment = sProcess.Comment;
end


%% ===== RUN =====
% % function sInput = Run(sProcess, sInput) %#ok<DEFNU>
% %     % Opposite values
% %     sInput.A = abs(sInput.A);
% %     % Warning if applying this process to raw recordings
% %     if strcmpi(sInput.FileType, 'raw')
% %         if isempty(sProcess.options.sensortypes.Value) || any(ismember(lower(strtrim(str_split(sProcess.options.sensortypes.Value, ',;'))), {'eeg', 'meg', 'seeg', 'ecog', 'nirs'}))
% %             bst_report('Warning', sProcess, sInput, 'Applying an absolute value to raw EEG, MEG, SEEG, ECoG or NIRS recordigs is not indicated. Check your processing pipeline.');
% %         end
% %     % Change DataType
% %     elseif ~strcmpi(sInput.FileType, 'timefreq')
% %         sInput.DataType = 'abs';
% %     end
% % end


function OutputFile = Run(sProcess, sInput)
posProgress = bst_progress('get');
    % Load input file
    for i=1:length(sInput)
    DataMat = in_bst_data(sInput(i).FileName);
    sStudy=bst_get('Study', sInput(i).iStudy);
    % Apply some function to the data in DataMat
% Fill the required fields of the structure
 hh=in_bst_channel(bst_get('ChannelFileForStudy',sInput(i).iStudy));
 Top1=table();
 Top1.name={hh.Channel.Name}';
%     OutputMat = db_template('dataMat');
OutputMat = db_template('matrixmat');
    OutputMat.Value      = compute_ent(DataMat.F);
        Top1.RawEn=OutputMat.Value(:,1);
Top1.NormEn=OutputMat.Value(:,2);
OutputMat.start=DataMat.Time(1);
OutputMat.end=DataMat.Time(end);
OutputMat.name={hh.Channel.Name}';
OutputMat.Top=Top1;
    [sx,sy]=size(OutputMat.Value);
    OutputMat.Time=[1:sy];
    OutputMat.Comment     = strcat(DataMat.Comment,'| ENT');
    % Generate a new file name in the same folder
%     OutputFile{i}=bst_process('GetNewFilename',bst_fileparts(sStudy.FileName),'dataMat');
 OutputFile{i}=bst_process('GetNewFilename',bst_fileparts(sStudy.FileName),'matrixmat');
    % Save the new file
    save(OutputFile{i}, '-struct', 'OutputMat');
    % Reference OutputFile in the database:
    db_add_data(sInput(i).iStudy, OutputFile{i}, OutputMat);
   posProgress= (i*100)/length(sInput);
    bst_progress('set', posProgress);
    end
end


function op=compute_ent(ip)
[x,y]=size(ip);
if x<y
    ip=ip';
end
% ent(ip(:,1));
 [ent1 ent2]=splitapply(@(x) ent(x),ip,1:size(ip,2));
 op=[ent2]';
end

function [op opn]=ent(ip)
N=length(ip);
nbins=round(2*((N)^(1/3)));
%ip must be a column vector

[P,~] = histcounts(ip,nbins);
Pn=P./N;
op=-nansum(Pn.*log(Pn));
opn=op/log(nbins);
end



