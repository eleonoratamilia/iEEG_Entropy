function varargout = process_normalizedshannon_entropy( varargin )
% PROCESS_NORMALIZEDSHANNON_ENTROPY: Return the entropy values for the input files.

% Please cite this article if you use this code: 
% Makaram N, Pesce M, Tsuboyama M, Bolton J, Harmon J, Papadelis C, Stone S, Pearl P, Rotenberg A, Grant EP, Tamilia E. 
% Targeting interictal low-entropy zones during epilepsy surgery predicts successful outcomes in pediatric drug-resistant epilepsy.
% Epilepsia. 2025 Sep 20. doi: 10.1111/epi.18636.
% PMID: 40974546.

%THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%SOFTWARE.
%Author: Navaneethakrishna Makaram email:navaneethakrishna.makaram@outlook.com

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
% Description the process
sProcess.Comment     = 'Normalized_Shannon_Entropy';
sProcess.FileTag     = 'Custom';
sProcess.Category    = 'Custom';
sProcess.SubGroup    = 'Entropy';
sProcess.Index       = 72;
sProcess.Description = '';
% Definition of the input accepted by this process
sProcess.InputTypes  = {'data', 'raw'};
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
function OutputFile = Run(sProcess, sInput)
posProgress = bst_progress('get');
% Load input file
for i=1:length(sInput) %Loop over multiple input files
    DataMat = in_bst_data(sInput(i).FileName);
    sStudy=bst_get('Study', sInput(i).iStudy);
    ch=in_bst_channel(bst_get('ChannelFileForStudy',sInput(i).iStudy));
    if ~isempty(sProcess.options.sensortypes.Value)
        [iChannels, ~] = channel_find(ch.Channel,sProcess.options.sensortypes.Value);
    else
        iChannels = 1:length(ch.Channel);
    end
    T_op1=table();% Create Output table
    T_op1.name={ch.Channel.Name}';
    OutputMat = db_template('timefreqmat'); % Create output structure
    % Apply entropy function to the data in DataMat
    OutputMat.TF      = compute_ent(DataMat.F);
    OutputMat.RowNames={ch.Channel.Name}';
    OutputMat.Time=[DataMat.Time(1),DataMat.Time(end)];
    OutputMat.Comment     = strcat(DataMat.Comment,'| ENT');
    OutputMat.Measure = 'a.u.';
    OutputMat.Method = 'Entropy';
    OutputMat.DataFile=sInput(i).FileName;
    OutputMat.DataType  = 'data';
    % Generate a new file name in the same folder
    OutputFile{i}=bst_process('GetNewFilename',bst_fileparts(sStudy.FileName),'timefreqmat');
    OutputMat = bst_history('add', OutputMat, 'compute', 'Entropy');
    OutputMat.ChannelFlag=DataMat.ChannelFlag;
    OutputMat.TF(~ismember(iChannels,[1:length(ch.Channel)]))=NaN;
    OutputMat.TF(~(OutputMat.ChannelFlag==1))=NaN;
    T_op1.NormEn=OutputMat.TF;
    OutputMat.events=[];
    OutputMat.T_op=T_op1;
    % Save the new file
    save(OutputFile{i}, '-struct', 'OutputMat');
    % Reference OutputFile in the database:
    db_add_data(sInput(i).iStudy, OutputFile{i}, OutputMat);
    posProgress= (i*100)/length(sInput);
    bst_progress('set', posProgress);
end
end


function op=compute_ent(ip)
    ip=ip';
    [ent1 ent2]=splitapply(@(x) ent(x),ip,1:size(ip,2));
    op=[ent2]';
end

function [op opn]=ent(ip)
    N=length(ip);
    nbins=round(2*((N)^(1/3)));% Compute number of bins based on RICE rule
    %ip must be a column vector
    [P,~] = histcounts(ip,nbins);
    Pn=P./N;
    op=-nansum(Pn.*log(Pn));
    opn=op/log(nbins);%Normalize the Entropy values
end



