function status = upd_cdata_applet(search_ccode, update, app)
%UPD_CDATA_APPLET Update COVID-19 WHO dataset
% Update and process country-code data.
%
% Uses last updated local dataset if not connected to the internet.
% This is a private function.
%
%INPUTS
% (Required)
% search_ccode : country code
% (Optional)
% update : update logic, 0 or 1
% app : app handle
%
%OUTPUTS
% status : success or failure, 1 or 0
%
%USAGE:
% CMD
% |upd_cdata_applet("ALL");| update and process all country-code data
%
% |upd_cdata_applet("NG",0);| process but do not update "NG" data
%
% |upd_cdata_applet("US");| update and process "US" data
%
% GUI
% |upd_cdata_applet("ALL",1,app);| update and process all country-code data
%
% |upd_cdata_applet("NG",0,app);| process but do not update "NG" data
%
% |upd_cdata_applet("US",1,app);| update and process "US" data
%
%Copyright
% <mailto:oasomefun@futa.edu.ng |oasomefun@futa.edu.ng|>|, 2020.|

if verLessThan('matlab', '9.8') % 9.7 = R2019b
    error('NLSIG-COVID19Lab requires Matlab R2020a or later');
end

assert(nargin<=3," Expected at most 3 arguments!")

is_app = true;
if nargin < 3 % not an applet
    is_app = false;
    if nargin < 2
        update = 1;
    end
end
assert(update == 0 || update == 1, "update is either: 0 or 1!")

% default error state
status = 0;

% DB file names
xlsx_file = "globalCV19_data.xlsx";
cbc_CV19datafile = "cbc_CV19_data.xlsx";
world_CV19datafile = "world_CV19_data.xlsx";


%% 1. ensure we are at the project's root
if ~(ismcc || isdeployed)
    [thisfp,thisfn,~]= fileparts(which('upd_cdata_applet.m'));
    rootfp = strrep(thisfp, [filesep 'cvmain' filesep 'cvcore'], '');
    if isfile(fullfile(thisfp,thisfn+".m"))
        current_userfp = cd(rootfp);
    end
else
    % we don't need to do anything
    % since its a deployed code.
end

if ~(ismcc || isdeployed)
    dir_msg = pwd;
    cprintf('[0.5, 0.5, 0.5]','%s\n',dir_msg);
    if update == 0 && search_ccode == "ALL"
        e_msg = sprintf("Nothing to do.\n");
        cprintf('[0.5, 0.5, 0.5]',char(e_msg));
        cd(current_userfp);
        return
    end
    
    who_filel = fullfile(rootfp, "local", xlsx_file);
    cbc_filel = fullfile(rootfp, "local", cbc_CV19datafile);
    world_filel = fullfile(rootfp, "local", world_CV19datafile);
    cc_filecsv = fullfile(rootfp, "local", "country_code_name.csv");
    cc_filexlsx = fullfile(rootfp, "local", "country_code_name.xlsx");
    who_filed = fullfile(rootfp, "data", xlsx_file);
    cbc_filed = fullfile(rootfp, "data", cbc_CV19datafile);
    world_filed = fullfile(rootfp, "data", world_CV19datafile);
    
    %     % create data dir.
    %     try
    %         old_folder = cd('data');
    %     catch
    %         mkstore("data");
    %         old_folder = cd("data");
    %     end
    cd(current_userfp);
else
    
    if update == 0 && search_ccode == "ALL"
        e_msg = sprintf("Nothing to do.");
        app.StatusLabel.Text = e_msg;
        app.StatusLabel.FontColor = [0.5, 0.5, 0.5];
        if ~(ismcc || isdeployed)
            cd(current_userfp);
        end
        return
    end
    
    
    who_filel = fullfile(ctfroot, "local", xlsx_file);
    cbc_filel = fullfile(ctfroot, "local", cbc_CV19datafile);
    world_filel = fullfile(ctfroot, "local", world_CV19datafile);
    who_filed = fullfile(ctfroot, "data", xlsx_file);
    cbc_filed = fullfile(ctfroot, "data", cbc_CV19datafile);
    world_filed = fullfile(ctfroot, "data", world_CV19datafile);
    cc_filecsv = fullfile(ctfroot, "local", "country_code_name.csv");
    cc_filexlsx = fullfile(ctfroot, "local", "country_code_name.xlsx");
end

% check if the 'xlsx_file' and'cbc_CV19datafile' exists in local folder
state = isfile(cbc_filel) && isfile(who_filel) && isfile(world_filel);

pause('on')
%% import latest WHO COVID-19 data
try
    if is_app == true
        app.StatusLabel.Text = "Querying web ...";
        app.StatusLabel.FontColor = [0.9, 0.5, 0.5];
    end
    
    if update == 1
        % Go online or fall back to last local copy.
        url="https://covid19.who.int/WHO-COVID-19-global-data.csv";
        
        try
            websave('tmp.csv',url);
            % convert csv file to table structure,
            % convert table structure to a excel's xlsx file
            % convert xlsx to table
            T = readtable('tmp.csv','ReadVariableNames',true,...
                'PreserveVariableNames',true,'TextType','string');
            
            writetable(T,who_filed);
            % copy updated copy of "xlsx_file" in dir:data to dir:local
            copyfile(who_filed, who_filel, 'f');
            webaccess = true;
            status = 1; % webaccess
            
        catch ME
            
            if state
                webaccess = false;
                status = 2; % no webaccess
                
                skyblue = [0.5,0.7,0.9];
                if is_app == true
                    app.StatusLabel.Text = "Done. Use Local DB: No Internet!";
                    app.StatusLabel.FontColor = skyblue;
                    pause(1);
                else
                    e_msg = sprintf("Not connected to the internet! falling back to local copy.\n");
                    cprintf(skyblue,e_msg);
                end
                
                %pause('off')
                % copy local copy of "xlsx_file" in dir:local to
                % dir:data
                copyfile(who_filel, who_filed, 'f');
                if ~(ismcc || isdeployed)
                    cd(current_userfp);
                end
            else
                if ~(ismcc || isdeployed)
                    red = [1 0.4 0.4];
                    e_msg = sprintf("Hi! something is wrong with my local directory/file structure.\n" + ...
                        "Try connecting to the internet and run me with an update value of '1'\n" + ...
                        "or redownload this toolbox or library.\n");
                    app.StatusLabel.Text = "Error: Directory Corrupted!";
                    app.StatusLabel.FontColor = red;
                    % ME
                    fprintf("Error Identifier: %s\n",ME.identifier);
                    fprintf("Error Message: %s\n",ME.message);
                    %fprintf("Error Cause: %s\n",ME.cause);
                    %fprintf("Error Trace: %s\n",ME.stack)
                    cd(current_userfp);
                    error(e_msg);
                end
                status = 0; % err
            end
        end
        
        %         try
        %            repo = "csse_covid_19_data/csse_covid_19_time_series/...
        %            time_series_covid19_recovered_global.csv";
        %            url = https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv
        %         catch
        %         end
        
        % Read country code and name from extracted WHO global data
        if state
            T = readtable(who_filed);
            % get table column names
            T_colnames = string(T.Properties.VariableNames);
            % get column index of country code and name in table T
            ccode_idx = find(strcmpi("Country_code", T_colnames));
            cname_idx = find(strcmpi("Country", T_colnames));
            % extract to a cell struct
            ccs = table2cell(T(:,ccode_idx:cname_idx));
            % preprocessing specific to WHO's data
            [ccode,ia] = unique(ccs(:,1));
            ccode(1) = []; ia(1) = [];
            cname = ccs(:,2);
            cname = cname(ia);
            % convert back to a table
            ccode = string(ccode);
            cname = string(cname);
            ccs = table(ccode, cname);
            % save
            writetable(ccs,cc_filecsv);
            writetable(ccs,cc_filexlsx);
        end
        % process country by country (cbc) data
        skyblue = [0.5,0.7,0.9];
        green = [0.5 0.9 0.5];
        boldgreen = [0.5 0.9 0.5];
        maxh = 1; % maximum data entry length
        
        % Update all and world
        if (~state || (search_ccode == "ALL" || search_ccode == "WD") && webaccess)
            
            if is_app == true
                app.StatusLabel.Text =  "Busy. Processing ...";
                app.StatusLabel.FontColor = [0.88,0.08,0.38];
                pause(0.2);
            else
                cprintf(boldgreen,'May take some minutes! ');
                cprintf(skyblue,"Processing... ");
            end
            Tcol = T{:,ccode_idx};
            for id = 1:numel(ccode)
                if is_app == true
                    app.StatusLabel.Text =  sprintf("%d of %d.",id,numel(ccode));
                    app.StatusLabel.FontColor = skyblue;
                    pause(0.2);
                else
                    fprintf("%d",id);
                end
                
                % create country by country data
                s_ccode = ccs{id,1};
                % select all rows specific to ccode
                cc_row_idx = strcmpi(s_ccode, Tcol);
                % cc_row_idx = find(strcmpi(search_ccode, T{:,ccode_idx}));
                % extract from T, by logical indexing
                cc_rowsT = T(cc_row_idx,:);
                % write/overwrite ccode sheet in cbc data file
                writetable(cc_rowsT,cbc_filed,'Sheet',s_ccode,...
                    'WriteMode','overwritesheet');
                
                % create world data
                maxh = max(maxh,height(cc_rowsT));
                if id == 1
                    global_rowsT = cc_rowsT;
                else
                    % deal with data: missing updated entries
                    % current selected country code height
                    currh =  height(cc_rowsT);
                    % previous selected country code height
                    globh = height(global_rowsT);
                    if currh > globh
                        lendiff = currh - globh;
                        for ix = (globh+1):(globh+lendiff)
                            new_rows = {global_rowsT{ix-1,1},global_rowsT{ix-1,2},...
                                global_rowsT{ix-1,3},global_rowsT{ix-1,4},0,0,0,0};
                            global_rowsT = [global_rowsT;new_rows]; %#ok<AGROW>
                        end
                    end
                    if globh > currh
                        lendiff = globh - currh;
                        for ix = (currh+1):(currh+lendiff)
                            new_rows = {cc_rowsT{ix-1,1},cc_rowsT{ix-1,2},...
                                cc_rowsT{ix-1,3},cc_rowsT{ix-1,4},0,0,0,0};
                            cc_rowsT = [cc_rowsT;new_rows]; %#ok<AGROW>
                        end
                    end
                    global_rowsT{:,5:8} = global_rowsT{:,5:8} + cc_rowsT{:,5:8};
                end
                
                if id == numel(ccode)
                    for idd = 1:maxh
                        global_rowsT(idd,2) = {'WD'};
                        global_rowsT(idd,3) = {'World'};
                        global_rowsT(idd,4) = {'GLOBAL'};
                    end
                    writetable(global_rowsT,world_filed,'Sheet','WD',...
                        'WriteMode','overwritesheet');
                end
                if id ~= numel(ccode) && is_app == false
                    % refresh rate (wait time ~ 30ms)
                    % pause(0.01);
                    fprintf(repmat('\b',1,length(num2str(id))));
                end
                
            end
            %
            if is_app == true
                app.StatusLabel.Text =  sprintf("%d of %d. Done.",numel(ccode),numel(ccode));
                app.StatusLabel.FontColor = green;
            else
                cprintf(green," Done.\n");
            end
        end
        
        % Update a country code
        if ~strcmp(search_ccode,"ALL") && ~strcmp(search_ccode,"WD")
            % for selected search_ccode
            % select all rows specific to ccode
            
            if is_app == true
                app.StatusLabel.Text =  "Processing... ";
                app.StatusLabel.FontColor = skyblue;
            else
                cprintf(skyblue,"Processing... ");
            end
            
            cc_row_idx = find(strcmpi(search_ccode, T{:,ccode_idx}));
            if isempty(cc_row_idx)
                e_msg = sprintf("Please check either of the files:\n"+ ...
                    "'country_code_name.xlsx' or 'country_code_name.csv'\n"+ ...
                    "for valid two-letter country codes.");
                
                status = 0; % err
                error(e_msg);
            end
            % extract from T
            cc_rowsT = T(cc_row_idx,:);
            % write/overwrite ccode sheet in cbc data file
            writetable(cc_rowsT,cbc_filed,'Sheet',search_ccode,...
                'WriteMode','overwritesheet');
            if is_app == true
                app.StatusLabel.Text = "Done.";
                app.StatusLabel.FontColor = boldgreen;
            else
                cprintf(green,"Done.\n");
            end
        end
        
        % copy updated cbc, world data to dir:local
        copyfile(cbc_filed, cbc_filel, 'f');
        copyfile(world_filed, world_filel, 'f');
        
    elseif update == 0
        if state
            % copy local copy of "xlsx_file, cbc, and world" in dir:local to dir:data
            copyfile(who_filel, who_filed, 'f');
            copyfile(cbc_filel, cbc_filed, 'f');
            copyfile(world_filel, world_filed, 'f');
            status = 2; % no webaccess
        else
            red = [1 0.4 0.4];
            e_msg = sprintf("Hi! something is wrong with my local directory/file structure.\n" + ...
                "Try connecting to the internet and run me with an update value of '1'\n" + ...
                "or redownload this toolbox or library.\n");
            
            if is_app == true
                app.StatusLabel.Text = "Error: Directory Corrupted!";
                app.StatusLabel.FontColor =  red;
            else
                cprintf(red,e_msg);
            end
            
            status = 0; % err
            error(e_msg);
            
        end
    end
    
    
    % return back to root
    if ~(ismcc || isdeployed)
        cd(current_userfp);
    end
    
catch ME
    boldred = [1 0.4 0.4];
    e_msg = sprintf("\nOops! Something went wrong. Beyond my control.\n");
    app.StatusLabel.Text = "Error: Oops. I'm Confused!";
    app.StatusLabel.FontColor = boldred;
    if ~(ismcc || isdeployed)
        cd(current_userfp);
    end
    
    status = 0; % err
    % ME
    fprintf("Error Identifier: %s\n",ME.identifier);
    fprintf("Error Message: %s\n",ME.message);
    %fprintf("Error Cause: %s\n",ME.cause);
    %fprintf("Error Trace: %s\n",ME.stack)
    
    
    
end

if status == 0
    error(e_msg);
end

end