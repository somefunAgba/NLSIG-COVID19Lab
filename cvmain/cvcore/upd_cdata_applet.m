function upd_cdata_applet(app, update, search_ccode)
%  UPD_CDATA Update local World Health Organization's COVID-19 dataset and process country 
% by country data using country codes by specifying whether to update or not.
% 
% Uses last updated local dataset if not connected to the internet. This is 
% a private function, used in the |get_cdata| public function.
% 
% |upd_cdata(1);| update and process all country data 
% 
% |upd_cdata(1, "NG");| update and process "NG" data
% 
% |upd_cdata(0, "US");| process but do not update "US" data
% Copyright
% <mailto:oasomefun@futa.edu.ng |oasomefun@futa.edu.ng|>|, 2020.|

if nargin < 2
    search_ccode = "ALL";
end

xlsx_file = "globalCV19_data.xlsx";
cbc_CV19datafile = "cbc_CV19_data.xlsx";
world_CV19datafile = "world_CV19_data.xlsx";


%% 1. ensure we are at the project's root
if ~(ismcc || isdeployed)
    [thisfp,thisfn,~]= fileparts(which('upd_cdata_applet.m'));
    rootfp = strrep(thisfp, [filesep 'cvmain' filesep 'cvcore'], '');
    if isfile(fullfile(thisfp,thisfn+".m"))
        old_dir = cd(rootfp);
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
        cd(old_dir);
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

    % create data dir.
    try
        old_folder = cd('data');
    catch
        mkstore("data");
        old_folder = cd("data");
    end
else
    
    if update == 0 && search_ccode == "ALL"
        e_msg = sprintf("Nothing to do.");
        app.StatusLabel.Text = e_msg;
        app.StatusLabel.FontColor = [0.5, 0.5, 0.5];
        if ~(ismcc || isdeployed)
            cd(old_dir);
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

%% import latest WHO COVID-19 data
try
    if update == 1
        % Go online or fall back to last local copy.
        url="https://covid19.who.int/WHO-COVID-19-global-data.csv";
        
        try
            websave("tmp.csv",url);
            % convert csv file to table structure,
            % convert table structure to a excel's xlsx file
            % convert xlsx to table
            T = readtable("tmp.csv","ReadVariableNames",true,...
                "PreserveVariableNames",true,"TextType","string");
            
            writetable(T,who_filed);
            % copy updated copy of "xlsx_file" in dir:data to dir:local
            copyfile(who_filed, who_filel, 'f');      
            webaccess = true;            
            
        catch
            
            if state
                webaccess = false;
                skyblue = [0.5,0.7,0.9];
                
                app.StatusLabel.Text = "Going Local: No Internet!";
                app.StatusLabel.FontColor = skyblue;
                pause('on');
                pause(0.1);
                pause('off')
                % copy local copy of "xlsx_file" in dir:local to
                % dir:data
                copyfile(who_filel, who_filed, 'f');
            else
                if ~(ismcc || isdeployed)
                    red = [1 0.4 0.4];
                    e_msg = sprintf("Hi! something is wrong with my local directory/file structure.\n" + ...
                        "Try connecting to the internet and run me with an update value of '1'\n" + ...
                        "or redownload this toolbox or library.\n");
                    app.StatusLabel.Text = "Error: Directory Corrupted!";
                    app.StatusLabel.FontColor = red; 
                    error(e_msg);
                end
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
        
        % Update all or world
        if (~state || (search_ccode == "ALL" || search_ccode == "WD") && webaccess)
            
            app.StatusLabel.Text =  "Busy. Processing ...";
            app.StatusLabel.FontColor = [0.88,0.08,0.38];
            
            Tcol = T{:,ccode_idx};
            for id = 1:numel(ccode)
                app.StatusLabel.Text =  sprintf("%d of %d.",id,numel(ccode));
                app.StatusLabel.FontColor = skyblue;
                
                % create country by country data
                s_ccode = ccs{id,1};
                % select all rows specific to ccode
                cc_row_idx = strcmpi(s_ccode, Tcol);
                % cc_row_idx = find(strcmpi(search_ccode, T{:,ccode_idx}));
                % extract from T, by logical indexing
                cc_rowsT = T(cc_row_idx,:);
                % write/overwrite ccode sheet in cbc data file
                writetable(cc_rowsT,cbc_filed,"Sheet",s_ccode,...
                    "WriteMode","overwritesheet");
                
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
                    writetable(global_rowsT,world_filed,"Sheet",'WD',...
                        "WriteMode","overwritesheet");
                end    
            end
            %
            app.StatusLabel.Text =  sprintf("%d of %d. Done.",numel(ccode),numel(ccode));
            app.StatusLabel.FontColor = green;
        end
        
        % Update a country code
        if ~strcmp(search_ccode,"ALL") && ~strcmp(search_ccode,"WD")
            % for selected search_ccode
            % select all rows specific to ccode
         
            app.StatusLabel.Text =  "Processing... ";
            app.StatusLabel.FontColor = skyblue;
            
            cc_row_idx = find(strcmpi(search_ccode, T{:,ccode_idx}));
            if isempty(cc_row_idx)
                e_msg = sprintf("Please check either of the files:\n"+ ...
                    "'country_code_name.xlsx' or 'country_code_name.csv'\n"+ ...
                    "for valid two-letter country codes.");
                error(e_msg);
            end
            % extract from T
            cc_rowsT = T(cc_row_idx,:);
            % write/overwrite ccode sheet in cbc data file
            writetable(cc_rowsT,cbc_filed,"Sheet",search_ccode,...
                "WriteMode","overwritesheet");
            app.StatusLabel.Text = "Done.";
            app.StatusLabel.FontColor = boldgreen;
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
        else
            red = [1 0.4 0.4];
            e_msg = sprintf("Hi! something is wrong with my local directory/file structure.\n" + ...
                "Try connecting to the internet and run me with an update value of '1'\n" + ...
                "or redownload this toolbox or library.\n");
            app.StatusLabel.Text = "Error: Directory Corrupted!";
            app.StatusLabel.FontColor =  red;
            error(e_msg);
        end
    end

    
% return back to root
if ~(ismcc || isdeployed)
    cd(old_folder);
end

catch
    boldred = [1 0.4 0.4];
    e_msg = sprintf("\nOops! Something went wrong. Beyond my control.\n");
    app.StatusLabel.Text = "Error: Oops. I'm Confused!";
    app.StatusLabel.FontColor = boldred;  
    if ~(ismcc || isdeployed)
        cd(old_folder);
    end
    error(e_msg);
    
end


end