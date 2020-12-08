function nameOfFolder = mkstore(nameOfFolder)
if ~isstring(nameOfFolder) && ~ischar(nameOfFolder)
    error('The folder name must be a valid word.');
end
% creates a directory 

%TODO: Concantenation

[status, msg, msgID] = mkdir (nameOfFolder); %#ok<ASGLU>
if status == 0
    disp(msg)
end

end
