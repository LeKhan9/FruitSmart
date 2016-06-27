% go through our fruits directory image by image
DATA_DIR = 'testFruit\';
fruit_dir = dir(DATA_DIR);
rgbSet = fopen('rgbSet.txt','wt');
%hsvSet = fopen('hsvSet.txt','wt');
%hSet = fopen('hSet.txt', 'wt');

histogram = ones(86,76);%

rgbBuckets = 25;

histInd = 0;%
for index = fruit_dir'
    if ~(strcmp(index.name,'.') || (strcmp(index.name,'..')))
        fileName = strcat(DATA_DIR, index.name);
        A = imread(fileName);
        
        [height,width, color] = size(A);
        [value1,value2] = size(size(A));
        
        % if image has RGB channels
        if(value2 == 3)  
            histInd = histInd + 1;%
            hsvImage = rgb2hsv(A);
            % determines desired output for NN based on fruit image
            if ~isempty(strfind(fileName,'watermelon'))
                output = [1 0 0 0 0 0 0 ];
            elseif ~isempty(strfind(fileName,'slice'))
                output = [0 1 0 0 0 0 0 ];
            elseif ~isempty(strfind(fileName,'banana'))
                output = [0 0 1 0 0 0 0];
            elseif ~isempty(strfind(fileName,'orange'))
                output = [0 0 0 1 0 0 0];
            elseif ~isempty(strfind(fileName,'tomato'))
                output = [0 0 0 0 1 0 0];
            else
                [strLength, o] = size(findstr(fileName, '_apple_'));
                [strLength2,o2] = size(findstr(fileName, 'apple'));
                if (strLength == 0)
                    output = [0 0 0 0 0 1 0];  
                else 
                    output = [0 0 0 0 0 0 1];
                end
            end
            
            
            
            rRanges = ones(1,rgbBuckets);
            gRanges = ones(1,rgbBuckets);
            bRanges= ones(1,rgbBuckets);
            
            rgbDivisor = 256/rgbBuckets;            
            
            
            %hsv computation
            %hsvBuckets = 25;      
            %hRanges = zeros(1,hsvBuckets+1);
            %sRanges = ones(1, hsvBuckets);
            %vRanges = ones(1, hsvBuckets);
            
            %hDivisor = 1/hsvBuckets;
            %sDivisor = 100/hsvBuckets;
            %vDivisor = sDivisor;
            
            pixels = 0;
            % iterating pixel by pixel and summing each channel
            for row=1:height
                for column=1:width  
                    % if white pixel, darker pixel ignore (background)
                    if ~( (A(row,column,1)> 200 && A(row,column,2)> 200 && A(row,column,3)> 200) || (A(row,column,1)<35 && A(row,column,2)<35 && A(row,column,3)< 35))
                        % simple 3 rgb channels
                        pixels = pixels + 1;
                        
                        
%                         
                         rIndex = floor(double(A(row,column,1))/rgbDivisor) + 1;
                         gIndex = floor(double(A(row,column,2))/rgbDivisor) + 1;
                         bIndex = floor(double(A(row,column,3))/rgbDivisor) + 1;
% 
                         rValue = double(A(row,column,1));
                         gValue = double(A(row,column,2));
                         bValue = double(A(row,column,3));
%                         
                         rRanges(1, rIndex) = rRanges(1,rIndex) + rValue;
                         gRanges(1, gIndex) = gRanges(1,gIndex) + gValue;
                         bRanges(1, bIndex) = bRanges(1,bIndex) + bValue;
                        
                        
                        %hsv technique
                       % hIndex = floor(double(hsvImage(row,column,1))/hDivisor) + 1;
                        %sIndex = floor(double(hsvImage(row,column,2))/sDivisor) + 1;
                        %vIndex = floor(double(hsvImage(row,column,3))/vDivisor) + 1;

                        %hValue = double(hsvImage(row,column,1));
                        %sValue = double(hsvImage(row,column,2));
                       % vValue = double(hsvImage(row,column,3));
                        
                        %hRanges(1, hIndex) = hRanges(1,hIndex) + hValue;
                        %sRanges(1, sIndex) = sRanges(1,sIndex) + sValue;
                        %vRanges(1, vIndex) = vRanges(1,vIndex) + vValue;

                    end
                end
            end

             [value2, outputPos] = max(output);

             rRanges = sqrt(rRanges ./ pixels);
             gRanges = sqrt(gRanges ./ pixels);
             bRanges = sqrt(bRanges ./ pixels);
             
             rgbRanges = zeros(76);
             
             rgbRanges= [rRanges gRanges bRanges outputPos];
%            hRanges = (hRanges ./ pixels);
                 
            
            %fprintf(hSet, '%.4f ', hRanges(1:end-1));
            %fprintf(hSet, '%d ', output);
            %fprintf(hSet,'\n');
            
            %hRanges(end) = outputPos;
            %sRanges = sqrt(sRanges ./ pixels);
            %vRanges = sqrt(vRanges ./ pixels);                 
            
            histogram(histInd,:) = rgbRanges;
            % file printing input/output pair for hsv
            %fprintf(hsvSet, '%.3f ', hRanges);
            %fprintf(hsvSet, '%.3f ', sRanges);
            %fprintf(hsvSet, '%.3f ', vRanges);
           % fprintf(hsvSet, '%d ', output);
            %fprintf(hsvSet,'\n');
            
%             fprintf(rgbSet, '%.3f ', rRanges);
%             fprintf(rgbSet, '%.3f ', gRanges);
%             fprintf(rgbSet, '%.3f ', bRanges);
%             fprintf(rgbSet, '%d ', output);
%             fprintf(rgbSet,'\n');
            

        end
    end
end

figure(4);
histogram = sortrows(histogram, 76);
subplot( 1, 2, 1); 
imagesc(histogram(:,1:end-1));
set(gca, 'ydir', 'normal');
xlabel('Stacked Histograms Ordered by Class');
subplot( 1, 2, 2);
plot(histogram(:,end), 1:size(histogram,1),'+');
axis( [1 7 1 size(histogram,1)]);
xlabel('Class');