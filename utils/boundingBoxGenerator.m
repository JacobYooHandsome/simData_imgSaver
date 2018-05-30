clear 
close all
DEBUG=false
ROOT = 'tools/';
SAVE_ROOT = 'tools_bbs/';
listFolders = dir(ROOT);
fileID = fopen('toolsBBS4.txt','w');

for folderIdx = 1:length(listFolders)
    folderName = listFolders(folderIdx).name;
    listImgs = dir([ROOT folderName '/*.jpg']);
    fprintf(['processing ' folderName ' ..\n']);
    mkdir([SAVE_ROOT folderName '_bbs']); 
    
    for imgIdx = 1:length(listImgs)
        imgName = listImgs(imgIdx).name;
        img = imread([ROOT folderName '/' imgName]);
        [filepath, name, ext] = fileparts(imgName);
        imshow(img);
        
        BLUE_RANGE = [220,250]/360;
        INTENSITY_T = 0.1;
        hsv = rgb2hsv(img);
        blueAreasMask = hsv(:,:,1)>BLUE_RANGE(1) & hsv(:,:,1) < BLUE_RANGE(2) & hsv(:,:,3) > INTENSITY_T & hsv(:,:,2) > 0.33;
        if DEBUG
            figure; imagesc(blueAreasMask);
        end

        BW = blueAreasMask;
        CC = bwconncomp(blueAreasMask);
        numPixels = cellfun(@numel,CC.PixelIdxList);
        [biggest,idx] = max(numPixels);
        for i=1:length(CC.PixelIdxList)
            if i ~= idx
               BW(CC.PixelIdxList{i}) = 0;
            end
        end
        if DEBUG
            figure;imshow(BW);
        end


        J = imcomplement(BW);
        if DEBUG
            figure; imshow(J);
        end
        
        CC = bwconncomp(J);
        numPixels = cellfun(@numel,CC.PixelIdxList);
        [piexlnum,index] = sort(numPixels);
        idy = index(end-1);
        for i=1:length(CC.PixelIdxList)
            if i ~= idy
               J(CC.PixelIdxList{i}) = 0;
            end
        end
        if DEBUG
            figure;imshow(J);
        end


        structBoundaries = bwboundaries(J);
        xy=structBoundaries{1};
        rightBottom = max(xy);
        topLeft = min(xy);

        figure(1)
        hold on
        plot([rightBottom(2) rightBottom(2) topLeft(2) topLeft(2) rightBottom(2)], [rightBottom(1) topLeft(1) topLeft(1) rightBottom(1) rightBottom(1)], 'color', 'r')
        %pause(0.01)
        
        fprintf(fileID, '%s %f %f %f %f\n', name, topLeft(2), topLeft(1), rightBottom(2), rightBottom(1) );
        F=getframe;
        imwrite(F.cdata, [SAVE_ROOT folderName '_bbs/seg_'  imgName]);
    end
end
fclose(fileID)
