function upd_cdata(update, search_ccode)
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
%
dir_msg = pwd;
cprintf('[0.5, 0.5, 0.5]','%s\n',dir_msg);
%
xlsx_file = "globalCV19_data.xlsx";
cbc_CV19datafile = "cbc_CV19_data.xlsx";
world_CV19datafile = "world_CV19_data.xlsx";
who_file = "local/"+xlsx_file;
cbc_file = "local/"+cbc_CV19datafile;
world_file = "local/"+world_CV19datafile;
%% check if the 'xlsx_file' and'cbc_CV19datafile' exists in local folder
state = isfile(cbc_file) && isfile(who_file) && isfile(world_file);
% create data dir.
try
    old_folder = cd('data');
    % data_folder = pwd;
catch
    mkstore("data");
    old_folder = cd("data");
    % data_folder = pwd;
end
if update == 0 && search_ccode == "ALL"
    e_msg = sprintf("Nothing to do.\n");
    cprintf('[0.5, 0.5, 0.5]',char(e_msg));
    cd(old_folder);
    return
end
% import latest WHO COVID-19 data
try
    if update == 1
        url="https://covid19.who.int/WHO-COVID-19-global-data.csv";
        try
            websave("tmp.csv",url);
            % convert csv file to table structure,
            % convert table structure to a excel's xlsx file
            % convert xlsx to table
            T = readtable("tmp.csv","ReadVariableNames",true,...
                "PreserveVariableNames",true,"TextType","string");
            writetable(T,xlsx_file);
            % copy updated copy of "xlsx_file" in dir:data to dir:local
            copyfile(xlsx_file, "../local", 'f');
            webaccess = true;
        catch
            if state
                webaccess = false;
                skyblue = [0.5,0.7,0.9];
                e_msg = sprintf("Not connected to the internet! falling back to local copy.\n");
                cprintf(skyblue,e_msg);
                % copy local copy of "xlsx_file" in dir:local to dir:data
                cd(old_folder);
                cd("local");
                copyfile(xlsx_file, "../data", 'f');
                cd(old_folder);
                cd("data");
            else
                red = -[1 0.4 0.4];
                e_msg = sprintf("Hi! something is wrong with my local directory/file structure.\n" + ...
                    "Try connecting to the internet and run me with an update value of '1'\n" + ...
                    "or redownload this toolbox or library.\n");
                cprintf(red,e_msg);
            end
        end
        
        % read country code and name from extracted WHO's COVID-19 global data
        if state
            T = readtable(xlsx_file);
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
            writetable(ccs,"../local/country_code_name.csv");
            writetable(ccs,"../local/country_code_name.xlsx");
        end
        % process country by country (cbc) data
        skyblue = [0.5,0.7,0.9];
        green = [0.5 0.9 0.5];
        boldgreen = '*[0.5 0.9 0.5]';
        maxh = 1; % maximum data entry length
        % update all or world
        if (~state || (search_ccode == "ALL" || search_ccode == "WD") && webaccess)
            % for all ccodes
            cprintf(boldgreen,'May take some minutes! ');
            cprintf(skyblue,"Processing... ");
            Tcol = T{:,ccode_idx};
            for id = 1:numel(ccode)
                cprintf(skyblue,"%d",id);
                
                % create country by country data
                s_ccode = ccs{id,1};
                % select all rows specific to ccode
                cc_row_idx = strcmpi(s_ccode, Tcol);
                % cc_row_idx = find(strcmpi(search_ccode, T{:,ccode_idx}));
                % extract from T, by logical indexing
                cc_rowsT = T(cc_row_idx,:);
                % write/overwrite ccode sheet in cbc data file
                writetable(cc_rowsT,cbc_CV19datafile,"Sheet",s_ccode,...
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
                    writetable(global_rowsT,world_CV19datafile,"Sheet",'WD',...
                        "WriteMode","overwritesheet");
                end
                
                if id ~= numel(ccode)
                    % refresh rate (wait time ~ 30ms)
                    % pause(0.01);
                    fprintf(repmat('\b',1,length(num2str(id))));
                end
                
                
            end
            %
            cprintf(green," Done.\n");
        end
        % update a country code
        if ~strcmp(search_ccode,"ALL") && ~strcmp(search_ccode,"WD")
            % for selected search_ccode
            % select all rows specific to ccode
            cprintf(skyblue,"Processing... ");
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
            writetable(cc_rowsT,cbc_CV19datafile,"Sheet",search_ccode,...
                "WriteMode","overwritesheet");
            cprintf(green,"Completed.\n");
        end
        
        % copy updated cbc, world data to dir:local
        copyfile(cbc_CV19datafile, "../local", 'f');
        copyfile(world_CV19datafile, "../local", 'f');
        
    elseif update == 0
        if state
            % copy local copy of "xlsx_file, cbc, and world" in dir:local to dir:data
            cd(old_folder);
            old_folder = cd("local");
            copyfile(xlsx_file, "../data", 'f');
            copyfile(cbc_CV19datafile, "../data", 'f');
            copyfile(world_CV19datafile, "../data", 'f');
            cd(old_folder);
            cd("data");
        else
            red = -[1 0.4 0.4];
            e_msg = sprintf("Hi! something is wrong with my local directory/file structure.\n" + ...
                "Try connecting to the internet and run me with an update value of '1'\n" + ...
                "or redownload this toolbox or library.\n");
            cprintf(red,e_msg);
        end
    end
% return back to root
    
    cd(old_folder);
catch
    cd(old_folder);
    boldred = '*[1 0.4 0.4]';
    e_msg = sprintf("\nOops! Something went wrong. Beyond my control.\n");
    cprintf(boldred,char(e_msg));
    return;
end
end