function [] = error_info(index)

if index == 1
    txt = 'Objects overlap, no correct calculation possible \n';
elseif index == 2
    txt = 'Clustering: No objects detected \n';
elseif index == 3
    txt = 'The calculation of the object parameter failed \n';
elseif index == 4
    txt = 'YOLO: No objects detected \n';
end
    

fprintf('-------------------------------------------------------\n\n');
fprintf('ERROR:                                   Time: %s\n',datestr(now,'HH:MM:SS'));
fprintf(txt);
fprintf('-------------------------------------------------------\n\n');